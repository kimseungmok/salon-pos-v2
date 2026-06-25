import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/prepaid_pass/logic/prepaid_pass_logic.dart';

void main() {
  PrepaidPassMenuRow menu({
    String expiryType = 'none',
    int? expiryCustomDays,
  }) {
    return PrepaidPassMenuRow(
      id: 1,
      type: 'amount',
      name: 'テスト券',
      price: 100000,
      allowCustomPrice: false,
      bonusType: 'none',
      expiryType: expiryType,
      expiryCustomDays: expiryCustomDays,
      status: 'active',
    );
  }

  group('computeExpiry (F-PP-01b)', () {
    final purchasedAt = DateTime(2026, 6, 23);

    test('none → null(무기한)', () {
      expect(computeExpiry(menu(expiryType: 'none'), purchasedAt), null);
    });

    test('90d → +90일', () {
      expect(
        computeExpiry(menu(expiryType: '90d'), purchasedAt),
        purchasedAt.add(const Duration(days: 90)),
      );
    });

    test('1y → +1년(같은 월일)', () {
      expect(
        computeExpiry(menu(expiryType: '1y'), purchasedAt),
        DateTime(2027, 6, 23),
      );
    });

    test('custom → expiryCustomDays만큼', () {
      expect(
        computeExpiry(menu(expiryType: 'custom', expiryCustomDays: 45), purchasedAt),
        purchasedAt.add(const Duration(days: 45)),
      );
    });
  });

  group('applyPrepaidAmountPayment (F-PP-03 혼합결제)', () {
    test('잔액이 충분하면 전액 선불권으로 차감', () {
      final r = applyPrepaidAmountPayment(50000, 5000);
      expect(r.usedFromPrepaid, 5000);
      expect(r.remainingToPayOtherwise, 0);
    });

    test('잔액 부족 시 한도까지만 차감, 나머지는 다른 결제수단', () {
      final r = applyPrepaidAmountPayment(3000, 5000);
      expect(r.usedFromPrepaid, 3000);
      expect(r.remainingToPayOtherwise, 2000);
    });

    test('잔액 0이면 전액 다른 결제수단', () {
      final r = applyPrepaidAmountPayment(0, 5000);
      expect(r.usedFromPrepaid, 0);
      expect(r.remainingToPayOtherwise, 5000);
    });
  });

  group('canUseCountPass', () {
    test('잔여횟수 > 0 → true', () => expect(canUseCountPass(3), true));
    test('잔여횟수 0 → false', () => expect(canUseCountPass(0), false));
  });
}
