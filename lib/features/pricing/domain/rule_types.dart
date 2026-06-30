/// A-10 리뷰 후속: `ruleType` 문자열을 한 곳에서만 정의 — Engine(로직
/// 계층)과 Repository(데이터 계층) 양쪽이 매직스트링을 따로 들고
/// 있지 않도록 의존성 없는 별도 파일로 둔다(Engine이 Repository를,
/// 또는 그 반대로 의존하지 않게 하기 위함 — 계층 분리 유지).
class RuleType {
  RuleType._();

  static const timeBase = 'time_base';
  static const peak = 'peak';
  static const all = {timeBase, peak};
}
