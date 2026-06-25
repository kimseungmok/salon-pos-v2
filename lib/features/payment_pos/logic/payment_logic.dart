import '../../../db/app_database.dart';

/// design/spec/v3/payment_pos/data_spec.md 산출 로직 그대로.

/// F-PAY-02a: 거스름돈 계산.
int computeChange(int received, int amount) {
  final change = received - amount;
  return change < 0 ? 0 : change;
}

/// 결제 가능 여부(받은금액이 결제금액 이상인지) — UI에서 결제버튼
/// 활성/비활성 판단에 사용.
bool canPayWithCash(int received, int amount) => received >= amount;

/// F-PAY-04: 분할결제 — 메뉴별 결제 시 선택된 아이템들의 합계.
int payByItems(List<int> selectedItemIds, List<OrderItemRow> items) {
  return items
      .where((i) => selectedItemIds.contains(i.id))
      .fold<int>(0, (sum, i) => sum + i.unitPrice * i.quantity);
}

/// F-MKT-01: 쿠폰 할인액 계산. percent는 "10%", amount는 "¥1,000" 형식.
int applyCouponDiscount(String discountValue, int orderTotal) {
  final trimmed = discountValue.trim();
  if (trimmed.endsWith('%')) {
    final pct = int.tryParse(trimmed.substring(0, trimmed.length - 1)) ?? 0;
    return (orderTotal * pct / 100).floor();
  }
  final digitsOnly = trimmed.replaceAll(RegExp(r'[^\d]'), '');
  return int.tryParse(digitsOnly) ?? 0;
}
