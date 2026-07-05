# A-28: Milestone 2 Design Definition (Evidence-based)

> 이 문서는 A-26 Requirement와 A-27 Analysis에서 확인된 사실을 기반으로 Milestone 2 설계를 정의한다.
> **제약**: 설계 정의만 수행. 코드 수정 금지. 구현 금지. 새로운 Requirement 생성 금지. 추론 금지.
> **기준 자료**: `docs/README.md`, `docs/WORK_LOG.md`, `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/A26_REQUIREMENT_DEFINITION.md`, `docs/A27_REQUIREMENT_ANALYSIS.md`, `docs/ARCHITECTURE_SUMMARY.md`, `docs/DECISION_HISTORY.md`, 실제 코드, ADR
> 작성일: 2026-07-05

---

## PART 0.5 — Requirement Baseline Verification

A-27에서 확인된 Requirement 상태 재확인:

| Requirement | A-27 확인 상태 | 이번 설계 포함 여부 |
|---|---|---|
| **REQ-A26** `BookingCompletionCaller` UI 통합 검증 | 일부 확인됨 | 확인된 범위 안에서 설계 수행 |
| **REQ-A27** 회귀 테스트 재실행 및 기준선 재확정 | 일부 확인됨 | 확인된 범위 안에서 설계 수행 |
| **REQ-A28** 운영자용 흐름 문서 | 일부 확인됨 | 확인된 범위 안에서 설계 수행 |
| **REQ-M2-1** `BookingRepository.getBookingById()` 추가 | 일부 확인됨 | 확인된 범위 안에서 설계 수행 |
| **REQ-M2-2** `addItem()` 병렬화 | 일부 확인됨 | 확인된 범위 안에서 설계 수행 |
| **REQ-M2-3** 미매칭 상품 명시적 정책 | 일부 확인됨 | 확인된 범위 안에서 설계 수행 |

> 모든 Requirement가 "일부 확인됨" 상태. 미확인 Requirement 없음.
> 각 Requirement의 확인되지 않은 항목(UI 이벤트 미정, 기준선 재확정 기준 미명시 등)은 설계 근거로 사용하지 않는다.

---

## PART 1 — Design Target Inventory

| Requirement | 상태 | 설계 포함 여부 | 근거 |
|---|---|---|---|
| **REQ-A26** `BookingCompletionCaller` UI 통합 검증 | 일부 확인됨 | **포함** — 확인된 범위 안에서 | `A27_REQUIREMENT_ANALYSIS.md` PART 2: Caller 존재/DI/테스트 확인됨. Provider 미등록/화면 없음/라우트 없음 확인됨 |
| **REQ-A27** 회귀 테스트 재실행 및 기준선 재확정 | 일부 확인됨 | **포함** — 확인된 범위 안에서 | `A27_REQUIREMENT_ANALYSIS.md` PART 2: 372건 Pass 확인됨. 공식 기준선 재확정 문서 없음 확인됨 |
| **REQ-A28** 운영자용 흐름 문서 | 일부 확인됨 | **포함** — 확인된 범위 안에서 | `A27_REQUIREMENT_ANALYSIS.md` PART 2: `ARCHITECTURE_SUMMARY.md` §5 흐름 기록 존재 확인됨. 운영자 문서 없음 확인됨 |
| **REQ-M2-1** `getBookingById()` 추가 | 일부 확인됨 | **포함** — 확인된 범위 안에서 | `A27_REQUIREMENT_ANALYSIS.md` PART 2: 수정 대상 파일 확인됨. 보류 사유(A-25 계약) 확인됨 |
| **REQ-M2-2** `addItem()` 병렬화 | 일부 확인됨 | **포함** — 확인된 범위 안에서 | `A27_REQUIREMENT_ANALYSIS.md` PART 2: for loop 순차 await 확인됨. 보류 사유(A-25 계약) 확인됨 |
| **REQ-M2-3** 미매칭 상품 명시적 정책 | 일부 확인됨 | **포함** — 확인된 범위 안에서 | `A27_REQUIREMENT_ANALYSIS.md` PART 2: silent skip 패턴 확인됨. 보류 사유(A-25 계약) 확인됨 |

