import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';

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
  SessionRepository(this._db);

  final AppDatabase _db;

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
    String? staffId,
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
  /// 를 품목 합계로 재계산하고, `itemType=='staff_fee'`면
  /// `staff_earning_ledger`에도 자동 기록한다.
  Future<PaymentSessionItemRow> addItem({
    required int sessionId,
    required String itemType,
    String? refType,
    String? refId,
    required String itemName,
    int qty = 1,
    required int unitPrice,
    String? staffId,
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

      if (itemType == 'staff_fee' && staffId != null) {
        await _db.into(_db.staffEarningLedgers).insert(
              StaffEarningLedgersCompanion.insert(
                sessionId: sessionId,
                sessionItemId: Value(itemId),
                staffId: staffId,
                earningType: 'staff_fee',
                amount: amount,
                createdAt: now,
              ),
            );
      }

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
      await _db.batch((batch) {
        batch.insertAll(
          _db.paymentMethodBreakdowns,
          paymentMethods.map(
            (m) => PaymentMethodBreakdownsCompanion.insert(
              sessionId: sessionId,
              method: m.method,
              amount: m.amount,
              receivedAt: now,
            ),
          ),
        );
      });

      await (_db.update(_db.paymentSessions)..where((s) => s.id.equals(sessionId)))
          .write(PaymentSessionsCompanion(
        status: Value(SessionStatus.closed.value),
        endAt: Value(now),
        updatedAt: Value(now),
      ));

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
}

/// 외부에서 문자열 status를 enum으로 변환할 때 사용(화면단 등).
SessionStatus sessionStatusOf(String value) => _statusFrom(value);
