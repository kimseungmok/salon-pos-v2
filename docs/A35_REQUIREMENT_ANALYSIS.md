# A-35: Milestone 3 Requirement Analysis

> **목적**: Milestone 3 Requirement를 실제 프로젝트 문서, 코드, Commit, Verification에 기반하여 분석한다. 새로운 사실을 생성하지 않는다 — 기존 정보를 재구성하여 기록한다.
> **제약**: Analysis만 수행. Implementation/Design/Interface Contract 금지. 새로운 Requirement 생성 금지. 추론 금지.
> **기준 자료**: `docs/PROJECT_ROADMAP.md`, `docs/MARK2_IDEAS.md`, `docs/A34_MILESTONE3_REQUIREMENT.md`, `docs/A33_MILESTONE2_CLOSURE.md`, `docs/README.md`, `docs/WORK_LOG.md`, 실제 코드, Commit 기록, Verification 결과
> 작성일: 2026-07-09

---

## PART 0.5 — Requirement Baseline Verification

A-34에서 정의된 Requirement 상태 확인:

| Requirement | 상태 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` `Future.wait()` 병렬화 | **확인됨** | `A34_MILESTONE3_REQUIREMENT.md` PART 6: "확인됨". 변경 대상 코드 `booking_completion_caller.dart:51~65` 확인됨. `MARK2_IDEAS.md` Performance 분류 명시 확인됨. |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | **일부 확인됨** | `A34_MILESTONE3_REQUIREMENT.md` PART 6: "일부 확인됨". 변경 대상 코드 `booking_completion_caller.dart:57~59` 확인됨. 정책 형태(로깅 vs 예외) 미결정. |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | **일부 확인됨** | `A34_MILESTONE3_REQUIREMENT.md` PART 6: "일부 확인됨". `PROJECT_ROADMAP.md` §Future 명시. ADR-005 미작성. 정책 결정 없음. |
| **REQ-M3-4** TOCTOU 동시성 대응 | **일부 확인됨** | `A34_MILESTONE3_REQUIREMENT.md` PART 6: "일부 확인됨". `PROJECT_ROADMAP.md` §Future 명시. 대응 방식 미확인. |

> **적용 규칙**: REQ-M3-2/M3-3/M3-4는 "일부 확인됨" — 확인 가능한 범위만 Analysis 대상으로 사용한다.

---

## PART 1 — Requirement Analysis

### REQ-M3-1: `addItem()` `Future.wait()` 병렬화

| 항목 | 확인된 내용 | 근거 |
|---|---|---|
| 현재 구현 형태 | `booking_completion_caller.dart:63~72`: `for (final id in productIds)` 순차 `await` loop. 각 `id`에 대해 `await _sessionRepository.addItem(...)` 순차 실행. | `lib/features/booking/data/booking_completion_caller.dart:63~72` |
| 변경 방향 | `MARK2_IDEAS.md` Performance 분류: "`Future.wait()`로 병렬화하면 다중 상품 시 성능을 개선할 수 있다." | `MARK2_IDEAS.md` |
| Milestone 2 미구현 사유 | WORK_LOG A-29: "Future.wait 전략 변경 금지" 규칙 적용. `A33_MILESTONE2_CLOSURE.md` PART 6: "다음 Milestone 이관" 확인. | WORK_LOG A-29, `A33_MILESTONE2_CLOSURE.md` PART 6 |
| 대상 메서드 현재 상태 | `_sessionRepository.addItem()`은 `booking_completion_caller.dart` 외부에 있음. 현재 Caller 코드에서 순차 `await`로만 호출됨. | `lib/features/booking/data/booking_completion_caller.dart:63~72` |
| A-25 계약(Milestone 2 이전) | `MARK2_IDEAS.md`: "A-25 계약('순서 변경 금지', 'parallel 금지')을 준수하기 위해 보류." | `MARK2_IDEAS.md` |

### REQ-M3-2: 미매칭 상품 명시적 정책 (확인 가능한 범위)

| 항목 | 확인된 내용 | 근거 |
|---|---|---|
| 현재 구현 형태 | `booking_completion_caller.dart:65~66`: `final product = products.where((p) => p.id == id).firstOrNull;` → `if (product == null) continue;` silent skip. | `lib/features/booking/data/booking_completion_caller.dart:65~66` |
| 변경 방향 (확인 가능 범위) | `MARK2_IDEAS.md` Technical Debt 분류: "감지할 로깅/예외가 없어 운영 시 추적이 어렵다." "로깅/예외" 두 가지가 후보로 언급됨. | `MARK2_IDEAS.md` |
| Milestone 2 미구현 사유 | WORK_LOG A-29: "Logging 정책 추가 금지" 규칙 적용. `A33_MILESTONE2_CLOSURE.md` PART 6: "다음 Milestone 이관" 확인. | WORK_LOG A-29, `A33_MILESTONE2_CLOSURE.md` PART 6 |
| 정책 형태 | 미결정 — 로깅 vs 예외 중 어느 것인지 `MARK2_IDEAS.md`, `A28_5_INTERFACE_CONTRACT_DEFINITION.md`(IC-5), `A33_MILESTONE2_CLOSURE.md` 모두 "미확인" 상태로 기록. | `MARK2_IDEAS.md`, `A28_5_INTERFACE_CONTRACT_DEFINITION.md` PART 5 IC-5, `A33_MILESTONE2_CLOSURE.md` PART 3 IC-5 |
| 기존 동일 패턴 | `MARK2_IDEAS.md`: "`computeEndAt()`의 `firstOrNull`도 동일하게 조용히 무시하는 패턴이라 일관성은 유지됨." | `MARK2_IDEAS.md` Technical Debt 분류 |

### REQ-M3-3: 복수 Promotion 중첩 정책 (확인 가능한 범위)

| 항목 | 확인된 내용 | 근거 |
|---|---|---|
| 현재 구현 형태 | `promotion_engine.dart:30`: 주석 "할인 중첩(여러 Rule 동시 적용)은 A-11 MVP 범위 밖이다 — 항상 최우선 Rule 1개만 적용한다". `calcDiscount()` 내부: `candidates.first` — 단 1개 Rule만 반환. | `lib/features/promotion/logic/promotion_engine.dart:30,52` |
| ADR-005 상태 | `docs/adr/` 내 ADR-004까지만 존재. ADR-005 파일 없음. `A12_STAFF_EARNING_ARCHITECTURE.md`: "ADR-005는 미존재 확인됨 — `docs/adr/`에 ADR-001~ADR-004까지만 존재". | `docs/adr/` 파일 목록, `A12_STAFF_EARNING_ARCHITECTURE.md` |
| 보류 경위 | `A12_STAFF_EARNING_ARCHITECTURE.md`: "ADR-005 — A-11.5에서 권장안은 제시했으나 정책이 하나로 확정되지 않아 ADR 작성을 보류". | `A12_STAFF_EARNING_ARCHITECTURE.md` |
| 분석 문서 | `docs/A11_5_PROMOTION_EXPANSION_PLAN.md` 존재 확인. PART 3에 할인 중첩 정책 비교 기록됨. | `docs/A11_5_PROMOTION_EXPANSION_PLAN.md` |
| PROJECT_ROADMAP 명시 | `PROJECT_ROADMAP.md` §Future: "A-11.5에서 식별한 복수 Promotion 중첩 정책(ADR-005 미작성으로 보류됨)". | `docs/PROJECT_ROADMAP.md` §Future |

### REQ-M3-4: TOCTOU 동시성 대응 (확인 가능한 범위)

| 항목 | 확인된 내용 | 근거 |
|---|---|---|
| 문제 정의 | `A13_CONCURRENCY_VALIDATION.md` PART 3: "`closeSession()` 내 2번(상태 확인)과 8번(상태 쓰기) 사이를 원자적 연산으로 묶는 것이 없다 — TOCTOU(Time-Of-Check to Time-Of-Use) 레이스". | `docs/A13_CONCURRENCY_VALIDATION.md` |
| 현재 위험 시나리오 | `A13_CONCURRENCY_VALIDATION.md` PART 1: "UI 중복 클릭 — 가장 현실적으로 발생 가능. 두 `closeSession()` 호출이 모두 `status='open'` 확인 후 진행 → `payment_method_breakdowns`/`staff_earning_ledgers` 중복 기록." | `docs/A13_CONCURRENCY_VALIDATION.md` PART 1 |
| ADR-007 이관 결정 | `ADR-007-a13-mvp-transaction-scope.md`: "문제 2(동시 실행/TOCTOU)에 대한 대응은 A-13 MVP에서 구현하지 않고 A-14 이후로 명시적으로 이관한다." | `docs/adr/ADR-007-a13-mvp-transaction-scope.md` |
| ADR-007 명시 사항 | `ADR-007-a13-mvp-transaction-scope.md`: "A-13 완료 후에도 동시 실행(TOCTOU) 위험은 코드상 그대로 남는다 — 알려진 채로 남겨두는 부채." | `docs/adr/ADR-007-a13-mvp-transaction-scope.md` |
| `MILESTONE_1` 이관 기록 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`: "TOCTOU 동시성 대응 — ADR-007에서 의도적 이관. UI 연결 전 재평가 필요." | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` |
| 조건부 UPDATE 방향 | `A13_CONCURRENCY_VALIDATION.md` PART 3: "조건부 UPDATE(`UPDATE … WHERE status='open'`, 영향 행 수 0이면 중단) 방향 언급됨 — 단, 본 문서는 결론을 내리지 않는다." | `docs/A13_CONCURRENCY_VALIDATION.md` PART 3 |
| 대응 방식 결정 상태 | 미결정 — `A13_CONCURRENCY_VALIDATION.md` 결론 없음. `PROJECT_ROADMAP.md` §Future "처리" 이상의 상세 없음. | `docs/A13_CONCURRENCY_VALIDATION.md`, `docs/PROJECT_ROADMAP.md` §Future |

---

## PART 2 — Requirement Relationship Traceability

| Requirement | 관련 코드 | 관련 문서 | 관련 Commit | 근거 |
|---|---|---|---|---|
| **REQ-M3-1** | `lib/features/booking/data/booking_completion_caller.dart:63~72` (순차 for loop) | `MARK2_IDEAS.md` (Performance 분류), `A33_MILESTONE2_CLOSURE.md` PART 6 | `a12190b` (A-25 BookingCompletionCaller 구현) | `MARK2_IDEAS.md`, `booking_completion_caller.dart` 직접 확인 |
| **REQ-M3-2** | `lib/features/booking/data/booking_completion_caller.dart:65~66` (`if (product == null) continue;`) | `MARK2_IDEAS.md` (Technical Debt 분류), `A28_5_INTERFACE_CONTRACT_DEFINITION.md` IC-5, `A33_MILESTONE2_CLOSURE.md` PART 3 | `a12190b` (A-25 BookingCompletionCaller 구현) | `MARK2_IDEAS.md`, `booking_completion_caller.dart` 직접 확인 |
| **REQ-M3-3** | `lib/features/promotion/logic/promotion_engine.dart:30,52` (단일 Rule 적용) | `PROJECT_ROADMAP.md` §Future, `A11_5_PROMOTION_EXPANSION_PLAN.md`, `A12_STAFF_EARNING_ARCHITECTURE.md` | 미확인 | `PROJECT_ROADMAP.md` §Future 명시, `promotion_engine.dart` 직접 확인 |
| **REQ-M3-4** | 미확인 (대상 코드: `closeSession()` 내부 추정되나 `A13_CONCURRENCY_VALIDATION.md` 기준) | `PROJECT_ROADMAP.md` §Future, `A13_CONCURRENCY_VALIDATION.md`, `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `ADR-007-a13-mvp-transaction-scope.md` | 미확인 | `PROJECT_ROADMAP.md` §Future, ADR-007 이관 결정 |

