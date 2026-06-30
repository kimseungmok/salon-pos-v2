import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/features/staff_earning/domain/earnable_item.dart';
import 'package:salon_pos_v2/features/staff_earning/domain/earning_rule.dart';
import 'package:salon_pos_v2/features/staff_earning/logic/staff_earning_engine.dart';

/// A-12 Staff Earning Engine MVP 검증. 순수 계산 클래스라 DB 없이
/// 테스트한다.
void main() {
  const engine = StaffEarningEngine();

  EarnableItem item({
    int id = 1,
    String itemType = 'staff_fee',
    int? staffId = 1,
    required int amount,
  }) {
    return EarnableItem(id: id, itemType: itemType, staffId: staffId, amount: amount);
  }

  group('기본 계산', () {
    test('staff_fee 품목 1건 — 기본 rate(100%)면 amount 그대로 수익', () {
      final results = engine.calcEarnings(items: [item(amount: 1000)]);
      expect(results, hasLength(1));
      expect(results.single.staffId, 1);
      expect(results.single.totalAmount, 1000);
      expect(results.single.earningAmount, 1000);
      expect(results.single.earningRate, 100);
      expect(results.single.sessionItemId, 1);
    });

    test('rate가 50%면 절반만 수익', () {
      final results = engine.calcEarnings(
        items: [item(amount: 1000)],
        rule: const EarningRule(rate: 50),
      );
      expect(results.single.earningAmount, 500);
    });
  });

  group('할인 품목 제외', () {
    test('itemType=discount는 staffId가 있어도 계산 대상에서 제외', () {
      final results = engine.calcEarnings(items: [
        item(id: 1, itemType: 'staff_fee', staffId: 1, amount: 1000),
        item(id: 2, itemType: 'discount', staffId: 1, amount: -500),
      ]);
      expect(results, hasLength(1));
      expect(results.single.sessionItemId, 1);
    });

    test('service/product 등 staff_fee가 아닌 타입도 계산 대상에서 제외(기존 동작과 동일)', () {
      final results = engine.calcEarnings(items: [
        item(id: 1, itemType: 'service', staffId: 1, amount: 5000),
      ]);
      expect(results, isEmpty);
    });
  });

  group('subtotal 0', () {
    test('amount가 0이면 earningAmount도 0(예외 없음)', () {
      final results = engine.calcEarnings(items: [item(amount: 0)]);
      expect(results.single.totalAmount, 0);
      expect(results.single.earningAmount, 0);
    });
  });

  group('Staff 없음', () {
    test('staffId가 null인 staff_fee 품목은 계산 대상에서 제외', () {
      final results = engine.calcEarnings(items: [
        item(staffId: null, amount: 1000),
      ]);
      expect(results, isEmpty);
    });

    test('입력이 빈 리스트면 결과도 빈 리스트', () {
      final results = engine.calcEarnings(items: const []);
      expect(results, isEmpty);
    });
  });

  group('여러 Staff 계산', () {
    test('서로 다른 staffId의 staff_fee 품목이 각각 별도 결과로 계산됨', () {
      final results = engine.calcEarnings(items: [
        item(id: 1, staffId: 1, amount: 1000),
        item(id: 2, staffId: 2, amount: 2000),
      ]);
      expect(results, hasLength(2));
      expect(results[0].staffId, 1);
      expect(results[0].earningAmount, 1000);
      expect(results[1].staffId, 2);
      expect(results[1].earningAmount, 2000);
    });
  });

  group('음수 방지', () {
    test('rate가 음수여도 earningAmount는 0 이하로 내려가지 않음', () {
      final results = engine.calcEarnings(
        items: [item(amount: 1000)],
        rule: const EarningRule(rate: -10),
      );
      expect(results.single.earningAmount, 0);
    });
  });
}
