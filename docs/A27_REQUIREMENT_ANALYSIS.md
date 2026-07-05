# A-27: Milestone 2 Requirement Analysis (Evidence-based)

> 이 문서는 Milestone 2 Requirement를 기존 프로젝트 자료를 기반으로 분석(Analysis)한다.
> **제약**: 조사·문서화만 수행. 코드 수정 금지. 설계 생성 금지. 새로운 Requirement 생성 금지. 추론 금지. 인과관계 해석 금지.
> **기준 자료**: `docs/README.md`, `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/A26_REQUIREMENT_DEFINITION.md`, `docs/WORK_LOG.md`, `docs/ARCHITECTURE_SUMMARY.md`, `docs/DECISION_HISTORY.md`, 실제 코드, 실제 Commit 기록, Verification 결과
> 작성일: 2026-07-05

---

## PART 1 — Requirement Evidence Inventory

A-26에서 확인된 Requirement Candidate 각각의 Evidence:

| Requirement | Requirement 근거 | 관련 문서 | 관련 코드 | 상태 |
|---|---|---|---|---|
| **REQ-A26** `BookingCompletionCaller`가 실제 UI 호출 경로에서 정상 동작하는지 통합 검증 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7: "`BookingCompletionCaller` UI 연동 — 미구현, `completeBooking()` 호출 UI 없음 — A-26에서 검토" | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7/§8, `docs/PROJECT_ROADMAP.md` §Next | `lib/features/booking/data/booking_completion_caller.dart` | 미구현 |
| **REQ-A27** A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정 | `PROJECT_ROADMAP.md` §Next: "A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정" | `docs/PROJECT_ROADMAP.md` §Next | 미확인 | 미구현 |
| **REQ-A28** Booking 완료 → Session 생성 흐름의 운영자용 문서 작성 | `PROJECT_ROADMAP.md` §Next: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지 등 정리" | `docs/PROJECT_ROADMAP.md` §Next, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | 미확인 (문서 작업) | 미구현 |
| **REQ-M2-1** `BookingRepository.getBookingById()` 단건 조회 메서드 추가 | `docs/MARK2_IDEAS.md`: "현재 `BookingRepository`에 ID 기준 단건 조회 메서드가 없어 Caller의 호출자가 Booking 엔티티를 직접 pre-fetch해서 전달해야 한다" | `docs/MARK2_IDEAS.md` (Repository 분류) | `lib/features/booking/data/booking_repository.dart` | 미구현(보류) |
| **REQ-M2-2** `addItem()` 병렬 호출(`Future.wait()`) 지원 | `docs/MARK2_IDEAS.md`: "여러 상품에 대해 `addItem()`을 순차 `await`로 처리 중 — `Future.wait()`로 병렬화하면 다중 상품 시 성능을 개선할 수 있다" | `docs/MARK2_IDEAS.md` (Performance 분류) | `lib/features/booking/data/booking_completion_caller.dart` (for loop 부분) | 미구현(보류) |
| **REQ-M2-3** `productIdsCsv` 파싱 미매칭 상품에 대한 명시적 정책 정의 | `docs/MARK2_IDEAS.md`: "CSV의 Product ID가 없으면 조용히 건너뛴다 — 운영 시 추적이 어렵다" | `docs/MARK2_IDEAS.md` (Technical Debt 분류) | `lib/features/booking/data/booking_completion_caller.dart:47~52` | 미구현(보류) |

---

## PART 2 — Requirement Evidence Analysis

### REQ-A26: `BookingCompletionCaller` UI 통합 검증

