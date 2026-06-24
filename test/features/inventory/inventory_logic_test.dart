import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/inventory/logic/inventory_logic.dart';

void main() {
  InventoryItemRow item(int quantity, int threshold) => InventoryItemRow(
        id: 'i1',
        name: 'テスト品目',
        category: 'カラー剤',
        quantity: quantity,
        threshold: threshold,
      );

  group('statusOf (F-INV-01)', () {
    test('수량 0 → 品切れ', () {
      expect(statusOf(item(0, 5)), InventoryStatus.outOfStock);
    });

    test('수량 < 기준치 → 不足', () {
      expect(statusOf(item(3, 5)), InventoryStatus.low);
    });

    test('수량 == 기준치 → 正常(경계값)', () {
      expect(statusOf(item(5, 5)), InventoryStatus.normal);
    });

    test('수량 > 기준치 → 正常', () {
      expect(statusOf(item(10, 5)), InventoryStatus.normal);
    });
  });
}
