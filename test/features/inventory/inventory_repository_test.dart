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
        () => repo.adjustQuantity(itemId: 999999, delta: 1, reason: 'stock_in'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('deleteItem (A-5: 이력보존 삭제정책)', () {
    test('존재하지 않는 품목 삭제 → NotFoundException', () async {
      expect(
        () => repo.deleteItem(999999),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('이력이 없는 품목은 삭제 가능', () async {
      final item = await repo.createItem(name: 'テスト品目', category: 'その他');
      await repo.deleteItem(item.id); // 예외 없이 통과해야 함
      final found = await (db.select(db.inventoryItems)
            ..where((t) => t.id.equals(item.id)))
          .getSingleOrNull();
      expect(found, null);
    });

    test('이력이 1건이라도 있는 품목은 삭제 거부 → BusinessRuleException', () async {
      final item = await repo.createItem(name: 'カラー剤', category: 'カラー剤');
      await repo.adjustQuantity(itemId: item.id, delta: 10, reason: 'stock_in');
      expect(
        () => repo.deleteItem(item.id),
        throwsA(isA<BusinessRuleException>()),
      );
      // 삭제 거부 후에도 품목/이력 데이터는 그대로 보존되어야 한다.
      final found = await (db.select(db.inventoryItems)
            ..where((t) => t.id.equals(item.id)))
          .getSingleOrNull();
      expect(found != null, true);
      final logs = await (db.select(db.inventoryLogs)
            ..where((t) => t.itemId.equals(item.id)))
          .get();
      expect(logs, hasLength(1));
    });

    test('이력이 있어 삭제가 거부된 뒤에도 재고 수량 조정 로직은 영향 없음', () async {
      final item = await repo.createItem(name: 'パーマ液', category: 'パーマ剤');
      await repo.adjustQuantity(itemId: item.id, delta: 10, reason: 'stock_in');
      expect(() => repo.deleteItem(item.id), throwsA(isA<BusinessRuleException>()));

      await repo.adjustQuantity(itemId: item.id, delta: -3, reason: 'use');
      final updated = await (db.select(db.inventoryItems)
            ..where((t) => t.id.equals(item.id)))
          .getSingle();
      expect(updated.quantity, 7);
    });
  });
}
