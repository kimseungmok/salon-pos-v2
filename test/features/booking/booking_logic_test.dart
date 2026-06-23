import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/booking/logic/booking_logic.dart';

void main() {
  ProductRow product(String id, int duration) => ProductRow(
        id: id,
        name: id,
        categoryId: 'c1',
        price: 1000,
        allowCustomPrice: false,
        kioskVisible: true,
        durationMin: duration,
      );

  group('computeEndAt', () {
    test('단일 메뉴 소요시간만큼 더함', () {
      final end = computeEndAt(
        DateTime(2026, 6, 23, 14),
        ['p1'],
        [product('p1', 40)],
      );
      expect(end, DateTime(2026, 6, 23, 14, 40));
    });

    test('복수 메뉴는 합산(40分+90分=130分 → 14:00+130分=16:10)', () {
      final end = computeEndAt(
        DateTime(2026, 6, 23, 14),
        ['p1', 'p2'],
        [product('p1', 40), product('p2', 90)],
      );
      expect(end, DateTime(2026, 6, 23, 16, 10));
    });

    test('존재하지 않는 상품 id는 0분으로 취급', () {
      final end = computeEndAt(
        DateTime(2026, 6, 23, 14),
        ['no-such'],
        [product('p1', 40)],
      );
      expect(end, DateTime(2026, 6, 23, 14));
    });
  });

  group('waitColor', () {
    final now = DateTime(2026, 6, 23, 14, 30);

    test('9분 → gray', () {
      expect(
        waitColor(now.subtract(const Duration(minutes: 9)), now),
        WaitColor.gray,
      );
    });

    test('정확히 10분(경계값) → orange', () {
      expect(
        waitColor(now.subtract(const Duration(minutes: 10)), now),
        WaitColor.orange,
      );
    });

    test('19분 → orange', () {
      expect(
        waitColor(now.subtract(const Duration(minutes: 19)), now),
        WaitColor.orange,
      );
    });

    test('정확히 20분(경계값) → red', () {
      expect(
        waitColor(now.subtract(const Duration(minutes: 20)), now),
        WaitColor.red,
      );
    });
  });

  group('overlaps', () {
    test('겹치는 구간 → true', () {
      expect(
        overlaps(
          DateTime(2026, 6, 23, 14),
          DateTime(2026, 6, 23, 15),
          DateTime(2026, 6, 23, 14, 30),
          DateTime(2026, 6, 23, 15, 30),
        ),
        true,
      );
    });

    test('접하지만 겹치지 않는 구간(15시 끝, 15시 시작) → false', () {
      expect(
        overlaps(
          DateTime(2026, 6, 23, 14),
          DateTime(2026, 6, 23, 15),
          DateTime(2026, 6, 23, 15),
          DateTime(2026, 6, 23, 16),
        ),
        false,
      );
    });

    test('완전히 분리된 구간 → false', () {
      expect(
        overlaps(
          DateTime(2026, 6, 23, 14),
          DateTime(2026, 6, 23, 15),
          DateTime(2026, 6, 23, 18),
          DateTime(2026, 6, 23, 19),
        ),
        false,
      );
    });
  });
}
