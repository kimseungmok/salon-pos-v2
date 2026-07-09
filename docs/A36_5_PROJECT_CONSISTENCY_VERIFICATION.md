# A-36.5: Milestone 3 Project Consistency Verification

> **목적**: Milestone 3 Requirement, PROJECT_ROADMAP, 현재 프로젝트 구현 상태 사이의 정합성을 확인한다.
> **성격**: 일반 개발 프로세스(Requirement → Analysis → Design → Interface Contract → Implementation)의 일부가 아닌 예외적인 프로젝트 관리 작업. 이후 모든 Milestone에서 반복 수행하는 단계로 사용하지 않는다.
> **제약**: Requirement 변경 금지. Roadmap 수정 금지. Design 변경 금지. Interface Contract 변경 금지. Implementation 금지. 추론 금지.
> **기준 자료**: `docs/PROJECT_ROADMAP.md`, `docs/MARK2_IDEAS.md`, `docs/A34_MILESTONE3_REQUIREMENT.md`, `docs/A35_REQUIREMENT_ANALYSIS.md`, `docs/A36_DESIGN_DEFINITION.md`, `docs/A33_MILESTONE2_CLOSURE.md`, `docs/README.md`, `docs/WORK_LOG.md`, 실제 코드, 실제 Commit, 실제 Verification
> 작성일: 2026-07-09

---

## PART 0.5 — Verification 대상 확인

A-34에서 정의된 Milestone 3 Requirement 상태 확인:

| Requirement | 상태 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` `Future.wait()` 병렬화 | **확인됨** | `A36_DESIGN_DEFINITION.md` PART 0.5, `A35_REQUIREMENT_ANALYSIS.md` PART 5 |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | **일부 확인됨** | `A36_DESIGN_DEFINITION.md` PART 0.5. 정책 형태(로깅 vs 예외) 미결정. |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | **일부 확인됨** | `A36_DESIGN_DEFINITION.md` PART 0.5. ADR-005 미작성, 정책 미결정. |
| **REQ-M3-4** TOCTOU 동시성 대응 | **일부 확인됨** | `A36_DESIGN_DEFINITION.md` PART 0.5. A-18.3 기구현 확인됨. Roadmap/코드 불일치 존재. |

> 미확인 Requirement 없음 — 전체 4건 Consistency Verification 대상.

---

## PART 1 — Project Consistency Verification

Requirement ↔ PROJECT_ROADMAP ↔ 현재 구현 상태 정합성:

### REQ-M3-1: `addItem()` `Future.wait()` 병렬화

| 항목 | 내용 |
|---|---|
| **Roadmap 상태** | `PROJECT_ROADMAP.md` §Future "MARK2 Review": "병렬 `addItem()`" 우선순위 검토 항목으로 기재. |
| **현재 구현 상태** | `lib/features/booking/data/booking_completion_caller.dart:63~72`: 순차 for loop `await` — 병렬화 미구현. |
| **Consistency 상태** | **일치** |
| **근거** | Roadmap: Future 검토 항목. 코드: 순차 loop 미변경. Roadmap과 코드 상태 일치. |

### REQ-M3-2: 미매칭 상품 명시적 정책

| 항목 | 내용 |
|---|---|
| **Roadmap 상태** | `PROJECT_ROADMAP.md` §Future "MARK2 Review": "미매칭 상품 명시적 정책" 우선순위 검토 항목으로 기재. |
| **현재 구현 상태** | `lib/features/booking/data/booking_completion_caller.dart:65~66`: `if (product == null) continue;` silent skip 유지. 명시적 정책 미구현. |
| **Consistency 상태** | **일치** |
| **근거** | Roadmap: Future 검토 항목. 코드: silent skip 미변경. Roadmap과 코드 상태 일치. |

### REQ-M3-3: 복수 Promotion 중첩 정책 (ADR-005)

| 항목 | 내용 |
|---|---|
| **Roadmap 상태** | `PROJECT_ROADMAP.md` §Future "Technical Debt Review": "A-11.5에서 식별한 복수 Promotion 중첩 정책(ADR-005 미작성으로 보류됨)". |
| **현재 구현 상태** | `lib/features/promotion/logic/promotion_engine.dart:52`: `candidates.first` — 단일 Rule만 반환. `docs/adr/`에 ADR-005 파일 없음(ADR-004까지만 존재). |
| **Consistency 상태** | **일치** |
| **근거** | Roadmap: Future 검토 항목(ADR-005 미작성 명시). 코드: 단일 Rule 유지. ADR-005 미작성. Roadmap과 코드/문서 상태 일치. |

### REQ-M3-4: TOCTOU 동시성 대응

| 항목 | 내용 |
|---|---|
| **Roadmap 상태** | `PROJECT_ROADMAP.md` §Future "Technical Debt Review": "TOCTOU 대응(ADR-007에서 의도적으로 이관된 동시성 대응) 처리" — Future 이관 항목으로 기재됨. |
| **현재 구현 상태** | `lib/features/session/workflow/session_closing_workflow.dart:86~103`: A-18.3(WORK_LOG "A-18.3: Conditional Update Implementation")에서 Conditional UPDATE(`WHERE status='open'` 조건 + 영향 행 수 0이면 `BusinessRuleException`) 이미 구현 완료됨. |
| **Consistency 상태** | **불일치** |
| **근거** | Roadmap: "처리" 필요한 Future 항목으로 기재. 코드: `session_closing_workflow.dart:86~103`에 A-18.3 구현 완료. Roadmap이 코드 현실을 반영하지 않음. |

---

## PART 2 — Implementation Presence Observation

| Requirement | 구현 상태 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` `Future.wait()` 병렬화 | **구현 미확인** | `booking_completion_caller.dart:63~72`: 순차 for loop 유지. `Future.wait()` 코드 없음. |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | **구현 미확인** | `booking_completion_caller.dart:65~66`: `if (product == null) continue;` 유지. 로깅/예외 코드 없음. |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | **구현 미확인** | `promotion_engine.dart:52`: `candidates.first` 단일 Rule 반환 유지. ADR-005 파일 없음. |
| **REQ-M3-4** TOCTOU 동시성 대응 | **일부 구현 확인** | `session_closing_workflow.dart:86~103`: A-18.3 Conditional UPDATE 구현됨. 단, `PROJECT_ROADMAP.md` §Future에 여전히 이관 항목으로 기재됨. |

