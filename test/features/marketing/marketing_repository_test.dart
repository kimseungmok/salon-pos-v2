import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/marketing/data/marketing_repository.dart';

void main() {
  late AppDatabase db;
  late MarketingRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = MarketingRepository(db);
  });

  tearDown(() => db.close());

  group('createCoupon (F-MKT-01)', () {
    test('할인 쿠폰 정상 발행', () async {
      final c = await repo.createCoupon(
        season: 'christmas',
        benefitType: 'discount',
        discountValue: '10%',
        expiryDays: '30',
      );
      expect(c.season, 'christmas');
      expect(c.status, 'active');
    });

    test('기본 템플릿 외 시즌 → ValidationException', () async {
      expect(
        () => repo.createCoupon(
          season: 'invalid_season',
          benefitType: 'discount',
          discountValue: '10%',
          expiryDays: '30',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('할인인데 할인액 누락 → ValidationException', () async {
      expect(
        () => repo.createCoupon(
          season: 'rainy',
          benefitType: 'discount',
          expiryDays: '30',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('증정인데 증정상품 누락 → ValidationException', () async {
      expect(
        () => repo.createCoupon(
          season: 'rainy',
          benefitType: 'gift',
          expiryDays: '30',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('잘못된 유효기간 값 → ValidationException', () async {
      expect(
        () => repo.createCoupon(
          season: 'rainy',
          benefitType: 'discount',
          discountValue: '10%',
          expiryDays: '999',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('isCouponExpired', () {
    test('always는 절대 만료되지 않음', () async {
      final c = await repo.createCoupon(
        season: 'rainy',
        benefitType: 'discount',
        discountValue: '10%',
        expiryDays: 'always',
      );
      expect(repo.isCouponExpired(c), false);
    });

    test('생성 직후 30일 쿠폰은 아직 만료 아님', () async {
      final c = await repo.createCoupon(
        season: 'rainy',
        benefitType: 'discount',
        discountValue: '10%',
        expiryDays: '30',
      );
      expect(repo.isCouponExpired(c), false);
    });
  });

  group('createCampaign (F-MKT-02 독자기능)', () {
    test('정상 생성', () async {
      final c = await repo.createCampaign(
        name: '平日ナイトタイム割引',
        conditionType: 'time_of_day',
        discountValue: '10%',
      );
      expect(c.enabled, true);
    });

    test('이름 공백 → ValidationException', () async {
      expect(
        () => repo.createCampaign(name: '  ', conditionType: 'time_of_day', discountValue: '10%'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('toggleCampaign', () {
    test('정상 토글', () async {
      final c = await repo.createCampaign(
        name: '誕生月キャンペーン',
        conditionType: 'birthday_month',
        discountValue: '¥1,000',
      );
      await repo.toggleCampaign(c.id, false);
      final updated = await (db.select(db.campaigns)..where((t) => t.id.equals(c.id))).getSingle();
      expect(updated.enabled, false);
    });

    test('존재하지 않는 캠페인 → NotFoundException', () async {
      expect(
        () => repo.toggleCampaign('no-such-id', false),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getPointPolicy / updatePointPolicy (F-MKT-03)', () {
    test('초기값은 기본 정책', () async {
      final p = await repo.getPointPolicy();
      expect(p.earnRate, 0);
      expect(p.earnScope, 'all');
    });

    test('정상 갱신', () async {
      await repo.updatePointPolicy(
        enabled: true,
        earnRate: 5,
        minUsablePoints: 100,
        earnScope: 'all',
        useScope: 'exclude_some',
      );
      final p = await repo.getPointPolicy();
      expect(p.earnRate, 5);
      expect(p.useScope, 'exclude_some');
    });

    test('재갱신해도 단일 레코드 유지(매장당 1건)', () async {
      await repo.updatePointPolicy(
        enabled: true, earnRate: 5, minUsablePoints: 100, earnScope: 'all', useScope: 'all',
      );
      await repo.updatePointPolicy(
        enabled: false, earnRate: 8, minUsablePoints: 200, earnScope: 'all', useScope: 'all',
      );
      final all = await db.select(db.pointPolicies).get();
      expect(all.length, 1);
      expect(all.first.earnRate, 8);
    });

    test('付与率 범위 초과 → ValidationException', () async {
      expect(
        () => repo.updatePointPolicy(
          enabled: true, earnRate: 150, minUsablePoints: 100, earnScope: 'all', useScope: 'all',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('최소 사용포인트 음수 → ValidationException', () async {
      expect(
        () => repo.updatePointPolicy(
          enabled: true, earnRate: 5, minUsablePoints: -1, earnScope: 'all', useScope: 'all',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