---

## PART 3 — Existing Structure Observation

Requirement와 연결되는 기존 구조:

| Component | 현재 역할 | 근거 |
|---|---|---|
| `BookingCompletionCaller` (`lib/features/booking/data/booking_completion_caller.dart`) | Booking 완료 → Session 생성 흐름 오케스트레이션. `completeBooking()` → `createSession()` → `watchProducts().first` → productIdsCsv 파싱 → `addItem() × N` 순차 실행. | `lib/features/booking/data/booking_completion_caller.dart` |
| `SessionRepository.addItem()` | Session Item 1건 저장. `BookingCompletionCaller`에서 for loop 내 순차 `await`로 N회 호출됨. | `lib/features/booking/data/booking_completion_caller.dart:67~72`, `lib/features/session/data/session_repository.dart` |
| `PromotionEngine.calcDiscount()` (`lib/features/promotion/logic/promotion_engine.dart`) | 단일 순수 계산 클래스. 현재 `priority` 최우선 Rule 1개만 반환. 할인 중첩 미지원 — 코드 주석에 "A-11 MVP 범위 밖"으로 명시. | `lib/features/promotion/logic/promotion_engine.dart:30` |
| `closeSession()` (`lib/features/session/data/session_repository.dart`) | Session 마감 워크플로. A-12.7 분석에서 TOCTOU 위험 구간(2번 상태 확인 ~ 8번 상태 변경)이 비원자적으로 실행됨이 확인됨. | `docs/A13_CONCURRENCY_VALIDATION.md` PART 1, PART 3 |
| ADR-007 (`docs/adr/ADR-007-a13-mvp-transaction-scope.md`) | A-13 MVP Transaction Scope 결정. TOCTOU 대응을 "A-14 이후로 이관" 명시. 현재 알려진 부채로 기록됨. | `docs/adr/ADR-007-a13-mvp-transaction-scope.md` |

