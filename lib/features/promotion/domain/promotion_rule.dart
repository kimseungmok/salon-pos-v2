/// A-11 Promotion Engine MVP. `PromotionEngine`이 Drift 생성 타입
/// (`PromotionRuleRow`)을 직접 참조하지 않도록 만든 순수 Dart 모델
/// (POJO) — Drift/DB에 대한 의존이 전혀 없다(`PricingRule`과 동일한
/// 원칙, ADR-001). `PromotionRuleRepository`가 Drift Row를 이 타입으로
/// 변환해 반환하고, `PromotionEngine`은 이 타입만 안다.
///
/// `createdAt`/`updatedAt`은 계산에 쓰이지 않아 POJO에 포함하지 않는다
/// (감사용 컬럼은 DB Row에만 남고, Engine까지 흘러갈 필요가 없다).
class PromotionRule {
  const PromotionRule({
    required this.id,
    required this.shopId,
    required this.businessType,
    required this.ruleType,
    required this.discountType,
    required this.priority,
    required this.amount,
    required this.startAt,
    required this.endAt,
    required this.status,
  });

  final int id;
  final int shopId;
  final String businessType;
  final String ruleType;
  final String discountType;
  final int priority;
  final int amount;
  final DateTime? startAt;
  final DateTime? endAt;
  final String status;
}
