# A-32: Milestone 2 Remaining Implementation

> **목적**: A-30 Verification 및 A-31 Follow-up 결과를 기준으로, 현재 구현 가능한 Remaining Implementation만 수행한다.
> **제약**: Requirement/Design/Contract 변경 금지. 새로운 Requirement/Design 생성 금지. Change Control 해제 금지. 새로운 구현 전략 제안 금지.
> **기준 문서**: `docs/A26_REQUIREMENT_DEFINITION.md`, `docs/A27_REQUIREMENT_ANALYSIS.md`, `docs/A28_DESIGN_DEFINITION.md`, `docs/A28_5_INTERFACE_CONTRACT_DEFINITION.md`, `docs/A30_IMPLEMENTATION_VERIFICATION.md`, `docs/A31_FOLLOWUP_IMPLEMENTATION.md`, `docs/PROJECT_ROADMAP.md`, `docs/WORK_LOG.md`, 현재 코드베이스
> 작성일: 2026-07-08

---

## PART 0.5 — Remaining Implementation Verification

A-30 및 A-31 결과를 기준으로 각 Design Decision의 구현 가능 여부를 분류한다.

| Design Decision | A-30 상태 | A-31 처리 | A-32 분류 | 근거 |
|---|---|---|---|---|
| **D-1** `bookingCompletionCallerProvider` 등록 | 확인됨 | — | **구현 완료** | A-29 Commit `98defb3`. `lib/features/booking/providers.dart:22~28` |
| **D-2** `BookingListScreen` 신규 파일 | 확인됨 | — | **구현 완료** | A-29 Commit `98defb3`. `lib/features/booking/screens/booking_list_screen.dart` |
| **D-3** `/waiting/bookings` 서브라우트 추가 | 확인됨 | — | **구현 완료** | A-29 Commit `98defb3`. `lib/core/router.dart:57~60` |
| **D-4** `WaitingListScreen` 완료 액션 연결 | 일부 확인됨(CC-1) | — | **구현 완료(CC-1 유지)** | A-29 Commit `98defb3`. `waiting_list_screen.dart:46~51` 予約完了 버튼 |
| **D-5** 회귀 Baseline 문서 | 미확인 | 구현 완료 | **구현 완료** | A-31 Commit `0cebb97`. `docs/baseline/A29_REGRESSION_BASELINE.md` |
| **D-6** 운영자용 흐름 문서 | 미확인 | 구현 완료 | **구현 완료** | A-31 Commit `0cebb97`. `docs/BOOKING_COMPLETION_OPERATOR_GUIDE.md` |
| **D-7** `getBookingById()` 추가 | 확인됨 | — | **구현 완료** | A-29 Commit `98defb3`. `booking_repository.dart:331~334` |
| **D-8** `addItem()` `Future.wait()` 병렬화 | 미확인 | — | **구현 불가** | "Future.wait 전략 변경 금지" 규칙. WORK_LOG A-29: "구현 금지" 기록 |
| **D-9** silent skip → 명시적 정책 | 미확인 | — | **구현 불가** | "Logging 정책 추가 금지" 규칙. WORK_LOG A-29: "구현 금지" 기록 |

**구현 대상**: 없음 — 모든 구현 가능 항목(D-1~D-7)이 A-29/A-31에서 이미 완료됨.

---

## PART 1 — Implementation Target Inventory

| 항목 | 근거 Requirement | 근거 Design | 근거 Interface Contract | 상태 |
|---|---|---|---|---|
| `bookingCompletionCallerProvider` 등록 | REQ-A26 | D-1 | IC-1 | 구현 완료 |
| `BookingListScreen` 신규 파일 | REQ-A26 | D-2 | IC-1, IC-2 | 구현 완료 |
| `/waiting/bookings` 라우트 추가 | REQ-A26 | D-3 | — | 구현 완료 |
| `WaitingListScreen` 완료 액션 연결 | REQ-A26 | D-4 | IC-2 | 구현 완료(CC-1 유지) |
| 회귀 Baseline 문서 | REQ-A27 | D-5 | — | 구현 완료 |
| 운영자용 흐름 문서 | REQ-A28 | D-6 | — | 구현 완료 |
| `getBookingById(int id)` 추가 | REQ-M2-1 | D-7 | IC-3 | 구현 완료 |
| `addItem()` `Future.wait()` 병렬화 | REQ-M2-2 | D-8 | IC-4 | 구현 불가 |
| silent skip → 명시적 정책 | REQ-M2-3 | D-9 | IC-5 | 구현 불가 |

