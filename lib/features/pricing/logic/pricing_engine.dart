import '../domain/pricing_rule.dart';
import '../domain/rule_types.dart';

/// A-10 Pricing Engine MVP. **순수 계산 클래스 — DB에 직접 접근하지
/// 않는다.** `PricingRule` 리스트를 매개변수로 받아서 계산만 한다
/// (규칙을 조회하는 책임은 `PricingRuleRepository`에 있음).
///
/// A-10 리뷰 후속: 피크 시간대는 더 이상 이 클래스의 상수가 아니다 —
/// 매칭된 `PricingRule`의 `peakStartHour`/`peakEndHour` 필드를 그대로
/// 읽어서 판정한다. **Engine은 "어떤 시간대가 피크인지"를 결정하지
/// 않고, Rule에 적힌 값을 해석만 한다** — 지점(`shopId`)/업종마다 다른
/// 피크 시간대를 둘 수 있는 건 Repository가 `shopId`로 Rule을 좁혀서
/// 넘겨주기 때문이며, Engine은 그 사실 자체를 모른다(역할 분리 유지).
class PricingEngine {
  const PricingEngine();

  /// `ruleType='time_base'`인 규칙 중 [businessType]에 매칭되는 것을
  /// `priority`가 가장 작은(우선순위가 가장 높은) 것부터 적용한다.
  /// 매칭되는 규칙이 없으면 0을 반환한다(설정 누락을 조용히 0원으로
  /// 처리 — MVP 범위에서는 예외를 던지지 않기로 결정, §A10 리뷰 Q1
  /// 후속).
  int calcTimeFee({
    required int minutes,
    required String businessType,
    required List<PricingRule> rules,
  }) {
    final rule = _bestRule(rules, businessType, RuleType.timeBase);
    if (rule == null) return 0;
    return rule.value * minutes;
  }

  /// `ruleType='peak'`인 규칙 중 [businessType]에 매칭되는 것을 찾아,
  /// 그 규칙 자신의 `peakStartHour`/`peakEndHour`로 [at]이 피크
  /// 시간대인지 판정한다(시간대는 더 이상 Engine 상수가 아니라 매칭된
  /// Rule이 들고 있는 값). 피크가 아니거나 매칭 규칙이 없으면 0.
  int calcPeakSurcharge({
    required DateTime at,
    required int baseFee,
    required String businessType,
    required List<PricingRule> rules,
  }) {
    final rule = _bestRule(rules, businessType, RuleType.peak);
    if (rule == null) return 0;
    if (!isWithinPeakWindow(at, startHour: rule.peakStartHour, endHour: rule.peakEndHour)) {
      return 0;
    }
    return (baseFee * rule.value / 100).floor();
  }

  /// [timeFee]와 [peakSurcharge]를 더한 합계. Promotion(할인)/Settlement
  /// (결제수단 검증)은 A-10 범위 밖이라 포함하지 않는다 — 단순 합산만.
  int calcTotal({
    required int timeFee,
    required int peakSurcharge,
  }) {
    return timeFee + peakSurcharge;
  }

  /// [at]의 시(hour)가 [startHour]~[endHour] 범위(끝 시각 미포함)에
  /// 속하는지 판정하는 순수 계산 유틸 — 어떤 시간대가 "피크"인지는
  /// 호출자(매칭된 Rule)가 결정하고, 이 메서드는 그 범위 안에 [at]이
  /// 있는지만 계산한다(정책 결정 없음).
  ///
  /// [startHour] > [endHour]면 자정을 넘는 구간으로 취급한다(예:
  /// 22~6시 → `hour >= 22 || hour < 6`). [startHour] == [endHour]면
  /// 항상 false(길이 0인 구간 — 설정 오류로 간주, 조용히 무시).
  bool isWithinPeakWindow(
    DateTime at, {
    required int startHour,
    required int endHour,
  }) {
    if (startHour == endHour) return false;
    if (startHour < endHour) {
      return at.hour >= startHour && at.hour < endHour;
    }
    return at.hour >= startHour || at.hour < endHour;
  }

  /// [businessType]/[ruleType]에 매칭되고 `isActive`인 규칙 중
  /// `priority`가 가장 작은 것 1개를 반환(동일 우선순위면 리스트의
  /// 먼저 나온 것 — Repository가 `priority ASC, id ASC`로 이미 정렬해
  /// 넘겨주므로 이 정렬은 방어적 차원). 매칭 규칙이 없으면 null.
  PricingRule? _bestRule(
    List<PricingRule> rules,
    String businessType,
    String ruleType,
  ) {
    final matching = rules
        .where((r) =>
            r.businessType == businessType &&
            r.ruleType == ruleType &&
            r.isActive)
        .toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
    return matching.isEmpty ? null : matching.first;
  }
}
