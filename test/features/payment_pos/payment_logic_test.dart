import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/payment_pos/logic/payment_logic.dart';

void main() {
  group('computeChange (F-PAY-02a)', () {
    test('정확히 지불 → 거스름돈 0', () {
      expect(computeChange(5000, 5000), 0);
    });

    test('더 많이 지불 → 차액 반환', () {
      expect(computeChange(10000, 5500), 4500);
    });

    test('부족하게 지불해도 음수 대신 0 반환(UI에서 별도 차단)', () {
      expect(computeChange(3000, 5000), 0);
    });
  });

  group('canPayWithCash', () {
    test('받은금액 == 결제금액 → true', () {
      expect(canPayWithCash(5000, 5000), true);
    });

    test('받은금액 < 결제금액 → false', () {
      expect(canPayWithCash(4999, 5000), false);
    });
  });

  group('payByItems (F-PAY-04 메뉴별 결제)', () {
    OrderItemRow item(String id, int price, int qty) => OrderItemRow(
          id: id,
          orderId: 'o1',
          productId: id,
          productName: id,
          quantity: qty,
          unitPrice: price,
        );

    test('선택된 아이템들의 합계만 계산', () {
      final items = [item('a', 5000, 1), item('b', 8000, 2), item('c', 3000, 1)];
      final total = payByItems(['a', 'b'], items);
      expect(total, 5000 + 8000 * 2);
    });

    test('선택 없으면 0', () {
      final items = [item('a', 5000, 1)];
      expect(payByItems([], items), 0);
    });
  });

  group('applyCouponDiscount (F-MKT-01)', () {
    test('퍼센트 할인', () {
      expect(applyCouponDiscount('10%', 10000), 1000);
    });

    test('금액 할인(¥ 기호 포함)', () {
      expect(applyCouponDiscount('¥1,000', 10000), 1000);
    });

    test('소수점은 버림(floor)', () {
      expect(applyCouponDiscount('15%', 999), 149);
    });
  });
}
