import 'package:drift/drift.dart';

/// design/spec/v3/inventory/data_spec.md "엔티티: InventoryItem" 그대로.
/// F-INV-00: 商品(Product)/決済(OrderItem)와 의도적으로 FK 연결하지
/// 않는다 — 판매 상품과 소모성 자재(컬러제·펌약 등)는 완전히 별개로
/// 관리(독자기능, 토스 근거 없음).
@DataClassName('InventoryItemRow')
class InventoryItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get category => text()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  IntColumn get threshold => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/inventory/data_spec.md "엔티티: InventoryLog" 그대로.
@DataClassName('InventoryLogRow')
class InventoryLogs extends Table {
  TextColumn get id => text()();
  TextColumn get itemId =>
      text().references(InventoryItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get delta => integer()();

  /// stock_in / use / disposal / adjustment.
  TextColumn get reason => text()();
  TextColumn get staffId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
