import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/marketing/logic/marketing_logic.dart';

void main() {
  PointPolicyRow policy({bool enabled = true, double rate = 5}) => PointPolicyRow(
        id: 'singleton',
        enabled: enabled,
        earnRate: rate,
        minUsablePoints: 100,
        earnScope: 'all',
        useScope: 'all',
        pointValueYen: 1,
      );

  group('computeEarnedPoints (F-MKT-03)', () {
    test('정상 적립 계산(5% of 10000 = 500)', () {
      expect(computeEarnedPoints(10000, policy(rate: 5)), 500);
    });

    test('정책 OFF면 0', () {
      expect(computeEarnedPoints(10000, policy(enabled: false)), 0);
    });

    test('소수점은 버림', () {
      expect(computeEarnedPoints(999, policy(rate: 5)), 49);
    });
  });

  group('applyCouponDiscount 재사용 확인', () {
    test('퍼센트 할인', () {
      expect(applyCouponDiscount('10%', 10000), 1000);
    });
  });
}
