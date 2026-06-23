# 売上レポート — 데이터 정의서

## 집계 단위: SalesSummary (기간별 산출 — 저장 엔티티가 아니라 조회 시 Order/Payment에서 집계)

| 필드 | 산출 소스 |
|---|---|
| netSales | Σ Order.totalAmount − Σ refund(Order.status=cancelled 환불액) |
| orderCount | count(Order, status=completed) |
| refundAmount | Σ refund |
| byPaymentMethod | groupBy(Payment.method) → Σ Payment.amount |

## 산출 로직: 기간별 売上概況 (F-SALES-01)

```ts
function salesSummary(period: 'day'|'week'|'month', refDate: Date, orders: Order[], payments: Payment[]): SalesSummary {
  const range = periodRange(period, refDate); // [start, end)
  const inRange = orders.filter(o => range.includes(o.createdAt));
  const netSales = inRange.reduce((s, o) => s + o.totalAmount, 0)
                  - inRange.filter(o => o.status === 'cancelled').reduce((s, o) => s + o.totalAmount, 0);
  const orderCount = inRange.filter(o => o.status === 'completed').length;
  const refundAmount = inRange.filter(o => o.status === 'cancelled').reduce((s, o) => s + o.totalAmount, 0);
  const byPaymentMethod = groupSum(payments.filter(p => range.includes(p.createdAt)), 'method', 'amount');
  return { netSales, orderCount, refundAmount, byPaymentMethod };
}
```

## 산출 로직: 売上カレンダー 일별 숫자 (F-SALES-01)

```ts
function dailySales(date: Date, orders: Order[]): number {
  return orders
    .filter(o => isSameDate(o.createdAt, date) && o.status === 'completed')
    .reduce((s, o) => s + o.totalAmount, 0);
}
```

## 화면-데이터 매핑

| 화면 영역 | 읽기 | 비고 |
|---|---|---|
| 売上概況 | Order, Payment | F-SALES-01 |
| 顧客分析 | Order(customerId) + groupOf() | customer/data_spec.md 재사용 |
| スタッフ実績 | OrderItem.staffId 집계 | staff/data_spec.md 연동 |
| 売上カレンダー | Order(일별 groupBy) | |