---

## PART 4 — Missing Evidence Observation

| Requirement | 미확인 항목 | 근거 |
|---|---|---|
| **REQ-M3-1** | 관련 ADR 없음. 병렬화 전략 세부사항(오류 처리, Future.wait 스코프 범위) 관련 문서 없음. | `MARK2_IDEAS.md`: "Future.wait()로 병렬화" 이상의 상세 없음 |
| **REQ-M3-2** | 관련 ADR 없음. 정책 형태(로깅 vs 예외) 결정 문서 없음. IC-5가 "미확인" 상태로 종료됨. | `A28_5_INTERFACE_CONTRACT_DEFINITION.md` PART 5 IC-5, `A33_MILESTONE2_CLOSURE.md` PART 3 |
| **REQ-M3-3** | ADR-005 파일 없음(`docs/adr/`에 ADR-004까지만 존재). 중첩 정책 결정 문서 없음. `A11_5_PROMOTION_EXPANSION_PLAN.md`에 비교 기록만 있고 결론 없음. 관련 Commit 없음. | `docs/adr/` 파일 목록, `A12_STAFF_EARNING_ARCHITECTURE.md` |
| **REQ-M3-4** | 대응 방식 결정 문서 없음. 대상 코드 위치가 명시된 문서 없음(`A13_CONCURRENCY_VALIDATION.md`에 문제는 분석됐으나 결론 없음). 관련 Commit 없음. | `docs/A13_CONCURRENCY_VALIDATION.md` PART 3: "본 문서는 결론을 내리지 않는다", `docs/adr/ADR-007-a13-mvp-transaction-scope.md` |