| 항목 | 확인 근거 | 확인된 사실 | 근거 위치 | 상태 |
|---|---|---|---|---|
| `BookingCompletionCaller` 존재 | 코드 | `lib/features/booking/data/booking_completion_caller.dart` 파일 60행 존재 | `lib/features/booking/data/booking_completion_caller.dart` | 확인됨 |
| Caller 메서드 시그니처 | 코드 | `complete({required BookingRow booking, required String businessType})` | `booking_completion_caller.dart:35` | 확인됨 |
| Caller DI 구조 | 코드 | 생성자 주입 3개: `BookingRepository`, `SessionRepository`, `ProductRepository` | `booking_completion_caller.dart:21~33` | 확인됨 |
| Provider 등록 여부 | 코드 | `lib/features/booking/providers.dart`에 `BookingCompletionCaller` Provider 없음 — `bookingRepositoryProvider`, `waitingListStreamProvider` 2개만 존재 | `lib/features/booking/providers.dart` | 확인됨(미등록) |
| UI 화면 존재 여부 | 코드 | `lib/features/booking/screens/`에 `waiting_list_screen.dart` 1개만 존재 | `lib/features/booking/screens/` 디렉터리 | 확인됨(완료 화면 없음) |
| 라우트 존재 여부 | 코드 | `lib/core/router.dart`에 예약 완료 관련 라우트 없음 | `lib/core/router.dart` | 확인됨(라우트 없음) |
| `completeBooking()` UI 호출 | 코드 | `lib/` 전체에서 `BookingCompletionCaller` 및 `completeBooking()` 호출은 `booking_completion_caller.dart` 자신 외에 없음 | `lib/` grep 결과 | 확인됨(0건) |
| `payment_repository.dart` 주석 | 코드 | `payment_repository.dart:184`: "예약경로(`completeBooking()` 연동)는 1차 범위에 포함하지 않음" | `lib/features/payment_pos/data/payment_repository.dart:184` | 확인됨 |
| MILESTONE_1 §7 기재 | 문서 | "UI 연동 — 미구현, `completeBooking()` 호출 UI 없음 — A-26에서 검토" | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 | 확인됨 |
| Booking 완료 화면 라우트 | 문서 | A-23에서 확인된 그대로 "라우트 없음" 상태 유지 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 | 확인됨 |
| A-25에서 확인된 테스트 결과 | Verification | 테스트 4건(단일 상품 / 복수 상품 / 빈 CSV / 미매칭 ID) — All Pass | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §6 | 확인됨 |

### REQ-A27: 회귀 테스트 재실행 및 기준선 재확정

| 항목 | 확인 근거 | 확인된 사실 | 근거 위치 | 상태 |
|---|---|---|---|---|
| A-25 구현 완료 시점 테스트 | Verification | 전체 테스트 373건 All tests passed | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §6 | 확인됨 |
| A-26 작업(문서화) 후 테스트 | Verification | 372건 All tests passed (A-26 작업 결과, 코드 변경 없음) | `docs/A26_REQUIREMENT_DEFINITION.md` PART 9 | 확인됨 |
| 공식 회귀 Baseline 문서 | 문서 | A-25 이후 별도 회귀 Baseline 문서 없음 — `docs/baseline/SESSION_CLOSING_BASELINE.md`는 Session Closing 한정 Baseline | `docs/README.md` Milestones 섹션 | 확인됨(재확정 문서 없음) |
| 기준선 재확정 기준 | 문서 | `PROJECT_ROADMAP.md` §Next: "기준선 재확정" — 구체적 재확정 기준이 문서에 기재되지 않음 | `docs/PROJECT_ROADMAP.md` §Next A-27 항목 | 미확인 |

### REQ-A28: 운영자용 흐름 문서

| 항목 | 확인 근거 | 확인된 사실 | 근거 위치 | 상태 |
|---|---|---|---|---|
| 운영자 문서 존재 여부 | 문서 | `docs/`에 "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" 설명하는 운영자용 문서 없음 | `docs/README.md` 전체 | 확인됨(없음) |
| UI 이벤트 명시 여부 | 문서 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" — 이벤트가 명시되지 않음 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | 확인됨(미명시) |
| Booking 완료 흐름 설명 | 문서 | `ARCHITECTURE_SUMMARY.md`: 구현 흐름 요약 있음 (`BookingCompletionCaller.complete()` → `completeBooking()` → `createSession()` → `watchProducts()` → `addItem() × N`) | `docs/ARCHITECTURE_SUMMARY.md` §5 | 확인됨(구현 흐름 있음, 운영 문서 아님) |