---

## PART 2 — Existing Design Candidate Observation

기존 코드에서 확인된 변경 후보 위치:

### REQ-A26: `BookingCompletionCaller` UI 통합 검증

| 항목 | 기존 코드에서 확인된 변경 후보 위치 | 근거 코드 | 변경 목적 |
|---|---|---|---|
| Provider 등록 위치 | `lib/features/booking/providers.dart` — `bookingRepositoryProvider`, `waitingListStreamProvider` 2개 현존 | `lib/features/booking/providers.dart:1~17` | `BookingCompletionCaller` Provider 추가 위치 후보 |
| Provider DI 구조 | `lib/features/session/providers.dart:11` `sessionRepositoryProvider`, `lib/features/product/providers.dart:13` `productRepositoryProvider` — 이미 존재하는 Provider | `lib/features/session/providers.dart:11`, `lib/features/product/providers.dart:13` | `BookingCompletionCaller` 생성자 주입 3개(`BookingRepository`, `SessionRepository`, `ProductRepository`)의 DI 의존 후보 |
| UI 화면 파일 위치 | `lib/features/booking/screens/waiting_list_screen.dart` — 현존하는 화면 파일. 같은 디렉터리 구조 | `lib/features/booking/screens/waiting_list_screen.dart` | 예약 완료 화면 파일 추가 위치 후보(디렉터리) |
| 라우트 등록 위치 | `lib/core/router.dart` `StatefulShellRoute.indexedStack` branches 배열 — 10개 branch 현존 | `lib/core/router.dart:32~83` | 예약 완료 관련 라우트 추가 위치 후보 |
| `WaitingListScreen` 내 액션 위치 | `lib/features/booking/screens/waiting_list_screen.dart` — `WaitingEntryRow`별 액션 버튼 구조 | `lib/features/booking/screens/waiting_list_screen.dart` | 예약 완료 버튼 추가 위치 후보 |

### REQ-A27: 회귀 테스트 재실행 및 기준선 재확정

| 항목 | 기존 코드에서 확인된 변경 후보 위치 | 근거 코드 | 변경 목적 |
|---|---|---|---|
| Baseline 문서 위치 | `docs/baseline/SESSION_CLOSING_BASELINE.md` — Session Closing 한정 Baseline 현존 | `docs/README.md` Architecture 섹션 | A-25 이후 회귀 Baseline 문서 추가 위치 후보(디렉터리) |
| 테스트 디렉터리 | `test/` — 현재 372건 존재 | `A27_REQUIREMENT_ANALYSIS.md` PART 9 | 회귀 테스트 재실행 대상 |

### REQ-A28: 운영자용 흐름 문서

| 항목 | 기존 코드에서 확인된 변경 후보 위치 | 근거 코드 | 변경 목적 |
|---|---|---|---|
| 기존 흐름 기록 | `docs/ARCHITECTURE_SUMMARY.md` §5 구현 흐름 요약 5단계 | `docs/ARCHITECTURE_SUMMARY.md` §5 | 운영자 문서의 기반 자료 |
| 문서 위치 | `docs/` — 운영자용 흐름 문서 파일 없음 | `docs/README.md` | 신규 운영자 문서 추가 위치 후보 |

### REQ-M2-1: `getBookingById()` 추가

| 항목 | 기존 코드에서 확인된 변경 후보 위치 | 근거 코드 | 변경 목적 |
|---|---|---|---|
| 메서드 추가 위치 | `lib/features/booking/data/booking_repository.dart` — 현재 공개 메서드 목록: `watchBookings()`, `createBooking()`, `updateBooking()`, `cancelBooking()`, `completeBooking()`, `watchWaiting()`, `addWaiting()`, `callWaiting()`, `cancelWaiting()` | `lib/features/booking/data/booking_repository.dart` | 단건 조회 메서드 추가 위치 |

