import '../domain/earnable_item.dart';
import '../domain/earning_rule.dart';
import '../domain/staff_earning_result.dart';

/// A-12 Staff Earning Engine MVP(`docs/A12_STAFF_EARNING_ARCHITECTURE.md`,
/// `ADR-006`). **순수 계산 클래스** — Repository를 모르고, Drift를
/// 모르고, `SessionRepository`를 모른다(ADR-001 원칙을 Pricing/
/// Promotion Engine과 동일하게 적용).
///
/// **할인 전 금액 기준(ADR-006)**: 할인 품목(`itemType='discount'`)은
/// 계산 대상에서 제외한다 — 할인이 직원 수익에 전혀 영향을 주지
/// 않는다는 뜻이다. `Ledger` 저장은 하지 않는다 — 그건 호출자
/// (`SessionRepository.closeSession()`)가 이 결과를 받아 처리할 일이다.
class StaffEarningEngine {
  const StaffEarningEngine();

  /// `itemType == 'staff_fee'`이고 `staffId`가 있는 품목마다 1개씩
  /// [StaffEarningResult]를 만든다. `itemType == 'discount'`인 품목은
  /// 입력에 섞여 있어도 무시한다(방어적 — 호출자가 이미 걸러서 넘겨도
  /// Engine 스스로도 한 번 더 확인한다).
  List<StaffEarningResult> calcEarnings({
    required List<EarnableItem> items,
    EarningRule rule = const EarningRule(),
  }) {
    return items
        .where((i) => i.itemType == 'staff_fee' && i.itemType != 'discount' && i.staffId != null)
        .map((i) => _calcOne(i, rule))
        .toList();
  }

  StaffEarningResult _calcOne(EarnableItem item, EarningRule rule) {
    final totalAmount = item.amount;
    final rawEarning = (totalAmount * rule.rate / 100).floor();
    final earningAmount = rawEarning < 0 ? 0 : rawEarning;
    return StaffEarningResult(
      staffId: item.staffId!,
      sessionItemId: item.id,
      totalAmount: totalAmount,
      earningAmount: earningAmount,
      earningRate: rule.rate,
    );
  }
}