---

## PART 5 — Analysis Status

| Requirement | 상태 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` `Future.wait()` 병렬화 | **확인됨** | 변경 대상 코드(`booking_completion_caller.dart:63~72`), 변경 방향(`MARK2_IDEAS.md`), Milestone 2 이관 이유(WORK_LOG A-29) 전부 문서/코드에서 확인됨. |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | **일부 확인됨** | 변경 대상 코드(`booking_completion_caller.dart:65~66`), 변경 방향("로깅 또는 예외"), Milestone 2 이관 이유 확인됨. 정책 형태(로깅 vs 예외) 미결정 — `MARK2_IDEAS.md`/IC-5 모두 미확인 상태. |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | **일부 확인됨** | 현재 단일 Rule 구조(`promotion_engine.dart:52`), ADR-005 미작성, 분석 문서(`A11_5_PROMOTION_EXPANSION_PLAN.md`) 존재 확인됨. 중첩 정책 결정 없음. |
| **REQ-M3-4** TOCTOU 동시성 대응 | **일부 확인됨** | 문제 정의(`A13_CONCURRENCY_VALIDATION.md`), ADR-007 이관 결정, `MILESTONE_1` 이관 기록 확인됨. 대응 방식 및 대상 코드 위치 미결정. |

---

## Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 11.9s)
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

코드 변경 없음. 이 문서는 순수 Requirement Analysis 작업이다.

---

**"Milestone 3 Requirement Analysis Established"**