### REQ-M2-1: `BookingRepository.getBookingById()` 추가

| 항목 | 확인 근거 | 확인된 사실 | 근거 위치 | 상태 |
|---|---|---|---|---|
| 현재 `BookingRepository` 메서드 목록 | 코드 | `watchBookings()`, `createBooking()`, `updateBooking()`, `cancelBooking()`, `completeBooking()`, `watchWaiting()`, `addWaiting()`, `callWaiting()`, `cancelWaiting()` — `getBookingById()` 없음 | `lib/features/booking/data/booking_repository.dart` | 확인됨(없음) |
| 보류 이유 | 문서 | `MARK2_IDEAS.md`: "A-25 계약('BookingRepository 수정 금지')을 준수하기 위해 보류" | `docs/MARK2_IDEAS.md` (Repository 분류) | 확인됨 |
| A-25 계약 | 문서 | `ARCHITECTURE_SUMMARY.md` §2: "`BookingRepository`/`SessionRepository`/`ProductRepository` 중 어느 것도 수정하지 않는다. 기존 public 메서드만 사용한다." | `docs/ARCHITECTURE_SUMMARY.md` §2 | 확인됨 |
| Caller 호출자 pre-fetch 패턴 | 코드/문서 | Caller 시그니처 `complete({required BookingRow booking, ...})` — 호출자가 `BookingRow` 사전 조회 후 전달 | `booking_completion_caller.dart:35`, `docs/MARK2_IDEAS.md` | 확인됨 |

### REQ-M2-2: `addItem()` 병렬화

| 항목 | 확인 근거 | 확인된 사실 | 근거 위치 | 상태 |
|---|---|---|---|---|
| 현재 구현 패턴 | 코드 | `for (final id in productIds)` → `await _sessionRepository.addItem(...)` — 순차 await | `booking_completion_caller.dart:51~65` | 확인됨(순차) |
| 보류 이유 | 문서 | `MARK2_IDEAS.md`: "A-25 계약('순서 변경 금지', 'parallel 금지')을 준수하기 위해 보류" | `docs/MARK2_IDEAS.md` (Performance 분류) | 확인됨 |
| `DECISION_HISTORY.md` 기재 | 문서 | "A-25 계약('parallel 금지'). 예약 건당 상품 수가 소수라 성능 영향 미미. 병렬화는 MARK2 아이디어로 이관." | `docs/DECISION_HISTORY.md` A-25 항목 | 확인됨 |

### REQ-M2-3: 미매칭 상품 명시적 정책

| 항목 | 확인 근거 | 확인된 사실 | 근거 위치 | 상태 |
|---|---|---|---|---|
| 현재 구현 패턴 | 코드 | `products.where((p) => p.id == id).firstOrNull` → `if (product == null) continue;` — silent skip | `booking_completion_caller.dart:57~59` | 확인됨(silent skip) |
| 보류 이유 | 문서 | `MARK2_IDEAS.md`: "A-25 계약('새로운 로직 추가 금지')을 준수하기 위해 보류. 기존 코드(`computeEndAt()`의 `firstOrNull`)도 동일하게 조용히 무시하는 패턴이라 일관성은 유지됨." | `docs/MARK2_IDEAS.md` (Technical Debt 분류) | 확인됨 |
| `computeEndAt()` 동일 패턴 | 문서 | `ARCHITECTURE_SUMMARY.md` §6: "`computeEndAt()` 패턴 — `firstOrNull`으로 메모리 매칭" | `docs/ARCHITECTURE_SUMMARY.md` (A-24.6 관련) | 확인됨 |

---

## PART 3 — Requirement Traceability

