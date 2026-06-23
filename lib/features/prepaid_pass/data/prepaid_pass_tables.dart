import 'package:drift/drift.dart';

/// design/spec/v3/prepaid_pass/data_spec.md "엔티티: PrepaidPassMenu"
/// 그대로. F-PP-01.
@DataClassName('PrepaidPassMenuRow')
class PrepaidPassMenus extends Table {
  TextColumn get id => text()();

  /// amount(금액권) / count(횟수권). 생성 후 변경 불가(앱에서 강제).
  TextColumn get type => text()();
  TextColumn get name => text().withLength(min: 1, max: 40)();

  /// count 타입만 필수, 1개만.
  TextColumn get linkedProductId => text().nullable()();
  IntColumn get price => integer()();
  BoolColumn get allowCustomPrice =>
      boolean().withDefault(const Constant(false))();

  /// count 타입만. 1회 구매시 제공 횟수.
  IntColumn get countPerPurchase => integer().nullable()();

  /// none / bonus.
  TextColumn get bonusType => text().withDefault(const Constant('none'))();
  IntColumn get bonusAmount => integer().nullable()();
  IntColumn get bonusCount => integer().nullable()();

  /// none/90d/180d/1y/2y/3y/fixedDate/custom.
  TextColumn get expiryType => text().withDefault(const Constant('none'))();

  /// fixedDate면 날짜, custom이면 일수(밀리초가 아니라 "일" 단위 정수를
  /// dateTime 컬럼에 epoch 변환 없이 별도 보관하기보단, 둘 다 단순화해
  /// "일수"로 통일 저장한다 — fixedDate는 호출측에서 일수로 환산해 넘김.
  IntColumn get expiryCustomDays => integer().nullable()();

  /// active/disabled.
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/prepaid_pass/data_spec.md "엔티티: PrepaidPassBalance"
/// 그대로.
@DataClassName('PrepaidPassBalanceRow')
class PrepaidPassBalances extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get menuId => text()();
  IntColumn get remainingAmount => integer().nullable()();
  IntColumn get remainingCount => integer().nullable()();
  DateTimeColumn get purchasedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// active/expired/voided.
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/prepaid_pass/data_spec.md "엔티티: PrepaidPassTransaction"
/// 그대로.
@DataClassName('PrepaidPassTransactionRow')
class PrepaidPassTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get balanceId => text()();

  /// charge/use/refund.
  TextColumn get type => text()();
  IntColumn get amount => integer().nullable()();
  IntColumn get count => integer().nullable()();
  TextColumn get relatedOrderId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
