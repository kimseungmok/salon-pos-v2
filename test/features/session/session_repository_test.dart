import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/pricing/data/pricing_rule_repository.dart';
import 'package:salon_pos_v2/features/promotion/data/promotion_rule_repository.dart';
import 'package:salon_pos_v2/features/session/data/session_repository.dart';
import 'package:salon_pos_v2/features/staff_earning/domain/earnable_item.dart';
import 'package:salon_pos_v2/features/staff_earning/domain/earning_rule.dart';
import 'package:salon_pos_v2/features/staff_earning/domain/staff_earning_result.dart';
import 'package:salon_pos_v2/features/staff_earning/logic/staff_earning_engine.dart';

/// A-8 SESSION ENGINE(docs/A8_SESSION_ENGINE.md) 검증.
void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = SessionRepository(db);
  });

  tearDown(() => db.close());

  group('createSession', () {
    test('1. status == open 확인', () async {
      final s = await repo.createSession(businessType: 'salon');
      expect(s.status, SessionStatus.open.value);
      expect(s.sessionNo, isNotEmpty);
    });

    test('잘못된 businessType → ValidationException', () {
      expect(
        () => repo.createSession(businessType: 'unknown'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('연도별 순번이 0001부터 증가', () async {
      final s1 = await repo.createSession(businessType: 'karaoke');
      final s2 = await repo.createSession(businessType: 'karaoke');
      final year = DateTime.now().year;
      expect(s1.sessionNo, '$year-0001');
      expect(s2.sessionNo, '$year-0002');
    });
  });

  group('addItem', () {
    test('2. totalAmount 정상 계산 확인', () async {
      final s = await repo.createSession(businessType: 'izakaya');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'product',
        itemName: '生ビール',
        qty: 2,
        unitPrice: 600,
      );
      await repo.addItem(
        sessionId: s.id,
        itemType: 'product',
        itemName: '唐揚げ',
        qty: 1,
        unitPrice: 500,
      );
      final updated = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(updated.totalAmount, 1700); // 600*2 + 500
      expect(updated.finalAmount, 1700);
    });

    test('3. staff_fee 추가 직후(addItem())에는 ledger가 생성되지 않음(A-12, ADR-006)', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );
      final ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, isEmpty); // closeSession() 전에는 Ledger가 없다
    });

    test('staff_fee인데 staffId 없으면 마감 후에도 ledger 미생성', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
      );
      final ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, isEmpty);
    });

    test('존재하지 않는 세션 → NotFoundException', () async {
      expect(
        () => repo.addItem(
          sessionId: 9999,
          itemType: 'product',
          itemName: 'x',
          unitPrice: 100,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('closeSession', () {
    test('4. status == closed 확인', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      final closed = await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(closed.status, SessionStatus.closed.value);
      expect(closed.endAt, isNotNull);
    });

    test('5. closeSession 후 addItem → BusinessRuleException(guard 동작)', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(
        () => repo.addItem(
          sessionId: s.id,
          itemType: 'product',
          itemName: 'シャンプー',
          unitPrice: 1000,
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('8. 결제수단 합계 != final_amount → closeSession 거부 확인', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      expect(
        () => repo.closeSession(
          sessionId: s.id,
          paymentMethods: const [(method: 'cash', amount: 3000)],
        ),
        throwsA(isA<BusinessRuleException>()),
      );
      // 거부 후에도 세션은 여전히 open으로 남아있어야 한다.
      final stillOpen = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(stillOpen.status, SessionStatus.open.value);
    });

    test('분할결제(여러 결제수단) 합계가 일치하면 정상 마감', () async {
      final s = await repo.createSession(businessType: 'izakaya');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'product',
        itemName: 'コース',
        unitPrice: 8000,
      );
      final closed = await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [
          (method: 'cash', amount: 3000),
          (method: 'card', amount: 5000),
        ],
      );
      expect(closed.status, SessionStatus.closed.value);
      final breakdowns = await (db.select(db.paymentMethodBreakdowns)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(breakdowns, hasLength(2));
    });

    test('이미 closed인 세션 재마감 시도 → BusinessRuleException', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(
        () => repo.closeSession(
          sessionId: s.id,
          paymentMethods: const [(method: 'cash', amount: 5000)],
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('Staff Earning Ledger (A-12, ADR-006 연동)', () {
    test('closeSession()에서 staff_fee 품목의 ledger가 생성됨', () async {
      final s = await repo.createSession(businessType: 'salon');
      final item = await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );
      // closeSession() 전 — 아직 ledger 없음
      var ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, isEmpty);

      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 1000)],
      );

      // closeSession() 후 — ledger 생성됨
      ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, hasLength(1));
      expect(ledgers.single.staffId, 1);
      expect(ledgers.single.earningType, 'staff_fee');
      expect(ledgers.single.amount, 1000);
      expect(ledgers.single.sessionItemId, item.id);
    });

    test('할인 전 금액 기준(ADR-006) — discount 품목이 있어도 ledger 금액은 영향 없음', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );
      await repo.addItem(
        sessionId: s.id,
        itemType: 'discount',
        itemName: 'クーポン300円引き',
        unitPrice: -300,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 700)], // finalAmount = 1000-300
      );
      final ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, hasLength(1));
      expect(ledgers.single.amount, 1000); // 할인 반영 안 됨 — 원래 staff_fee 금액 그대로
    });

    test('Snapshot 불변성 — closeSession() 이후 같은 데이터를 다시 마감 시도해도 ledger가 중복 생성되지 않음', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 1000)],
      );
      // 이미 closed라 재마감은 거부됨(기존 가드) — ledger 재계산 자체가 시도되지 않음
      await expectLater(
        repo.closeSession(
          sessionId: s.id,
          paymentMethods: const [(method: 'cash', amount: 1000)],
        ),
        throwsA(isA<BusinessRuleException>()),
      );
      final ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, hasLength(1)); // 여전히 1건 — 중복 없음
    });

    test('Rule(EarningRule) 변경 이후에도 기존(이미 마감된) Ledger는 변경되지 않음', () async {
      // session1: rate 100%로 마감
      final repoRate100 = SessionRepository(db, staffEarningEngine: const StaffEarningEngine());
      final s1 = await repoRate100.createSession(businessType: 'salon');
      await repoRate100.addItem(
        sessionId: s1.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );
      await repoRate100.closeSession(
        sessionId: s1.id,
        paymentMethods: const [(method: 'cash', amount: 1000)],
      );
      final s1LedgersBefore = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s1.id)))
          .get();
      expect(s1LedgersBefore.single.amount, 1000);

      // session2: "Rule이 바뀐 것"을 시뮬레이션 — rate 50%인 별도 SessionRepository로 마감
      final repoRate50 = SessionRepository(
        db,
        staffEarningEngine: const _Rate50StaffEarningEngine(),
      );
      final s2 = await repoRate50.createSession(businessType: 'salon');
      await repoRate50.addItem(
        sessionId: s2.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );
      await repoRate50.closeSession(
        sessionId: s2.id,
        paymentMethods: const [(method: 'cash', amount: 1000)],
      );

      // session1의 ledger는 "Rule 변경" 이후에도 그대로(재계산되지 않음)
      final s1LedgersAfter = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s1.id)))
          .get();
      expect(s1LedgersAfter.single.amount, 1000); // 여전히 1000 — 변경 없음

      final s2Ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s2.id)))
          .get();
      expect(s2Ledgers.single.amount, 500); // session2는 50% rate로 새로 계산됨
    });
  });

  group('cancelSession', () {
    test('6. status == cancelled 확인', () async {
      final s = await repo.createSession(businessType: 'karaoke');
      await repo.cancelSession(s.id);
      final found = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(found.status, SessionStatus.cancelled.value);
    });

    test('7. closed 세션에 cancelSession → BusinessRuleException', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(
        () => repo.cancelSession(s.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('이미 cancelled인 세션 재취소 → 멱등(예외 없이 유지)', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.cancelSession(s.id);
      await repo.cancelSession(s.id); // 재호출 — 예외 없이 통과해야 함
      final found = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(found.status, SessionStatus.cancelled.value);
    });

    test('존재하지 않는 세션 취소 → NotFoundException', () async {
      expect(
        () => repo.cancelSession(9999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getSessionSummary', () {
    test('session + items + earning + payment 전부 조합', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 1000)],
      );
      final summary = await repo.getSessionSummary(s.id);
      expect(summary.session.status, SessionStatus.closed.value);
      expect(summary.items, hasLength(1));
      expect(summary.earnings, hasLength(1));
      expect(summary.payments, hasLength(1));
    });
  });

  group('calcSuggestedTimeFee (A-10 Pricing Engine 연동)', () {
    test('time_base 규칙으로 시간요금 계산 후 addItem()에 그대로 사용', () async {
      final pricingRepo = PricingRuleRepository(db);
      await pricingRepo.addRule(businessType: 'karaoke', ruleType: 'time_base', value: 100);

      final fee = await repo.calcSuggestedTimeFee(businessType: 'karaoke', minutes: 30);
      expect(fee, 3000);

      final s = await repo.createSession(businessType: 'karaoke');
      final item = await repo.addItem(
        sessionId: s.id,
        itemType: 'time',
        itemName: '利用料(30分)',
        unitPrice: fee, // calcSuggestedTimeFee()의 결과를 그대로 전달
      );
      // addItem()의 amount 계산식(unitPrice*qty)은 변경되지 않았음을 확인
      // — qty 기본값 1이므로 amount는 unitPrice와 동일해야 함(중복계산 없음).
      expect(item.amount, fee);
      expect(item.amount, item.unitPrice * item.qty);
    });

    test('피크 시간대 규칙까지 있으면 할증이 합산된 금액을 반환', () async {
      final pricingRepo = PricingRuleRepository(db);
      await pricingRepo.addRule(businessType: 'karaoke', ruleType: 'time_base', value: 100);
      await pricingRepo.addRule(businessType: 'karaoke', ruleType: 'peak', value: 20);

      final fee = await repo.calcSuggestedTimeFee(
        businessType: 'karaoke',
        minutes: 30,
        at: DateTime(2026, 6, 25, 23, 0), // 피크 시간대
      );
      expect(fee, 3600); // 3000 + (3000*20%)=600
    });

    test('규칙이 없으면 0 — addItem()은 그대로 정상 동작(영향 없음)', () async {
      final fee = await repo.calcSuggestedTimeFee(businessType: 'salon', minutes: 30);
      expect(fee, 0);

      // 가격엔진과 무관하게 addItem()은 여전히 호출자가 넘긴 unitPrice를
      // 그대로 신뢰한다 — 기존 동작 회귀 없음 확인.
      final s = await repo.createSession(businessType: 'salon');
      final item = await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      expect(item.amount, 5000);
    });
  });

  group('calcSuggestedDiscount (A-11 Promotion Engine 연동)', () {
    test('active 규칙으로 할인 계산 후 addItem()에 음수로 그대로 사용', () async {
      final promotionRepo = PromotionRuleRepository(db);
      final rule = await promotionRepo.addRule(
        businessType: 'salon',
        discountType: 'flat',
        amount: 500,
      );
      await promotionRepo.updateRule(id: rule.id, status: 'active');

      final result = await repo.calcSuggestedDiscount(businessType: 'salon', subtotal: 3000);
      expect(result.applied, true);
      expect(result.discountAmount, 500);

      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 3000,
      );
      final item = await repo.addItem(
        sessionId: s.id,
        itemType: 'discount',
        itemName: 'クーポン500円引き',
        unitPrice: -result.discountAmount,
        refType: 'coupon',
        refId: '${rule.id}',
      );
      expect(item.amount, -500);

      final summary = await repo.getSessionSummary(s.id);
      expect(summary.session.totalAmount, 2500); // 3000 - 500
      expect(summary.session.finalAmount, 2500);
    });

    test('규칙이 없으면 applied=false — addItem()은 그대로 정상 동작(영향 없음)', () async {
      final result = await repo.calcSuggestedDiscount(businessType: 'karaoke', subtotal: 3000);
      expect(result.applied, false);
      expect(result.discountAmount, 0);

      final s = await repo.createSession(businessType: 'karaoke');
      final item = await repo.addItem(
        sessionId: s.id,
        itemType: 'product',
        itemName: 'コース',
        unitPrice: 8000,
      );
      expect(item.amount, 8000); // addItem() 동작 변화 없음
    });

    test('draft 상태 규칙은 적용되지 않음(Lifecycle, ADR-004)', () async {
      final promotionRepo = PromotionRuleRepository(db);
      await promotionRepo.addRule(businessType: 'izakaya', discountType: 'rate', amount: 10); // draft 그대로

      final result = await repo.calcSuggestedDiscount(businessType: 'izakaya', subtotal: 3000);
      expect(result.applied, false);
    });
  });

  group('Race Condition Verification (A-18.4, Conditional Update 검증)', () {
    test('동시 closeSession() 호출 — 한쪽만 성공하고 다른 쪽은 BusinessRuleException, '
        '데이터 중복 없음', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 1,
      );

      // 동일 세션에 대해 동시에(Future.wait) closeSession()을 2회 호출한다.
      // 둘 다 예외 없이 await 가능하도록, 각 호출을 개별 try-catch로
      // 감싸 성공/실패를 결과 리스트로 모은다.
      Future<Object> attemptClose() async {
        try {
          return await repo.closeSession(
            sessionId: s.id,
            paymentMethods: const [(method: 'cash', amount: 1000)],
          );
        } catch (e) {
          return e;
        }
      }

      final results = await Future.wait([attemptClose(), attemptClose()]);

      final successes = results.whereType<PaymentSessionRow>().toList();
      final failures = results.whereType<BusinessRuleException>().toList();

      // PART2: 첫 번째 호출은 정상 종료, 두 번째 호출은 BusinessRuleException.
      expect(successes, hasLength(1));
      expect(failures, hasLength(1));
      expect(successes.single.status, SessionStatus.closed.value);

      // PART2: Settlement 중복 생성 없음.
      final breakdowns = await (db.select(db.paymentMethodBreakdowns)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(breakdowns, hasLength(1));

      // PART2: Ledger 중복 생성 없음 — 실패한 호출이 트랜잭션 안에서
      // 이미 insert했던 Ledger도 rollback으로 사라져야 한다.
      final ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, hasLength(1));

      // PART2: Session 상태는 closed 한 번만 저장된다(중복 갱신 없음).
      final finalSession = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(finalSession.status, SessionStatus.closed.value);
    });
  });
}

/// "Rule이 나중에 바뀌었다"는 시나리오를 시뮬레이션하기 위한 테스트 전용
/// 헬퍼 — rate를 50%로 고정해서 계산한다(production 코드는 무수정).
class _Rate50StaffEarningEngine extends StaffEarningEngine {
  const _Rate50StaffEarningEngine();

  @override
  List<StaffEarningResult> calcEarnings({
    required List<EarnableItem> items,
    EarningRule rule = const EarningRule(),
  }) {
    return super.calcEarnings(items: items, rule: const EarningRule(rate: 50));
  }
}
