# マーケティング — 데이터 정의서

## 엔티티: Coupon (F-MKT-01)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| code | string | |
| season | string | 템플릿 키(예: `christmas`) |
| benefitType | enum(`discount`,`gift`) | |
| discountValue | string \| null | "10%" 또는 "¥1,000" |
| discountScope | enum(`total`,`specific_product`) \| null | |
| minOrderAmount | integer \| null | |
| giftProductId | string \| null | benefitType=gift |
| expiryDays | enum(7,14,30,`always`) | |
| status | enum(`active`,`upcoming`,`expired`) | |
| createdAt | datetime | |

## 엔티티: Campaign (F-MKT-02, 토스 근거 없음 — 살롱 고유)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string | |
| name | string | |
| conditionType | enum(`time_of_day`,`day_of_week`,`birthday_month`,`weather`,...) | |
| discountValue | string | |
| enabled | boolean | |

## 엔티티: PointPolicy (F-MKT-03, 매장당 1건 — 다건 아님)

| 필드 | 타입 | 설명 |
|---|---|---|
| enabled | boolean | 결제수단으로서 포인트 허용 여부 |
| earnRate | number | % |
| minUsablePoints | integer | |
| earnScope | enum(`all`,`exclude_some`) | |
| useScope | enum(`all`,`exclude_some`) | |
| pointValueYen | number | 보너스(프레샤 참고) |
| expiryDays | integer \| null | 보너스 |

## 산출 로직: 쿠폰 적용액 (F-MKT-01, F-PAY-02 연동)

```ts
function applyCoupon(coupon: Coupon, orderTotal: number): { discount: number } {
  if (coupon.benefitType === 'gift') return { discount: 0 }; // 증정은 별도 처리(가장 비싼 증정상품 무료)
  if (coupon.discountValue!.endsWith('%')) {
    const pct = parseInt(coupon.discountValue!);
    return { discount: Math.floor(orderTotal * pct / 100) };
  }
  return { discount: parseInt(coupon.discountValue!.replace(/[¥,]/g, '')) };
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 19 クーポン発行 | Coupon, Customer(동의여부) | Coupon 생성 |
| 20 キャンペーン管理 | Campaign | Campaign 생성/토글 |
| 21 ポイント政策 | PointPolicy | PointPolicy 갱신(매장당 단일 레코드) |