### REQ-M2-2: `addItem()` 병렬화

| 항목 | 기존 코드에서 확인된 변경 후보 위치 | 근거 코드 | 변경 목적 |
|---|---|---|---|
| 변경 대상 코드 위치 | `lib/features/booking/data/booking_completion_caller.dart:51~65` — `for (final id in productIds)` 순차 await loop | `booking_completion_caller.dart:51~65` | `Future.wait()` 병렬화로 변경 위치 |

### REQ-M2-3: 미매칭 상품 명시적 정책

| 항목 | 기존 코드에서 확인된 변경 후보 위치 | 근거 코드 | 변경 목적 |
|---|---|---|---|
| 변경 대상 코드 위치 | `lib/features/booking/data/booking_completion_caller.dart:57~59` — `firstOrNull` → `if (product == null) continue;` silent skip | `booking_completion_caller.dart:57~59` | 명시적 정책(로깅/예외) 추가 위치 |

---

## PART 3 — Design Boundary

### REQ-A26: `BookingCompletionCaller` UI 통합 검증

| 항목 | 내용 |
|---|---|
| **설계 대상 범위** | `lib/features/booking/providers.dart`에 `BookingCompletionCaller` Provider 추가. `lib/features/booking/screens/`에 예약 완료 UI 화면 추가. `lib/core/router.dart`에 해당 화면 라우트 추가. `WaitingListScreen` 또는 해당 완료 화면에서 Caller 호출 연결. |
| **설계 제외 범위** | `BookingCompletionCaller` 내부 로직 변경. `BookingRepository`/`SessionRepository`/`ProductRepository` 수정. 새 Repository 생성. TOCTOU 동시성 대응(`MILESTONE_1` §7: "UI 연결 전 재평가 필요"로 명시된 항목 — 이번 설계에서 포함하지 않음). |
| **근거** | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7: "UI 연동 미구현 — A-26에서 검토". `A27_REQUIREMENT_ANALYSIS.md` PART 2: Provider 미등록, 화면 없음, 라우트 없음. `ARCHITECTURE_SUMMARY.md` §2: Repository 수정 금지 원칙. |

### REQ-A27: 회귀 테스트 재실행 및 기준선 재확정

| 항목 | 내용 |
|---|---|
| **설계 대상 범위** | 전체 테스트 재실행 및 결과 기록. `docs/baseline/` 또는 `docs/`에 A-25 이후 회귀 Baseline 문서 작성. |
| **설계 제외 범위** | 새 테스트 작성. 기존 테스트 수정. 기준선 재확정의 구체적 기준 정의(문서에 명시된 기준 없음). |
| **근거** | `PROJECT_ROADMAP.md` §Next: "A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정". `A27_REQUIREMENT_ANALYSIS.md` PART 2: 공식 기준선 재확정 문서 없음 확인. |

### REQ-A28: 운영자용 흐름 문서

| 항목 | 내용 |
|---|---|
| **설계 대상 범위** | Booking 완료 → Session 생성 흐름을 기술하는 운영자용 문서 작성(`docs/` 내 신규 파일). 기존 `ARCHITECTURE_SUMMARY.md` §5 흐름 요약을 운영자 관점으로 기술. |
| **설계 제외 범위** | UI 이벤트 정의(미확인 항목). 코드 수정. 새 기능 제안. |
| **근거** | `PROJECT_ROADMAP.md` §Next: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지 등 정리". `A27_REQUIREMENT_ANALYSIS.md` PART 4: UI 이벤트 미정 — 미확인 항목은 설계 근거 불가. `ARCHITECTURE_SUMMARY.md` §5: 구현 흐름 5단계 존재. |

