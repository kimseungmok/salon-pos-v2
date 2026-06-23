import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';

const _uuid = Uuid();
const _singlePointPolicyId = 'singleton';

/// design/spec/v3/marketing/feature_spec.md F-MKT-01/02/03 그대로.
class MarketingRepository {
  MarketingRepository(this._db);

  final AppDatabase _db;

  static const _validSeasons = {
    'whiteday', 'sakura', 'graduation', 'snow', 'valentine', 'birthday',
    'christmas', 'newyear', 'kidsday', 'parentsday', 'exam', 'halloween',
    'rainy', 'summer',
  };
  static const _validExpiryDays = {'7', '14', '30', 'always'};

  // ── F-MKT-01: 쿠폰 ────────────────────────────────────────────────

  Stream<List<CouponRow>> watchCoupons() {
    return (_db.select(_db.coupons)
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
        .watch();
  }

  Future<CouponRow> createCoupon({
    required String season,
    required String benefitType,
    String? discountValue,
    String? discountScope,
    int? minOrderAmount,
    String? giftProductId,
    required String expiryDays,
  }) async {
    if (!_validSeasons.contains(season)) {
      throw const ValidationException('現在提供されている季節テンプレート内から選択してください。');
    }
    if (!{'discount', 'gift'}.contains(benefitType)) {
      throw const ValidationException('クーポン特典の値が正しくありません。');
    }
    if (benefitType == 'discount' && (discountValue == null || discountValue.trim().isEmpty)) {
      throw const ValidationException('割引額を入力してください。');
    }
    if (benefitType == 'gift' && (giftProductId == null || giftProductId.isEmpty)) {
      throw const ValidationException('プレゼント商品を選択してください。');
    }
    if (!_validExpiryDays.contains(expiryDays)) {
      throw const ValidationException('クーポン有効期間の値が正しくありません。');
    }

    try {
      final id = _uuid.v4();
      final now = DateTime.now();
      final code = '${season.toUpperCase()}${(now.millisecondsSinceEpoch % 1000).toString().padLeft(3, '0')}';
      await _db.into(_db.coupons).insert(
            CouponsCompanion.insert(
              id: id,
              code: code,
              season: season,
              benefitType: benefitType,
              discountValue: Value(discountValue),
              discountScope: Value(discountScope),
              minOrderAmount: Value(minOrderAmount),
              giftProductId: Value(giftProductId),
              expiryDays: expiryDays,
              createdAt: now,
            ),
          );
      return CouponRow(
        id: id,
        code: code,
        season: season,
        benefitType: benefitType,
        discountValue: discountValue,
        discountScope: discountScope,
        minOrderAmount: minOrderAmount,
        giftProductId: giftProductId,
        expiryDays: expiryDays,
        status: 'active',
        createdAt: now,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// 만료 여부 동적 판정(저장하지 않음 — customer 모듈의 groupOf()와
  /// 동일한 원칙: 파생값은 항상 조회 시점에 계산).
  bool isCouponExpired(CouponRow coupon) {
    if (coupon.expiryDays == 'always') return false;
    final days = int.parse(coupon.expiryDays);
    return DateTime.now().isAfter(coupon.createdAt.add(Duration(days: days)));
  }

  // ── F-MKT-02: 캠페인(독자기능) ───────────────────────────────────

  Stream<List<CampaignRow>> watchCampaigns() => _db.select(_db.campaigns).watch();

  Future<CampaignRow> createCampaign({
    required String name,
    required String conditionType,
    required String discountValue,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('キャンペーン名を入力してください。');
    }
    try {
      final id = _uuid.v4();
      await _db.into(_db.campaigns).insert(
            CampaignsCompanion.insert(
              id: id,
              name: trimmed,
              conditionType: conditionType,
              discountValue: discountValue,
            ),
          );
      return CampaignRow(
        id: id,
        name: trimmed,
        conditionType: conditionType,
        discountValue: discountValue,
        enabled: true,
      );
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<void> toggleCampaign(String id, bool enabled) async {
    final rows = await (_db.update(_db.campaigns)..where((c) => c.id.equals(id)))
        .write(CampaignsCompanion(enabled: Value(enabled)));
    if (rows == 0) {
      throw const NotFoundException('キャンペーンが見つかりませんでした。');
    }
  }

  // ── F-MKT-03: 포인트 정책(매장당 단일 레코드) ───────────────────

  Stream<PointPolicyRow> watchPointPolicy() {
    return (_db.select(_db.pointPolicies)
          ..where((p) => p.id.equals(_singlePointPolicyId)))
        .watchSingleOrNull()
        .map((row) => row ?? _defaultPolicy());
  }

  Future<PointPolicyRow> getPointPolicy() async {
    final row = await (_db.select(_db.pointPolicies)
          ..where((p) => p.id.equals(_singlePointPolicyId)))
        .getSingleOrNull();
    return row ?? _defaultPolicy();
  }

  PointPolicyRow _defaultPolicy() => PointPolicyRow(
        id: _singlePointPolicyId,
        enabled: true,
        earnRate: 0,
        minUsablePoints: 0,
        earnScope: 'all',
        useScope: 'all',
        pointValueYen: 1,
      );

  Future<PointPolicyRow> updatePointPolicy({
    required bool enabled,
    required double earnRate,
    required int minUsablePoints,
    required String earnScope,
    required String useScope,
    double pointValueYen = 1,
    int? expiryDays,
  }) async {
    if (earnRate < 0 || earnRate > 100) {
      throw const ValidationException('付与率は0〜100の範囲で入力してください。');
    }
    if (minUsablePoints < 0) {
      throw const ValidationException('最低利用ポイントは0以上にしてください。');
    }
    if (!{'all', 'exclude_some'}.contains(earnScope) ||
        !{'all', 'exclude_some'}.contains(useScope)) {
      throw const ValidationException('対象商品の値が正しくありません。');
    }
    try {
      final companion = PointPoliciesCompanion(
        id: const Value(_singlePointPolicyId),
        enabled: Value(enabled),
        earnRate: Value(earnRate),
        minUsablePoints: Value(minUsablePoints),
        earnScope: Value(earnScope),
        useScope: Value(useScope),
        pointValueYen: Value(pointValueYen),
        expiryDays: Value(expiryDays),
      );
      await _db.into(_db.pointPolicies).insertOnConflictUpdate(companion);
      return PointPolicyRow(
        id: _singlePointPolicyId,
        enabled: enabled,
        earnRate: earnRate,
        minUsablePoints: minUsablePoints,
        earnScope: earnScope,
        useScope: useScope,
        pointValueYen: pointValueYen,
        expiryDays: expiryDays,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}
