import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../../pricing/data/pricing_rule_repository.dart';
import '../../pricing/domain/rule_types.dart';
import '../../pricing/logic/pricing_engine.dart';
import '../../promotion/data/promotion_rule_repository.dart';
import '../../promotion/logic/promotion_engine.dart';
import '../../staff_earning/logic/staff_earning_engine.dart';
import '../workflow/session_closing_workflow.dart';

/// A-8 SESSION ENGINE(docs/A8_SESSION_ENGINE.md). 'open'/'closed'/
/// 'cancelled' 세 값만 쓴다 — 저장은 기존 코드베이스 관례(TEXT 컬럼 +
/// 문자열 비교)를 따르고, 호출 측 타입 안전성을 위해 enum을 둔다.
enum SessionStatus { open, closed, cancelled }

extension SessionStatusX on SessionStatus {
  String get value => name;
}

SessionStatus _statusFrom(String value) =>
    SessionStatus.values.firstWhere((s) => s.value == value);

/// `getSessionSummary()`의 반환형 — 4개 테이블을 조합한 읍 read-only
/// 합성 뷰. 별도 테이블이 아니라 메모리상의 단순 데이터 묶음이다.
class SessionSummary {
  SessionSummary({
    required this.session,
    required this.items,
    required this.earnings,
    required this.payments,
  });

  final PaymentSessionRow session;
  final List<PaymentSessionItemRow> items;
  final List<StaffEarningLedgerRow> earnings;
  final List<PaymentMethodBreakdownRow> payments;
}

/// 결제수단 1건 입력값(`closeSession()`에 넘기는 매개변수).
typedef PaymentMethodInput = ({String method, int amount});

class SessionRepository {
  /// A-10(docs/A10_IMPLEMENTATION_READINESS_REVIEW.md): [pricingRuleRepository]/
  /// [pricingEngine]은 선택적 매개변수다 — 기존 호출부(`SessionRepository(db)`)
  /// 가 전부 그대로 컴파일되도록 기본값(같은 [db] 기반 새 인스턴스)으로
  /// 떨어진다. `addItem()` 본문은 이 변경으로 단 한 줄도 바뀌지 않았다
  /// (calcSuggestedTimeFee()만 추가 — 최소 침습 연동).
  /// A-11(docs/A11_IMPLEMENTATION_PLAN.md): [promotionRuleRepository]/
  /// [promotionEngine]도 동일하게 선택적 매개변수다 — 기존 호출부 무수정.
  /// A-12(docs/A12_STAFF_EARNING_ARCHITECTURE.md, ADR-006): [staffEarningEngine]
  /// 도 동일한 선택적 매개변수 패턴 — `StaffEarningEngine`은 Repository가
  /// 필요 없는 순수 계산 클래스라 별도 Repository 주입은 없다.
  SessionRepository(
    this._db, {
    PricingRuleRepository? pricingRuleRepository,
    PricingEngine? pricingEngine,
    PromotionRuleRepository? promotionRuleRepository,
    PromotionEngine? promotionEngine,
    StaffEarningEngine? staffEarningEngine,
  })  : _pricingRuleRepository =
            pricingRuleRepository ?? PricingRuleRepository(_db),
        _pricingEngine = pricingEngine ?? const PricingEngine(),
        _promotionRuleRepository =
            promotionRuleRepository ?? PromotionRuleRepository(_db),
        _promotionEngine = promotionEngine ?? const PromotionEngine(),
        _sessionClosingWorkflow = SessionClosingWorkflow(
          _db,
          staffEarningEngine: staffEarningEngine,
        );

  final AppDatabase _db;
  final PricingRuleRepository _pricingRuleRepository;
  final PricingEngine _pricingEngine;
  final PromotionRuleRepository _promotionRuleRepository;
  final PromotionEngine _promotionEngine;

  /// A-14 Phase 1(Workflow Extraction): `closeSession()`의 Workflow
  /// Coordination 책임을 그대로 옮긴 곳 — `SessionRepository`는 이제
  /// 이 클래스를 "호출"만 한다(`docs/A14_WORKFLOW_CONTRACT_VALIDATION.md`).
  final SessionClosingWorkflow _sessionClosingWorkflow;