### REQ-M2-1: `getBookingById()` 추가

| 항목 | 내용 |
|---|---|
| **설계 대상 범위** | `lib/features/booking/data/booking_repository.dart`에 ID 기준 단건 조회 메서드 추가. |
| **설계 제외 범위** | `BookingCompletionCaller` 내부 변경. `SessionRepository`/`ProductRepository` 수정. Caller 시그니처 변경. |
| **근거** | `MARK2_IDEAS.md` (Repository 분류): "BookingRepository에 ID 기준 단건 조회 메서드가 없어 호출자가 pre-fetch해야 한다". `A27_REQUIREMENT_ANALYSIS.md` PART 2: `booking_repository.dart` 공개 메서드 목록 확인됨. |

### REQ-M2-2: `addItem()` 병렬화

| 항목 | 내용 |
|---|---|
| **설계 대상 범위** | `lib/features/booking/data/booking_completion_caller.dart:51~65` for loop을 `Future.wait()` 병렬화로 변경. |
| **설계 제외 범위** | `addItem()` 자체 수정. 호출 순서 변경 이외의 변경. 새 메서드 추가. |
| **근거** | `MARK2_IDEAS.md` (Performance 분류): "Future.wait()로 병렬화하면 다중 상품 시 성능을 개선할 수 있다". `DECISION_HISTORY.md` A-25 항목: "병렬화는 MARK2 아이디어로 이관". `booking_completion_caller.dart:51~65`: 순차 for loop 존재 확인. |

### REQ-M2-3: 미매칭 상품 명시적 정책

| 항목 | 내용 |
|---|---|
| **설계 대상 범위** | `lib/features/booking/data/booking_completion_caller.dart:57~59` silent skip을 명시적 정책(로깅 또는 예외)으로 변경. |
| **설계 제외 범위** | `addItem()` 자체 수정. 매칭 로직 변경. 새 테이블/컬럼 추가. |
| **근거** | `MARK2_IDEAS.md` (Technical Debt 분류): "감지할 로깅/예외가 없어 운영 시 추적이 어렵다". `DECISION_HISTORY.md` A-25 항목: "새로운 로직 추가 금지 — MARK2 아이디어로 이관". `booking_completion_caller.dart:57~59`: silent skip 패턴 존재 확인. |

---

## PART 4 — Design Decision Definition

### Decision D-1: `BookingCompletionCaller` Provider 등록

| 항목 | 내용 |
|---|---|
| **설계 내용** | `lib/features/booking/providers.dart`에 `bookingCompletionCallerProvider` 추가. 의존: `bookingRepositoryProvider`(현존), `sessionRepositoryProvider`(현존, `lib/features/session/providers.dart`), `productRepositoryProvider`(현존, `lib/features/product/providers.dart`). |
| **근거 1** | **Requirement**: `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 — "UI 연동 미구현 — A-26에서 검토" |
| **근거 2** | **코드**: `lib/features/booking/providers.dart` — `BookingCompletionCaller` Provider 없음 확인. `booking_completion_caller.dart` 생성자 3개 DI 확인. |
| **근거 3** | **코드**: `lib/features/session/providers.dart:11` `sessionRepositoryProvider` 현존. `lib/features/product/providers.dart:13` `productRepositoryProvider` 현존. |

### Decision D-2: 예약 완료 UI 화면 신규 파일

| 항목 | 내용 |
|---|---|
| **설계 내용** | `lib/features/booking/screens/`에 예약 완료 UI 화면 파일 추가. `bookingCompletionCallerProvider`를 통해 `BookingCompletionCaller.complete()`를 호출. |
| **근거 1** | **Requirement**: `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 — "Booking 완료 화면/라우트 — 미구현, A-23에서 확인된 그대로 라우트 없음" |
| **근거 2** | **코드**: `lib/features/booking/screens/` — `waiting_list_screen.dart`만 존재. 완료 화면 파일 없음 확인. |

