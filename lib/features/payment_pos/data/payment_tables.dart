import 'package:drift/drift.dart';

/// design/spec/v3/payment_pos/data_spec.md "엔티티: Order"/"OrderItem"
/// 그대로.
///
/// 구현상 단순화 메모(M5, resumable 작업 기록): [prepaidUsedJson]은
/// 선불권 사용 내역(F-PP-03)을 담을 자리지만, prepaid_pass 모듈(M6)이
/// 아직 없어 지금은 항상 빈 배열로만 저장한다. M6에서 실제 차감 연동을
/// 추가할 때 이 컬럼의 JSON 스키마를 그때 확정한다.
///
/// A-9(docs/ID_CONVENTION.md): PK/FK는 INTEGER AUTOINCREMENT — UUID 금지.
@DataClassName('OrderRow')
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get customerId => integer().nullable()();
  IntColumn get totalAmount => integer()();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get pointsUsed => integer().withDefault(const Constant(0))();
  TextColumn get prepaidUsedJson => text().withDefault(const Constant('[]'))();

  /// pending/completed/cancelled/partially_paid.
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('OrderItemRow')
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId =>
      integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer()();
  IntColumn get unitPrice => integer()();
  IntColumn get staffId => integer().nullable()();
}

/// design/spec/v3/payment_pos/data_spec.md "엔티티: Payment" 그대로.
/// 回数券/利用券은 prepaid_pass로 통합 결정(CROSS_VALIDATION.md) —
/// method enum에 별도로 두지 않는다.
@DataClassName('PaymentRow')
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId =>
      integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  TextColumn get method => text()();
  IntColumn get amount => integer()();
  TextColumn get splitType => text().nullable()();
  IntColumn get cashReceived => integer().nullable()();
  IntColumn get cashChange => integer().nullable()();

  /// method='prepaid_pass'일 때만 사용 — 어느 PrepaidPassBalance에서
  /// 차감했는지 추적(M5의 TODO를 M6에서 이 컬럼으로 해소,
  /// CROSS_VALIDATION.md 수정2 후속).
  IntColumn get prepaidBalanceId => integer().nullable()();

  /// completed/refunded.
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get createdAt => dateTime()();
}
