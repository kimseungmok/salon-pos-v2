import 'package:drift/drift.dart';

/// design/spec/v3/marketing/data_spec.md "엔티티: Coupon" 그대로.
/// F-MKT-01 — 시즌 템플릿 기반 1회성 쿠폰.
@DataClassName('CouponRow')
class Coupons extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();

  /// 시즌 템플릿 키(christmas/valentine/rainy 등) — 자유 텍스트 아님,
  /// 기본 제공 템플릿 내에서만 선택(F-MKT-01 "현재 제공되는 기본
  /// 템플릿 내에서만").
  TextColumn get season => text()();

  /// discount / gift.
  TextColumn get benefitType => text()();
  TextColumn get discountValue => text().nullable()();

  /// total / specific_product.
  TextColumn get discountScope => text().nullable()();
  IntColumn get minOrderAmount => integer().nullable()();
  TextColumn get giftProductId => text().nullable()();

  /// '7' / '14' / '30' / 'always'.
  TextColumn get expiryDays => text()();

  /// active/upcoming/expired.
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/marketing/data_spec.md "엔티티: Campaign" 그대로.
/// F-MKT-02 — 토스 근거 없는 살롱 고유 자산(독자기능).
@DataClassName('CampaignRow')
class Campaigns extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get conditionType => text()();
  TextColumn get discountValue => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/marketing/data_spec.md "엔티티: PointPolicy" 그대로.
/// **매장당 1건만 존재**(다건 아님) — F-MKT-03.
@DataClassName('PointPolicyRow')
class PointPolicies extends Table {
  TextColumn get id => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  RealColumn get earnRate => real().withDefault(const Constant(0))();
  IntColumn get minUsablePoints => integer().withDefault(const Constant(0))();

  /// all / exclude_some.
  TextColumn get earnScope => text().withDefault(const Constant('all'))();
  TextColumn get useScope => text().withDefault(const Constant('all'))();

  /// 보너스(プレシャ参考) — 토스 기본화면에 없는 보조정보.
  RealColumn get pointValueYen => real().withDefault(const Constant(1))();
  IntColumn get expiryDays => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
