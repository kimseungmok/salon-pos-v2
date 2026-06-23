import '../../../db/app_database.dart';

/// design/spec/v3/prepaid_pass/data_spec.md 산출 로직 그대로.

/// F-PP-01b: 사용기한 계산. expiryCustomDays는 fixedDate/custom 모두
/// "일수"로 통일 저장(prepaid_pass_tables.dart 주석 참조).
DateTime? computeExpiry(PrepaidPassMenuRow menu, DateTime purchasedAt) {
  switch (menu.expiryType) {
    case 'none':
      return null;
    case '90d':
      return purchasedAt.add(const Duration(days: 90));
    case '180d':
      return purchasedAt.add(const Duration(days: 180));
    case '1y':
      return DateTime(purchasedAt.year + 1, purchasedAt.month, purchasedAt.day);
    case '2y':
      return DateTime(purchasedAt.year + 2, purchasedAt.month, purchasedAt.day);
    case '3y':
      return DateTime(purchasedAt.year + 3, purchasedAt.month, purchasedAt.day);
    case 'fixedDate':
    case 'custom':
      return purchasedAt.add(Duration(days: menu.expiryCustomDays ?? 0));
    default:
      return null;
  }
}

/// F-PP-03: 사용 시 차감(혼합결제 — 잔액 한도까지 차감 후 나머지는
/// 다른 결제수단).
class PrepaidPaymentResult {
  const PrepaidPaymentResult({
    required this.usedFromPrepaid,
    required this.remainingToPayOtherwise,
  });

  final int usedFromPrepaid;
  final int remainingToPayOtherwise;
}

PrepaidPaymentResult applyPrepaidAmountPayment(int available, int requestedAmount) {
  final used = available < requestedAmount ? available : requestedAmount;
  return PrepaidPaymentResult(
    usedFromPrepaid: used,
    remainingToPayOtherwise: requestedAmount - used,
  );
}

/// 횟수권은 1회 시술 = 1회 차감(부분차감 없음). 잔여횟수가 있으면 차감
/// 가능(true), 없으면 false(다른 결제수단으로 전액 결제해야 함).
bool canUseCountPass(int remainingCount) => remainingCount > 0;