### Decision D-3: 라우트 추가

| 항목 | 내용 |
|---|---|
| **설계 내용** | `lib/core/router.dart`에 D-2의 예약 완료 화면으로 이동하는 라우트 추가. 기존 `StatefulShellRoute.indexedStack` 또는 서브라우트 구조 사용. |
| **근거 1** | **코드**: `lib/core/router.dart` — 예약 완료 관련 라우트 없음 확인. |
| **근거 2** | **Requirement**: `A26_REQUIREMENT_DEFINITION.md` PART 5 — "라우트 없음" Gap 확인. `A27_REQUIREMENT_ANALYSIS.md` PART 2 — "라우트 없음" 확인. |

### Decision D-4: `WaitingListScreen` 완료 액션 연결

| 항목 | 내용 |
|---|---|
| **설계 내용** | `WaitingListScreen` 또는 예약 완료 UI 화면에서 `bookingCompletionCallerProvider`를 watch하여 `complete()` 호출 연결. `complete()`에 필요한 `BusinessType` 값은 호출자가 외부에서 전달. |
| **근거 1** | **코드**: `booking_completion_caller.dart:35` — 시그니처 `complete({required BookingRow booking, required String businessType})`. `businessType`은 외부 주입 필수. |
| **근거 2** | **Analysis**: `A27_REQUIREMENT_ANALYSIS.md` PART 2 REQ-A26 — "`completeBooking()` UI 호출 0건" 확인. `MILESTONE_1` §7: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" 미정. |

> **주의**: `businessType` 전달 값은 UI 이벤트 및 비즈니스 맥락이 미확인 상태. D-4는 구조적 연결 위치만 정의하며, `businessType` 값 결정은 이번 설계 범위에 포함하지 않는다.

### Decision D-5: 회귀 Baseline 문서 작성

| 항목 | 내용 |
|---|---|
| **설계 내용** | REQ-A26 구현 완료 후 전체 테스트 재실행 결과를 `docs/baseline/` 또는 `docs/`에 문서로 기록. |
| **근거 1** | **Requirement**: `PROJECT_ROADMAP.md` §Next A-27 — "A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정". |
| **근거 2** | **코드/Verification**: `A27_REQUIREMENT_ANALYSIS.md` PART 2 — 공식 기준선 재확정 문서 없음 확인. 기존 `docs/baseline/SESSION_CLOSING_BASELINE.md` 현존. |

### Decision D-6: 운영자용 흐름 문서 작성

| 항목 | 내용 |
|---|---|
| **설계 내용** | `docs/`에 Booking 완료 → Session 생성 흐름을 기술하는 운영자용 문서 신규 작성. 기반 자료: `ARCHITECTURE_SUMMARY.md` §5의 5단계 흐름 요약. |
| **근거 1** | **Requirement**: `PROJECT_ROADMAP.md` §Next A-28 — "운영자용 문서(어떤 UI 이벤트가 `complete()`를 호출해야 하는지 등) 정리". |
| **근거 2** | **문서**: `ARCHITECTURE_SUMMARY.md` §5 — 구현 흐름 5단계(`completeBooking()` → `createSession()` → `watchProducts()` → CSV 파싱 → `addItem() × N`) 현존. |

### Decision D-7: `BookingRepository.getBookingById()` 추가

| 항목 | 내용 |
|---|---|
| **설계 내용** | `lib/features/booking/data/booking_repository.dart`에 `Future<BookingRow?> getBookingById(int id)` 추가(또는 동등한 단건 조회 메서드). |
| **근거 1** | **Requirement**: `MARK2_IDEAS.md` (Repository 분류) — "ID 기준 단건 조회 메서드가 없어 호출자가 pre-fetch해야 한다". |
| **근거 2** | **코드**: `booking_repository.dart` 공개 메서드 목록 — `getBookingById()` 없음 확인. 기존 `watchBookings()` Stream 기반 전체 조회만 존재. |

