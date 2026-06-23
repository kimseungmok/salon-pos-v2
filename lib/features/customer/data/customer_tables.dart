import 'package:drift/drift.dart';

/// design/spec/v3/customer/data_spec.md "엔티티: Customer" 그대로.
/// 주의: `tag`/`bdayMonth` 같은 정적 그룹 필드는 절대 추가하지 않는다
/// — 그룹은 항상 groupOf()로 동적 계산(F-CUST-01, 저장하지 않음).
@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get phone => text()();
  TextColumn get memo => text().nullable()();
  IntColumn get points => integer().withDefault(const Constant(0))();
  DateTimeColumn get birthday => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/customer/data_spec.md "엔티티: VisitRecord" 그대로.
@DataClassName('VisitRecordRow')
class VisitRecords extends Table {
  TextColumn get id => text()();
  TextColumn get customerId =>
      text().references(Customers, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get visitDate => dateTime()();
  TextColumn get staffId => text().nullable()();
  IntColumn get amount => integer().withDefault(const Constant(0))();

  /// completed/noshow/cancelled. F-CUST-01 그룹산출은 completed만 카운트.
  TextColumn get status => text().withDefault(const Constant('completed'))();

  @override
  Set<Column> get primaryKey => {id};
}
