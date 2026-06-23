# レジ金管理 (시재관리) — 데이터 정의서

## 엔티티: CashCount (개점/폐점 카운트 1건)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| type | enum(`open`, `close`) | |
| date | date | |
| branchId | string (FK → Branch) | |
| denominations | Record<denomValue, quantity> | 예: `{10000: 2, 5000: 0, 1000: 0, 500: 3, ...}` |
| totalAmount | integer | 산출값(아래 로직) |
| expectedAmount | integer | open: 전일 마감액 / close: 시작금+현금매출−환불 |
| diffAmount | integer | totalAmount − expectedAmount |
| diffReason | string \| null | F-CASH-02 폐점 시 차액 사유(v3 신규) |
| confirmedAt | datetime \| null | 確定 버튼 클릭 시각 |
| confirmedBy | string (FK → Staff) | |

## 엔티티: ClosingChecklistItem (폐점 체크리스트, F-CASH-04)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string | |
| label | string | 일본어 라벨 그대로 저장 |
| checked | boolean | |

## 산출 로직: 총액 계산

```ts
const DENOM_UNITS: Record<number, '枚' | '個'> = {
  10000: '枚', 5000: '枚', 1000: '枚',
  500: '個', 100: '個', 50: '個', 10: '個', 5: '個', 1: '個',
};

function computeTotal(denominations: Record<number, number>): number {
  return Object.entries(denominations)
    .reduce((sum, [value, qty]) => sum + Number(value) * qty, 0);
}
```

## 산출 로직: 폐점 예상액 (F-CASH-01)

```ts
function expectedCloseAmount(openAmount: number, cashSales: number, cashRefunds: number): number {
  return openAmount + cashSales - cashRefunds;
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 22 開店準備 | 전일 CashCount(type=close).totalAmount → expectedAmount, StaffCheckin(F-CASH-03) | CashCount(type=open) 생성 |
| 23 レジ締め | 당일 Order/Payment 집계(현금매출) → expectedAmount, ClosingChecklistItem | CashCount(type=close) 생성, ClosingChecklistItem.checked 갱신 |
