# A-11.95: Staff Earning Implementation Readiness

> **목적**: A-12 구현 전에 남아 있는 미결정 사항만 확정한다. 새로운 기능/아키텍처를 만들지 않는다 — ADR-002/003/004/006을 기준으로 A-12 구현 준비 상태를 완성한다.
> **구현 범위**: 없음(코드/DB/테스트 변경 0건, 본 문서로 검증)
> **전제 문서**: `docs/A12_STAFF_EARNING_ARCHITECTURE.md`, `docs/adr/ADR-002~ADR-006`
> 작성일: 2026-06-26

---

## PART 1 — `StaffEarningLedger` 정의 확정

### 최종 정의(6개 항목)

1. **`StaffEarningLedger`는 Financial Event가 아니다.** "이벤트"는 ADR-003의 정의상 발생 시점에 그 자체로 사실이 되는 1차 기록(`PaymentSessionItem`, `PaymentMethodBreakdown`)을 가리킨다. `StaffEarningLedger`는 그런 1차 사실이 아니다.
2. **`StaffEarningLedger`는 Persistent Snapshot(영속 스냅샷)이다.** 마감 시점에 1차 이벤트들로부터 계산된 결과를 한 번 기록해 둔 것 — "사건"이 아니라 "그 시점에 계산해 본 결과를 저장해 둔 것"이다.
3. **`SessionItem`(`PaymentSessionItem`)으로부터 파생되는 확정 결과다.** 진실의 원천은 항상 `PaymentSessionItem`(`staff_fee`/`service` 등)이고, `StaffEarningLedger`는 그로부터 ADR-006의 정책(할인 전 금액 기준)을 적용해 계산된 출력이다.
4. **Rule(가격 규칙/Promotion 규칙) 변경 이후에도 과거 Ledger는 변경되지 않는다.** `PricingRule`/`PromotionRule`이 나중에 수정되거나 비활성화돼도, 이미 `closeSession()`으로 확정된 과거 세션의 Ledger 값은 그대로 유지된다 — 스냅샷이 찍힌 시점의 결과가 영구히 고정된다(영수증 재현성, A-8 품목 스냅샷 원칙과 동일한 정신).
5. **Ledger 생성 시점은 `closeSession()`이다.** ADR-006에서 이미 확정된 그대로 — 마감 시점에 1회 계산해 기록한다.
6. **`addItem()`에서는 Ledger를 생성하지 않는다.** 현재 코드(`session_repository.dart` 176~187행)의 즉시 생성 로직은 A-12 구현 시 제거/이전 대상이며, 본 항목은 그 변경이 "맞는 방향"임을 재확인하는 정의다(코드는 이번 단계에서 수정하지 않음).

### "Snapshot"이라는 용어가 정확한 이유

"파생 데이터"라고만 부르면 "조회할 때마다 다시 계산되는 값"(예: SQL VIEW)과 혼동될 수 있다. `StaffEarningLedger`는 그렇지 않다 — **한 번 계산되어 저장되면, 원본 데이터(`PaymentSessionItem`, `PricingRule`, `PromotionRule`)가 나중에 바뀌어도 그 저장된 값은 다시 계산되지 않는다.** 이것이 "Snapshot"이라는 표현이 "파생 데이터"보다 정확한 이유다 — **계산은 파생적이지만, 저장은 영속적이고 불변이다.**

### ADR-003/ADR-006과의 재확인

| ADR | 재확인 결과 |
|---|---|
| **ADR-003**(Financial Events) | **충돌 없음 — 오히려 항목 1~6이 ADR-003을 더 정밀하게 구현하는 정의다.** `A12_STAFF_EARNING_ARCHITECTURE.md` §5에서 식별된 "실행 격차"(현재 `addItem()` 즉시 생성이 잠정값을 사건처럼 다룸)는 항목 5·6("Ledger 생성 시점은 `closeSession()`")으로 정확히 해소된다. ADR-003 자체는 수정하지 않는다 — "Ledger는 이벤트가 아니라 스냅샷"이라는 구분을 명시함으로써, ADR-003이 정의하는 "Event"(`PaymentSessionItem` 등 1차 사실)와 "그로부터 파생된 Snapshot"(`StaffEarningLedger`)이 같은 카테고리가 아님을 명확히 했을 뿐이다. |
| **ADR-006**(Staff Earning Policy) | **충돌 없음 — 본 PART는 ADR-006이 이미 결정한 내용(할인 전 기준, `closeSession()` 시점 확정)을 그대로 재서술한 것이다.** 새로운 결정을 추가하지 않았다. |

---

## PART 2 — `SessionRepository` 책임 정리

### 현재 `SessionRepository`가 수행하는 2가지 책임

