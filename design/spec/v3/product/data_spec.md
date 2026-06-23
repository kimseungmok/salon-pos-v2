# 商品・カテゴリ — 데이터 정의서

## 엔티티: Category

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| name | string | |
| color | string (hex) | **F-PROD-02 — 카테고리당 고정 1색**. 02(注文) 타일 배경색의 단일 소스 |
| kioskVisible | boolean | |
| sortOrder | integer | |

## 엔티티: Product

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| name | string | |
| categoryId | string (FK → Category) | 단일 소속(F-PROD-01) |
| price | integer | |
| allowCustomPrice | boolean | F-PROD-03 |
| kioskVisible | boolean | |
| optionGroupIds | string[] | 다중선택 |
| durationMin | integer \| null | 시술시간(F-BOOK-02 종료시각 산출에 사용) |

## 엔티티: OptionGroup / Option

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string | |
| name | string | 예: "長さ", "コース追加" |
| choices | { label: string, priceDelta: integer }[] | |

## 산출 로직: 타일 배경색 (F-PAY-01 연동)

```ts
function tileColorOf(product: Product, categories: Category[]): string {
  return categories.find(c => c.id === product.categoryId)!.color;
}
// 기존 v2의 TILE_COLORS 순환 인덱스 방식을 대체 — 카테고리 고정색만 사용
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 25 商品リスト | Product, Category, OptionGroup | Product 생성/수정, Category 생성 |
| 02 注文(연동) | Product, Category.color | (없음, 읽기 전용 연동) |
