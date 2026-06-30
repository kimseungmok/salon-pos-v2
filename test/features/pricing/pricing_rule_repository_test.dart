import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/pricing/data/pricing_rule_repository.dart';

void main() {
  late AppDatabase db;
  late PricingRuleRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = PricingRuleRepository(db);
  });

  tearDown(() => db.close());

  group('addRule', () {
    test('정상 생성(time_base)', () async {
      final rule = await repo.addRule(
        businessType: 'karaoke',
        ruleType: 'time_base',
        value: 100,
      );
      expect(rule.businessType, 'karaoke');
      expect(rule.ruleType, 'time_base');
      expect(rule.value, 100);
      expect(rule.isActive, true);
    });

    test('정상 생성(peak) — 기본 피크 시간대(22~6시) 확인', () async {
      final rule = await repo.addRule(
        businessType: 'izakaya',
        ruleType: 'peak',
        value: 20,
        priority: 1,
      );
      expect(rule.ruleType, 'peak');
      expect(rule.priority, 1);
      expect(rule.peakStartHour, 22);
      expect(rule.peakEndHour, 6);
    });

    test('점심 피크처럼 커스텀 시간대로도 생성 가능(하드코딩 아님)', () async {
      final rule = await repo.addRule(
        businessType: 'izakaya',
        ruleType: 'peak',
        value: 30,
        peakStartHour: 12,
        peakEndHour: 14,
      );
      expect(rule.peakStartHour, 12);
      expect(rule.peakEndHour, 14);
    });

    test('잘못된 시간대(범위 밖) → ValidationException', () async {
      expect(
        () => repo.addRule(businessType: 'izakaya', ruleType: 'peak', value: 20, peakStartHour: 24),
        throwsA(isA<ValidationException>()),
      );
    });

    test('잘못된 businessType → ValidationException', () async {
      expect(
        () => repo.addRule(businessType: 'unknown', ruleType: 'time_base', value: 100),
        throwsA(isA<ValidationException>()),
      );
    });

    test('잘못된 ruleType → ValidationException', () async {
      expect(
        () => repo.addRule(businessType: 'salon', ruleType: 'discount_rate', value: 10),
        throwsA(isA<ValidationException>()),
      );
    });

    test('음수 value → ValidationException', () async {
      expect(
        () => repo.addRule(businessType: 'salon', ruleType: 'time_base', value: -1),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('getRules', () {
    test('businessType으로만 조회하면 time_base+peak 전부 반환', () async {
      await repo.addRule(businessType: 'karaoke', ruleType: 'time_base', value: 100);
      await repo.addRule(businessType: 'karaoke', ruleType: 'peak', value: 20);
      await repo.addRule(businessType: 'salon', ruleType: 'time_base', value: 999);

      final rules = await repo.getRules(businessType: 'karaoke');
      expect(rules, hasLength(2));
    });

    test('ruleType까지 지정하면 해당 종류만 반환', () async {
      await repo.addRule(businessType: 'karaoke', ruleType: 'time_base', value: 100);
      await repo.addRule(businessType: 'karaoke', ruleType: 'peak', value: 20);

      final rules = await repo.getRules(businessType: 'karaoke', ruleType: 'peak');
      expect(rules, hasLength(1));
      expect(rules.single.ruleType, 'peak');
    });

    test('activeOnly=true(기본값)면 비활성화된 규칙은 제외', () async {
      final rule = await repo.addRule(businessType: 'karaoke', ruleType: 'time_base', value: 100);
      await repo.deactivateRule(rule.id);

      final rules = await repo.getRules(businessType: 'karaoke');
      expect(rules, isEmpty);
    });

    test('activeOnly=false면 비활성화된 규칙도 포함', () async {
      final rule = await repo.addRule(businessType: 'karaoke', ruleType: 'time_base', value: 100);
      await repo.deactivateRule(rule.id);

      final rules = await repo.getRules(businessType: 'karaoke', activeOnly: false);
      expect(rules, hasLength(1));
    });

    test('shopId로 지점별 규칙이 격리된다(40개 이상 지점 지원 검증)', () async {
      await repo.addRule(shopId: 1, businessType: 'karaoke', ruleType: 'time_base', value: 100);
      await repo.addRule(shopId: 2, businessType: 'karaoke', ruleType: 'time_base', value: 999);

      final shop1Rules = await repo.getRules(businessType: 'karaoke', shopId: 1);
      final shop2Rules = await repo.getRules(businessType: 'karaoke', shopId: 2);

      expect(shop1Rules, hasLength(1));
      expect(shop1Rules.single.value, 100);
      expect(shop2Rules, hasLength(1));
      expect(shop2Rules.single.value, 999);
    });

    test('shopId 지정 없이 조회하면 기본값(1)이 적용된다(기존 호출부 동작 불변)', () async {
      await repo.addRule(businessType: 'salon', ruleType: 'time_base', value: 100); // shopId 기본값 1
      await repo.addRule(shopId: 2, businessType: 'salon', ruleType: 'time_base', value: 999);

      final rules = await repo.getRules(businessType: 'salon');
      expect(rules, hasLength(1));
      expect(rules.single.value, 100);
    });

    test('priority 동률이면 id가 작은(먼저 생성된) 규칙이 먼저 — 정렬이 우연이 아님', () async {
      final first = await repo.addRule(businessType: 'salon', ruleType: 'time_base', value: 100, priority: 5);
      await repo.addRule(businessType: 'salon', ruleType: 'time_base', value: 200, priority: 5);

      final rules = await repo.getRules(businessType: 'salon');
      expect(rules.first.id, first.id);
    });
  });

  group('deactivateRule', () {
    test('정상 비활성화', () async {
      final rule = await repo.addRule(businessType: 'salon', ruleType: 'time_base', value: 50);
      await repo.deactivateRule(rule.id);
      final rules = await repo.getRules(businessType: 'salon', activeOnly: false);
      expect(rules.single.isActive, false);
    });

    test('이미 비활성화된 규칙에 재호출해도 예외 없이 멱등', () async {
      final rule = await repo.addRule(businessType: 'salon', ruleType: 'time_base', value: 50);
      await repo.deactivateRule(rule.id);
      await repo.deactivateRule(rule.id); // 재호출 — 예외 없이 통과해야 함
      final rules = await repo.getRules(businessType: 'salon', activeOnly: false);
      expect(rules.single.isActive, false);
    });

    test('존재하지 않는 규칙 → NotFoundException', () async {
      expect(
        () => repo.deactivateRule(999999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
