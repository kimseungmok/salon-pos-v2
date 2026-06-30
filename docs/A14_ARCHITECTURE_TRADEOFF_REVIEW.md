# A-14 Phase 4: Architecture Trade-off Review

> **목적**: Phase 2(`A14_WORKFLOW_DEPENDENCY_VALIDATION.md`)와 Phase 3(`A14_WORKFLOW_PATTERN_VALIDATION.md`)에서 `Review`로 기록된 항목이 지금 수정해야 하는 구조적 문제인지, 의도적으로 받아들일 Trade-off인지 최종 판정한다. 새 설계/계층 없음.
> **대상 코드**: `lib/features/session/workflow/session_closing_workflow.dart`, `lib/features/session/data/session_repository.dart`(Phase 1 이후 무변경 확인)
> **근거**: ADR-001~ADR-007, A-14 Phase 1~3
> 작성일: 2026-06-26

---

## PART 1 — Review 항목 재확인

Phase 2/Phase 3 문서를 직접 재조회(`grep`)해 `Review`로 기록된 항목만 가져온다 — 예시를 새로 만들지 않았다.

| Review 항목 | 최초 기록 문서 | 현재 코드 상태 | 현재도 Review인가 |
|---|---|---|---|
| `SessionClosingWorkflow`가 `_db.transaction()`을 직접 호출 — Transaction 시작/관리 책임의 위치(`SessionClosingWorkflow.run()`이 ADR-001의 "Repository만 Drift를 안다"는 표현과 정확히 일치하는지) | `docs/A14_WORKFLOW_DEPENDENCY_VALIDATION.md` PART3(최초), `docs/A14_WORKFLOW_PATTERN_VALIDATION.md` PART3(재확인) | `session_closing_workflow.dart` 39행 `await _db.transaction(() async { ... })` — Phase 1 구현 이후 무변경(확인됨) | **Yes** |
| "Repository는 데이터 접근을 담당한다"는 원칙이 `SessionClosingWorkflow`의 Drift 직접 호출(insert/update/select)로 인해 100% 순수하게 지켜지지 않음 | `docs/A14_WORKFLOW_PATTERN_VALIDATION.md` PART4 | 위와 동일한 코드 상태(무변경) | **Yes** |

**확인된 사실**: 위 2개 항목은 **같은 근본 원인**(`SessionClosingWorkflow`가 Drift API를 직접 호출)을 서로 다른 각도(구체적 책임 위치 vs 일반 원칙)에서 서술한 것이다 — Phase 2/3을 통틀어 새로운 Review 항목은 발견되지 않았다.

---

## PART 2 — Trade-off 여부 판단

| Review 항목 | 현재 구조의 장점 | 현재 구조의 단점 | Trade-off 허용 여부 |
|---|---|---|---|
| Transaction 시작/관리 위치 | ADR-007이 확정한 Transaction Scope(Settlement insert~Session 상태 변경)를 단일 콜백 안에서 정확히 보존한다 — A-13이 막은 "부분 실패로 인한 중복" 문제(`docs/A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md`)가 Phase 1 이후에도 재발하지 않는다. 코드 위치만 이동했을 뿐이라 Phase 1에서 회귀 0건(전체 테스트 368건 통과)으로 실증됨. | ADR-001의 "Repository만 Drift를 안다"는 표현을 글자 그대로 적용하면, `SessionClosingWorkflow`도 Drift 트랜잭션 API를 직접 다루는 계층이 되어 그 원칙의 적용 범위가 한 곳에서 흐려진다. | **Accepted** |
| "Repository는 데이터 접근을 담당한다" 원칙 | 7개 public 메서드 중 6개(`createSession`/`addItem`/`cancelSession`/`getSessionSummary`/`calcSuggestedTimeFee`/`calcSuggestedDiscount`)에서는 이 원칙이 그대로 지켜진다 — 예외는 `closeSession()`이 위임하는 단 하나의 경로뿐이다. | 위 항목과 동일한 근본 원인 — `closeSession()` 경로 1곳에서 원칙이 순수하게 지켜지지 않는다. | **Accepted** |

