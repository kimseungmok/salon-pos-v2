import 'package:drift/drift.dart';

/// A-11 Promotion Engine MVP(`docs/A11_IMPLEMENTATION_PLAN.md`,
/// `docs/adr/ADR-004-promotion-rule-lifecycle.md`). `pricing_rule`과는
/// 별도 테이블 — 혼용하지 않는다(`docs/A11_PROMOTION_ENGINE_DESIGN.md`
/// §4 옵션 B 채택).
///
/// **Lifecycle(ADR-004)**: `status`는 `'draft'｜'active'｜'disabled'`
/// 3개 값만 저장한다. `'expired'`는 저장하지 않는다 — `startAt`/`endAt`
/// 을 기준으로 `PromotionEngine`이 조회/계산 시점에 즉석 판정한다(배치
/// 작업 없음).
@DataClassName('PromotionRuleRow')
class PromotionRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shopId => integer().withDefault(const Constant(1))();

  /// 'salon' | 'karaoke' | 'izakaya'.
  TextColumn get businessType => text()();

  /// MVP에서는 항상 'discount' — 향후 다른 Promotion 종류(예:
  /// 포인트 적립)가 추가될 자리만 마련(현재는 'discount' 1종만 검증).
  TextColumn get ruleType => text().withDefault(const Constant('discount'))();

  /// 'flat'(정액) | 'rate'(정률).
  TextColumn get discountType => text()();

  /// 같은 businessType 규칙이 여러 개 매칭될 때 우선순위 — 값이
  /// 작을수록 먼저 적용된다(PricingRule과 동일한 관례).
  IntColumn get priority => integer().withDefault(const Constant(0))();

  /// flat: 차감할 금액(원). rate: 할인율(%, 정수).
  IntColumn get amount => integer()();

  /// 유효 기간(둘 다 nullable — null이면 그 경계 없음). 이 두 컬럼을
  /// 기준으로 한 "지금 적용 가능한가" 판정은 Repository가 아니라
  /// PromotionEngine이 수행한다(`docs/A11_IMPLEMENTATION_PLAN.md`
  /// PART 3 — Peak Rule 처리와 동일한 선례).
  DateTimeColumn get startAt => dateTime().nullable()();
  DateTimeColumn get endAt => dateTime().nullable()();

  /// 'draft' | 'active' | 'disabled'(ADR-004, Expired는 저장하지 않음).
  TextColumn get status => text().withDefault(const Constant('draft'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
