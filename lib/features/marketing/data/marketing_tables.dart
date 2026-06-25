import 'package:drift/drift.dart';

/// design/spec/v3/marketing/data_spec.md "엔티티: Coupon" 그대로.
/// F-MKT-01 — 시즌 템플릿 기반 1회성 쿠폰.
///
/// A-9(docs/ID_CONVENTION.md): PK/FK는 INTEGER AUTOINCREMENT — UUID 금지.
@DataClassName('CouponRow')
class Coupons extends Table {
  IntColumn get id => integer().autoIncrement()();
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
  IntColumn get giftProductId => integer().nullable()();

  /// '7' / '14' / '30' / 'always'.
  TextColumn get expiryDays => text()();

  /// active/upcoming/expired.
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get createdAt => dateTime()();
}

/// design/spec/v3/marketing/data_spec.md "엔티티: Campaign" 그대로.
/// F-MKT-02 — 토스 근거 없는 살롱 고유 자산(독자기능).
@DataClassName('CampaignRow')
class Campaigns extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get conditionType => text()();
  TextColumn get discountValue => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

/// design/spec/v3/marketing/data_spec.md "엔티티: PointPolicy" 그대로.
/// **매장당 1건만 존재**(다건 아님) — F-MKT-03. id는 항상 고정값(1)으로
/// upsert한다(marketing_repository.dart `_singlePointPolicyId` 참조).
@DataClassName('PointPolicyRow')
class PointPolicies extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  RealColumn get earnRate => real().withDefault(const Constant(0))();
  IntColumn get minUsablePoints => integer().withDefault(const Constant(0))();

  /// all / exclude_some.
  TextColumn get earnScope => text().withDefault(const Constant('all'))();
  TextColumn get useScope => text().withDefault(const Constant('all'))();

  /// 보너스(プレシャ参考) — 토스 기본화면에 없는 보조정보.
  RealColumn get pointValueYen => real().withDefault(const Constant(1))();
  IntColumn get expiryDays => integer().nullable()();
}