---

## PART 3 — Existing Asset Traceability

| Requirement | 관련 코드 | 관련 Commit | 관련 문서 | 근거 |
|---|---|---|---|---|
| **REQ-M3-1** | `lib/features/booking/data/booking_completion_caller.dart:63~72` | `a12190b`(A-25 구현) | `MARK2_IDEAS.md` (Performance 분류), `A35_REQUIREMENT_ANALYSIS.md` PART 2 | `booking_completion_caller.dart` 직접 확인 |
| **REQ-M3-2** | `lib/features/booking/data/booking_completion_caller.dart:65~66` | `a12190b`(A-25 구현) | `MARK2_IDEAS.md` (Technical Debt 분류), `A35_REQUIREMENT_ANALYSIS.md` PART 2 | `booking_completion_caller.dart` 직접 확인 |
| **REQ-M3-3** | `lib/features/promotion/logic/promotion_engine.dart:52` | 미확인 | `PROJECT_ROADMAP.md` §Future, `A11_5_PROMOTION_EXPANSION_PLAN.md`, `A35_REQUIREMENT_ANALYSIS.md` PART 2 | `promotion_engine.dart` 직접 확인, `docs/adr/` 파일 목록 확인 |
| **REQ-M3-4** | `lib/features/session/workflow/session_closing_workflow.dart:86~103` | WORK_LOG A-18.3(Conditional Update Implementation) | `PROJECT_ROADMAP.md` §Future, `docs/adr/ADR-007-a13-mvp-transaction-scope.md`, `docs/A13_CONCURRENCY_VALIDATION.md`, `A35_REQUIREMENT_ANALYSIS.md` PART 2 | `session_closing_workflow.dart` 직접 확인, WORK_LOG A-18.3 확인 |

---

## PART 4 — Project Consistency Difference Observation

프로젝트 자료 간 정합성 차이:

