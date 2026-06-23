# 在庫管理 — 데이터 정의서

## 엔티티: InventoryItem

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| name | string | 예: "カラー剤（ブラウン系）" |
| category | string | 예: "カラー剤" |
| quantity | integer | 현재 수량 |
| threshold | integer | F-INV-01 상태 판정 기준값 |
| unit | string \| null | 표시용(본/個 등, 선택) |

## 엔티티: InventoryLog (변동 이력, F-INV-02)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| itemId | string (FK → InventoryItem) | |
| delta | integer | 변동량(음수=차감, 양수=입고) |
| reason | enum(`stock_in`,`use`,`disposal`,`adjustment`) | 入荷/使用/廃棄/調整 |
| staffId | string (FK → Staff) | |
| createdAt | datetime | |

## 산출 로직: 상태 판정

```ts
function statusOf(item: InventoryItem): '正常' | '不足' | '品切れ' {
  if (item.quantity === 0) return '品切れ';
  if (item.quantity < item.threshold) return '不足';
  return '正常';
}
```

## 산출 로직: 수량 조정 (F-INV-01, 자동 로그 기록)

```ts
function adjustQuantity(item: InventoryItem, delta: number, reason: InventoryLog['reason'], staffId: string) {
  item.quantity = Math.max(0, item.quantity + delta);
  // InventoryLog 자동 생성(F-INV-02)
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 14 在庫現況 | InventoryItem | InventoryItem.quantity 조정 → InventoryLog 자동 생성 |
| 15 在庫変動履歴 | InventoryLog | (없음, 조회 전용) |

> **F-PROD/F-PAY와 연결하지 않음**(F-INV-00) — `Product`나 `OrderItem`에서 `InventoryItem`을 참조하는 FK는 정의하지 않는다. 판매 시 자동 차감이 필요해지면 다음 차수에서 별도로 `Product.linkedInventoryItemId` 같은 필드를 신설해 명시적으로 정의할 것.