**판단 근거**(두 항목 공통): ADR-007은 ADR-001보다 **더 구체적이고, 더 나중에(A-13 시점) 확정된 결정**이다 — "이 특정 절차(Settlement~상태변경)는 반드시 단일 트랜잭션이어야 한다"는 ADR-007의 요구가, "Repository만 Drift를 안다"는 ADR-001의 일반 원칙과 같은 자리에서 충돌할 때, **더 구체적인 결정이 우선한다**고 보는 것이 두 ADR 모두를 작성한 동일한 설계 흐름(ADR-001~007이 순차적으로 서로를 참조하며 쌓인 것)에 부합한다. 또한 이 트레이드오프는 이미 Phase 1에서 실제로 적용되어 동작이 검증된 상태다 — 가상의 트레이드오프가 아니다.

---

## PART 3 — 현재 수정 필요 여부

| Review 항목 | 지금 수정 필요 여부 | 이유 |
|---|---|---|
| Transaction 시작/관리 위치 | **No** | PART2에서 `Accepted`로 판정된 트레이드오프다. 지금 수정(예: Transaction 관리를 다시 Repository로 되돌리거나 별도 형태로 분리)을 시도하면, Phase 1에서 이미 회귀 없이 검증된 현재 상태를 다시 흔드는 새로운 변경 위험을 만든다 — A-14 전체가 전제하는 "기존 동작/계산 결과 동일 유지"와 충돌할 새 리스크를 자발적으로 만드는 셈이다. |
| "Repository는 데이터 접근을 담당한다" 원칙 | **No** | 위 항목과 동일한 근본 원인이므로 동일한 판단. |

---

## PART 4 — ADR 일관성 확인

| ADR | 충돌 여부 | 근거 |
|---|---|---|
| ADR-001(Pricing Engine Domain Isolation) | **Review**(이전 Phase와 결론 동일, 변경 없음) | `SessionClosingWorkflow`가 Drift를 직접 호출하는 사실 자체가 코드 상 그대로이므로(PART1), Phase 2/3과 같은 근거로 같은 결론을 유지한다. **변경 사유 없음** — 이번 Phase는 이 사실을 "구조적 결함"이 아니라 "ADR-007과의 트레이드오프"로 명시적으로 재해석했을 뿐, 코드/사실 자체에 대한 판정(`Review`)은 바뀌지 않았다. |
| ADR-002(Discount Representation) | **OK** | `closeSession()`/`SessionClosingWorkflow` 어느 쪽도 할인 품목(`itemType='discount'`)을 직접 다루지 않는다(`addItem()`의 책임) — 무관, 변경 없음. |
| ADR-003(Financial Events) | **OK** | `StaffEarningLedger`(파생 스냅샷)와 `PaymentSessionItem`(이벤트)의 구분은 `SessionClosingWorkflow` 추출 이후에도 동일하게 유지된다 — 위치만 옮겼을 뿐 그 구분 자체를 건드리지 않았다. |
| ADR-004(Promotion Rule Lifecycle) | **OK** | `closeSession()`/Workflow와 무관한 도메인(Promotion Rule 상태 모델) — 영향 없음. |
| ADR-005(Promotion Stacking Policy) | **OK**(해당 없음) | 존재하지 않는 ADR(A-11.5에서 보류 확정, `docs/adr/` 디렉터리에 파일 없음) — 충돌 가능성 자체가 없음. |
| ADR-006(Staff Earning Policy) | **OK** | 할인 전 금액 기준 계산과 `closeSession()` 시점 1회 확정이라는 결정은 `SessionClosingWorkflow.run()` 내부에 그대로 보존돼 있다(65행 `calcEarnings()` 호출 로직 무변경) — 위치만 이동, 정책 변경 없음. |
| ADR-007(A-13 MVP Transaction Scope) | **OK** | Settlement~상태변경의 Transaction Scope가 `SessionClosingWorkflow.run()` 안에 정확히 그대로 보존된다 — 오히려 본 Phase의 PART2/3에서 확인했듯, **이 ADR이 ADR-001과의 트레이드오프를 정당화하는 근거**로 작용한다. |