| 대상 | 차이 내용 | 근거 |
|---|---|---|
| **Roadmap §Future "TOCTOU 대응" ↔ 코드** | `PROJECT_ROADMAP.md` §Future: "TOCTOU 대응(ADR-007에서 의도적으로 이관된 동시성 대응) 처리" — Future 이관 항목. 코드: `session_closing_workflow.dart:86~103`에 A-18.3(WORK_LOG 기록)에서 Conditional UPDATE 구현 완료. Roadmap이 코드 현실을 반영하지 않음. | `PROJECT_ROADMAP.md` §Future, `session_closing_workflow.dart:86~103`, WORK_LOG A-18.3 |
| **Roadmap §Future "Architecture Refactoring Candidate" ↔ 코드** | `PROJECT_ROADMAP.md` §Future: "`BookingRepository`에 단건 조회 메서드 부재로 Caller가 `BookingRow`를 pre-fetch해야 하는 구조 개선(MARK2 항목 1번)". 코드: `lib/features/booking/data/booking_repository.dart:331`: `Future<BookingRow?> getBookingById(int id)` A-29(D-7)에서 이미 구현됨. Roadmap이 코드 현실을 반영하지 않음. | `PROJECT_ROADMAP.md` §Future, `booking_repository.dart:331`, WORK_LOG A-29 |
| **Roadmap §Future "MARK2 Review — 단건 조회 메서드 추가" ↔ 코드** | `PROJECT_ROADMAP.md` §Future "MARK2 Review": "`docs/MARK2_IDEAS.md`에 기록된 3개 아이디어(단건 조회 메서드 추가, 병렬 `addItem()`, 미매칭 상품 명시적 정책) 우선순위 검토". 이 중 "단건 조회 메서드 추가"는 A-29(D-7)에서 구현 완료됨. Roadmap은 3개 아이디어 전체를 검토 대상으로 기재 — 구현 완료 항목이 포함됨. | `PROJECT_ROADMAP.md` §Future, `MARK2_IDEAS.md` Repository 분류, `booking_repository.dart:331`, WORK_LOG A-29 |

---

## PART 5 — Out-of-Scope Observation

이번 Consistency Verification 범위 안에서 확인된, Requirement와 직접 연결되지 않는 항목:

| 항목 | 관찰 결과 | 근거 |
|---|---|---|
| `A33_MILESTONE2_CLOSURE.md` PART 5 Known Limitation "CC-2 `businessType` 값 미확인" | `A33_MILESTONE2_CLOSURE.md` PART 6에서 "다음 Milestone 이관"으로 기재됨. REQ-M3-1~4 중 어느 항목과도 명시적으로 연결되지 않음. `PROJECT_ROADMAP.md` §Future에 관련 항목 없음. | `A33_MILESTONE2_CLOSURE.md` PART 5, `PROJECT_ROADMAP.md` §Future |
| `A33_MILESTONE2_CLOSURE.md` PART 5 Known Limitation "`BookingListScreen` 위젯/통합 테스트 없음" | `A33_MILESTONE2_CLOSURE.md` PART 6에서 "다음 Milestone 이관"으로 기재됨. REQ-M3-1~4 중 어느 항목과도 명시적으로 연결되지 않음. `PROJECT_ROADMAP.md` §Future에 관련 항목 없음. | `A33_MILESTONE2_CLOSURE.md` PART 5, `PROJECT_ROADMAP.md` §Future |

---

## PART 6 — Consistency Result

| Requirement | Consistency 상태 | 근거 |
|---|---|---|
| **REQ-M3-1** `addItem()` `Future.wait()` 병렬화 | **일치** | Roadmap: Future 검토 항목. 코드: 순차 loop 유지. 상태 일치. |
| **REQ-M3-2** 미매칭 상품 명시적 정책 | **일치** | Roadmap: Future 검토 항목. 코드: silent skip 유지. 상태 일치. |
| **REQ-M3-3** 복수 Promotion 중첩 정책 | **일치** | Roadmap: ADR-005 미작성으로 보류 기재. 코드: 단일 Rule 유지. ADR-005 미작성. 상태 일치. |
| **REQ-M3-4** TOCTOU 동시성 대응 | **불일치** | Roadmap: Future 이관 항목. 코드: A-18.3에서 Conditional UPDATE 구현 완료. Roadmap이 코드 현실을 반영하지 않음. |

---

## Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 13.3s)
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

코드 변경 없음. 이 문서는 순수 Consistency Verification 작업이다.

---

**"Milestone 3 Project Consistency Verified"**