1. **Repository 책임**: `PaymentSessions`/`PaymentSessionItems`/`StaffEarningLedgers`/`PaymentMethodBreakdowns` 테이블에 대한 CRUD(Drift 쿼리 작성·실행) — `PricingRuleRepository`/`PromotionRuleRepository`가 자기 테이블에 대해 수행하는 것과 같은 종류의 책임이다.
2. **Workflow Coordination 책임**: `createSession()`/`addItem()`/`closeSession()`/`cancelSession()`이 각각 "여러 단계를 정해진 순서로 실행"하는 절차를 담고 있다 — 예를 들어 `closeSession()`은 검증 → `PaymentMethodBreakdown` 저장 → 상태 전환을 순서대로 수행한다. 이건 단순 CRUD가 아니라 **여러 단계의 순서를 조율하는 책임**이다.

**"Application Service"라는 표현은 쓰지 않는다** — 지시대로, 이 책임에 어떤 정식 패턴 이름을 붙이는 결정은 본 문서에서 내리지 않는다.

### 명시 사항

- **Workflow Coordination은 임시 책임이다.** `SessionRepository`라는 클래스 이름과 위치(`data/` 폴더)가 본래 의도한 책임(Repository)을 넘어서는 역할을 떠안고 있다는 사실을 인지한 채로 둔다 — 지금 당장 분리하지 않는다는 뜻이지, 이 상태가 "올바른 최종 구조"라는 뜻은 아니다.
- **향후 Workflow 계층으로 이동한다.** Repository 책임만 남기고, 절차 조율 책임은 별도 계층으로 옮기는 것이 방향이다 — 단, 그 계층의 이름이나 구체적 구현 방식은 지금 정하지 않는다.
- **Workflow의 구체적인 형태(UseCase, Application Service, Command Handler 등)는 A-13 이후 결정한다.** 본 문서는 위 3가지 이름 중 어느 것도 채택하지 않는다 — "분리해야 한다는 방향"만 기록하고, "어떻게 분리할지"는 A-13 작업 시점에 결정한다.

---

## PART 3 — `closeSession()` 책임 명확화

### 현재 두 책임

1. **Session 상태 변경**: `status: open → closed`, `endAt` 기록.
2. **Financial Workflow 시작**: 결제수단 합계 검증, `PaymentMethodBreakdown` 저장 — 이게 곧 "마감"이라는 절차의 금전적 측면이다.

### Financial Workflow에 포함되는 것(현재 + A-12 이후)

| 단계 | 현재 상태 | A-12 이후 |
|---|---|---|
| Settlement 계산(결제수단 합계 = `finalAmount` 검증) | ✅ 이미 구현됨(A-13) | 그대로 유지 |
| Ledger Snapshot 생성 | ❌ 미구현(현재는 `addItem()`이 즉시 생성, ADR-006에 따라 `closeSession()`으로 이전 예정) | A-12가 추가할 단계 |
| Receipt 생성 | ❌ 미구현(범위 밖, 화면/출력 영역) | 본 문서·A-12 범위 밖 — 향후 별도 작업 |
| Sync 처리 | ❌ 미구현(이 앱은 오프라인 우선 단일 인스턴스 — 현재 동기화 대상 자체가 없음) | 향후 클라우드 동기화 기능이 생기면 고려 |

### Promotion Finalize는 포함하지 않는다

**Promotion은 `Discount SessionItem`(`PaymentSessionItem(itemType='discount')`) 생성 시점에 이미 완료된 것으로 본다.** 즉 `calcSuggestedDiscount()` → `addItem(itemType='discount')` 호출이 끝나면 Promotion 쪽 책임은 종료되며, `closeSession()`이 별도로 "할인을 마무리 짓는" 단계를 가질 필요가 없다 — 이는 ADR-002(할인은 품목 레벨 이벤트)와 PART 1(Ledger는 이벤트가 아니라 그 이벤트들로부터 계산된 스냅샷)의 직접적 결과다: 할인이 이벤트로서 이미 확정돼 있으므로, 마감 시점에는 그 이벤트를 "다시 확정"할 필요가 없고 그냥 읨어서 계산에 쓰기만 하면 된다.

---

## PART 4 — Transaction Boundary 후보 정리(확정하지 않음)

A-13에서 반드시 결정해야 하는 질문만 기록한다. **권장안을 제시할 수 있으나, 본 문서는 확정하지 않는다.**