| Requirement | Requirement 근거 | 관련 ADR | 관련 Commit | 관련 코드 |
|---|---|---|---|---|
| **REQ-A26** UI 통합 검증 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 | 미확인 (ADR 미작성) | `a12190b` (A-25 BookingCompletionCaller 구현 완료) | `lib/features/booking/data/booking_completion_caller.dart` |
| **REQ-A27** 회귀 테스트 재실행 | `PROJECT_ROADMAP.md` §Next A-27 | 미확인 | `a12190b` (A-25 이후 기준선) | 미확인 (전체 `test/` 대상) |
| **REQ-A28** 운영자용 흐름 문서 | `PROJECT_ROADMAP.md` §Next A-28, `MILESTONE_1` §8 | 미확인 | 미확인 | 미확인 (문서 작업) |
| **REQ-M2-1** `getBookingById()` 추가 | `docs/MARK2_IDEAS.md` Repository 분류 | 미확인 | 미확인 | `lib/features/booking/data/booking_repository.dart` |
| **REQ-M2-2** `addItem()` 병렬화 | `docs/MARK2_IDEAS.md` Performance 분류 | 미확인 | 미확인 | `lib/features/booking/data/booking_completion_caller.dart:51~65` |
| **REQ-M2-3** 미매칭 상품 정책 | `docs/MARK2_IDEAS.md` Technical Debt 분류 | 미확인 | 미확인 | `lib/features/booking/data/booking_completion_caller.dart:57~59` |

---

## PART 4 — Requirement Missing Information Observation

기존 문서에 명시적으로 기록된 TODO/미정/추후 확인/보류 항목만 기록:

| Requirement | 문서 내 명시 표현 | 근거 위치 |
|---|---|---|
| **REQ-A26** | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7: "`BookingCompletionCaller` UI 연동 — 미구현, `completeBooking()` 호출 UI 없음 — A-26에서 검토" | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 |
| **REQ-A26** | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7: "Booking 완료 화면/라우트 — 미구현, A-23에서 확인된 그대로 라우트 없음" | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 |
| **REQ-A26** | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7: "TOCTOU 동시성 대응 — ADR-007에서 의도적 이관, UI 연결 전 재평가 필요" | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 |
| **REQ-A28** | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" — 이벤트 미정 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 |
| **REQ-M2-1** | `docs/MARK2_IDEAS.md`: "A-25 계약('BookingRepository 수정 금지')을 준수하기 위해 보류" | `docs/MARK2_IDEAS.md` (Repository 분류) |
| **REQ-M2-2** | `docs/MARK2_IDEAS.md`: "A-25 계약('순서 변경 금지', 'parallel 금지')을 준수하기 위해 보류" | `docs/MARK2_IDEAS.md` (Performance 분류) |
| **REQ-M2-3** | `docs/MARK2_IDEAS.md`: "A-25 계약('새로운 로직 추가 금지')을 준수하기 위해 보류" | `docs/MARK2_IDEAS.md` (Technical Debt 분류) |

---

## PART 5 — Gap Observation

| Requirement | 현재 확인 상태 | 근거 | 관찰 결과 |
|---|---|---|---|
| **REQ-A26** UI 통합 검증 | 미구현 | `lib/features/booking/providers.dart`: `BookingCompletionCaller` Provider 없음. `lib/features/booking/screens/`: `waiting_list_screen.dart` 1개만 존재. `lib/core/router.dart`: 예약 완료 라우트 없음. `lib/` grep: `BookingCompletionCaller` 사용처 0건(자신 제외) | 구현 코드 없음 |
| **REQ-A27** 회귀 테스트 재실행 | 일부 확인됨 | 현재 테스트 372건 All tests passed(`A26_REQUIREMENT_DEFINITION.md` PART 9 확인). 공식 회귀 Baseline 문서는 존재하지 않음(`docs/baseline/`에 `SESSION_CLOSING_BASELINE.md`만 존재) | 테스트 Pass 상태 확인됨. 공식 기준선 재확정 문서 없음 |
| **REQ-A28** 운영자용 흐름 문서 | 미구현 | `docs/` 내 "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" 기술하는 운영자용 문서 파일 없음. `completeBooking()` UI 호출 0건 확인됨 | 구현 코드 없음 |
| **REQ-M2-1** `getBookingById()` | 미구현 | `lib/features/booking/data/booking_repository.dart`: `getBookingById()` 또는 동등한 단건 조회 메서드 없음(공개 메서드 목록 확인) | 구현 코드 없음 |
| **REQ-M2-2** `addItem()` 병렬화 | 일부 확인됨 | `booking_completion_caller.dart:51~65`: `for` loop 순차 await 존재. `Future.wait()` 미사용 | 관련 코드 존재(순차 구현). 병렬화 코드 없음 |
| **REQ-M2-3** 미매칭 상품 정책 | 일부 확인됨 | `booking_completion_caller.dart:57~59`: `firstOrNull` → `if (product == null) continue;` 패턴 존재. 로깅/예외 처리 없음 | 관련 코드 존재(silent skip). 명시적 정책 코드 없음 |

