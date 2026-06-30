import '../domain/discount_type.dart';
import '../domain/promotion_rule.dart';

/// `PromotionEngine.calcDiscount()`의 반환형 — 적용 여부/금액/근거
/// Rule의 id를 함께 담는다. 적용된 Rule이 없으면 [PromotionResult.none]
/// 을 그대로 쓴다.
class PromotionResult {
  const PromotionResult({
    required this.applied,
    required this.discountAmount,
    required this.appliedRuleId,
  });

  static const none = PromotionResult(applied: false, discountAmount: 0, appliedRuleId: null);

  final bool applied;
  final int discountAmount;
  final int? appliedRuleId;
}

/// A-11 Promotion Engine MVP. **순수 계산 클래스** — Repository를
/// 모르고, Drift를 모르고, SessionRepository를 모른다(ADR-001 원칙을
/// Pricing Engine과 동일하게 적용). `PaymentSessionItem` 저장은 하지
/// 않는다 — 그건 호출자가 이 결과를 `addItem()`에 전달해야 할 일이다.
class PromotionEngine {
  const PromotionEngine();

  /// 1. 기간 외(`startAt`/`endAt` 기준, [at] 시점) Rule 제외
  /// 2. `status != 'active'`인 Rule 제외
  /// 3. 남은 후보 중 `priority`가 가장 작은(우선순위가 가장 높은)것 1개 선택
  /// 4. `discountType`(`flat`/`rate`)에 따라 할인액 계산
  /// 5. [PromotionResult] 반환
  ///
  /// 할인 중첩(여러 Rule 동시 적용)은 A-11 MVP 범위 밖이다 — 항상
  /// 최우선 Rule 1개만 적용한다(`docs/A11_IMPLEMENTATION_PLAN.md`
  /// PART 6).
  PromotionResult calcDiscount({
    required int subtotal,
    required DateTime at,
    required List<PromotionRule> rules,
  }) {
    final candidates = rules
        .where((r) => r.status == 'active' && _isWithinValidityWindow(at, r))
        .toList()
      ..sort((a, b) {
        final byPriority = a.priority.compareTo(b.priority);
        return byPriority != 0 ? byPriority : a.id.compareTo(b.id);
      });

    if (candidates.isEmpty) return PromotionResult.none;

    final rule = candidates.first;
    final rawDiscount = rule.discountType == DiscountType.flat
        ? rule.amount
        : (subtotal * rule.amount / 100).floor();

    final maxDiscount = subtotal > 0 ? subtotal : 0;
    final discountAmount = rawDiscount.clamp(0, maxDiscount);

    if (discountAmount <= 0) return PromotionResult.none;

    return PromotionResult(
      applied: true,
      discountAmount: discountAmount,
      appliedRuleId: rule.id,
    );
  }

  /// [at]이 [rule]의 유효 기간(`startAt`~`endAt`) 안에 있는지 판정 —
  /// `Expired` 여부를 저장된 상태가 아니라 이 시점에 즉석으로 계산한다
  /// (ADR-004). `startAt`/`endAt`이 null이면 그 경계가 없다는 뜻이다.
  bool _isWithinValidityWindow(DateTime at, PromotionRule rule) {
    if (rule.startAt != null && at.isBefore(rule.startAt!)) return false;
    if (rule.endAt != null && !at.isBefore(rule.endAt!)) return false;
    return true;
  }
}