| # | 질문 | 권장 방향(참고용, 미확정) |
|---|---|---|
| 1 | Session 상태 변경과 Ledger Snapshot 생성은 하나의 트랜잭션이어야 하는가? | 둘 다 같은 DB(SQLite) 안의 쓰기이므로 같은 트랜잭션으로 묶는 것이 자연스러워 보이나, "Ledger 계산이 실패해도 마감 자체는 성립해야 하는가"라는 사업 규칙이 먼저 정해져야 한다 — A-13에서 결정. |
| 2 | Receipt 실패는 rollback 대상인가, 별도 정책인가? | Receipt(영수증 출력/생성)는 DB 트랜잭션과 무관한 외부 효과(프린터/PDF 등)일 가능성이 높아, 같은 트랜잭션에 묶기보다 "마감은 성립하되 영수증 발급은 재시도 가능한 별도 단계"로 보는 쪽이 일반적이나 — 이 앱의 실제 영수증 구현 방식이 아직 없어 단정할 수 없다. A-13에서 결정. |
| 3 | Sync 실패는 retry 대상인가? | 이 앱은 현재 오프라인 우선 단일 인스턴스로, "Sync"라는 개념이 아직 코드에 존재하지 않는다(README.md 원칙 그대로). 향후 동기화 기능이 추가되는 시점에 결정할 질문이며, A-12/A-13 어느 쪽도 지금 답할 필요가 없다. |
| 4 | 어떤 처리가 Commit 이후 비동기로 이동 가능한가? | DB 쓰기(Session 상태, Ledger)는 동기적으로 커밋되어야 하지만, Receipt 출력처럼 "커밋된 사실을 나중에 처리해도 되는" 단계가 있다면 비동기로 분리할 수 있다 — 어떤 단계가 그런 성격인지는 §3의 Financial Workflow 표가 구체화된 뒤에 판단 가능. A-13에서 결정. |

---

## PART 5 — Result 객체 장기 방향

- **A-12에서는 `StaffEarningResult`를 그대로 사용한다.** `PromotionResult`(A-11)와 이름 패턴을 맞춘 것이며, 본 문서는 이 이름을 바꾸지 않는다.
- **Result 계열 명명 규칙(예: `PromotionResult`/`StaffEarningResult`/향후 Settlement 쪽 결과 객체가 있다면 그것까지)은 A-13 이전에 일괄 검토한다.** 지금은 각 Engine이 자기 이름을 따로 정한 상태(`PromotionResult`, `StaffEarningResult`)이며, 이게 충분히 일관적인지(예: 공통 베이스 타입이 필요한지, 필드 구성 패턴을 통일해야 하는지)는 Settlement Engine까지 다 나온 뒤에 한 번에 판단하는 것이 합리적이다 — 지금 2개 사례만 보고 일반화하면 A-11.5/A-12 양쪽에서 이미 반복해서 적용한 "사례가 2~3개일 때는 추상화를 보류한다(YAGNI)"는 판단과 같은 원칙이다.
- **이번 단계에서는 명명 변경을 하지 않는다.**

---

## PART 6 — ADR 정합성 검토

### 충돌 여부

| ADR 쌍 | 충돌 여부 | 비고 |
|---|---|---|
| ADR-002 ↔ ADR-003 | 없음 | 이미 ADR-002 본문에서 ADR-003을 전제로 작성됨(품목 레벨 이벤트가 곧 ADR-003의 사례). |
| ADR-002 ↔ ADR-004 | 없음 | 할인 표현 방식(품목 이벤트)과 Promotion Rule Lifecycle(상태 모델)은 서로 다른 차원 — 교차 지점 없음. |
| ADR-002 ↔ ADR-006 | 없음 | ADR-006(할인 전 기준)을 택하면 할인 품목이 Staff Earning 계산에 영향을 안 주지만, 할인 품목 자체의 존재/표현(ADR-002)은 그대로 유지됨 — `A12_STAFF_EARNING_ARCHITECTURE.md` §PART7에서 이미 확인된 그대로 재확인. |
| ADR-003 ↔ ADR-004 | 없음 | Lifecycle은 Rule 상태(정책) 모델이고 ADR-003은 사건/파생 데이터 구분 — 차원이 다름. |
| ADR-003 ↔ ADR-006 | **이미 확인된 "실행 격차"**(ADR이 아니라 코드) | `A12_STAFF_EARNING_ARCHITECTURE.md` §PART5/§PART7에서 식별, 본 문서 PART 1에서 "Ledger=Snapshot, Event 아님"이라는 정의로 해소 확인. ADR 자체끼리는 충돌하지 않는다 — ADR-006이 그 격차를 메우는 해법을 제시한 ADR이다. |
| ADR-004 ↔ ADR-006 | 없음 | 서로 다른 도메인(Promotion Rule 상태 vs Staff Earning 계산 정책) — 교차 지점 없음. |

**종합: 4개 ADR 사이에 실제 충돌은 없다.**

### 중복 내용

- ADR-003과 ADR-006은 "Ledger 생성 시점"을 각각 다른 각도(일반 원칙 vs 구체 정책)에서 언급하지만, 이는 의도된 계층 관계다(ADR-003=원칙, ADR-006=그 원칙을 Staff Earning에 적용한 구체 사례) — **중복이 아니라 정상적인 일반/특수 관계**.
- 실질적인 문장 단위 중복은 발견되지 않았다.