  static const _validBusinessTypes = {'salon', 'karaoke', 'izakaya'};
  static const _validItemTypes = {
    'service',
    'product',
    'time',
    'staff_fee',
    'discount',
    'surcharge',
  };
  static const _validPaymentMethods = {
    'cash',
    'card',
    'point',
    'gift',
    'transfer',
  };

  /// STEP3: 전표 신규 생성. `status='open'`으로 시작, `sessionNo`는
  /// "연도-4자리순번" 형식으로 연도별 시퀀스를 다시 0001부터 시작한다.
  Future<PaymentSessionRow> createSession({
    required String businessType,
    int? staffId,
    int? customerId,
    int? roomId,
  }) async {
    if (!_validBusinessTypes.contains(businessType)) {
      throw const ValidationException('業種の値が正しくありません。');
    }
    try {
      final now = DateTime.now();
      final sessionNo = await _nextSessionNo(now);
      final id = await _db.into(_db.paymentSessions).insert(
            PaymentSessionsCompanion.insert(
              sessionNo: sessionNo,
              businessType: businessType,
              staffIdPrimary: Value(staffId),
              customerId: Value(customerId),
              roomId: Value(roomId),
              startAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
      return await (_db.select(_db.paymentSessions)
            ..where((s) => s.id.equals(id)))
          .getSingle();
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<String> _nextSessionNo(DateTime now) async {
    final year = now.year;
    final prefix = '$year-';
    final existing = await (_db.select(_db.paymentSessions)
          ..where((s) => s.sessionNo.like('$prefix%')))
        .get();
    final nextSeq = existing.length + 1;
    return '$prefix${nextSeq.toString().padLeft(4, '0')}';
  }

  /// STEP3: 전표 1건 조회(상태 가드 판단용 — 내부 헬퍼).
  Future<PaymentSessionRow> _requireSession(int sessionId) async {
    final session = await (_db.select(_db.paymentSessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();
    if (session == null) {
      throw const NotFoundException('セッションが見つかりませんでした。');
    }
    return session;
  }

  /// STEP3: 품목 추가. `status='open'`인 경우만 허용 — closed/cancelled
  /// 세션은 immutable(STEP4 상태전이 규칙 그대로). 추가 후 `totalAmount`
  /// 를 품목 합계로 재계산한다.
  ///
  /// A-12(ADR-006): `staff_earning_ledger`는 여기서 생성하지 않는다 —
  /// Ledger는 Financial Event가 아니라 `closeSession()` 시점에 1회
  /// 생성되는 Persistent Snapshot이다(`docs/A12_IMPLEMENTATION_READY.md`
  /// PART 1). A-11 이전에는 이 메서드가 `staff_fee` 품목 추가 즉시
  /// Ledger를 생성했으나, 그 즉시생성 방식이 ADR-003(이벤트는 불변)과
  /// 미묘하게 어긋난다는 점이 식별되어(A-11.9 리뷰) 제거했다.
  Future<PaymentSessionItemRow> addItem({
    required int sessionId,
    required String itemType,
    String? refType,
    String? refId,
    required String itemName,
    int qty = 1,
    required int unitPrice,
    int? staffId,
    String? metaJson,
  }) async {
    if (!_validItemTypes.contains(itemType)) {
      throw const ValidationException('項目種別の値が正しくありません。');
    }
    if (qty <= 0) {
      throw const ValidationException('数量は1以上にしてください。');
    }
    try {
      final session = await _requireSession(sessionId);
      if (session.status != SessionStatus.open.value) {
        throw const BusinessRuleException('クローズ・キャンセル済みのセッションは編集できません。');
      }

      final now = DateTime.now();
      final amount = unitPrice * qty;
      final itemId = await _db.into(_db.paymentSessionItems).insert(
            PaymentSessionItemsCompanion.insert(
              sessionId: sessionId,
              itemType: itemType,
              refType: Value(refType),
              refId: Value(refId),
              itemName: itemName,
              qty: Value(qty),
              unitPrice: unitPrice,
              amount: amount,
              staffId: Value(staffId),
              metaJson: Value(metaJson),
              createdAt: now,
            ),
          );

      await _recomputeTotals(sessionId);

      return await (_db.select(_db.paymentSessionItems)
            ..where((i) => i.id.equals(itemId)))
          .getSingle();
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// `totalAmount = SUM(items.amount)`, `finalAmount = totalAmount -
  /// discountAmount + taxAmount`. discount/surcharge는 이미 부호가 있는
  /// 개별 품목(itemType)으로 totalAmount에 합산되며, 세션 레벨
  /// discountAmount/taxAmount는 전체에 거는 별도 조정값이라 서로
  /// 독립적으로 취급한다(현재 STEP3 범위에는 그 조정값을 설정하는
  /// 메서드가 없어 기본값 0이 유지되고, finalAmount는 totalAmount와
  /// 같아진다).
  Future<void> _recomputeTotals(int sessionId) async {
    final items = await (_db.select(_db.paymentSessionItems)
          ..where((i) => i.sessionId.equals(sessionId)))
        .get();
    final total = items.fold<int>(0, (sum, i) => sum + i.amount);
    final session = await _requireSession(sessionId);
    final finalAmount = total - session.discountAmount + session.taxAmount;
    await (_db.update(_db.paymentSessions)..where((s) => s.id.equals(sessionId)))
        .write(PaymentSessionsCompanion(
      totalAmount: Value(total),
      finalAmount: Value(finalAmount),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// STEP3: 전표 마감. `open → closed` 전환은 1차원적이며(STEP4),
  /// 결제수단 합계가 `finalAmount`와 정확히 일치해야만 성립한다(검증
  /// 항목 8). 성립 후에는 `payment_method_breakdown`에 결제수단별
  /// 내역을 저장하고, 이후 이 세션은 `addItem()`/`cancelSession()`
  /// 어디서도 변경할 수 없다(closed guard).
  ///
  /// A-12(ADR-006): Settlement(결제수단 검증)이 끝난 뒤,
  /// `StaffEarningEngine`으로 `staff_earning_ledger` Snapshot을 1회
  /// 생성한다 — 이 Ledger는 이후 어떤 경로로도 다시 갱신되지 않는다
  /// (`Ledger 재계산 기능 없음` — Rule이 나중에 바뀌어도 이미 닫힌
  /// 세션의 Ledger는 그대로 유지).
  ///
  /// A-14 Phase 1(Workflow Extraction): 검증(입력 형식/세션 상태/결제
  /// 합계 일치)을 통과한 뒤의 실제 절차(Settlement 저장→Ledger 생성→
  /// 상태 변경, ADR-007의 Transaction Scope)는 `SessionClosingWorkflow`
  /// 가 수행한다 — 이 메서드는 그 Workflow를 "호출"만 한다. 로직/순서/
  /// Transaction 범위는 A-13과 한 글자도 다르지 않다(코드 위치만 이동).
  Future<PaymentSessionRow> closeSession({
    required int sessionId,
    required List<PaymentMethodInput> paymentMethods,
  }) async {
    for (final m in paymentMethods) {
      if (!_validPaymentMethods.contains(m.method)) {
        throw const ValidationException('決済手段の値が正しくありません。');
      }
      if (m.amount <= 0) {
        throw const ValidationException('決済金額は1円以上にしてください。');
      }
    }
    try {
      final session = await _requireSession(sessionId);
      if (session.status != SessionStatus.open.value) {
        throw const BusinessRuleException('既にクローズ・キャンセル済みのセッションです。');
      }

      final paidTotal = paymentMethods.fold<int>(0, (sum, m) => sum + m.amount);
      if (paidTotal != session.finalAmount) {
        throw const BusinessRuleException('決済手段の合計が請求金額と一致しません。');
      }

      final now = DateTime.now();
      await _sessionClosingWorkflow.run(
        sessionId: sessionId,
        paymentMethods: paymentMethods,
        now: now,
      );

      return await (_db.select(_db.paymentSessions)
            ..where((s) => s.id.equals(sessionId)))
          .getSingle();
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// STEP3/STEP4: `open → cancelled`만 허용. `closed`는 immutable이라
  /// 취소 자체가 차단된다(BusinessRuleException). 이미 `cancelled`인
  /// 세션에 재호출하면 멱등하게 아무 동작 없이 반환한다(A-7에서 확정한
  /// "같은 요청을 반복해도 상태가 변하지 않는다" 원칙을 신규 모듈에도
  /// 동일하게 적용).
  Future<void> cancelSession(int sessionId) async {
    try {
      final session = await _requireSession(sessionId);
      if (session.status == SessionStatus.cancelled.value) {
        return; // 멱등 — 아무 동작 없음
      }
      if (session.status == SessionStatus.closed.value) {
        throw const BusinessRuleException('クローズ済みのセッションはキャンセルできません。');
      }

      await (_db.update(_db.paymentSessions)..where((s) => s.id.equals(sessionId)))
          .write(PaymentSessionsCompanion(
        status: Value(SessionStatus.cancelled.value),
        updatedAt: Value(DateTime.now()),
      ));
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// STEP3: session + items + earning + payment 전부 조합.
  Future<SessionSummary> getSessionSummary(int sessionId) async {
    try {
      final session = await _requireSession(sessionId);
      final items = await (_db.select(_db.paymentSessionItems)
            ..where((i) => i.sessionId.equals(sessionId)))
          .get();
      final earnings = await (_db.select(_db.staffEarningLedgers)
            ..where((e) => e.sessionId.equals(sessionId)))
          .get();
      final payments = await (_db.select(_db.paymentMethodBreakdowns)
            ..where((p) => p.sessionId.equals(sessionId)))
          .get();
      return SessionSummary(
        session: session,
        items: items,
        earnings: earnings,
        payments: payments,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  /// A-10 Pricing Engine MVP — `addItem()`과 **독립적인** 가격 계산
  /// 도우미. `addItem()`의 `amount = unitPrice * qty` 계산식은 이
  /// 메서드와 무관하게 그대로 유지된다(중복계산 없음) — 호출자가 이
  /// 메서드의 반환값을 `addItem(unitPrice: ...)`에 그대로 넘기는
  /// 방식으로 연동한다. `addItem()` 자체는 이 메서드를 호출하지
  /// 않는다(자동 연동 아님 — 호출자가 선택적으로 사용).
  ///
  /// [at]을 생략하면 피크 할증은 계산하지 않는다(시간요금만 반환).
  /// [shopId]는 A-10 리뷰 후속(40개 이상 지점 지원) — 지점마다 다른
  /// 가격/피크 규칙을 쓸 수 있도록 그대로 `PricingRuleRepository`에
  /// 전달한다(기본값 1 — 단일 지점 호출부는 동작 불변).
  Future<int> calcSuggestedTimeFee({
    required String businessType,
    required int minutes,
    DateTime? at,
    int shopId = 1,
  }) async {
    final timeRules = await _pricingRuleRepository.getRules(
      businessType: businessType,
      shopId: shopId,
      ruleType: RuleType.timeBase,
    );
    final timeFee = _pricingEngine.calcTimeFee(
      minutes: minutes,
      businessType: businessType,
      rules: timeRules,
    );

    if (at == null) return timeFee;

    final peakRules = await _pricingRuleRepository.getRules(
      businessType: businessType,
      shopId: shopId,
      ruleType: RuleType.peak,
    );
    final peakSurcharge = _pricingEngine.calcPeakSurcharge(
      at: at,
      baseFee: timeFee,
      businessType: businessType,
      rules: peakRules,
    );

    return _pricingEngine.calcTotal(
      timeFee: timeFee,
      peakSurcharge: peakSurcharge,
    );
  }

  /// A-11 Promotion Engine MVP — `calcSuggestedTimeFee()`와 동일한
  /// "선택적 헬퍼" 패턴. `addItem()`/`closeSession()`/`cancelSession()`/
  /// `_recomputeTotals()` 어디도 이 메서드를 호출하지 않는다 — 호출자가
  /// 이 메서드의 결과(`PromotionResult.discountAmount`)를 음수로 만들어
  /// `addItem(itemType: 'discount', unitPrice: -discountAmount, ...)`로
  /// 직접 적용해야 한다(ADR-002). [PaymentSessionItem] 저장은 이 메서드
  /// 의 책임이 아니다.
  Future<PromotionResult> calcSuggestedDiscount({
    required String businessType,
    required int subtotal,
    DateTime? at,
    int shopId = 1,
  }) async {
    final rules = await _promotionRuleRepository.getRules(
      businessType: businessType,
      shopId: shopId,
    );
    return _promotionEngine.calcDiscount(
      subtotal: subtotal,
      at: at ?? DateTime.now(),
      rules: rules,
    );
  }
}

/// 외부에서 문자열 status를 enum으로 변환할 때 사용(화면단 등).
SessionStatus sessionStatusOf(String value) => _statusFrom(value);
