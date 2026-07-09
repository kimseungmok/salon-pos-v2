# A-34: Milestone 3 Requirement Definition

> **목적**: Milestone 3에서 계획된 기능의 Requirement를 실제 프로젝트 문서를 기준으로 정의한다.
> **제약**: Requirement Definition만 수행. Implementation 금지. Design 변경 금지. Interface Contract 생성 금지. PROJECT_ROADMAP 수정 금지. 문서에 명시적으로 존재하지 않는 새로운 Requirement 생성 금지. 추론 금지.
> **기준 문서**: `docs/PROJECT_ROADMAP.md`, `docs/MARK2_IDEAS.md`, `docs/README.md`, `docs/WORK_LOG.md`, `docs/A33_MILESTONE2_CLOSURE.md`, 실제 코드, 실제 Commit 기록
> 작성일: 2026-07-09

---

## PART 0.5 — Milestone Candidate Verification

`docs/PROJECT_ROADMAP.md` §Future 및 `docs/MARK2_IDEAS.md`에서 확인된 Milestone 3 Candidate:

| Candidate | 확인 근거 | 관련 문서 | 상태 |
|---|---|---|---|
| **C-1** `addItem()` 병렬 호출(`Future.wait()`) | `MARK2_IDEAS.md` Performance 분류: "여러 상품에 대해 `addItem()`을 순차 `await`로 처리 중 — `Future.wait()`로 병렬화하면 다중 상품 시 성능을 개선할 수 있다." `PROJECT_ROADMAP.md` §Future: "MARK2 Review" — 3개 아이디어 중 포함됨. `A33_MILESTONE2_CLOSURE.md` PART 6: "다음 Milestone 이관" | `MARK2_IDEAS.md`, `PROJECT_ROADMAP.md` §Future, `A33_MILESTONE2_CLOSURE.md` | **확인됨** |
| **C-2** `productIdsCsv` 파싱 미매칭 상품 명시적 정책(로깅/예외) | `MARK2_IDEAS.md` Technical Debt 분류: "CSV의 Product ID가 없으면 조용히 건너뛴다 — 감지할 로깅/예외가 없어 운영 시 추적이 어렵다." `PROJECT_ROADMAP.md` §Future: "MARK2 Review" 포함. `A33_MILESTONE2_CLOSURE.md` PART 6: "다음 Milestone 이관" | `MARK2_IDEAS.md`, `PROJECT_ROADMAP.md` §Future, `A33_MILESTONE2_CLOSURE.md` | **확인됨** |
| **C-3** 복수 Promotion 중첩 정책(ADR-005) 처리 | `PROJECT_ROADMAP.md` §Future: "Technical Debt Review — A-11.5에서 식별한 복수 Promotion 중첩 정책(ADR-005 미작성으로 보류됨)". `A33_MILESTONE2_CLOSURE.md`: 미언급(Milestone 2 범위 밖) | `PROJECT_ROADMAP.md` §Future | **일부 확인됨** |
| **C-4** TOCTOU 동시성 대응 | `PROJECT_ROADMAP.md` §Future: "Technical Debt Review — TOCTOU 대응(ADR-007에서 의도적으로 이관된 동시성 대응) 처리". `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`: "TOCTOU 동시성 대응 — ADR-007에서 의도적 이관. UI 연결 전 재평가 필요" | `PROJECT_ROADMAP.md` §Future, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/A13_CONCURRENCY_VALIDATION.md` | **일부 확인됨** |

---

## PART 1 — Requirement Inventory

`PROJECT_ROADMAP.md` §Future 및 `MARK2_IDEAS.md`에 명시된 내용만으로 구성한 Requirement:

| Requirement | Requirement 근거 | 관련 문서 | 관련 코드 | 상태 |
|---|---|---|---|---|
| **REQ-M3-1** `addItem()` 순차 await를 `Future.wait()` 병렬 호출로 변경하여 다중 상품 처리 성능 개선 | `MARK2_IDEAS.md` Performance 분류: "`Future.wait()`로 병렬화하면 다중 상품 시 성능을 개선할 수 있다." Milestone 2에서 "Future.wait 전략 변경 금지" 규칙으로 미구현됨(WORK_LOG A-29) | `MARK2_IDEAS.md`, `A33_MILESTONE2_CLOSURE.md` PART 6 | `lib/features/booking/data/booking_completion_caller.dart:51~65` (현재 순차 for loop) | **확인됨** |
| **REQ-M3-2** `productIdsCsv` 파싱 미매칭 상품에 대한 명시적 정책(로깅 또는 예외) 정의 | `MARK2_IDEAS.md` Technical Debt 분류: "감지할 로깅/예외가 없어 운영 시 추적이 어렵다." Milestone 2에서 "Logging 정책 추가 금지" 규칙으로 미구현됨(WORK_LOG A-29) | `MARK2_IDEAS.md`, `A33_MILESTONE2_CLOSURE.md` PART 6 | `lib/features/booking/data/booking_completion_caller.dart:57~59` (현재 `if (product == null) continue;` silent skip) | **확인됨** |
| **REQ-M3-3** 복수 Promotion 중첩 정책(ADR-005 미작성) 확정 및 처리 | `PROJECT_ROADMAP.md` §Future: "A-11.5에서 식별한 복수 Promotion 중첩 정책(ADR-005 미작성으로 보류됨)". `A11_5_PROMOTION_EXPANSION_PLAN.md`: "현재는 `priority` 최우선 Rule 1개만 적용" | `PROJECT_ROADMAP.md` §Future, `docs/A11_5_PROMOTION_EXPANSION_PLAN.md` | `lib/features/promotion/` (현재 단일 Rule 적용 구조) | **일부 확인됨** |
| **REQ-M3-4** TOCTOU 동시성 대응(ADR-007에서 의도적 이관) 처리 | `PROJECT_ROADMAP.md` §Future: "TOCTOU 대응(ADR-007에서 의도적으로 이관된 동시성 대응) 처리". `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`: "UI 연결 전 재평가 필요" | `PROJECT_ROADMAP.md` §Future, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/A13_CONCURRENCY_VALIDATION.md` | 미확인 | **일부 확인됨** |

