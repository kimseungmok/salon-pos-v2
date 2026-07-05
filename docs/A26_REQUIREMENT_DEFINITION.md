# A-26: Milestone 2 Requirement Definition (Candidate Verification)

> 이 문서는 Milestone 2에서 실제 구현 대상으로 계획된 Requirement를 확인하고 기록한다.
> **제약**: 조사·문서화만 수행. 코드 수정 금지. 설계 생성 금지. 새로운 Requirement 생성 금지. 기능 분해 금지. 추론 금지.
> **기준 자료**: `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/MILESTONE_2_READINESS_ASSESSMENT.md`, `docs/MARK2_IDEAS.md`, 실제 코드, git log
> 작성일: 2026-07-03

---

## PART 1 — Milestone 2 Candidate Inventory

`docs/PROJECT_ROADMAP.md` §Next 및 기존 문서에서 확인 가능한 Candidate:

| Candidate | 확인 근거 | 관련 문서 | 관련 코드 | 상태 |
|---|---|---|---|---|
| **A-26** Booking Integration Test | `PROJECT_ROADMAP.md` §Next: "`BookingCompletionCaller`가 실제 UI 호출 경로에서도 정상 동작하는지 통합 검증" | `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | `lib/features/booking/data/booking_completion_caller.dart` | 확인됨 |
| **A-27** Regression Verification | `PROJECT_ROADMAP.md` §Next: "A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정" | `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | 미확인 (테스트 대상 파일 전체) | 확인됨 |
| **A-28** Booking Flow Documentation | `PROJECT_ROADMAP.md` §Next: "Booking 완료 → Session 생성 흐름의 운영자용 문서(예: 어떤 UI 이벤트가 `complete()`를 호출해야 하는지 등) 정리" | `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | 미확인 (문서 작업, 코드 변경 없음) | 확인됨 |
| **MARK2-1** `BookingRepository.getBookingById()` 단건 조회 메서드 추가 | `docs/MARK2_IDEAS.md` (Repository 분류), `PROJECT_ROADMAP.md` §Future §Architecture Refactoring Candidate | `docs/MARK2_IDEAS.md` | `lib/features/booking/data/booking_repository.dart` | 확인됨 |
| **MARK2-2** `addItem()` 병렬 호출 지원 | `docs/MARK2_IDEAS.md` (Performance 분류) | `docs/MARK2_IDEAS.md` | `lib/features/booking/data/booking_completion_caller.dart`, `lib/features/session/data/session_repository.dart` | 확인됨 |
| **MARK2-3** 미매칭 상품 명시적 정책 | `docs/MARK2_IDEAS.md` (Technical Debt 분류) | `docs/MARK2_IDEAS.md` | `lib/features/booking/data/booking_completion_caller.dart` | 확인됨 |

> **분류 기준(PROJECT_ROADMAP.md 기준)**:
> - A-26~A-28: "단기 후속 작업" — 우선순위 높음
> - MARK2-1~3: "중·장기 검토 항목" — 우선순위 미정

---

## PART 2 — Requirement Inventory

기존 문서에 명시된 Requirement만 기록:

| Requirement | Requirement 근거 | 관련 문서 | 상태 |
|---|---|---|---|
| **REQ-A26** `BookingCompletionCaller`가 실제 UI 호출 경로에서 정상 동작하는지 통합 검증 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7: "`BookingCompletionCaller` UI 연동 — 미구현, completeBooking() 호출 UI 없음 — A-26에서 검토" | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7/§8 | 미구현 |
| **REQ-A27** A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정 | `PROJECT_ROADMAP.md` §Next A-27 항목 | `docs/PROJECT_ROADMAP.md` | 미구현 |
| **REQ-A28** Booking 완료 → Session 생성 흐름의 운영자용 문서 작성(어떤 UI 이벤트가 `complete()`를 호출해야 하는지) | `PROJECT_ROADMAP.md` §Next A-28 항목, `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` | 미구현 |
| **REQ-M2-1** `BookingRepository`에 ID 기준 단건 조회 메서드(`getBookingById()`) 추가 | `MARK2_IDEAS.md`: "현재 BookingRepository에 ID 기준 단건 조회 메서드가 없어 Caller의 호출자가 Booking 엔티티를 직접 pre-fetch해서 전달해야 한다" | `docs/MARK2_IDEAS.md` (Repository 분류) | 미구현(보류) |
| **REQ-M2-2** `addItem()` 병렬 호출(`Future.wait()`) 지원으로 다중 상품 성능 개선 | `MARK2_IDEAS.md`: "여러 상품에 대해 addItem()을 순차 await로 처리 중 — Future.wait()로 병렬화하면 다중 상품 시 성능을 개선할 수 있다" | `docs/MARK2_IDEAS.md` (Performance 분류) | 미구현(보류) |
| **REQ-M2-3** `productIdsCsv` 파싱 미매칭 상품에 대한 명시적 정책(로깅/예외) 정의 | `MARK2_IDEAS.md`: "CSV의 Product ID가 없으면 조용히 건너뛴다 — 운영 시 추적이 어렵다" | `docs/MARK2_IDEAS.md` (Technical Debt 분류) | 미구현(보류) |

---

## PART 3 — Requirement Traceability

Requirement와 기존 프로젝트 자료의 연결:

| Requirement | Requirement 근거 | 관련 ADR | 관련 Commit | 관련 코드 |
|---|---|---|---|---|
| **REQ-A26** UI 통합 검증 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7 | 미확인 (ADR 미작성) | `a12190b` (BookingCompletionCaller 구현 완료 커밋, A-26 검증 대상) | `lib/features/booking/data/booking_completion_caller.dart` |
| **REQ-A27** 회귀 테스트 재실행 | `PROJECT_ROADMAP.md` §Next | 미확인 | `a12190b` (A-25 구현 이후 기준선) | 미확인 (전체 test/ 디렉터리 대상) |
| **REQ-A28** 운영자용 흐름 문서 | `PROJECT_ROADMAP.md` §Next | 미확인 | 미확인 | 미확인 (문서 작업) |
| **REQ-M2-1** `getBookingById()` 추가 | `MARK2_IDEAS.md` (Repository) | 미확인 | 미확인 | `lib/features/booking/data/booking_repository.dart` |
| **REQ-M2-2** `addItem()` 병렬화 | `MARK2_IDEAS.md` (Performance) | 미확인 | 미확인 | `lib/features/booking/data/booking_completion_caller.dart:51~59` (현재 순차 loop) |
| **REQ-M2-3** 미매칭 상품 정책 | `MARK2_IDEAS.md` (Technical Debt) | 미확인 | 미확인 | `lib/features/booking/data/booking_completion_caller.dart:47~52` (현재 silent skip) |

---

## PART 4 — Dependency Observation

문서·코드·Commit·Contract·Traceability에서 **명시적으로 확인된** 의존성만 기록:

| Requirement | 의존 대상 | 근거 |
|---|---|---|
| **REQ-A26** UI 통합 검증 | `lib/features/booking/data/booking_completion_caller.dart` | A-26의 검증 대상이 `BookingCompletionCaller` 자체 — `MILESTONE_1` §7 "A-26에서 검토" 명시 |
| **REQ-A26** UI 통합 검증 | `lib/features/booking/providers.dart` (Provider 등록 여부) | `MILESTONE_2_READINESS_ASSESSMENT.md` PART 5: "Provider 미등록" 확인됨 |
| **REQ-A27** 회귀 테스트 | REQ-A26 완료 | `PROJECT_ROADMAP.md` §Next: A-27은 A-26 이후 항목으로 순서 기재됨 |
| **REQ-A28** 운영자 문서 | REQ-A26 완료 (UI 호출 경로 확인 후 문서화) | `MILESTONE_1` §8: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" — UI 경로 확인이 선행 조건 |
| **REQ-M2-1** `getBookingById()` | `lib/features/booking/data/booking_repository.dart` | `MARK2_IDEAS.md`: "BookingRepository에 ID 기준 단건 조회 메서드가 없어 … 우회함" — 해당 Repository 파일이 수정 대상 |
| **REQ-M2-2** `addItem()` 병렬화 | `lib/features/booking/data/booking_completion_caller.dart` (for loop 부분) | `MARK2_IDEAS.md`: "booking_completion_caller.dart의 for loop await를 Future.wait()로 변경" — 해당 파일 수정 필요 |
| **REQ-M2-3** 미매칭 정책 | `lib/features/booking/data/booking_completion_caller.dart:47~52` | `MARK2_IDEAS.md`: "CSV의 Product ID가 없으면 조용히 건너뛴다" — 해당 위치의 로직 변경 필요 |

---

## PART 5 — Gap Observation

Requirement와 현재 구현 상태의 차이:

| Requirement | 관찰 결과 |
|---|---|
| **REQ-A26** UI 통합 검증 | 구현 코드 없음 — `lib/features/booking/providers.dart`에 `BookingCompletionCaller` Provider 없음. `lib/features/booking/screens/`에 `booking_completion`이 포함된 화면 파일 없음. `lib/core/router.dart`에 예약 완료 라우트 없음. `lib/` 전체에서 `BookingCompletionCaller` 사용처가 `booking_completion_caller.dart` 자신 외에 없음. |
| **REQ-A27** 회귀 테스트 재실행 | 일부 구현 확인 — 현재 테스트 372건 All tests passed 상태(이번 작업 Baseline 확인 결과). 단, "A-25 이후 기준선 재확정" 문서는 없음 — 단순 Pass 확인만 존재하며 공식 Regression Baseline 문서가 생성되지 않음. |
| **REQ-A28** 운영자 문서 | 구현 코드 없음 — 운영자용 흐름 문서 파일이 `docs/` 내에 없음. UI 호출 경로도 아직 미확인 상태(`completeBooking()` UI 호출 0건). |
| **REQ-M2-1** `getBookingById()` | 구현 코드 없음 — `lib/features/booking/data/booking_repository.dart` 내 `getBookingById()` 또는 동등한 단건 조회 메서드 없음. |
| **REQ-M2-2** `addItem()` 병렬화 | 관련 코드 미확인(다른 방향) — `booking_completion_caller.dart:51~59` for loop await 현재 코드 존재. 병렬화 미구현. |
| **REQ-M2-3** 미매칭 상품 정책 | 관련 코드 미확인 (현재 silent skip 구현) — `booking_completion_caller.dart:47~52` `firstOrNull` → `continue` 패턴 현재 존재. 명시적 정책(로깅/예외) 없음. |

---

## PART 6 — Analysis Preparation Observation

기존 문서에서 명시적으로 확인된 미확인 사항:

| Requirement | 확인된 미확인 사항 |
|---|---|
| **REQ-A26** UI 통합 검증 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §7: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" 미정. `MILESTONE_2_READINESS_ASSESSMENT.md` PART 5: "Provider 미등록", "UI 화면 없음", "`completeBooking()` UI 호출 0건" |
| **REQ-A27** 회귀 테스트 재실행 | `PROJECT_ROADMAP.md` §Next: "기준선 재확정" — 재확정 기준이 문서에 명시되지 않음 |
| **REQ-A28** 운영자 문서 | `PROJECT_ROADMAP.md` §Next: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지 등" — UI 이벤트 식별이 선행 조건이나 현재 해당 이벤트 미정 |
| **REQ-M2-1** `getBookingById()` | `MARK2_IDEAS.md`: "A-25 계약('BookingRepository 수정 금지')을 준수하기 위해 보류" — Milestone 2에서 이 제약이 해제되는지 여부 미확인 |
| **REQ-M2-2** `addItem()` 병렬화 | `MARK2_IDEAS.md`: "A-25 계약('순서 변경 금지', 'parallel 금지')을 준수하기 위해 보류" — 동일 제약 해제 여부 미확인 |
| **REQ-M2-3** 미매칭 상품 정책 | `MARK2_IDEAS.md`: "A-25 계약('새로운 로직 추가 금지')을 준수하기 위해 보류" — 동일 제약 해제 여부 미확인 |

---

## PART 7 — Requirement Observation Summary

| 항목 | 상태 | 근거 |
|---|---|---|
| REQ-A26 Candidate 존재 확인 | 확인됨 | `PROJECT_ROADMAP.md` §Next, `MILESTONE_1` §8에 명시 |
| REQ-A26 구현 상태 | 확인됨 (미구현) | `lib/features/booking/providers.dart` Provider 없음, `lib/core/router.dart` 라우트 없음, `grep "BookingCompletionCaller" lib/` 결과 — 자신 외 사용처 0건 |
| REQ-A26 선행 조건(어떤 UI 이벤트) | 미확인 | `MILESTONE_1` §8 "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" — 명시된 이벤트 없음 |
| REQ-A27 Candidate 존재 확인 | 확인됨 | `PROJECT_ROADMAP.md` §Next에 명시 |
| REQ-A27 현재 테스트 상태 | 일부 확인됨 | 372건 All tests passed — 공식 Baseline 재확정 문서 없음 |
| REQ-A28 Candidate 존재 확인 | 확인됨 | `PROJECT_ROADMAP.md` §Next에 명시 |
| REQ-A28 선행 조건(UI 이벤트 식별) | 미확인 | UI 이벤트 미정 상태 (`completeBooking()` UI 호출 0건 확인됨) |
| REQ-M2-1 Candidate 존재 확인 | 확인됨 | `MARK2_IDEAS.md` Repository 분류에 명시 |
| REQ-M2-1 제약 해제 여부 | 미확인 | "BookingRepository 수정 금지" 제약이 Milestone 2에서 해제되는지 문서에 없음 |
| REQ-M2-2 Candidate 존재 확인 | 확인됨 | `MARK2_IDEAS.md` Performance 분류에 명시 |
| REQ-M2-2 제약 해제 여부 | 미확인 | "parallel 금지" 제약이 Milestone 2에서 해제되는지 문서에 없음 |
| REQ-M2-3 Candidate 존재 확인 | 확인됨 | `MARK2_IDEAS.md` Technical Debt 분류에 명시 |
| REQ-M2-3 제약 해제 여부 | 미확인 | "새로운 로직 추가 금지" 제약이 Milestone 2에서 해제되는지 문서에 없음 |

---

## PART 9 — Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 14.5s)
```

결과: **Pass**

### flutter test

```
+372: All tests passed!
```

결과: **Pass (372건)**

코드 변경 없음. 이 문서는 순수 조사·문서화 작업이다.

---

**"Milestone 2 Requirement Definition Established"**
