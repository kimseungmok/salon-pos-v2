import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/features/cash_management/logic/cash_logic.dart';

void main() {
  group('computeTotal (F-CASH-02)', () {
    test('권종별 합산', () {
      expect(computeTotal({10000: 2, 5000: 0, 500: 3}), 20000 + 1500);
    });

    test('빈 입력 → 0', () {
      expect(computeTotal({}), 0);
    });
  });

  group('expectedCloseAmount (F-CASH-01)', () {
    test('시작금+현금매출-환불', () {
      expect(expectedCloseAmount(50000, 100000, 5000), 145000);
    });
  });

  group('computeDiff', () {
    test('총액==예상액 → 0', () {
      expect(computeDiff(50000, 50000), 0);
    });

    test('총액 > 예상액 → 양수', () {
      expect(computeDiff(55000, 50000), 5000);
    });

    test('총액 < 예상액 → 음수', () {
      expect(computeDiff(45000, 50000), -5000);
    });
  });

  test('kDenomUnits — 지폐는 枚, 동전은 個', () {
    expect(kDenomUnits[10000], '枚');
    expect(kDenomUnits[5000], '枚');
    expect(kDenomUnits[1000], '枚');
    expect(kDenomUnits[500], '個');
    expect(kDenomUnits[100], '個');
    expect(kDenomUnits[1], '個');
  });
}
