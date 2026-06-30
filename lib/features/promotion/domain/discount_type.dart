/// A-11 Promotion Engine MVP. `discountType` 문자열을 한 곳에서만
/// 정의 — Repository(검증)와 Engine(분기 계산) 양쪽이 매직스트링을
/// 따로 들고 있지 않도록 의존성 없는 별도 파일로 둔다(pricing 모듈의
/// `RuleType` 패턴, ADR-001 원칙과 동일).
class DiscountType {
  DiscountType._();

  static const flat = 'flat';
  static const rate = 'rate';
  static const all = {flat, rate};
}
