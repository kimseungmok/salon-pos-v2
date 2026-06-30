# A-14 Phase 3: Workflow Pattern Validation

> **목적**: `SessionClosingWorkflow` 구조가 일회성 구현이 아니라 다른 Session 업무에도 동일 패턴으로 적용 가능한지 검증한다. 새 설계/계층/패턴/해결책 제안 없음 — 사실 확인만 수행한다.
> **대상 코드**: `lib/features/session/data/session_repository.dart`, `lib/features/session/workflow/session_closing_workflow.dart`
> **근거**: ADR-001~ADR-007, `docs/A14_WORKFLOW_DEPENDENCY_VALIDATION.md`(A-14 Phase 2)
> **명칭 주의**: `CancelSessionWorkflow`/`ReopenSessionWorkflow` 등은 지시문이 제공한 예시일 뿐이며, 현재 코드에 이런 클래스는 존재하지 않는다(아래 PART2에서 직접 확인). 본 문서는 실제로 존재하는 명칭(`SessionClosingWorkflow`, `SessionRepository`의 각 메서드명)만 분석 대상으로 삼는다.
> 작성일: 2026-06-26

---

## PART 1 — `SessionRepository` 역할 확인

`SessionRepository`의 public 메서드 전체(7개)를 확인한다.

| 메서드 | CRUD 중심 여부 | Workflow 필요 여부 | 현재 구조 적합성 |
|---|---|---|---|
| `createSession()`(103~135행) | Yes — `sessionNo` 생성 후 단일 insert+재조회 | **No** | 적합 — 트랜잭션도 다단계 조율도 없는 단순 절차, Repository 메서드로 충분(A-14 Phase 2 이전부터 무변경). |
| `addItem()`(168~219행) | Yes — insert 후 `_recomputeTotals()` 호출 | **No** — 현재 코드에 트랜잭션이 적용돼 있지 않다(ADR-007의 Transaction Scope는 `closeSession()`에만 한정, 코드 확인) | 적합 — 2단계 절차(insert→재계산)가 있으나 트랜잭션 결합이 없어 `closeSession()`과 같은 종류의 "Workflow 필요" 조건(트랜잭션으로 묶인 다단계 조율)을 충족하지 않는다. |
| `closeSession()`(260~298행) | No — 검증/조율/위임 중심 | **Yes**(이미 적용됨) | 적합 — `SessionClosingWorkflow`로 절차 부분이 분리돼 있다(Phase 1/2에서 검증 완료). |
| `cancelSession()`(305~325행) | Yes — 가드 후 단일 update | **No** | 적합 — 쓰기가 1곳뿐, 조율 대상이 없다. |
| `getSessionSummary()`(328~351행) | Yes — 4개 테이블 조회+조합 | **No** | 적합 — 쓰기 자체가 없어 트랜잭션/조율 개념이 적용되지 않는다. |
| `calcSuggestedTimeFee()`(364행~) | No — Rule 조회+Engine 계산 | **No** | 적합 — DB 쓰기가 없는 "선택적 헬퍼"(A-10부터의 기존 패턴), 트랜잭션 대상이 아니다. |
| `calcSuggestedDiscount()` | No — 위와 동일한 성격 | **No** | 적합 — 위와 동일한 이유. |

**종합**: 7개 public 메서드 중 "Workflow 필요"로 분류된 것은 `closeSession()` 1개뿐이다 — 나머지 6개는 모두 단일 쓰기(또는 쓰기 없음)라 트랜잭션으로 묶을 다단계 절차 자체가 없다.

---

## PART 2 — Workflow Pattern 재사용성 검증

`grep -rln "class.*Workflow" lib/` 실행 결과, **`SessionClosingWorkflow` 1개만 존재한다.** `CancelSessionWorkflow`/`ReopenSessionWorkflow` 같은 클래스는 코드에 없다.

| 대상 업무 | Workflow 적용 가능 여부 | 근거 |
|---|---|---|
| `closeSession()` | **Yes**(이미 적용됨) | `SessionClosingWorkflow`가 실제로 존재하고 호출되고 있다(PART1). |
| `addItem()` | **Partial** | `docs/A14_WORKFLOW_EXTRACTION_READY.md`(A-13.5) PART1에서 이미 "Partial"로 분류된 사실을 재확인 — insert→`_recomputeTotals()`라는 2단계 절차가 존재하나, 트랜잭션으로 묶여 있지 않고 ADR-007의 범위에도 포함되지 않아 `closeSession()`과 동일한 "Workflow가 필요해진 이유"(Transaction Scope 보존)가 현재 코드에는 없다. |
| `cancelSession()` | **No** | 단일 update 1건뿐, 다단계 조율이라 부를 절차가 코드에 없다. |
| `createSession()` | **No** | 단일 insert+재조회, 위와 동일한 이유. |
| `getSessionSummary()` | **No** | 쓰기 자체가 없다. |