**종합**: 7개 ADR(존재하는 6개+미존재 1개 확인) 중 ADR-001만 `Review`이며, 이는 Phase 2/3과 **동일한 결론**이다 — 새로운 충돌은 발견되지 않았다.

---

## PART 5 — 확장 구조 재검토

| 항목 | 현재 필요 여부 | 이유 |
|---|---|---|
| Workflow Interface | **Not Required** | Phase 2/3에서 확인된 그대로 — `SessionClosingWorkflow` 구현체는 여전히 1개뿐이고, 호출처도 `SessionRepository.closeSession()` 1곳뿐이다(코드 무변경, 재확인). |
| Workflow Provider | **Not Required** | `lib/features/session/providers.dart`가 Phase 1 이후 무변경 — `SessionClosingWorkflow`는 여전히 `SessionRepository` 생성자 내부에서 직접 생성되며, 독립적으로 주입받는 화면/Provider가 없다. |
| Workflow Repository | **Not Required** | `SessionClosingWorkflow`가 다루는 4개 테이블은 모두 A-8부터 있던 기존 테이블이며, 이 클래스만을 위한 별도 데이터 접근 계층이 필요하다는 근거가 코드/ADR 어디에도 없다. |

3개 항목 모두 Phase 2의 판정과 **동일**하다 — 코드가 그 사이에 바뀌지 않았으므로 결론도 바뀔 이유가 없다.

---

## PART 6 — Architecture 최종 판정

| 확인 항목 | 결과 |
|---|---|
| 현재 수정이 반드시 필요한 구조적 문제가 있는가 | **없음**(PART3, 2개 Review 항목 모두 `No`) |
| 현재 구조가 ADR과 충돌하는가 | ADR-001과 표현상 어긋나는 지점이 있으나(PART4), 이는 ADR-007과의 의도적 트레이드오프로 `Accepted` 판정됐다(PART2) — **실질적 충돌로 격상되지 않는다.** |
| A-14 진행을 막는 요소가 있는가 | **없음** — 위 두 항목 모두 A-14 범위 안에서 이미 해결(트레이드오프로 수용)된 사항이라, 지시문 기준("A-14 범위 안에서 해결 가능한 사항은 착수를 막는 사유로 간주하지 않는다")을 적용할 필요조차 없이 명시적으로 `Accepted`로 종결됐다. |

### 이전 Phase와의 관계

Phase 2(`"현재 구조 유지 권장"`)·Phase 3(`"현재 패턴 유지 권장"`)과 **동일한 방향의 결론**이지만, 결론의 성격이 다르다:

- Phase 2/3은 "막는 문제가 아니므로 보류/유지"라는 **잠정적 판단**이었다(Review 항목이 여전히 "재검토할 지점"으로 열려 있었음).
- 본 Phase 4는 그 동일한 항목을 **명시적으로 `Accepted` Trade-off로 종결**했다(PART2) — 더 이상 "재검토할 지점"이 아니라 "의도적으로 받아들인 설계 결정"으로 확정됐다는 점이 변경된 부분이다. 코드 사실(PART1) 자체는 바뀌지 않았으나, 그 사실에 대한 **판정의 성격**이 "열린 재검토 대상"에서 "종결된 Trade-off"로 바뀌었다.

### 최종 판정

**① 현재 구조 유지 권장.**

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | Review 항목 재확인 | ✅ PART 1 — 2건, 둘 다 현재도 Review(Yes) |
| 2 | Trade-off 여부 판단 | ✅ PART 2 — 2건 모두 `Accepted` |
| 3 | 현재 수정 필요 여부 확인 | ✅ PART 3 — 2건 모두 `No` |
| 4 | ADR 일관성 확인 | ✅ PART 4 — ADR-001만 `Review`(이전과 동일, 변경 없음 명시), 나머지 `OK` |
| 5 | 확장 구조 필요성 재검토 | ✅ PART 5 — 3건 모두 `Not Required`(Phase 2와 동일) |
| 6 | Architecture 최종 판정 | ✅ PART 6 — **① 현재 구조 유지 권장** |
| 7 | 코드/DB/테스트/ADR 변경 없음 확인 | 아래 git status로 확인 |