### Decision D-8: `addItem()` 순차 호출 → `Future.wait()` 병렬화

| 항목 | 내용 |
|---|---|
| **설계 내용** | `booking_completion_caller.dart:51~65` for loop `await` → `Future.wait(futures)` 형태로 변경. |
| **근거 1** | **Requirement**: `MARK2_IDEAS.md` (Performance 분류) — "`Future.wait()`로 병렬화하면 다중 상품 시 성능을 개선할 수 있다". |
| **근거 2** | **코드**: `booking_completion_caller.dart:51~65` — 순차 for loop await 존재 확인. **Commit/Decision**: `DECISION_HISTORY.md` A-25 항목 — "A-25 계약('parallel 금지'). 병렬화는 MARK2 아이디어로 이관." |

### Decision D-9: silent skip → 명시적 정책

| 항목 | 내용 |
|---|---|
| **설계 내용** | `booking_completion_caller.dart:57~59` `if (product == null) continue;` → 로깅 또는 예외를 포함하는 명시적 정책으로 변경. 정확한 구현 형태는 이번 설계에서 정의하지 않음(코드 레벨 결정은 구현 단계). |
| **근거 1** | **Requirement**: `MARK2_IDEAS.md` (Technical Debt 분류) — "감지할 로깅/예외가 없어 운영 시 추적이 어렵다". |
| **근거 2** | **코드**: `booking_completion_caller.dart:57~59` — silent skip 패턴 존재 확인. **Commit/Decision**: `DECISION_HISTORY.md` A-25 항목 — "A-25 계약('새로운 로직 추가 금지'). MARK2 아이디어로 이관." |

---

## PART 5 — Existing Flow Connection Observation

기존 호출 흐름 위에서 Requirement가 연결될 위치:

### REQ-A26: UI → `BookingCompletionCaller.complete()`

| 항목 | 내용 |
|---|---|
| **기존 시작 지점** | `lib/features/booking/screens/waiting_list_screen.dart` — `WaitingEntryRow` 목록 표시 화면 |
| **기존 호출 흐름** | `WaitingListScreen` → `ref.watch(waitingListStreamProvider)` → `BookingRepository.watchWaiting()` |
| **연결 후보 위치** | `WaitingListScreen` 내 각 항목의 액션 버튼 위치 → `ref.read(bookingCompletionCallerProvider)` → `complete(booking: ..., businessType: ...)` |
| **근거** | `waiting_list_screen.dart:16~17`: "UI는 다음 차수로 미룸" 주석. `booking_completion_caller.dart:35`: `complete()` 시그니처. `lib/features/booking/providers.dart`: `waitingListStreamProvider` 현존. |

### REQ-A26: Caller 내부 호출 흐름 (기존, 변경 없음)

| 항목 | 내용 |
|---|---|
| **기존 시작 지점** | `BookingCompletionCaller.complete()` |
| **기존 호출 흐름** | `complete()` → `completeBooking(booking.id)` → `createSession(...)` → `watchProducts().first` → productIdsCsv 파싱 → `addItem() × N` |
| **연결 후보 위치** | 해당 없음 — Caller 내부 흐름은 이번 설계 대상 아님 |
| **근거** | `ARCHITECTURE_SUMMARY.md` §5: 구현 흐름 5단계. `PART 3 REQ-A26 설계 제외 범위`: Caller 내부 로직 변경 제외. |

### REQ-M2-1: `getBookingById()` 호출 위치

| 항목 | 내용 |
|---|---|
| **기존 시작 지점** | UI 화면(D-2) 또는 `WaitingListScreen` |
| **기존 호출 흐름** | 현재: 호출자가 `watchBookings()` 전체 Stream에서 `BookingRow`를 pre-fetch 후 `complete(booking: ...)` 전달 |
| **연결 후보 위치** | `booking_repository.dart` 신규 메서드(`getBookingById(id)`) → 호출자가 단건 조회 가능 |
| **근거** | `MARK2_IDEAS.md` (Repository 분류): "Caller의 호출자가 Booking 엔티티를 직접 pre-fetch해서 전달해야 한다". `A27_REQUIREMENT_ANALYSIS.md` PART 2 REQ-M2-1: Caller 시그니처 `complete({required BookingRow booking, ...})` 확인. |