**그 외 명시적인 Workflow 책임(예: 별도 문서/주석으로 "이건 Workflow 책임이다"라고 표시된 코드)은 확인되지 않았다 — `closeSession()` 외에는 확인된 후보 없음.**

---

## PART 3 — Workflow와 Repository 경계 검증

| 책임 | 담당 클래스 | 적절성 |
|---|---|---|
| 입력 형식 검증(264~271행) | `SessionRepository`(`closeSession()` 본문) | **OK** |
| 세션 조회+가드(273~276행, `_requireSession()`) | `SessionRepository` | **OK** |
| Settlement 검증(합계 비교, 278~280행) | `SessionRepository`(인라인 로직) | **OK** |
| Settlement 저장(`payment_method_breakdowns` insert) | `SessionClosingWorkflow` | **OK** — ADR-007 Transaction Scope 안 |
| 품목 조회(Ledger 계산용) | `SessionClosingWorkflow` | **OK** |
| `StaffEarningEngine` 호출 | `SessionClosingWorkflow` | **OK** |
| Ledger 저장(조건부) | `SessionClosingWorkflow` | **OK** |
| Session 상태 변경 | `SessionClosingWorkflow` | **OK** |
| **Transaction 시작/관리**(`_db.transaction()` 호출 자체) | `SessionClosingWorkflow` | **Review** — A-14 Phase 2(`A14_WORKFLOW_DEPENDENCY_VALIDATION.md` PART3)에서 이미 동일하게 식별된 사항의 재확인. `SessionClosingWorkflow`가 Drift의 트랜잭션 API를 직접 호출한다는 점이 "Repository만 Drift를 안다"(ADR-001)는 표현과 정확히 일치하는지는 여전히 재검토 지점으로 남아 있다. |
| 재조회+반환값 준비(290~292행) | `SessionRepository` | **OK** |
| 예외 처리(`rethrow`/`writeFailed` 래핑) | `SessionRepository` | **OK** |

**종합**: 11개 책임 중 10개는 `OK`, 1개(Transaction 관리)만 `Review` — Phase 2와 동일한 결론이 Phase 3에서도 그대로 재확인됐다.

---

## PART 4 — 패턴 일관성 확인

| 원칙 | 현재 상태 | 비고 |
|---|---|---|
| Repository는 데이터 접근을 담당한다 | **Review** | `SessionRepository`의 대부분의 메서드는 이 원칙을 따르나, `SessionClosingWorkflow`도 동일하게 Drift 데이터 접근(insert/update/select)을 직접 수행한다 — "데이터 접근"이라는 책임이 두 클래스에 걸쳐 나뉘어 있다(PART3의 Transaction 관리 항목과 같은 근거). |
| Workflow는 업무 절차를 조율한다 | **OK** | `SessionClosingWorkflow.run()`이 정확히 이 역할을 수행한다 — Settlement→Engine호출→Ledger→상태변경이라는 순서를 그대로 보존(A-13과 한 글자도 다르지 않음, Phase 1에서 확인). |
| Engine은 순수 계산만 수행한다 | **OK** | `StaffEarningEngine`(과 `PricingEngine`/`PromotionEngine`)이 Drift/Repository/Workflow 어느 것도 모른다 — Phase 2 PART4에서 이미 확인, 본 문서에서 재확인. |
| Transaction Boundary는 Workflow에서 유지된다 | **OK** | 현재 정확히 그렇다 — `_db.transaction()`이 `SessionClosingWorkflow.run()` 안에 있다(ADR-007 범위와 일치). |

**관찰**: 4개 원칙 중 "Transaction Boundary는 Workflow에서 유지된다"(OK)와 "Repository는 데이터 접근을 담당한다"(Review)는 **서로 긴장 관계에 있다** — Workflow가 트랜잭션을 직접 관리하려면 Drift API(데이터 접근 수단)를 직접 다뤄야 하므로, 첫 번째 원칙을 만족시키는 행위가 그대로 세 번째 원칙(Repository만 데이터 접근)과의 정확한 일치를 어렵게 만든다. 이 긴장 관계는 Phase 2에서 이미 식별된 것과 동일한 구조적 사실이다.

---

## PART 5 — 반복 적용 가능성 평가(현재 코드/ADR만 근거)

