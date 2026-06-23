# 決済・POS — 데이터 정의서

## 엔티티: Order (주문/결제 단위)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| customerId | string \| null (FK → Customer) | 미지정 가능(워크인) |
| items | OrderItem[] | |
| totalAmount | integer | 할인/포인트/선불권 적용 전 정가 합계 |
| discountAmount | integer | F-MKT 쿠폰/할인 적용분 |
| pointsUsed | integer | |
| prepaidUsed | { balanceId: string, amount: integer }[] | F-PP-03 사용 내역 |
| payments | Payment[] | 분할결제 시 다건 |
| status | enum(`pending`, `completed`, `cancelled`, `partially_paid`) | |
| createdAt | datetime | |

## 엔티티: OrderItem

| 필드 | 타입 | 설명 |
|---|---|---|
| productId | string (FK → Product) | |
| quantity | integer | |
| unitPrice | integer | |
| staffId | string \| null | 시술 담당자(살롱 고유 — 토스 원본엔 없음, F-CUST 연동 시 VisitRecord.staffId로 매핑) |

## 엔티티: Payment (결제 1건 — 분할결제 시 Order당 N개)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| orderId | string (FK → Order) | |
| method | enum(`cash`,`card`,`paypay`,`linepay`,`bank_transfer`,`credit`,`prepaid_pass`,...) | F-PAY-02 |
| amount | integer | |
| splitType | enum(`full`,`amount`,`split_bill`,`by_item`) \| null | F-PAY-04, 분할 아니면 null |
| cashReceived | integer \| null | method=cash일 때만(F-PAY-02a) |
| cashChange | integer \| null | = cashReceived − amount |
| createdAt | datetime | |

## 산출 로직: 거스름돈 (F-PAY-02a)

```ts
function computeChange(received: number, amount: number): number {
  return Math.max(0, received - amount);
}
// received < amount 면 결제 버튼 비활성(UI 레이어에서 처리)
```

## 산출 로직: 분할결제 — 메뉴별 결제 (F-PAY-04, by_item)

```ts
function payByItems(order: Order, selectedItemIds: string[]): number {
  return order.items
    .filter(i => selectedItemIds.includes(i.id))
    .reduce((sum, i) => sum + i.unitPrice * i.quantity, 0);
}
```

## 산출 로직: 결제 취소(환불) — 원자적 처리 (F-PAY-05)

```ts
function cancelOrder(order: Order) {
  // 트랜잭션 시작
  for (const p of order.prepaidUsed) {
    voidChargeTransaction(/* balance, tx */); // prepaid_pass/data_spec.md 참조
  }
  if (order.pointsUsed > 0) {
    restorePoints(order.customerId, order.pointsUsed);
  }
  order.status = 'cancelled';
  // 트랜잭션 커밋 — 하나라도 실패하면 전체 롤백
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 02 注文 | Product, Category | Order(draft), OrderItem |
| 03 決済方法選択 | Order(draft), Customer 보유 Coupon/Point/PrepaidPassBalance | Payment 생성, Order.status 갱신 |
| 04 決済完了 | Order, Payment | 영수증 발행 로그(별도 엔티티, 범위 외) |
| 05 取引履歴 | Order, Payment | 취소 시 cancelOrder() 호출 |
