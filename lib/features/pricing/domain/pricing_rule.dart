/// A-10 리팩토링(R1): `PricingEngine`이 Drift 생성 타입(`PricingRuleRow`)을
/// 직접 참조하지 않도록 만든 순수 Dart 모델(POJO) — Drift/DB에 대한
/// 의존이 전혀 없다. `PricingRuleRepository`가 Drift Row를 이 타입으로
/// 변환해 반환하고, `PricingEngine`은 이 타입만 안다.
class PricingRule {
  const PricingRule({
    required this.id,
    required this.shopId,
    required this.businessType,
    required this.ruleType,
    required this.value,
    required this.priority,
    required this.isActive,
    required this.peakStartHour,
    required this.peakEndHour,
  });

  final int id;
  final int shopId;
  final String businessType;
  final String ruleType;
  final int value;
  final int priority;
  final bool isActive;
  final int peakStartHour;
  final int peakEndHour;
}
