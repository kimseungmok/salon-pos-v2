# スタッフ (직원) — 데이터 정의서

## 엔티티: Staff

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| name | string | |
| phone | string | |
| branchId | string (FK → Branch) | |
| role | string | **표시 전용** — POS에서 수정 불가(F-STAFF-00). 외부 통근관리시스템에서 동기화 |
| accountStatus | enum(`pending`,`connected`) \| null | 33 초대 흐름 결과. 초대 안 한 스태프는 null |
| invitedAt | datetime \| null | |

## 엔티티: Shift (시프트 1건)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| staffId | string (FK → Staff) | |
| date | date | |
| startTime | time \| null | null = 휴무 |
| endTime | time \| null | |

## 산출 로직: 담당자 가용여부 (F-BOOK-02 연동)

```ts
function staffAvailability(staffId: string, slotStart: Date, slotEnd: Date, shifts: Shift[], bookings: Booking[]): '空き' | '予約あり' | '休み' {
  const shift = shifts.find(s => s.staffId === staffId && isSameDate(s.date, slotStart));
  if (!shift || !shift.startTime) return '休み';
  const overlapping = bookings.some(b =>
    b.staffId === staffId && b.status !== 'cancelled' &&
    overlaps(b.startAt, b.endAt, slotStart, slotEnd)
  );
  return overlapping ? '予約あり' : '空き';
}
```

## 화면-데이터 매핑

| 화면 | 읽기 | 쓰기 |
|---|---|---|
| 33 招待 | Staff(accountStatus) | Staff.accountStatus 갱신, 초대 발송 트리거 |
| 11 一覧 | Staff | (없음) |
| 12 詳細 | Staff, Order(staffId 집계) | (역할/PIN은 쓰기 금지) |
| 13 シフト | Shift | Shift 생성/수정 |