---

## PART 2 — Remaining Implementation

구현 대상으로 확인된 항목이 없다.

A-28 Design Decision 범위 내 구현 가능한 모든 항목(D-1~D-7)은 A-29/A-31에서 이미 구현 완료됨.

이번 작업에서 코드 변경 없음.

---

## PART 3 — Interface Contract Preservation

코드 변경이 없으므로 Interface Contract 변경이 발생하지 않는다.

현재 상태의 Contract 만족 여부(A-30 기준):

| Interface Contract | 상태 | 근거 |
|---|---|---|
| **IC-1** `bookingCompletionCallerProvider` → `Provider<BookingCompletionCaller>` | 확인됨 | A-30 PART 3 IC-1: "확인됨" |
| **IC-2** `complete({required BookingRow, required String businessType})` → `Future<void>` | 일부 확인됨 | A-30 PART 3 IC-2: `businessType: 'salon'` — CC-2 Change Control 유지 |
| **IC-3** `getBookingById(int id)` → `Future<BookingRow?>` | 확인됨 | A-30 PART 3 IC-3: "확인됨" |
| **IC-4** `complete()` 외부 계약 유지(D-8 미구현 상태) | 확인됨 | A-30 PART 3 IC-4: "확인됨(D-8 미구현 상태)" |
| **IC-5** 미매칭 상품 처리 외부 계약 | 미확인 | A-30 PART 3 IC-5: D-9 미구현으로 변경 없음 |

---

## PART 4 — Change Control Preservation

| Change Control | 현재 상태 | 근거 |
|---|---|---|
| **CC-1** `WaitingEntryRow`에 `bookingId` 없어 `WaitingListScreen` 항목에서 직접 `complete()` 호출 불가 → `BookingListScreen`에서 연결 | 유지 | A-30 PART 4: 동일 상태 확인. 코드 변경 없음 |
| **CC-2** `businessType` 값 미확인 → `'salon'` 사용 | 유지 | A-30 PART 4: 동일 상태 확인. 코드 변경 없음 |

---

## PART 5 — Remaining Items Observation

이번 작업 종료 후 남아 있는 항목:

| 항목 | 상태 | 근거 |
|---|---|---|
| D-8 `addItem()` `Future.wait()` 병렬화 | 구현 불가 | "Future.wait 전략 변경 금지" 규칙. `DECISION_HISTORY.md` A-25: "병렬화는 MARK2 아이디어로 이관" |
| D-9 silent skip → 명시적 정책 | 구현 불가 | "Logging 정책 추가 금지" 규칙. `DECISION_HISTORY.md` A-25: "새로운 로직 추가 금지 — MARK2 아이디어로 이관" |
| CC-1 `WaitingEntryRow` `bookingId` 부재 | Change Control 유지 | `booking_tables.dart:52~63`: `WaitingEntries` 테이블에 `bookingId` 컬럼 없음 |
| CC-2 `businessType` 값 결정 미문서화 | Change Control 유지 | `A28_5_INTERFACE_CONTRACT_DEFINITION.md` PART 5: "미확인"으로 기재됨 |
| IC-5 `complete()` 미매칭 상품 처리 | 미확인 | D-9 미구현으로 `booking_completion_caller.dart:57~59`: `if (product == null) continue;` silent skip 유지 |
| `BookingListScreen` 위젯/통합 테스트 | 미확인 | A-28 Design에 테스트 명시 없음. A-30 Verification Gap으로 기록됨 |

---

## PART 6 — Verification

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 12.3s)
```

| 항목 | 결과 | A-30 대비 |
|---|---|---|
| flutter analyze | **Pass** | 새로운 실패 없음 |

### flutter test

| 항목 | 결과 | A-30 대비 |
|---|---|---|
| flutter test | **Pass (372건)** | 새로운 실패 없음 |

---

**"Milestone 2 Remaining Implementation Completed"**