---

## PART 2 — Requirement Scope Observation

| Requirement | 확인된 범위 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` 병렬화 | 변경 대상 코드 위치: `booking_completion_caller.dart:51~65` for loop 순차 await. 변경 방향: `Future.wait()` 병렬 호출. Milestone 2 미구현 이유: "Future.wait 전략 변경 금지" 규칙(WORK_LOG A-29). Milestone 2 이관 확인: `A33_MILESTONE2_CLOSURE.md` PART 6. | `MARK2_IDEAS.md` Performance 분류, `booking_completion_caller.dart:51~65`, WORK_LOG A-29, `A33_MILESTONE2_CLOSURE.md` PART 6 |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | 변경 대상 코드 위치: `booking_completion_caller.dart:57~59` silent skip 패턴. 정책 형태: 문서상 "로깅 또는 예외" 두 가지 언급됨 — 어느 것인지 결정되지 않음(`MARK2_IDEAS.md`: "로깅/예외"). Milestone 2 미구현 이유: "Logging 정책 추가 금지" 규칙(WORK_LOG A-29). Milestone 2 이관 확인: `A33_MILESTONE2_CLOSURE.md` PART 6. | `MARK2_IDEAS.md` Technical Debt 분류, `booking_completion_caller.dart:57~59`, WORK_LOG A-29, `A33_MILESTONE2_CLOSURE.md` PART 6 |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | 문서에 기록된 범위: `PROJECT_ROADMAP.md` §Future "ADR-005 미작성으로 보류됨". `A11_5_PROMOTION_EXPANSION_PLAN.md` PART 3에 할인 중첩 정책 비교 기록됨. 현재 구현: 단일 Rule `priority` 최우선 적용. ADR-005 파일 없음(`docs/adr/`에 ADR-001~ADR-004만 존재 — `A12_STAFF_EARNING_ARCHITECTURE.md` 확인). | `PROJECT_ROADMAP.md` §Future, `A11_5_PROMOTION_EXPANSION_PLAN.md`, `A12_STAFF_EARNING_ARCHITECTURE.md` |
| **REQ-M3-4** TOCTOU 동시성 대응 | 문서에 기록된 범위: `PROJECT_ROADMAP.md` §Future "ADR-007에서 의도적으로 이관된 동시성 대응 처리". `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`: "UI 연결 전 재평가 필요". 구체적 대응 방식: 코드 또는 ADR에서 미확인. `A13_CONCURRENCY_VALIDATION.md` 존재 확인됨. | `PROJECT_ROADMAP.md` §Future, `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/A13_CONCURRENCY_VALIDATION.md` |

---

## PART 3 — Requirement Traceability

| Requirement | Requirement 근거 | 관련 ADR | 관련 Commit | 관련 코드 |
|---|---|---|---|---|
| **REQ-M3-1** `addItem()` 병렬화 | `MARK2_IDEAS.md` Performance 분류 | 미확인 | `a12190b`(A-25 `BookingCompletionCaller` 구현 — 순차 loop 포함) | `lib/features/booking/data/booking_completion_caller.dart:51~65` |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | `MARK2_IDEAS.md` Technical Debt 분류 | 미확인 | `a12190b`(A-25 `BookingCompletionCaller` 구현 — silent skip 포함) | `lib/features/booking/data/booking_completion_caller.dart:57~59` |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | `PROJECT_ROADMAP.md` §Future Technical Debt Review | ADR-005 미작성(보류 확인: `A12_STAFF_EARNING_ARCHITECTURE.md`) | 미확인 | `lib/features/promotion/` |
| **REQ-M3-4** TOCTOU 동시성 대응 | `PROJECT_ROADMAP.md` §Future Technical Debt Review | ADR-007(`docs/adr/ADR-007.md` — Transaction Scope, TOCTOU 이관 결정 포함) | 미확인 | 미확인 |

---

## PART 4 — Requirement Evidence Missing Observation

| Requirement | 미확인 항목 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` 병렬화 | 관련 ADR 없음 — `MARK2_IDEAS.md`에 아이디어로 기록됨. 구체적 병렬화 전략(Future.wait 스코프, 오류 처리 방식) 문서에 미정. | `MARK2_IDEAS.md`: "Future.wait()로 병렬화" 이상의 상세 없음 |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | 관련 ADR 없음. 정책 형태(로깅 vs 예외) 미결정 — `MARK2_IDEAS.md`: "로깅/예외" 두 가지 언급만 있고 결정 없음. `A28_5_INTERFACE_CONTRACT_DEFINITION.md` IC-5: "미확인" 상태로 Milestone 2 종료됨. | `MARK2_IDEAS.md`, `A28_5_INTERFACE_CONTRACT_DEFINITION.md` PART 5, `A33_MILESTONE2_CLOSURE.md` PART 3 IC-5 |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | ADR-005 미작성(`docs/adr/`에 ADR-004까지만 존재). 중첩 정책 결정 문서 없음. `A11_5_PROMOTION_EXPANSION_PLAN.md`에 비교 기록은 있으나 확정 결론 없음. 관련 Commit 없음. | `A12_STAFF_EARNING_ARCHITECTURE.md`: "ADR-005는 미존재 확인". `A11_5_PROMOTION_EXPANSION_PLAN.md` 결과물 절 |
| **REQ-M3-4** TOCTOU 동시성 대응 | 구체적 대응 코드 위치 미확인. 대응 방식(Conditional Update 확장, Lock, 재시도 등) 문서에 미정. ADR-007에 이관 결정만 있고 구체 방식 없음. | `PROJECT_ROADMAP.md` §Future: "처리" 이상의 상세 없음. `A13_CONCURRENCY_VALIDATION.md` 내용 미확인 |

