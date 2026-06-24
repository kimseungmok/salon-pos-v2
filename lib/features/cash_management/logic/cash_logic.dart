/// design/spec/v3/cash_management/data_spec.md 산출 로직 그대로.
/// F-CASH-02: 권종은 지폐(枚)/동전(個)로 구분 표시.
const Map<int, String> kDenomUnits = {
  10000: '枚',
  5000: '枚',
  1000: '枚',
  500: '個',
  100: '個',
  50: '個',
  10: '個',
  5: '個',
  1: '個',
};

int computeTotal(Map<int, int> denominations) {
  return denominations.entries.fold<int>(0, (sum, e) => sum + e.key * e.value);
}

/// F-CASH-01: 폐점 예상액 = 시작금 + 현금매출 − 환불.
int expectedCloseAmount(int openAmount, int cashSales, int cashRefunds) {
  return openAmount + cashSales - cashRefunds;
}

/// F-CASH-02: 차액(총액 − 예상액). 0이면 일치.
int computeDiff(int total, int expected) => total - expected;
