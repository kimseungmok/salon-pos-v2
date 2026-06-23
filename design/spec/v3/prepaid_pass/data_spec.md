# プリペイド券 (선불권) — 데이터 정의서 [신규]

## 엔티티: PrepaidPassMenu (선불권 메뉴 — 매장이 만든 "상품")

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| type | enum(`amount`, `count`) | F-PP-01. 생성 후 변경 불가 |
| name | string | 예: "10万円チャージ券" |
| linkedProductId | string \| null (FK → Product) | `count` 타입만 필수, 1개만. `amount` 타입은 null |
| price | integer | 결제가격(¥) |
| allowCustomPrice | boolean | "매번 직접 입력할게요" 체크 여부 |
| countPerPurchase | integer \| null | `count` 타입만. 1회 구매시 제공 횟수 |
| bonusType | enum(`none`, `bonus`) | F-PP-01a |
| bonusAmount | integer \| null | bonusType=bonus, type=amount일 때 추가 충전액 |
| bonusCount | integer \| null | bonusType=bonus, type=count일 때 추가 횟수 |
| expiryType | enum(`none`, `90d`, `180d`, `1y`, `2y`, `3y`, `fixedDate`, `custom`) | F-PP-01b |
| expiryValue | date \| integer \| null | fixedDate면 date, custom이면 일수(integer) |
| status | enum(`active`, `disabled`) | 무효화된 메뉴는 신규 판매 불가하나 기존 보유자 사용은 계속 가능 |
| createdAt | datetime | |

## 엔티티: PrepaidPassBalance (고객별 보유 잔액)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| customerId | string (FK → Customer) | |
| menuId | string (FK → PrepaidPassMenu) | |
| remainingAmount | integer \| null | type=amount일 때 잔액(¥) |
| remainingCount | integer \| null | type=count일 때 남은 횟수 |
| purchasedAt | datetime | 충전(구매) 시점 — 유효기간 계산 기준일 |
| expiresAt | datetime \| null | purchasedAt + menu.expiryType 계산 결과. null이면 무기한 |
| status | enum(`active`, `expired`, `voided`) | `voided` = 결제취소로 소멸(F-PP-02 환불 규칙) |

## 엔티티: PrepaidPassTransaction (충전/사용 거래 이력)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| balanceId | string (FK → PrepaidPassBalance) | |
| type | enum(`charge`, `use`, `refund`) | |
| amount | integer \| null | 금액형 변동분(¥), 음수 가능(use 시 음수) |
| count | integer \| null | 횟수형 변동분, 음수 가능 |
| relatedOrderId | string \| null (FK → Order) | 결제와 연결된 주문 ID |
| createdAt | datetime | |

## 산출 로직: 만료일 계산

```ts
function computeExpiry(menu: PrepaidPassMenu, purchasedAt: Date): Date | null {
  switch (menu.expiryType) {
    case 'none': return null;
    case '90d': return addDays(purchasedAt, 90);
    case '180d': return addDays(purchasedAt, 180);
    case '1y': return addYears(purchasedAt, 1);
    case '2y': return addYears(purchasedAt, 2);
    case '3y': return addYears(purchasedAt, 3);
    case 'fixedDate': return menu.expiryValue as Date;
    case 'custom': return addDays(purchasedAt, menu.expiryValue as number);
  }
}
```

## 산출 로직: 사용 시 차감 (F-PP-03 혼합결제 규칙)

```ts
function applyPrepaidPayment(balance: PrepaidPassBalance, requestedAmount: number) {
  const available = balance.remainingAmount ?? 0;
  const usedFromPrepaid = Math.min(available, requestedAmount);
  const remainingToPayOtherwise = requestedAmount - usedFromPrepaid;

  balance.remainingAmount = available - usedFromPrepaid;
  // PrepaidPassTransaction(type: 'use', amount: -usedFromPrepaid) 기록

  return { usedFromPrepaid, remainingToPayOtherwise };
}
```

## 산출 로직: 결제 취소(환불) 시 (F-PP-02)

```ts
function voidChargeTransaction(balance: PrepaidPassBalance, tx: PrepaidPassTransaction) {
  // 충전 거래를 취소하면 해당 충전분 전체를 잔액에서 차감하고 balance를 voided 처리
  // "다시 담기" 불가 — 신규 충전을 다시 만들어야 함
  balance.status = 'voided';
  balance.remainingAmount = 0;
  balance.remainingCount = 0;
  // PrepaidPassTransaction(type: 'refund', amount: -tx.amount) 기록
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 27 プリペイド券管理 | PrepaidPassMenu 전체 목록 | PrepaidPassMenu 생성/수정/비활성화 |
| 28 모드A(チャージ) | PrepaidPassMenu 목록, Customer | PrepaidPassBalance 생성, PrepaidPassTransaction(`charge`) 생성 |
| 28 모드B(使用) | 해당 Customer의 PrepaidPassBalance 목록 | PrepaidPassBalance 갱신, PrepaidPassTransaction(`use`) 생성 |
| 10 顧客詳細 | 해당 Customer의 PrepaidPassBalance 합계 | (없음, 28 모달로 위임) |
