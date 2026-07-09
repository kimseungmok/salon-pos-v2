# A-36: Milestone 3 Design Definition

> **목적**: Milestone 3 Requirement와 Analysis를 기반으로 Design Decision을 정의한다. 새로운 기능을 생성하지 않는다 — Requirement, Analysis, 코드, Commit에 명시적으로 존재하는 정보를 바탕으로 기존 구조 안에서 적용 위치와 Design Decision을 정의한다.
> **제약**: Design Definition만 수행. Implementation 금지. Interface Contract 생성 금지. 새로운 Requirement 생성 금지. 추론 금지.
> **기준 자료**: `docs/PROJECT_ROADMAP.md`, `docs/MARK2_IDEAS.md`, `docs/A34_MILESTONE3_REQUIREMENT.md`, `docs/A35_REQUIREMENT_ANALYSIS.md`, `docs/A33_MILESTONE2_CLOSURE.md`, 실제 코드, 실제 Commit
> 작성일: 2026-07-09

---

## PART 0.5 — Requirement Baseline Verification

A-35 Requirement Analysis 상태 확인:

| Requirement | 상태 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` `Future.wait()` 병렬화 | **확인됨** | `A35_REQUIREMENT_ANALYSIS.md` PART 5: "확인됨". 변경 대상 코드, 변경 방향, 이관 이유 전부 확인됨. |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | **일부 확인됨** | `A35_REQUIREMENT_ANALYSIS.md` PART 5: "일부 확인됨". 변경 대상 코드 확인됨. 정책 형태(로깅 vs 예외) 미결정. |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | **일부 확인됨** | `A35_REQUIREMENT_ANALYSIS.md` PART 5: "일부 확인됨". 현재 단일 Rule 구조 확인됨. ADR-005 미작성. 중첩 정책 미결정. |
| **REQ-M3-4** TOCTOU 동시성 대응 | **일부 확인됨** | `A35_REQUIREMENT_ANALYSIS.md` PART 5: "일부 확인됨". 문제 정의/ADR-007 이관 결정 확인됨. A-35 작성 시점에 대응 방식·코드 위치 미확인으로 기록됨. |

> **추가 확인 사항(A-36 기준 자료 조사에서 발견)**: `lib/features/session/workflow/session_closing_workflow.dart:86~103`에 A-18.3(WORK_LOG "A-18.3: Conditional Update Implementation")에서 이미 Conditional UPDATE(`WHERE status='open'` 조건 + 영향 행 수 0이면 `BusinessRuleException`) 구현 완료됨. 이는 `A13_CONCURRENCY_VALIDATION.md` PART 3에서 언급된 TOCTOU 해결 방향과 일치한다. A-35에서 "미확인"으로 기록된 "대응 방식·코드 위치"는 실제 코드상 A-18.3에서 이미 구현된 상태였다.

> **적용 규칙**: REQ-M3-1 → Design 대상. REQ-M3-2/M3-3 → 확인된 범위만 Design 대상. REQ-M3-4 → A-36 기준 자료 조사 결과를 반영하여 PART 1에서 상태 기록.

---

## PART 1 — Design Decision Inventory

| Requirement | Design Decision | 근거 | 상태 |
|---|---|---|---|
| **REQ-M3-1** | **DD-1**: `booking_completion_caller.dart:63~72` 순차 for loop `await`를 `Future.wait()` 병렬 호출로 변경 | `MARK2_IDEAS.md` Performance 분류: "`Future.wait()`로 병렬화". `A35_REQUIREMENT_ANALYSIS.md` PART 1: 변경 대상 코드 확인됨 | **정의됨** |
| **REQ-M3-2** | **DD-2**: `booking_completion_caller.dart:65~66` `if (product == null) continue;` silent skip을 명시적 처리로 변경 | `MARK2_IDEAS.md` Technical Debt 분류: "로깅/예외가 없어 운영 시 추적이 어렵다". `A35_REQUIREMENT_ANALYSIS.md` PART 1: 변경 대상 코드 확인됨 | **일부 정의됨** — 변경 위치 정의됨. 정책 형태(로깅 vs 예외) 미결정 |
| **REQ-M3-3** | **DD-3**: `promotion_engine.dart` `calcDiscount()` 내 단일 Rule 선택 구조(`candidates.first`) 변경 위치 확인 | `PROJECT_ROADMAP.md` §Future: "ADR-005 미작성으로 보류됨". `promotion_engine.dart:52`: 단일 Rule 구조 확인됨 | **일부 정의됨** — 변경 위치 정의됨. 중첩 정책(ADR-005) 미결정으로 구체적 변경 내용 미정 |
| **REQ-M3-4** | **DD-4**: A-18.3에서 이미 Conditional UPDATE 구현 완료됨 — 추가 Design 불필요 | WORK_LOG "A-18.3: Conditional Update Implementation". `session_closing_workflow.dart:86~103`: `WHERE status='open'` 조건부 UPDATE + 영향 행 수 0이면 `BusinessRuleException` 기록됨 | **미확인** — PROJECT_ROADMAP §Future에 여전히 이관 항목으로 기재. 코드 구현 상태와 Roadmap 문서 간 불일치가 존재하며, 이 불일치 해소는 이번 Design 범위 밖 |

---

## PART 2 — Minimal Change Design

기존 구조 안에서 확인된 변경 위치:

### DD-1: `addItem()` 병렬화 (REQ-M3-1)

| 항목 | 내용 |
|---|---|
| **변경 위치** | `lib/features/booking/data/booking_completion_caller.dart:63~72` |
| **기존 코드 형태** | `for (final id in productIds) { ... await _sessionRepository.addItem(...); }` 순차 for loop |
| **변경 방향** | `Future.wait(productIds.map((id) => ...))` 형태로 변경 |
| **근거 코드** | `lib/features/booking/data/booking_completion_caller.dart:63~72` |
| **변경 목적** | `MARK2_IDEAS.md` Performance 분류: "다중 상품 시 성능을 개선할 수 있다" |

### DD-2: 미매칭 상품 명시적 정책 (REQ-M3-2)

| 항목 | 내용 |
|---|---|
| **변경 위치** | `lib/features/booking/data/booking_completion_caller.dart:65~66` |
| **기존 코드 형태** | `final product = products.where((p) => p.id == id).firstOrNull;` → `if (product == null) continue;` |
| **변경 방향** | silent skip을 명시적 처리로 변경. 구체적 형태(로깅 vs 예외) 미결정 |
| **근거 코드** | `lib/features/booking/data/booking_completion_caller.dart:65~66` |
| **변경 목적** | `MARK2_IDEAS.md` Technical Debt 분류: "감지할 로깅/예외가 없어 운영 시 추적이 어렵다" |

### DD-3: Promotion 중첩 정책 변경 위치 (REQ-M3-3)

| 항목 | 내용 |
|---|---|
| **변경 위치** | `lib/features/promotion/logic/promotion_engine.dart:52` (`candidates.first` 단일 Rule 반환 부분) |
| **기존 코드 형태** | `candidates.first` — priority 최우선 Rule 1개만 반환 |
| **변경 방향** | 중첩 정책 확정 후 변경 가능. 정책(ADR-005) 미결정으로 변경 내용 미정 |
| **근거 코드** | `lib/features/promotion/logic/promotion_engine.dart:30~52` |
| **변경 목적** | `PROJECT_ROADMAP.md` §Future: "복수 Promotion 중첩 정책(ADR-005 미작성으로 보류됨)" |

### DD-4: TOCTOU (REQ-M3-4) — 기존 구현 상태 확인

| 항목 | 내용 |
|---|---|
| **기존 구현** | `lib/features/session/workflow/session_closing_workflow.dart:86~103` — A-18.3에서 이미 Conditional UPDATE 구현됨 |
| **기존 코드 형태** | `UPDATE paymentSessions WHERE id=? AND status='open'` → 영향 행 수 0이면 `BusinessRuleException` |
| **Roadmap 상태** | `PROJECT_ROADMAP.md` §Future: "TOCTOU 대응 처리" 여전히 이관 항목으로 기재 |
| **관찰 결과** | 코드와 Roadmap 간 불일치 상태. 이 불일치 해소는 이번 Design 범위 밖 |

---

## PART 3 — Existing Structure Observation

| 구조 | 역할 | 근거 |
|---|---|---|
| `BookingCompletionCaller` (`lib/features/booking/data/booking_completion_caller.dart`) | Booking 완료 → Session 생성 오케스트레이션. `complete()` 내부에서 `completeBooking()` → `createSession()` → `watchProducts().first` → CSV 파싱 → `addItem() × N` 순차 실행. DD-1/DD-2 변경 대상. | `lib/features/booking/data/booking_completion_caller.dart:30~79` |
| `SessionRepository.addItem()` (`lib/features/session/data/session_repository.dart`) | Session Item 1건 저장. 현재 `BookingCompletionCaller.complete()` for loop에서 순차 `await`로 N회 호출됨. DD-1 병렬화 대상 메서드의 호출 대상. | `lib/features/session/data/session_repository.dart:158~`, `booking_completion_caller.dart:67~72` |
| `PromotionEngine.calcDiscount()` (`lib/features/promotion/logic/promotion_engine.dart`) | 순수 계산 클래스. 현재 `priority` 최우선 Rule 1개(`candidates.first`)만 반환. 코드 주석: "할인 중첩(여러 Rule 동시 적용)은 A-11 MVP 범위 밖". DD-3 변경 위치. | `lib/features/promotion/logic/promotion_engine.dart:30,52` |
| `SessionClosingWorkflow.run()` (`lib/features/session/workflow/session_closing_workflow.dart`) | Session 마감 워크플로. A-18.3에서 Conditional UPDATE 구현됨. 코드 주석: "A-18.3(ADR-007 범위 내 Minimal Change)". REQ-M3-4의 코드 대응이 이미 완료된 위치. | `lib/features/session/workflow/session_closing_workflow.dart:86~103` |
| ADR-007 (`docs/adr/ADR-007-a13-mvp-transaction-scope.md`) | TOCTOU 대응을 "A-14 이후로 이관" 결정. A-18.3에서 해당 대응이 이미 구현됨. Roadmap §Future에는 여전히 이관 항목으로 기재된 상태. | `docs/adr/ADR-007-a13-mvp-transaction-scope.md`, WORK_LOG A-18.3 |

---

## PART 4 — Design Decision Traceability

| Design Decision | Requirement | Analysis | 근거 코드 | 관련 Commit | 근거 |
|---|---|---|---|---|---|
| **DD-1** `addItem()` `Future.wait()` 병렬화 | REQ-M3-1: `MARK2_IDEAS.md` Performance 분류 | `A35_REQUIREMENT_ANALYSIS.md` PART 1: 변경 대상 코드 확인됨, A-25 계약 이관 사유 확인됨 | `booking_completion_caller.dart:63~72` 순차 for loop | `a12190b`(A-25 구현 — 순차 loop 포함) | Requirement(`MARK2_IDEAS.md`) + Analysis(`A35`) + 코드(`booking_completion_caller.dart`) |
| **DD-2** 미매칭 상품 명시적 정책 | REQ-M3-2: `MARK2_IDEAS.md` Technical Debt 분류 | `A35_REQUIREMENT_ANALYSIS.md` PART 1: 변경 대상 코드 확인됨, 정책 형태 미결정 확인됨 | `booking_completion_caller.dart:65~66` silent skip | `a12190b`(A-25 구현 — silent skip 포함) | Requirement(`MARK2_IDEAS.md`) + Analysis(`A35`) + 코드(`booking_completion_caller.dart`) |
| **DD-3** Promotion 중첩 정책 변경 위치 | REQ-M3-3: `PROJECT_ROADMAP.md` §Future | `A35_REQUIREMENT_ANALYSIS.md` PART 1: 단일 Rule 구조 확인됨, ADR-005 미작성 확인됨 | `promotion_engine.dart:52` `candidates.first` | 미확인 | Requirement(`PROJECT_ROADMAP.md`) + Analysis(`A35`) + 코드(`promotion_engine.dart`) |
| **DD-4** TOCTOU 기존 구현 상태 확인 | REQ-M3-4: `PROJECT_ROADMAP.md` §Future | `A35_REQUIREMENT_ANALYSIS.md` PART 1: 문제 정의/ADR-007 이관 결정 확인됨 | `session_closing_workflow.dart:86~103` Conditional UPDATE | WORK_LOG A-18.3(Conditional Update Implementation) | Analysis(`A35`) + 코드(`session_closing_workflow.dart`) + Commit(WORK_LOG A-18.3) |

---

## PART 5 — Design Evidence Missing Observation

| Requirement | 미확인 항목 | 근거 |
|---|---|---|
| **REQ-M3-1** | DD-1 구현 후 `Future.wait()` 내 오류 처리 방식(하나 실패 시 전체 롤백 vs 부분 실패 허용) 관련 문서 없음. 관련 ADR 없음. | `MARK2_IDEAS.md`: "Future.wait()로 병렬화" 이상의 상세 없음 |
| **REQ-M3-2** | 정책 형태(로깅 vs 예외) 결정 문서 없음. 관련 ADR 없음. `MARK2_IDEAS.md`: "로깅/예외" 두 가지 후보 기재, 결정 없음. IC-5: "미확인" 상태(`A33_MILESTONE2_CLOSURE.md` PART 3) | `MARK2_IDEAS.md`, `A28_5_INTERFACE_CONTRACT_DEFINITION.md` PART 5 IC-5 |
| **REQ-M3-3** | ADR-005 파일 없음(`docs/adr/`에 ADR-004까지만 존재). 중첩 정책 결정 문서 없음. `A11_5_PROMOTION_EXPANSION_PLAN.md` PART 3에 비교 기록은 있으나 결론 없음. 관련 Commit 없음. | `docs/adr/` 파일 목록, `A12_STAFF_EARNING_ARCHITECTURE.md` |
| **REQ-M3-4** | `PROJECT_ROADMAP.md` §Future와 `session_closing_workflow.dart:86~103` A-18.3 구현 간 불일치 해소 문서 없음. Roadmap 갱신 없이 이관 항목으로 기재된 상태. | `PROJECT_ROADMAP.md` §Future, WORK_LOG A-18.3, `session_closing_workflow.dart:86~103` |

---

## PART 6 — Design Status

| Design Decision | 상태 | 근거 |
|---|---|---|
| **DD-1** `addItem()` `Future.wait()` 병렬화 | **정의됨** | 변경 위치(`booking_completion_caller.dart:63~72`), 변경 방향(`Future.wait()`), Requirement 근거(`MARK2_IDEAS.md`) 전부 확인됨 |
| **DD-2** 미매칭 상품 명시적 정책 | **일부 정의됨** | 변경 위치(`booking_completion_caller.dart:65~66`) 정의됨. 정책 형태(로깅 vs 예외) 미결정 — `MARK2_IDEAS.md`/IC-5 모두 미확인 |
| **DD-3** Promotion 중첩 정책 변경 위치 | **일부 정의됨** | 변경 위치(`promotion_engine.dart:52`) 정의됨. 중첩 정책(ADR-005) 미결정으로 변경 내용 미정 |
| **DD-4** TOCTOU 기존 구현 상태 | **미확인** | 코드상 A-18.3에서 구현 완료됨. 단 `PROJECT_ROADMAP.md` §Future가 여전히 이관 항목으로 기재 — 코드/Roadmap 불일치 상태로, 이번 Design 범위에서 Design Decision으로 정의 불가 |

---

## Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 9.6s)
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

코드 변경 없음. 이 문서는 순수 Design Definition 작업이다.

---

**"Milestone 3 Design Established"**
