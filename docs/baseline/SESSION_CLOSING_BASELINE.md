# Session Closing Baseline

> **목적**: A-14~A-18에서 확정된 Session Closing(`closeSession()`) 구조를 프로젝트의 공식 Baseline으로 문서화한다. 새 분석/설계 없음 — 기존 문서와 코드에서 확인된 내용만 기록한다.
> **대상 코드**: `lib/features/session/data/session_repository.dart`, `lib/features/session/workflow/session_closing_workflow.dart`, `lib/features/staff_earning/logic/staff_earning_engine.dart`
> **근거 문서**: ADR-001/003/006/007, `docs/A13_*.md`, `docs/A14_*.md`, `docs/A15_WORKFLOW_RESPONSIBILITY_REFINEMENT.md`, `docs/A16_ARCHITECTURE_FINALIZATION.md`, `docs/A17_OPERATIONAL_STABILITY_CHECK.md`, `docs/A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md`, `docs/A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md`
> 작성일: 2026-06-30

---

## PART 1 — 최종 구조 정리

### `SessionRepository`

- **역할**: `payment_sessions`/`payment_session_items`/`staff_earning_ledgers`/`payment_method_breakdowns` 4개 테이블에 대한 CRUD 및 `closeSession()` 호출 전 검증 절차의 진입점.
- **책임**: `closeSession()` 기준으로 (1) 입력 형식 검증, (2) 세션 조회+상태 가드(`_requireSession()`), (3) Settlement 합계 검증(`paidTotal == finalAmount`), (4) `SessionClosingWorkflow.run()` 호출, (5) 재조회 후 반환, (6) 예외 처리(`rethrow`/`DatabaseException.writeFailed` 래핑). `createSession()`/`addItem()`/`cancelSession()`/`getSessionSummary()`/`calcSuggestedTimeFee()`/`calcSuggestedDiscount()`는 A-14 이후 무변경.
- **호출 관계**: `closeSession()` → `SessionClosingWorkflow.run()`(1회 호출, `await`로 대기) → 재조회. `SessionRepository`는 `SessionClosingWorkflow`를 생성자에서 직접 생성해 보유(`_sessionClosingWorkflow` 필드, Provider 경유 없음).

### `SessionClosingWorkflow`

- **역할**: `closeSession()`의 Workflow Coordination 책임(Settlement 저장 → `StaffEarningEngine` 호출 → Ledger 저장 → Session 상태 변경)을 수행하는 단일 목적 클래스.
- **책임**: `run({sessionId, paymentMethods, now})` 메서드 1개. 내부에서 `_db.transaction()` 콜백 하나를 통해 (1) `payment_method_breakdowns` insert, (2) `payment_session_items` 조회 후 `EarnableItem` 변환, (3) `StaffEarningEngine.calcEarnings()` 호출, (4) 결과가 있으면 `staff_earning_ledgers` insert(조건부), (5) `payment_sessions` 상태를 `WHERE status='open'` 조건으로 갱신하고 영향 행 수가 0이면 `BusinessRuleException`을 던짐(Conditional Update). 호출자(`SessionRepository`)의 검증을 다시 수행하지 않는다.
- **호출 관계**: `SessionRepository.closeSession()`에서만 호출됨(코드 전체에서 호출처 1곳). `AppDatabase`와 `StaffEarningEngine`을 생성자로 받아 보유.

### `StaffEarningEngine`

- **역할**: 직원 수익을 계산하는 순수 계산 클래스.
- **책임**: `calcEarnings({items, rule})` — `itemType == 'staff_fee'`이고 `staffId`가 있는 품목마다 `StaffEarningResult`(할인 전 금액 기준)를 계산해 반환. DB/Repository/Workflow 어느 것도 모름(ADR-001).
- **호출 관계**: `SessionClosingWorkflow.run()` 내부에서 1회 호출됨. 이 Engine은 누구에게도 의존하지 않고, 호출만 당한다.

### Transaction Boundary

- **역할**: Settlement 저장~Session 상태 변경 구간의 원자성 보장(ADR-007).
- **책임**: `SessionClosingWorkflow.run()` 안의 단일 `_db.transaction(() async { ... })` 콜백이 결제수단 insert/품목조회/Ledger insert/상태변경(Conditional Update 포함) 전부를 감싼다 — 콜백 내부에서 예외가 발생하면(가드 미통과 포함) 그 호출의 모든 쓰기가 rollback된다.
- **호출 관계**: `SessionRepository.closeSession()`의 검증(입력형식/세션조회·가드/Settlement계산)은 이 Transaction **밖**에서 수행되고, `SessionClosingWorkflow.run()` 호출부터 Transaction **안**으로 들어간다.

---

## PART 2 — 확정된 설계 결정 정리(A-14~A-18에서 확정된 것만)

