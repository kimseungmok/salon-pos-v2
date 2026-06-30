# A-15: Workflow Responsibility Refinement Analysis

> **목적**: A-14 Phase 1 이후 분리된 `SessionClosingWorkflow` 구조를 기준으로 `SessionRepository`-Workflow 간 책임 경계를 더 명확하게 정리한다. 새 설계/계층 없음, Business Logic 변경 없음, 구현 없음(분석만).
> **대상 코드**: `lib/features/session/data/session_repository.dart`, `lib/features/session/workflow/session_closing_workflow.dart`(둘 다 A-14 Phase 1 이후 무변경)
> **근거**: ADR-001~ADR-007, A-14 Phase 1~4(`docs/A14_*.md`)
> 작성일: 2026-06-26

---

## PART 0 — 기준 원칙

A-14 Phase 1~4에서 이미 확인이 완료된 항목은 **"이전과 동일"**로 표기하고 반복 분석하지 않는다. 본 문서가 새로 평가하는 것은 PART5의 "테스트 영향 가능성" 1개 항목뿐이며, 나머지는 전부 기존 A-14 문서의 재확인이다.

---

## PART 1 — Workflow 호출부 책임 정리(`closeSession()` 기준, 실제 코드만)

| 책임 | Repository 유지 | Workflow 이동 여부 | 이유 |
|---|---|---|---|
| 입력 형식 검증(264~271행) | Yes | No | 이전과 동일 — `docs/A14_WORKFLOW_DEPENDENCY_VALIDATION.md` PART2에서 이미 확인. |
| 세션 조회+가드(273~276행, `_requireSession()`) | Yes | No | 이전과 동일. |
| Settlement 검증(합계 비교, 278~280행, 인라인) | Yes | No | 이전과 동일. |
| Settlement 저장(`payment_method_breakdowns` insert) | No | Yes | 이전과 동일 — A-14 Phase 1에서 이동, Phase 2/3에서 재확인. |
| 품목 조회(Ledger 계산용) | No | Yes | 이전과 동일. |
| `StaffEarningEngine.calcEarnings()` 호출 | No | Yes | 이전과 동일. |
| Ledger 저장(조건부) | No | Yes | 이전과 동일. |
| Session 상태 변경 | No | Yes | 이전과 동일. |
| Transaction 시작/관리(`_db.transaction()` 호출) | No | Yes | 이전과 동일 — 다만 이 항목은 ADR-001과의 표현상 어긋남이 있었으나, A-14 Phase 4에서 **`Accepted` Trade-off로 종결됨**(`docs/A14_ARCHITECTURE_TRADEOFF_REVIEW.md` PART2). |
| 재조회+반환값 준비(290~292행) | Yes | No | 이전과 동일. |
| 예외 처리(`rethrow`/`DatabaseException.writeFailed` 래핑) | Yes | No | 이전과 동일. |

---

## PART 2 — Workflow 책임 검증

| 책임 | 현재 구현 여부 | ADR 충돌 여부 |
|---|---|---|
| Settlement 저장(`payment_method_breakdowns` insert) | Yes | OK |
| 품목 조회(`payment_session_items` select) | Yes | OK |
| `PaymentSessionItemRow → EarnableItem` 변환 | Yes | OK — Drift 비의존 POJO로의 변환이라 ADR-001과 합치(이전과 동일). |
| `StaffEarningEngine.calcEarnings()` 호출 | Yes | OK — Engine은 여전히 Drift/Repository/Workflow 어느 것도 모름(이전과 동일, `docs/A14_WORKFLOW_DEPENDENCY_VALIDATION.md` PART4). |
| Ledger 저장(조건부) | Yes | OK |
| Session 상태 변경 | Yes | OK |
| Transaction 관리(`_db.transaction()` 호출 자체) | Yes | **Review**(이전과 동일 — A-14 Phase 4에서 `Accepted` Trade-off로 종결됨, 새로운 결론 없음) |

---

## PART 3 — Public Interface 안정성 확인

| 항목 | 변경 여부 | 영향 |
|---|---|---|
| public method 구조(`createSession`/`addItem`/`closeSession`/`cancelSession`/`getSessionSummary`/`calcSuggestedTimeFee`/`calcSuggestedDiscount`, 7개) | No | 없음 — A-14 Phase 1 이후 시그니처 무변경(코드 확인). |
| 반환 타입(`PaymentSessionRow`/`PaymentSessionItemRow`/`void`/`SessionSummary`/`int`/`PromotionResult`) | No | 없음 — `closeSession()`의 반환 타입(`Future<PaymentSessionRow>`)도 그대로. |
| 예외 계약(`ValidationException`/`BusinessRuleException`/`NotFoundException`/`DatabaseException`의 발생 조건) | No | 없음 — 검증/가드 로직이 전부 `closeSession()` 본문(PART1에서 "Repository 유지"로 분류된 부분)에 그대로 있어, 예외가 발생하는 조건 자체가 바뀌지 않았다. |
| Provider 주입 방식(`sessionRepositoryProvider`가 `pricingRuleRepository`/`pricingEngine`/`promotionRuleRepository`/`promotionEngine`/`staffEarningEngine` 5개 선택적 매개변수를 주입) | No | 없음 — `lib/features/session/providers.dart` 무변경. `SessionClosingWorkflow`는 Provider를 거치지 않고 `SessionRepository` 생성자 내부에서 직접 생성된다(이전과 동일 사실). |

