import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/inventory/data/inventory_repository.dart';

void main() {
  late AppDatabase db;
  late InventoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = InventoryRepository(db);
  });

  tearDown(() => db.close());

  group('createItem', () {
    test('정상 생성', () async {
      final item = await repo.createItem(
        name: 'カラー剤（ブラウン系）',
        category: 'カラー剤',
        quantity: 24,
        threshold: 10,
      );
      expect(item.quantity, 24);
    });

    test('이름 공백 → ValidationException', () async {
      expect(
        () => repo.createItem(name: '  ', category: 'カラー剤'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('음수 수량 → ValidationException', () async {
      expect(
        () => repo.createItem(name: 'テスト', category: 'カラー剤', quantity: -1),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('adjustQuantity (F-INV-01, 자동 로그기록)', () {
    test('증가 조정 + 로그 자동생성', () async {
      final item = await repo.createItem(name: 'シャンプー', category: '消耗品', quantity: 5);
      await repo.adjustQuantity(itemId: item.id, delta: 20, reason: 'stock_in');
      final updated =
          await (db.select(db.inventoryItems)..where((i) => i.id.equals(item.id))).getSingle();
      expect(updated.quantity, 25);

      final logs = await db.select(db.inventoryLogs).get();
      expect(logs.length, 1);
      expect(logs.first.delta, 20);
      expect(logs.first.reason, 'stock_in');
    });

    test('차감 조정', () async {
      final item = await repo.createItem(name: 'シャンプー', category: '消耗品', quantity: 5);
      await repo.adjustQuantity(itemId: item.id, delta: -2, reason: 'use');
      final updated =
          await (db.select(db.inventoryItems)..where((i) => i.id.equals(item.id))).getSingle();
      expect(updated.quantity, 3);
    });

    test('잘못된 reason → ValidationException', () async {
      final item = await repo.createItem(name: 'シャンプー', category: '消耗品', quantity: 5);
      expect(
        () => repo.adjustQuantity(itemId: item.id, delta: 1, reason: 'invalid'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('재고보다 많은 차감 시도 → BusinessRuleException', () async {
      final item = await repo.createItem(name: 'シャンプー', category: '消耗品', quantity: 5);
      expect(
        () => repo.adjustQuantity(itemId: item.id, delta: -10, reason: 'use'),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('존재하지 않는 품목 → NotFoundException', () async {
      expect(
        () => repo.adjustQuantity(itemId: 'no-such-id', delta: 1, reason: 'stock_in'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('deleteItem', () {
    test('존재하지 않는 품목 삭제 → NotFoundException', () async {
      expect(
        () => repo.deleteItem('no-such-id'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
