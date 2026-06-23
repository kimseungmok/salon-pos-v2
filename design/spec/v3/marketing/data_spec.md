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

## 산출 로직: 포인트 적립 (F-MKT-03, 결제완료 트리거 — 교차검증 수정 2)

```ts
// payment_pos의 결제완료 처리(F-PAY-03)에서 호출된다. 적립 대상 상품 범위는
// PointPolicy.earnScope(F-MKT-03 ③)에 따라 호출 측에서 미리 필터링한 금액을 넘긴다.
function computeEarnedPoints(eligibleAmount: number, policy: PointPolicy): number {
  if (!policy.enabled) return 0;
  return Math.floor(eligibleAmount * policy.earnRate / 100);
}
```

## 산출 로직: 포인트 환원 (F-PAY-05 결제취소 시 — 교차검증 수정 2)

```ts
// payment_pos/data_spec.md의 cancelOrder()에서 호출되는 restorePoints()의 정의는 여기.
function restorePoints(customer: Customer, usedPoints: number): void {
  customer.points += usedPoints;
  // 적립되었던 포인트(이 주문으로 얻은 적립분)도 함께 회수해야 하면 별도 트랜잭션 기록 필요(향후 검토)
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 19 クーポン発行 | Coupon, Customer(동의여부) | Coupon 생성 |
| 20 キャンペーン管理 | Campaign | Campaign 생성/토글 |
| 21 ポイント政策 | PointPolicy | PointPolicy 갱신(매장당 단일 레코드) |