### 참조 관계

```
ADR-001(Domain Isolation) ──────────────┐
                                         ├─▶ ADR-006(Staff Earning Policy)이
ADR-003(Financial Events) ──────────────┤    둘을 전제로 결론을 도출
                                         │
ADR-002(Discount Representation) ───────┘
        │
        ▼
ADR-004(Promotion Rule Lifecycle) — ADR-002와 같은 A-11 작업에서 파생, 서로 독립적 주제
```

ADR-005(Promotion Stacking Policy)는 A-11.5에서 보류 확정되어 존재하지 않으며, 본 4개 ADR의 참조 관계에 포함되지 않는다(`docs/A11_5_PROMOTION_EXPANSION_PLAN.md` 재확인).

### 누락된 결정

- **Transaction Boundary**(PART 4) — 의도적으로 미결, A-13으로 이관. "누락"이 아니라 "범위 밖으로 명시적으로 위임된 것".
- **Result 객체 명명 규칙**(PART 5) — 의도적으로 미결, A-13 이전 일괄 검토로 이관.
- 위 2가지 외에 ADR 4개의 검토 과정에서 새로 발견된 누락 사항은 없다.

### ADR 수정 필요 여부

**수정 필요 없음.** PART 1에서 다룬 ADR-003↔ADR-006 격차는 "ADR 수정"이 아니라 이미 ADR-006이 제시한 해법(closeSession 시점 확정)을 코드로 실행하는 **후속 작업**이다 — 이는 A-12 구현 자체이며, 이미 본 문서 PART 1·PART 3에서 "ADR을 고치지 않는다"는 결론을 재확인했다. 새로운 후속 작업 항목은 없다(A-12 구현 자체가 유일한 후속 작업).

---

## PART 7 — A-12 구현 준비 완료 선언

다음이 모두 확정/명시됐다:

- `StaffEarningLedger`의 정의(이벤트 아님, 스냅샷, 파생, 불변, `closeSession()` 생성, `addItem()` 미생성) — PART 1
- `SessionRepository`의 현재 책임(Repository + 임시 Workflow Coordination)과 분리가 필요하다는 방향(구체적 형태는 A-13 이후) — PART 2
- `closeSession()`의 현재 책임(Session 상태 변경 + Financial Workflow) 및 Financial Workflow의 구성(Settlement/Ledger/Receipt/Sync), Promotion Finalize 불포함 — PART 3
- Transaction Boundary는 의도적으로 미결 — A-13으로 명시적 이관(질문 4개 기록) — PART 4
- Result 객체 명명은 변경하지 않고 `StaffEarningResult` 그대로 사용, 일괄 검토는 A-13 이전으로 이관 — PART 5
- ADR-002/003/004/006 사이 충돌 없음, 중복 없음(정상적 일반/특수 관계만 존재), 누락은 의도적으로 이관된 2건뿐, ADR 수정 불필요 — PART 6

**A-12(Staff Earning Engine MVP) 구현은 본 문서와 `docs/A12_STAFF_EARNING_ARCHITECTURE.md`(특히 PART 6의 MVP 범위)를 그대로 따르면 추가 설계 논의 없이 착수 가능하다.**

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | `StaffEarningLedger` 정의 확정 | ✅ PART 1 |
| 2 | `SessionRepository` 현재 책임/향후 분리 방향 문서화 | ✅ PART 2 |
| 3 | `closeSession()` 책임 명확화 | ✅ PART 3 |
| 4 | Transaction Boundary 후보 정리 | ✅ PART 4(확정 안 함, A-13 이관) |
| 5 | Result 객체 장기 방향 정리 | ✅ PART 5(명명 변경 없음) |
| 6 | ADR-002/003/004/006 정합성 확인 | ✅ PART 6 — 충돌 없음 |
| 7 | A-12 구현 준비 완료 선언 | ✅ PART 7 |
| 8 | 코드/DB 변경 없음 확인 | 아래 git status로 확인 |

## ADR-006 보완 여부

지시문은 "필요 시 ADR-006 보완(StaffEarningLedger 정의 및 생성 시점 명확화)"을 허용했으나, **PART 1에서 그 정의를 본 문서(`A12_IMPLEMENTATION_READY.md`)에 이미 명확히 기록했고, ADR-006 자체의 결정(할인 전 기준, `closeSession()` 시점 확정)과 충돌하거나 그것을 변경할 내용이 아니므로 ADR-006 파일은 수정하지 않는다.** "정의의 정교화"는 ADR 본문을 고치는 것보다, ADR이 참조하는 별도 설계 문서(본 문서)에 두는 것이 ADR을 "결정 기록"으로서 가볍게 유지하는 데 더 적합하다고 판단했다.