| 결정 | 내용 | 근거 |
|---|---|---|
| Repository Responsibility | `SessionRepository`는 CRUD+호출 전 검증+Workflow 호출만 수행, Workflow 추출 이후 추가 책임을 떠안지 않음 | `docs/A16_ARCHITECTURE_FINALIZATION.md` PART3 |
| Workflow Responsibility | `SessionClosingWorkflow`는 마감 절차(Settlement~상태변경) 조율이라는 단일 목적만 수행 | `docs/A14_WORKFLOW_PATTERN_VALIDATION.md` PART4, `docs/A15_WORKFLOW_RESPONSIBILITY_REFINEMENT.md` PART4 |
| Transaction Boundary | Settlement 저장~Session 상태 변경이 단일 Transaction(ADR-007)이며, A-14 Workflow 추출 이후에도 동일 범위로 보존됨 | ADR-007, `docs/A16_ARCHITECTURE_FINALIZATION.md` PART4 |
| Repository-Workflow 간 Drift 접근 Trade-off | `SessionClosingWorkflow`가 `AppDatabase`를 직접 호출(ADR-001 "Repository만 Drift를 안다"는 표현과 어긋남)하는 것은 ADR-007의 Transaction 경계를 보존하기 위한 의도된 Trade-off로 `Accepted` 종결됨(수정 필요 없음으로 확정) | `docs/A14_ARCHITECTURE_TRADEOFF_REVIEW.md` PART2/PART6 |
| Conditional Update | Session 상태 변경 `UPDATE` 문에 `WHERE status='open'` 조건을 추가하고 영향 행 수를 확인 — 0이면 기존 `BusinessRuleException`을 재사용해 던짐(새 Exception 타입 추가 없음) | `docs/A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md` PART6, `lib/features/session/workflow/session_closing_workflow.dart` |
| Race Condition 대응 방식 | 동시 `closeSession()` 호출 시 Conditional Update가 한쪽만 성공시키고 다른 쪽은 `BusinessRuleException`과 함께 해당 호출의 트랜잭션 전체(자신이 쓴 Settlement/Ledger 포함)를 rollback시킴 — `Future.wait()` 기반 테스트로 실제 동작 확인됨 | `docs/A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md`, `test/features/session/session_repository_test.dart`(Race Condition Verification 그룹) |

---

## PART 3 — 검증 결과 정리

| 항목 | 상태 |
|---|---|
| Architecture Review | **Completed** |
| Responsibility Review | **Completed** |
| Runtime Stability | **Completed** |
| Idempotency | **Completed** |
| Race Condition Verification | **Completed** |

---

## PART 4 — 향후 개발 기준

Session Closing 기능을 앞으로 수정할 때 반드시 유지해야 하는 기준(수정 제안/개선 아이디어 없음, 유지 항목만 기록):

- **Repository 책임 유지**: `SessionRepository`는 CRUD 및 호출 전 검증, Workflow 호출만 수행한다 — 새로운 절차 조율 로직을 `SessionRepository`에 직접 추가하지 않는다.
- **Workflow 책임 유지**: `SessionClosingWorkflow`는 Session 마감이라는 단일 목적만 수행한다 — Receipt/Sync 등 다른 종류의 절차를 이 클래스에 추가하지 않는다.
- **Transaction Boundary 유지**: Settlement 저장~Session 상태 변경은 항상 단일 Transaction 안에 있어야 한다(ADR-007) — 이 범위를 좁히거나(부분 실패 위험 재발) 넓히는(외부 I/O를 트랜잭션에 끌어들임) 변경을 하지 않는다.
- **Conditional Update 유지**: Session 상태 변경 `UPDATE` 문은 `WHERE status='open'` 조건과 영향 행 수 확인을 항상 포함해야 한다 — 이 조건을 제거하면 Race Condition 대응이 무력화된다.
- **Public Interface 유지**: `SessionRepository`의 7개 public 메서드(`createSession`/`addItem`/`closeSession`/`cancelSession`/`getSessionSummary`/`calcSuggestedTimeFee`/`calcSuggestedDiscount`) 시그니처, 반환 타입, 예외 계약을 변경하지 않는다.
- **Engine 순수성 유지**: `StaffEarningEngine`(및 `PricingEngine`/`PromotionEngine`)은 Drift/Repository/Workflow 어느 것도 모르는 상태를 유지한다(ADR-001).

---

## PART 5 — 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **369건 전부 통과**(`All tests passed!`) |

---

## PART 6 — 최종 선언

| 확인 항목 | 결과 |
|---|---|
| 구조가 Baseline으로 확정되었는가 | 그렇다(PART1) |
| 기존 설계와 모순이 없는가 | 모순 없다(PART2, A-14~A-18 결정과 일치) |
| 검증 결과가 모두 반영되었는가 | 반영됨(PART3, 5개 항목 전부 `Completed`) |
| 향후 개발 기준이 정리되었는가 | 정리됨(PART4) |

**"Session Closing Baseline Established"**