---

## PART 6 — Requirement Analysis Status

| Requirement | 현재 확인 상태 |
|---|---|
| **REQ-A26** UI 통합 검증 | 일부 확인됨 — 검증 대상(`BookingCompletionCaller`) 존재 확인. Provider/화면/라우트 미구현 확인. UI 이벤트 미정 |
| **REQ-A27** 회귀 테스트 재실행 | 일부 확인됨 — 현재 테스트 Pass 상태 확인. 공식 기준선 재확정 문서 없음 |
| **REQ-A28** 운영자용 흐름 문서 | 일부 확인됨 — 문서화 대상 흐름(`ARCHITECTURE_SUMMARY.md` §5) 존재 확인. UI 이벤트 미정. 운영자 문서 없음 |
| **REQ-M2-1** `getBookingById()` | 일부 확인됨 — 수정 대상 파일(`booking_repository.dart`) 확인. 해당 메서드 없음 확인. 보류 사유 확인 |
| **REQ-M2-2** `addItem()` 병렬화 | 일부 확인됨 — 변경 대상 코드(for loop) 확인. 보류 사유 확인 |
| **REQ-M2-3** 미매칭 상품 정책 | 일부 확인됨 — 변경 대상 코드(silent skip) 확인. 보류 사유 확인 |

---

## PART 7 — Analysis Observation

Analysis 과정에서 확인된 사실:

| 항목 | 관찰 내용 | 근거 |
|---|---|---|
| `BookingCompletionCaller` 테스트 범위 | A-25에서 작성된 테스트 4건은 단위 테스트 수준 — 단일 상품 / 복수 상품 / 빈 CSV / 미매칭 ID 케이스 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §6 |
| `BookingCompletionCaller` Provider 부재 | `lib/features/booking/providers.dart`에 `BookingCompletionCaller` Provider가 없어 위젯/화면에서 DI 불가 | `lib/features/booking/providers.dart` |
| A-25 계약 범위 | "Repository 수정 금지", "순서 변경 금지", "parallel 금지", "새로운 로직 추가 금지" — 4개 제약이 MARK2 보류 사유 | `docs/ARCHITECTURE_SUMMARY.md` §2, `docs/MARK2_IDEAS.md` |
| `ARCHITECTURE_SUMMARY.md` 흐름 기록 | `BookingCompletionCaller.complete()` 실행 순서 5단계가 문서에 기재돼 있음 | `docs/ARCHITECTURE_SUMMARY.md` §5 |
| `payment_repository.dart` 주석 | `payment_repository.dart:184`에 "예약경로 1차 범위 포함 안 함"이 코드 주석으로 명시됨 | `lib/features/payment_pos/data/payment_repository.dart:184` |
| `waitingListScreen` 주석 | `lib/features/booking/screens/waiting_list_screen.dart:16~17`: "UI는 다음 차수로 미룸" 주석 존재 | `lib/features/booking/screens/waiting_list_screen.dart:16~17` |
| 테스트 카운트 변화 | A-25 구현 직후 373건 → A-26 문서화 후 372건 (코드 변경 없음, 이번 A-27 Baseline 확인 대기 중) | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §6, `docs/A26_REQUIREMENT_DEFINITION.md` PART 9 |

---

## PART 9 — Baseline 확인

아래 결과는 이 문서 작성 시점의 실측값이다.

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

코드 변경 없음. 이 문서는 순수 조사·분석·문서화 작업이다.

---

**"Requirement Analysis Established"**
