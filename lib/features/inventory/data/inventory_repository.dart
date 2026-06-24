import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';

const _uuid = Uuid();

/// design/spec/v3/inventory/feature_spec.md F-INV-00~02 그대로 구현.
/// **절대 원칙(F-INV-00)**: 이 레포지토리는 Product/Order 테이블을
/// import하거나 참조하지 않는다 — 재고는 商品/決済와 완전히 독립.
class InventoryRepository {
  InventoryRepository(this._db);

  final AppDatabase _db;

  static const _validReasons = {'stock_in', 'use', 'disposal', 'adjustment'};

  Stream<List<InventoryItemRow>> watchItems() {
    return (_db.select(_db.inventoryItems)
          ..orderBy([(i) => OrderingTerm.asc(i.name)]))
        .watch();
  }

  Stream<List<InventoryLogRow>> watchLogsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.inventoryLogs)
          ..where((l) =>
              l.createdAt.isBiggerOrEqualValue(start) & l.createdAt.isSmallerThanValue(end))
          ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]))
        .watch();
  }

  Future<InventoryItemRow> createItem({
    required String name,
    required String category,
    int quantity = 0,
    int threshold = 0,
    String? unit,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('品目名を入力してください。');
    }
    if (quantity < 0 || threshold < 0) {
      throw const ValidationException('在庫数・しきい値は0以上にしてください。');
    }
    try {
      final id = _uuid.v4();
      await _db.into(_db.inventoryItems).insert(
            InventoryItemsCompanion.insert(
              id: id,
              name: trimmed,
              category: category,
              quantity: Value(quantity),
              threshold: Value(threshold),
              unit: Value(unit),
            ),
          );
      return InventoryItemRow(
        id: id,
        name: trimmed,
        category: category,
        quantity: quantity,
        threshold: threshold,
        unit: unit,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// F-INV-01: 수량 조정 — 변경분을 InventoryLog에 자동 기록.
  Future<void> adjustQuantity({
    required String itemId,
    required int delta,
    required String reason,
    String? staffId,
  }) async {
    if (!_validReasons.contains(reason)) {
      throw const ValidationException('変動理由の値が正しくありません。');
    }
    try {
      final item = await (_db.select(_db.inventoryItems)
            ..where((i) => i.id.equals(itemId)))
          .getSingleOrNull();
      if (item == null) {
        throw const NotFoundException('品目が見つかりませんでした。');
      }
      final newQuantity = item.quantity + delta;
      if (newQuantity < 0) {
        throw const BusinessRuleException('在庫数が不足しているため、その数量は調整できません。');
      }

      await (_db.update(_db.inventoryItems)..where((i) => i.id.equals(itemId)))
          .write(InventoryItemsCompanion(quantity: Value(newQuantity)));
      await _db.into(_db.inventoryLogs).insert(
            InventoryLogsCompanion.insert(
              id: _uuid.v4(),
              itemId: itemId,
              delta: delta,
              reason: reason,
              staffId: Value(staffId),
              createdAt: DateTime.now(),
            ),
          );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      final rows = await (_db.delete(_db.inventoryItems)
            ..where((i) => i.id.equals(itemId)))
          .go();
      if (rows == 0) {
        throw const NotFoundException('品目が見つかりませんでした（既に削除されている可能性があります）。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}
