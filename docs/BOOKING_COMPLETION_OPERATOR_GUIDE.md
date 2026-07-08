# Booking 완료 → Session 생성 흐름 운영자 가이드

> **목적**: 예약 완료(来店完了) 처리 흐름을 운영자 관점에서 기술한다. 새 설계 없음 — A-25/A-29 구현과 `ARCHITECTURE_SUMMARY.md` §5에서 확인된 내용만 기록한다.
> **근거 문서**: `docs/ARCHITECTURE_SUMMARY.md` §5, `docs/A28_DESIGN_DEFINITION.md` D-6, `docs/A30_IMPLEMENTATION_VERIFICATION.md`
> 작성일: 2026-07-08

---

## 1. UI 진입 경로 (A-29 구현 결과)

```
待機 탭(ウェイティング管理)
  └─ AppBar "予約完了" 버튼
       └─ /waiting/bookings (BookingListScreen)
            └─ 各予約行の "来店完了" ボタン
                 └─ BookingCompletionCaller.complete() 호출
```

| UI 위치 | 파일 | 확인 근거 |
|---|---|---|
| 待機 탭 | `lib/core/router.dart` `/waiting` 브랜치 | `router.dart:50~63` |
| 予約完了 버튼 | `lib/features/booking/screens/waiting_list_screen.dart` AppBar | `waiting_list_screen.dart:46~51` |
| BookingListScreen | `lib/features/booking/screens/booking_list_screen.dart` | `booking_list_screen.dart:18~119` |
| 来店完了 버튼 | `BookingListScreen` 각 예약 항목 trailing | `booking_list_screen.dart:113` |

---

## 2. 완료 처리 실행 순서 (BookingCompletionCaller.complete())

`ARCHITECTURE_SUMMARY.md` §5에서 확인된 5단계 흐름:

```
BookingCompletionCaller.complete({booking, businessType})
  │
  ├─ 1. completeBooking(booking.id)
  │       예약 상태 → 'completed'
  │       [BookingRepository]
  │
  ├─ 2. createSession(businessType, staffId, customerId, roomId=null)
  │       전표(PaymentSession) 생성
  │       [SessionRepository]
  │
  ├─ 3. watchProducts().first
  │       전체 상품 목록 1회 조회
  │       [ProductRepository]
  │
  ├─ 4. productIdsCsv 파싱 + 메모리 매칭
  │       예약에 연결된 상품 ID 추출
  │       매칭 실패한 ID는 조용히 건너뜀(현재 동작)
  │
  └─ 5. addItem() × N (상품당 1회)
          itemType='service', refType='booking'
          itemName=Product.name(스냅샷), unitPrice=Product.price(스냅샷)
          [SessionRepository]
```

---

## 3. 처리 대상 예약 조건

| 조건 | 내용 | 근거 코드 |
|---|---|---|
| 표시 조건 | `status == 'confirmed'` 인 예약만 목록에 표시 | `booking_list_screen.dart:33` |
| 완료 가능 조건 | `completeBooking()` 내부: 미존재/이미 완료/취소·노쇼 상태면 예외 throw | `booking_repository.dart:308~317` |
| 정렬 기준 | `startAt` 오름차순 | `booking_list_screen.dart:35` |

---

## 4. 미확인 항목 (A-30 Verification Gap 유지)

| 항목 | 상태 | 근거 |
|---|---|---|
| `businessType` 결정 기준 | Change Control(CC-2) 상태 유지 | A-29 PART 7: `'salon'` 사용. `A28_5_INTERFACE_CONTRACT_DEFINITION.md` PART 5: 미확인으로 기재 |
| 미매칭 상품 운영 대응 | 미구현(D-9 보류) | `booking_completion_caller.dart:57~59`: 현재 silent skip |