| 평가 항목 | 결과 | 근거 |
|---|---|---|
| Workflow 클래스가 공통 인터페이스/베이스 클래스를 갖는가 | **Not Applicable** | `SessionClosingWorkflow`는 구체 클래스 1개뿐이고, 코드에 인터페이스/추상 클래스가 없다(Phase 2 PART5 "Not Required"와 일치하는 사실). |
| `SessionRepository`가 여러 Workflow를 보유하는 구조인가 | **Not Applicable** | `SessionRepository`는 Workflow 필드를 1개(`_sessionClosingWorkflow`)만 가진다 — 여러 Workflow를 다루는 구조(리스트, 팩토리, 레지스트리 등)는 코드에 없다. |
| `addItem()`/`cancelSession()` 등이 이미 같은 패턴(검증→Workflow 위임→재조회)을 따르는가 | **Not Applicable** | PART1에서 확인한 대로 이 메서드들은 Workflow를 호출하지 않고 직접 데이터 접근을 수행한다 — 현재 `closeSession()`만 이 패턴을 따른다. |
| Transaction Boundary를 Workflow가 직접 관리하는 방식이 다른 다단계 쓰기 메서드에도 동일하게 나타나는가 | **Not Applicable** | `addItem()`(insert+재계산 2단계)에는 트랜잭션 자체가 없다(코드 확인) — 비교 대상이 될 사례가 없다. |

**종합**: 4개 평가 항목 모두 `Not Applicable`로 확인됐다 — 이는 "패턴이 적용 불가능하다"는 뜻이 아니라, **현재 코드에 비교/검증할 두 번째 사례가 존재하지 않아, "반복 적용 가능 여부" 자체를 현재 코드만으로 확정할 근거가 없다**는 사실을 가리킨다.

---

## PART 6 — Phase 3 결론

| 확인 항목 | 결과 |
|---|---|
| 현재 Workflow 구조가 반복 가능한 패턴인가 | **현재 코드만으로는 확정할 수 없다**(PART5) — 사례가 1건뿐이라 "반복 가능"이라는 판단 자체에 필요한 비교 대상이 없다. 이는 구조적 결함이 아니라 적용 사례 수의 한계다. |
| Repository 책임이 명확한가 | 대체로 명확하나(PART1/3 대부분 `OK`), PART4에서 식별된 긴장 관계(Transaction 관리 위치)로 인해 "Repository는 데이터 접근만 담당한다"는 원칙이 100% 순수하게 지켜지지는 않는다(`Review` 1건). |
| Workflow 책임이 명확한가 | **명확하다** — PART3/4에서 "Workflow는 절차를 조율한다"는 원칙이 `OK`로 확인됐고, `SessionClosingWorkflow`의 책임 범위(ADR-007 그대로)가 흐려진 지점이 없다. |
| 현재 구현을 막는 구조적 문제가 있는가 | PART3/4에서 식별된 긴장 관계(Transaction Boundary 유지 ↔ Repository만 데이터 접근)가 있으나, 이는 Phase 2에서 이미 "ADR-007을 정확히 지키기 위한 현재 구현의 결과이며 실제 동작을 막지 않는다"로 판단된 것과 동일한 사안이다. 지시문 기준("A-14 범위 안에서 해결 가능한 사항은 착수를 막는 사유로 간주하지 않는다")에 따라 막는 문제로 간주하지 않는다. |

### 결론

구조적 개선 가능성(PART3/4의 `Review` 1건, 동일 사안의 반복 확인)이 존재하지만, 이는 현재 구현을 막는 문제가 아니라 ADR-007을 지키기 위한 의식적 결과이며 Phase 1/2에서 실제 동작에 문제가 없음이 이미 확인됐다 — **"현재 패턴 유지 권장"**으로 판단한다.

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | `SessionRepository` 역할 확인 | ✅ PART 1 — public 메서드 7개 전부, Workflow 필요=Yes는 1건뿐 |
| 2 | Workflow Pattern 재사용성 검증 | ✅ PART 2 — 실제 클래스 1개(`SessionClosingWorkflow`) 확인, 다른 후보는 Partial 1건/No 3건 |
| 3 | Workflow-Repository 경계 검증 | ✅ PART 3 — 11개 책임, OK 10건/Review 1건 |
| 4 | 패턴 일관성 확인 | ✅ PART 4 — 4개 원칙, OK 3건/Review 1건, 긴장 관계 명시 |
| 5 | 반복 적용 가능성 평가 | ✅ PART 5 — 4개 항목 전부 Not Applicable(사례 부족) |
| 6 | 현재 패턴 유지 가능 여부 확인 | ✅ PART 6 — **현재 패턴 유지 권장** |
| 7 | 코드/DB/테스트/ADR 변경 없음 확인 | 아래 git status로 확인 |
