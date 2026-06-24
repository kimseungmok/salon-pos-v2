import 'package:drift/drift.dart';

/// design/spec/v3/cash_management/data_spec.md "엔티티: CashCount" 그대로.
///
/// 구현상 단순화 메모(M8): [denominationsJson]은 `{"10000":2,"5000":0,...}`
/// 형식의 JSON 문자열로 저장한다 — Drift에 Map 컬럼 타입이 없고, 권종
/// 9종은 항상 고정 집합이라 별도 자식 테이블을 만드는 것은 과설계.
@DataClassName('CashCountRow')
class CashCounts extends Table {
  TextColumn get id => text()();

  /// open / close.
  TextColumn get type => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get denominationsJson => text()();
  IntColumn get totalAmount => integer()();
  IntColumn get expectedAmount => integer()();
  IntColumn get diffAmount => integer()();
  TextColumn get diffReason => text().nullable()();
  DateTimeColumn get confirmedAt => dateTime().nullable()();
  TextColumn get confirmedBy => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/cash_management/data_spec.md "엔티티:
/// ClosingChecklistItem" 그대로. F-CASH-04 — 살롱 고유(토스 근거 없음).
@DataClassName('ClosingChecklistItemRow')
class ClosingChecklistItems extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get label => text()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