---

## PART 6 — Design Evidence Missing Observation

설계에 필요한 자료 중 실제 확인되지 않은 항목:

| Requirement | 미확인 항목 | 근거 |
|---|---|---|
| **REQ-A26** | `businessType` 전달 값 — 어떤 값을 사용해야 하는지 문서에 명시되지 않음 | `MILESTONE_1` §7: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" 미정. `A27_REQUIREMENT_ANALYSIS.md` PART 4: 미확인 항목으로 기재. |
| **REQ-A26** | 완료 화면의 UI 구성 상세 — 어떤 정보를 표시하는지 문서에 명시되지 않음 | `MILESTONE_1` §7: 화면 명세 없음. 관련 화면 사양 문서 미확인. |
| **REQ-A27** | 기준선 재확정의 구체적 기준 — "기준선 재확정"의 판단 기준이 문서에 명시되지 않음 | `PROJECT_ROADMAP.md` §Next A-27: 기준 기재 없음. `A27_REQUIREMENT_ANALYSIS.md` PART 4: 미확인으로 기재. |
| **REQ-A28** | 어떤 UI 이벤트가 `complete()`를 호출해야 하는지 — 운영자 문서의 핵심 내용이나 미정 | `MILESTONE_1` §8: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" 명시적으로 미정. `A27_REQUIREMENT_ANALYSIS.md` PART 4: 미확인으로 기재. |
| **REQ-M2-3** | 명시적 정책의 구체적 형태 — 로깅인지 예외(throw)인지 문서에 명시되지 않음 | `MARK2_IDEAS.md`: "로깅/예외" 두 가지 언급하나 어느 것인지 결정되지 않음. |

---

## PART 7 — Design Definition Status

| Requirement | 설계 상태 |
|---|---|
| **REQ-A26** `BookingCompletionCaller` UI 통합 검증 | 일부 정의됨 — Provider 등록(D-1), 화면 파일 위치(D-2), 라우트 추가(D-3), 호출 연결 위치(D-4) 정의됨. `businessType` 값, 화면 UI 상세 미확인으로 일부 미정. |
| **REQ-A27** 회귀 테스트 재실행 및 기준선 재확정 | 일부 정의됨 — Baseline 문서 작성 위치(D-5) 정의됨. 기준선 재확정의 구체적 기준 미확인. |
| **REQ-A28** 운영자용 흐름 문서 | 일부 정의됨 — 문서 작성 위치 및 기반 자료(D-6) 정의됨. UI 이벤트 내용 미확인으로 일부 미정. |
| **REQ-M2-1** `getBookingById()` 추가 | 정의됨 — 추가 위치(`booking_repository.dart`), 메서드 시그니처 형태(`Future<BookingRow?> getBookingById(int id)`) 정의됨(D-7). |
| **REQ-M2-2** `addItem()` 병렬화 | 정의됨 — 변경 위치(`booking_completion_caller.dart:51~65`), 변경 방향(`Future.wait()`) 정의됨(D-8). |
| **REQ-M2-3** 미매칭 상품 명시적 정책 | 일부 정의됨 — 변경 위치(`booking_completion_caller.dart:57~59`) 정의됨(D-9). 구체적 정책 형태(로깅 vs 예외) 미확인. |

---

## Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found!
```

결과: **Pass**

### flutter test

```
+372: All tests passed!
```

결과: **Pass (372건)**

코드 변경 없음. 이 문서는 순수 설계 정의 작업이다.

---

**"Milestone 2 Design Definition Established"**