---

## PART 5 — Requirement Link Observation

현재 Requirement와 직접 연결되지 않는 프로젝트 항목:

| 항목 | 관찰 결과 | 근거 |
|---|---|---|
| CC-1 `WaitingEntryRow.bookingId` 부재 | `A33_MILESTONE2_CLOSURE.md` PART 6 "다음 Milestone 이관"으로 기록됨. Milestone 3 Requirement(REQ-M3-1~4) 중 어느 항목과도 명시적으로 연결되지 않음. `PROJECT_ROADMAP.md`/`MARK2_IDEAS.md`에 관련 Candidate 없음. | `A33_MILESTONE2_CLOSURE.md` PART 6, `PROJECT_ROADMAP.md` §Future, `MARK2_IDEAS.md` |
| CC-2 `businessType` 값 미확인 | `A33_MILESTONE2_CLOSURE.md` PART 6 "다음 Milestone 이관"으로 기록됨. REQ-M3-1~4 중 어느 항목과도 명시적으로 연결되지 않음. `PROJECT_ROADMAP.md`/`MARK2_IDEAS.md`에 관련 Candidate 없음. | `A33_MILESTONE2_CLOSURE.md` PART 6, `PROJECT_ROADMAP.md` §Future, `MARK2_IDEAS.md` |
| `BookingListScreen` 위젯/통합 테스트 없음 | `A33_MILESTONE2_CLOSURE.md` PART 6 "다음 Milestone 이관"으로 기록됨. REQ-M3-1~4 중 어느 항목과도 명시적으로 연결되지 않음. `PROJECT_ROADMAP.md`에 관련 Candidate 없음. | `A33_MILESTONE2_CLOSURE.md` PART 6, `PROJECT_ROADMAP.md` §Future |
| `PROJECT_ROADMAP.md` §Future "Architecture Refactoring Candidate" | "`BookingRepository`에 단건 조회 메서드 부재로 Caller가 `BookingRow`를 pre-fetch해야 하는 구조 개선(MARK2 항목 1번)"으로 기록됨. `MARK2_IDEAS.md` Repository 분류 항목(`getBookingById()`)은 Milestone 2(D-7)에서 이미 구현 완료됨. 해당 Roadmap 항목과 구현 완료 상태의 관계가 문서에 명시적으로 정리되지 않음. | `PROJECT_ROADMAP.md` §Future, `MARK2_IDEAS.md` Repository 분류, `A29_REGRESSION_BASELINE.md`, `A32_REMAINING_IMPLEMENTATION.md` |