**종합**: Public Interface 4개 측면 전부 `No`(무변경) — A-15 시점까지 외부에서 관찰 가능한 어떤 계약도 깨지지 않았다.

---

## PART 4 — Workflow 내부 응집도 확인

| 항목 | 결과 | 근거 |
|---|---|---|
| 하나의 목적만 수행하는가 | **OK** | `SessionClosingWorkflow`는 `run()` 메서드 1개만 가지며, 그 책임은 "마감 절차 수행"이라는 단일 목적이다(PART2의 6개 책임 전부 이 단일 목적 안에 있음). |
| Repository 책임이 포함되어 있는가 | **Review** | `_db.select()`/`_db.batch()`/`_db.update()` 등 Drift 직접 호출을 포함한다 — 이전과 동일(A-14 Phase 2/3/4에서 이미 식별, Phase 4에서 `Accepted` Trade-off로 종결됨). 새로운 사실이 아니다. |
| 다른 Workflow 성격이 혼재되어 있는가 | **OK** | 코드 전체(92행)를 확인한 결과 `run()` 메서드 1개뿐이며, Receipt/Sync/Promotion Finalize 같은 다른 종류의 절차가 섞여 있지 않다 — A-13 PART3에서 이미 "Promotion Finalize는 Discount SessionItem 생성 시점에 완료된 것으로 보고 `closeSession()`/Workflow가 별도로 다루지 않는다"는 결정(`docs/A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md`)과 일치한다. |

**종합**: 응집도는 높다(`OK` 2건) — 유일한 `Review`는 PART1/2에서 반복 확인된 동일한 Trade-off일 뿐, 새로운 응집도 문제가 아니다.

---

## PART 5 — 이동 가능성 검토(분석만, 실제 이동 없음)

| 항목 | 필요 여부 | 이유 |
|---|---|---|
| Workflow Interface 필요 여부 | **No** | 이전과 동일 — 구현체 1개(`SessionClosingWorkflow`), 호출처 1곳(`SessionRepository.closeSession()`)뿐이라는 사실이 A-14 Phase 2/3/4와 변함없음(코드 무변경 확인). |
| Workflow Provider/DI 구조 필요 여부 | **No** | 이전과 동일 — `SessionRepository` 생성자 내부 직접 생성으로 충분, 별도 주입처가 코드에 없음. |
| Workflow Repository 필요 여부 | **No** | 이전과 동일 — `SessionClosingWorkflow`가 다루는 4개 테이블은 모두 기존 테이블, 신규 영속 데이터가 없음. |
| 테스트 영향 가능성(Workflow 책임을 더 이동할 경우) | **Unknown** | **본 PART에서 새로 평가한 항목** — 이번 오더는 실제 이동을 수행하지 않으므로, "이동했을 때 테스트가 어떻게 영향받을지"를 코드로 확정할 근거가 없다. 가상의 추가 분리(예: Transaction 관리를 어딘가로 다시 옮기는 경우)에 대한 영향을 지금 예측하는 것은 추측에 해당하며, 본 문서는 "실제 이동/구현을 수행하지 않는다"는 제약상 이를 `Yes`/`No`로 단정하지 않는다. |

---

## PART 6 — 테스트 및 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **368건 전부 통과**(`All tests passed!`) — A-14 Phase 1 적용 이후와 동일한 건수, 회귀 없음 |

본 결과는 "현재 상태가 안정적임을 보여주는 기준선"으로만 기록한다 — 어떤 코드도 수정하지 않았으므로 이 결과는 A-14 Phase 4 시점과 동일한 상태의 재확인이다.

---

## PART 7 — 최종 정리

| 확인 항목 | 결과 |
|---|---|
| Workflow 책임 경계가 명확한가 | **명확하다** — PART1(11개 책임 전부 Repository/Workflow 중 한쪽으로 명확히 분류됨), PART4(응집도 `OK` 2건/`Review` 1건, 그 `Review`도 새로운 모호함이 아니라 기존에 식별·종결된 Trade-off). |
| Repository 책임이 유지되고 있는가 | **유지되고 있다** — PART1에서 "Repository 유지"로 분류된 5개 책임(입력검증/세션조회·가드/Settlement검증/재조회/예외처리)이 전부 `closeSession()`에 그대로 남아 있다(PART3에서 Public Interface 무변경으로 재확인). |
| ADR-007 Transaction 경계가 유지되고 있는가 | **유지되고 있다** — PART2에서 확인한 대로 Settlement 저장~상태 변경이 `SessionClosingWorkflow.run()`의 단일 `_db.transaction()` 안에 그대로 있다(코드 무변경). |
| 추가 설계 없이 유지 가능한 구조인가 | **그렇다** — PART5의 3개 항목(Interface/Provider/Repository) 모두 `No`로 확인됐고, PART6의 기준선(analyze 클린, 테스트 368건 통과)이 현재 구조가 안정적으로 동작함을 보여준다. |

### 결론

4개 항목 모두 충족되었다.

**"Workflow Responsibility Refinement 확인 완료"**
