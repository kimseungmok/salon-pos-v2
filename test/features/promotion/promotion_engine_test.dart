import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/features/promotion/domain/promotion_rule.dart';
import 'package:salon_pos_v2/features/promotion/logic/promotion_engine.dart';

/// A-11 Promotion Engine MVP 검증. 순수 계산 클래스라 DB 없이 테스트한다.
void main() {
  const engine = PromotionEngine();

  PromotionRule rule({
    int id = 1,
    String businessType = 'salon',
    String discountType = 'flat',
    required int amount,
    int priority = 0,
    String status = 'active',
    DateTime? startAt,
    DateTime? endAt,
  }) {
    return PromotionRule(
      id: id,
      shopId: 1,
      businessType: businessType,
      ruleType: 'discount',
      discountType: discountType,
      priority: priority,
      amount: amount,
      startAt: startAt,
      endAt: endAt,
      status: status,
    );
  }

  final now = DateTime(2026, 6, 26, 12, 0);

  group('flat 할인', () {
    test('정액 500원 할인', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(discountType: 'flat', amount: 500)],
      );
      expect(result.applied, true);
      expect(result.discountAmount, 500);
      expect(result.appliedRuleId, 1);
    });
  });

  group('rate 할인', () {
    test('정률 10% 할인', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(discountType: 'rate', amount: 10)],
      );
      expect(result.applied, true);
      expect(result.discountAmount, 300);
    });

    test('정률 할인의 소수점은 버림(floor)', () {
      final result = engine.calcDiscount(
        subtotal: 999,
        at: now,
        rules: [rule(discountType: 'rate', amount: 10)],
      ); // 99.9 → 99
      expect(result.discountAmount, 99);
    });
  });

  group('inactive 제외', () {
    test('status가 active가 아니면 적용되지 않음', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(discountType: 'flat', amount: 500, status: 'draft')],
      );
      expect(result.applied, false);
      expect(result.discountAmount, 0);
    });

    test('disabled 규칙도 제외', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(discountType: 'flat', amount: 500, status: 'disabled')],
      );
      expect(result.applied, false);
    });
  });

  group('기간 외 제외(Expired는 저장값이 아니라 즉석 판정)', () {
    test('startAt 이전이면 적용되지 않음', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [
          rule(
            discountType: 'flat',
            amount: 500,
            startAt: now.add(const Duration(days: 1)),
          ),
        ],
      );
      expect(result.applied, false);
    });

    test('endAt 이후(=Expired)면 적용되지 않음 — status는 여전히 active', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [
          rule(
            discountType: 'flat',
            amount: 500,
            status: 'active', // 컬럼상으로는 여전히 active
            endAt: now.subtract(const Duration(days: 1)), // 그러나 기간은 지남
          ),
        ],
      );
      expect(result.applied, false); // Engine이 즉석으로 Expired 판정
    });

    test('endAt 정각은 만료 처리(경계값, endAt 미포함)', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(discountType: 'flat', amount: 500, endAt: now)],
      );
      expect(result.applied, false);
    });

    test('startAt~endAt 범위 안이면 정상 적용', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [
          rule(
            discountType: 'flat',
            amount: 500,
            startAt: now.subtract(const Duration(days: 1)),
            endAt: now.add(const Duration(days: 1)),
          ),
        ],
      );
      expect(result.applied, true);
    });

    test('startAt/endAt이 둘 다 null이면 기간 제약 없음', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(discountType: 'flat', amount: 500)],
      );
      expect(result.applied, true);
    });
  });

  group('priority 적용', () {
    test('priority가 가장 작은(우선순위 높은) 규칙 1개만 적용 — 중첩 없음', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [
          rule(id: 1, discountType: 'flat', amount: 500, priority: 5),
          rule(id: 2, discountType: 'flat', amount: 1000, priority: 1),
        ],
      );
      expect(result.appliedRuleId, 2);
      expect(result.discountAmount, 1000);
    });

    test('priority 동률이면 id가 작은 쪽 — 정렬이 우연이 아님', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [
          rule(id: 2, discountType: 'flat', amount: 1000, priority: 1),
          rule(id: 1, discountType: 'flat', amount: 500, priority: 1),
        ],
      );
      expect(result.appliedRuleId, 1);
    });
  });

  group('Rule 없으면 할인 없음', () {
    test('빈 리스트', () {
      final result = engine.calcDiscount(subtotal: 3000, at: now, rules: const []);
      expect(result, PromotionResult.none);
    });

    test('businessType이 매칭되지 않으면(상위 호출자가 이미 필터링했다는 전제 — Engine은 비교하지 않음) 그대로 적용', () {
      // 주: businessType 필터는 Repository.getRules()의 책임(§A11_IMPLEMENTATION_PLAN PART3).
      // Engine은 넘어온 rules 리스트를 그대로 신뢰하고 매칭한다.
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(businessType: 'karaoke', discountType: 'flat', amount: 500)],
      );
      expect(result.applied, true);
    });
  });

  group('할인금액 음수 방지', () {
    test('amount가 0이면 할인 없음 처리', () {
      final result = engine.calcDiscount(
        subtotal: 3000,
        at: now,
        rules: [rule(discountType: 'flat', amount: 0)],
      );
      expect(result.applied, false);
      expect(result.discountAmount, 0);
    });
  });

  group('subtotal 0 처리', () {
    test('subtotal이 0이면 정액 할인도 0으로 clamp(음수 finalAmount 방지)', () {
      final result = engine.calcDiscount(
        subtotal: 0,
        at: now,
        rules: [rule(discountType: 'flat', amount: 500)],
      );
      expect(result.applied, false);
      expect(result.discountAmount, 0);
    });

    test('subtotal이 정액 할인보다 작으면 subtotal로 clamp', () {
      final result = engine.calcDiscount(
        subtotal: 300,
        at: now,
        rules: [rule(discountType: 'flat', amount: 500)],
      );
      expect(result.discountAmount, 300);
    });
  });
}