---

## PART 6 — Requirement Status

| Requirement | 상태 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` `Future.wait()` 병렬화 | **확인됨** | `MARK2_IDEAS.md` Performance 분류에 명시. 변경 대상 코드(`booking_completion_caller.dart:51~65`) 확인됨. Milestone 2 이관 확인됨(`A33_MILESTONE2_CLOSURE.md` PART 6). |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | **일부 확인됨** | `MARK2_IDEAS.md` Technical Debt 분류에 명시. 변경 대상 코드(`booking_completion_caller.dart:57~59`) 확인됨. 정책 형태(로깅 vs 예외) 미결정. |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | **일부 확인됨** | `PROJECT_ROADMAP.md` §Future에 명시. 관련 분석 문서(`A11_5_PROMOTION_EXPANSION_PLAN.md`) 존재 확인됨. ADR-005 미작성. 정책 결정 없음. |
| **REQ-M3-4** TOCTOU 동시성 대응 | **일부 확인됨** | `PROJECT_ROADMAP.md` §Future에 명시. `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`에 이관 기록 존재. 대응 방식 및 대상 코드 미확인. |

---

## Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 4.0s)
```

| 항목 | 결과 |
|---|---|
| flutter analyze | **Pass** |

### flutter test

```
+372: All tests passed!
```

| 항목 | 결과 |
|---|---|
| flutter test | **Pass (372건)** |

코드 변경 없음. 이 문서는 순수 Requirement Definition 작업이다.

---

**"Milestone 3 Requirement Established"**
