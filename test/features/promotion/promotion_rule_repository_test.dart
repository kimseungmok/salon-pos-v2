import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/promotion/data/promotion_rule_repository.dart';

void main() {
  late AppDatabase db;
  late PromotionRuleRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = PromotionRuleRepository(db);
  });

  tearDown(() => db.close());

  group('addRule', () {
    test('기본값으로 생성하면 status는 draft(ADR-004)', () async {
      final rule = await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500);
      expect(rule.status, 'draft');
      expect(rule.ruleType, 'discount');
    });

    test('정률 할인도 생성 가능', () async {
      final rule = await repo.addRule(businessType: 'izakaya', discountType: 'rate', amount: 10);
      expect(rule.discountType, 'rate');
      expect(rule.amount, 10);
    });

    test('잘못된 businessType → ValidationException', () async {
      expect(
        () => repo.addRule(businessType: 'unknown', discountType: 'flat', amount: 500),
        throwsA(isA<ValidationException>()),
      );
    });

    test('잘못된 discountType → ValidationException', () async {
      expect(
        () => repo.addRule(businessType: 'salon', discountType: 'percent', amount: 500),
        throwsA(isA<ValidationException>()),
      );
    });

    test('음수 amount → ValidationException', () async {
      expect(
        () => repo.addRule(businessType: 'salon', discountType: 'flat', amount: -1),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('getRules', () {
    test('status 기본값(active)으로 조회 — draft는 제외', () async {
      await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500); // draft
      final rules = await repo.getRules(businessType: 'salon');
      expect(rules, isEmpty);
    });

    test('updateRule로 active 전환 후에는 조회된다', () async {
      final rule = await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500);
      await repo.updateRule(id: rule.id, status: 'active');
      final rules = await repo.getRules(businessType: 'salon');
      expect(rules, hasLength(1));
      expect(rules.single.status, 'active');
    });

    test('status: null이면 모든 상태 포함', () async {
      await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500); // draft
      final rules = await repo.getRules(businessType: 'salon', status: null);
      expect(rules, hasLength(1));
    });

    test('shopId로 지점별 규칙이 격리된다', () async {
      await repo.addRule(shopId: 1, businessType: 'salon', discountType: 'flat', amount: 100, status: 'active');
      await repo.addRule(shopId: 2, businessType: 'salon', discountType: 'flat', amount: 999, status: 'active');

      final shop1 = await repo.getRules(businessType: 'salon', shopId: 1);
      final shop2 = await repo.getRules(businessType: 'salon', shopId: 2);

      expect(shop1, hasLength(1));
      expect(shop1.single.amount, 100);
      expect(shop2, hasLength(1));
      expect(shop2.single.amount, 999);
    });

    test('priority ASC, id ASC 명시적 정렬 — 동률이면 id 순서(A-10 M1 재발 방지)', () async {
      final first = await repo.addRule(
        businessType: 'salon', discountType: 'flat', amount: 100, priority: 5, status: 'active',
      );
      await repo.addRule(
        businessType: 'salon', discountType: 'flat', amount: 200, priority: 5, status: 'active',
      );

      final rules = await repo.getRules(businessType: 'salon');
      expect(rules.first.id, first.id);
    });

    test('startAt/endAt에 의한 필터링은 하지 않는다(Engine 책임, ADR-004)', () async {
      final past = DateTime(2000, 1, 1);
      await repo.addRule(
        businessType: 'salon',
        discountType: 'flat',
        amount: 500,
        status: 'active',
        endAt: past, // 이미 지난 기간이어도
      );
      final rules = await repo.getRules(businessType: 'salon');
      expect(rules, hasLength(1)); // Repository는 그대로 반환한다 — Expired 판정을 하지 않음
    });
  });

  group('updateRule', () {
    test('부분 업데이트 — 넘기지 않은 필드는 유지', () async {
      final rule = await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500, priority: 0);
      final updated = await repo.updateRule(id: rule.id, priority: 9);
      expect(updated.priority, 9);
      expect(updated.amount, 500); // 유지됨
    });

    test('존재하지 않는 규칙 → NotFoundException', () async {
      expect(
        () => repo.updateRule(id: 999999, priority: 1),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('잘못된 status로 업데이트 → ValidationException', () async {
      final rule = await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500);
      expect(
        () => repo.updateRule(id: rule.id, status: 'expired'), // DB에 저장되는 값이 아님(ADR-004)
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('deactivateRule', () {
    test('정상 비활성화', () async {
      final rule = await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500, status: 'active');
      await repo.deactivateRule(rule.id);
      final rules = await repo.getRules(businessType: 'salon', status: null);
      expect(rules.single.status, 'disabled');
    });

    test('이미 비활성화된 규칙에 재호출해도 예외 없이 멱등', () async {
      final rule = await repo.addRule(businessType: 'salon', discountType: 'flat', amount: 500, status: 'active');
      await repo.deactivateRule(rule.id);
      await repo.deactivateRule(rule.id);
      final rules = await repo.getRules(businessType: 'salon', status: null);
      expect(rules.single.status, 'disabled');
    });

    test('존재하지 않는 규칙 → NotFoundException', () async {
      expect(
        () => repo.deactivateRule(999999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
