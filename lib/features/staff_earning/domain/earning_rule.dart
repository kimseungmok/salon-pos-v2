/// A-12 Staff Earning Engine MVP(ADR-006: 할인 전 금액 기준).
/// `PricingRule`/`PromotionRule`과 달리 DB 테이블이 없다 — A-12 MVP는
/// 직원 수당 비율을 정책으로 저장/조회하지 않는다(범위 밖,
/// `docs/A12_STAFF_EARNING_ARCHITECTURE.md` PART 6). [rate]는 항상
/// 100(%) 기본값으로 호출되어, 기존 `addItem()` 즉시생성 동작(품목
/// `amount`를 그대로 수익으로 인정)과 결과적으로 동일한 값을 만든다.
class EarningRule {
  const EarningRule({this.rate = 100});

  /// 수당 비율(%, 정수). 100이면 품목 금액 전액이 그대로 수익이 된다.
  final int rate;
}
