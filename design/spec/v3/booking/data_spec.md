# 予約 (예약) — 데이터 정의서

## 엔티티: Booking (예약)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| customerId | string \| null (FK → Customer) | |
| staffId | string \| null | null = 미지정 |
| menuIds | string[] | |
| startAt | datetime | |
| endAt | datetime | 메뉴 합계 소요시간으로 자동 산출 |
| depositEnabled | boolean | F-BOOK-02a |
| depositMethod | enum(`bank_transfer`,`card`) \| null | |
| depositAmount | integer \| null | |
| depositReceived | boolean | |
| refundNote | string | 기본값: "返金は24時間以内に可能です。" |
| repeatRule | enum(`none`,`weekly`,`biweekly`,`monthly`) | F-BOOK-02 정기예약 |
| memo | string \| null | |
| requiresApproval | boolean | |
| status | enum(`confirmed`,`completed`,`noshow`,`cancelled`) | F-CUST-01의 VisitRecord 생성 트리거(status=completed 시) |

## 엔티티: WaitingEntry (웨이팅, F-BOOK-03 — 토스 근거 없음)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| customerName | string | 비회원도 허용(이름만) |
| phone | string \| null | |
| menuIds | string[] | |
| preferredStaffId | string \| null | |
| checkInAt | datetime | |
| order | integer | 수동 순서변경 가능 |
| status | enum(`waiting`,`called`,`seated`,`cancelled`) | |

## 산출 로직: 예약 종료시각

```ts
function computeEndAt(startAt: Date, menuIds: string[], menus: Menu[]): Date {
  const totalMinutes = menuIds.reduce((sum, id) => sum + menus.find(m => m.id === id)!.durationMin, 0);
  return addMinutes(startAt, totalMinutes);
}
```

## 산출 로직: 대기시간 경과 색상 (F-BOOK-03)

```ts
function waitColor(checkInAt: Date, now: Date): 'gray' | 'orange' | 'red' {
  const minutes = diffInMinutes(now, checkInAt);
  if (minutes < 10) return 'gray';
  if (minutes < 20) return 'orange';
  return 'red';
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 06 予約カレンダー | Booking(기간 필터), Customer(groupOf 결과) | Booking.status 변경(노쇼 처리 등) |
| 07 予約登録フォーム | Customer, Menu, Staff(가용여부) | Booking 생성/수정 |
| 08 ウェイティング管理 | WaitingEntry | WaitingEntry 생성/순서변경/상태변경 |
