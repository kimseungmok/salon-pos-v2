/// A-12 Staff Earning Engine MVP. `StaffEarningEngine`이 Drift 생성
/// 타입(`PaymentSessionItemRow`)을 직접 참조하지 않도록 만든 순수
/// Dart 모델(POJO) — `PricingRule`/`PromotionRule`과 동일한 원칙
/// (ADR-001). `SessionRepository`가 `PaymentSessionItemRow`를 이
/// 타입으로 변환해 Engine에 넘긴다.
class EarnableItem {
  const EarnableItem({
    required this.id,
    required this.itemType,
    required this.staffId,
    required this.amount,
  });

  final int id;
  final String itemType;
  final int? staffId;
  final int amount;
}
