# A-13.6: Workflow Interface Readiness

> **목적**: 향후 Workflow 계층 구현 전에, Workflow의 입력/출력/책임 경계를 현재 코드 기준으로 정리한다. 새 설계/DTO/Workflow/UseCase 없음.
> **대상 코드**: `lib/features/session/data/session_repository.dart`의 `closeSession()`(247~336행, A-13 Transaction 적용 후 최종 상태)
> **선행 문서**: `docs/A14_WORKFLOW_EXTRACTION_READY.md`(A-13.5 — Repository/Workflow 책임 분류, 분리를 막는 구조적 제약 식별)
> 작성일: 2026-06-26

---

## PART 1 — Workflow Input 분석

| 데이터 | 생성 위치 | Workflow 입력 필요 여부 | 호출자가 제공 가능한가 | 비고 |
|---|---|---|---|---|
| `sessionId` | 호출자(매개변수) | **Yes** | Yes | 이미 외부 입력값 — Workflow가 "어떤 세션을 마감할지" 알아야 하는 가장 기본적인 정보. |
| `paymentMethods` | 호출자(매개변수) | **Yes** | Yes | 동일 — 외부 입력값. |
| `session`(`PaymentSessionRow`) | `_requireSession()` 내부 Drift 조회(260행) | **No** | No | Drift Row이며, ADR-001 원칙상 Repository만 이 데이터를 직접 얻어야 한다. A-13.5 PART3에서 이미 "값 자체는 전달 가능하나 조회 행위는 Repository 책임"으로 구분됨 — 단, 현재 코드에서 Workflow가 `closeSession()`을 통째로 호출하는 형태(A-13.5 결론)라면 이 데이터를 Workflow가 직접 받을 필요 자체가 없다. |
| `paidTotal`(계산값) | `closeSession()` 본문 `fold()`(265행) | **No** | No | `paymentMethods`로부터 파생되는 값 — Workflow가 별도로 제공할 필요 없이 Repository 내부에서 그때그때 계산된다. |
| `now`(`DateTime.now()`) | `closeSession()` 본문(270행) | **No**(현재는 매개변수로 노출되지 않음) | 가능은 하나 현재는 아님 | 결제수단/Ledger/상태갱신 3곳에서 동일 값을 재사용(A-13.5 PART3에서 확인) — 테스트 용이성을 위해 외부에서 주입받게 할 여지는 있으나, 현재 코드는 그렇게 되어 있지 않다. |
| `sessionItems`(`List<PaymentSessionItemRow>`) | `_db.select()`(290~292행) | **No** | No | Drift Row — `session`과 동일한 이유. |
| `earnableItems`(`List<EarnableItem>`) | `closeSession()` 본문 변환(293~300행) | **No** | 이론상 가능(이미 Drift 비의존 POJO) | A-13.5 PART3에서 확인된 제약(Engine 호출이 트랜잭션 콜백 안에 결합돼 있음) 때문에, 이 값을 Workflow가 별도로 받아 Engine을 직접 호출하는 형태는 트랜잭션 경계를 깨므로 현재는 적합하지 않다. |

**종합**: 현재 코드의 제약(트랜잭션 콜백이 `closeSession()` 내부에 통째로 있어야 함, A-13.5 결론) 위에서, Workflow가 실제로 받아야 하는 입력은 **`sessionId`와 `paymentMethods` 둘뿐이다** — 나머지는 전부 Repository 내부에서 생성/소비되는 중간 데이터다.

---

## PART 2 — Workflow Output 분석

| 결과 | 생성 위치 | Workflow 출력 필요 여부 | Repository 내부 처리 여부 |
|---|---|---|---|
| `PaymentSessionRow`(마감된 세션, 반환값) | 재조회(328~330행) | **Yes** | No(외부로 반환되는 값 — 현재도 `closeSession()`의 반환값) |
| `payment_method_breakdowns` insert 결과 | 트랜잭션 내부(276~288행) | **No** | **Yes**(부수효과만, 별도 반환값 없음 — 현재 코드가 이 결과를 호출자에게 돌려주지 않음) |
| `staff_earning_ledgers` insert 결과 | 트랜잭션 내부(303~317행) | **No** | **Yes**(위와 동일, 부수효과만) |
| 예외(`ValidationException`/`BusinessRuleException`/`DatabaseException`) | `closeSession()` 본문 각 검증 지점 + `catch` 블록(331~335행) | **Yes** | No(호출자/Workflow에 전파되어야 함 — `rethrow`가 이미 그 역할을 수행) |

**종합**: 현재 코드 기준으로 `closeSession()`의 "출력"은 사실상 **두 가지뿐**이다 — 성공 시 `PaymentSessionRow`, 실패 시 예외. 중간 부수효과(결제수단/Ledger insert)는 Workflow가 직접 다룰 출력이 아니라 Repository가 감춰서 처리하는 내부 사항이다. **새로운 Result 객체를 제안할 근거가 현재 코드에는 없다** — 지시대로 새 객체를 만들지 않았다.

---

## PART 3 — Workflow 책임 경계 검증(`closeSession()` 단계별, A-13.5 PART2의 9단계 재사용)

| 단계 | Repository 책임 | Workflow 책임 | 분리 가능 여부 |
|---|---|---|---|
| 1. 입력 검증(251~258행) | 없음(DB 미접근) | 입력 형식 검증을 가져갈 수 있음 | **Yes** |
| 2. 세션 조회+가드(260~263행) | `_requireSession()`(Drift 조회) | "가드 통과 여부에 따라 다음 동작을 결정"하는 분기 자체는 Workflow도 가질 수 있음 | **Partial** — 조회 행위는 Repository에 묶여 있고, 그 결과로 내리는 판단만 분리 가능 |
| 3. Settlement 계산(265~268행) | 없음(순수 계산이나 현재 Repository 메서드 안에 있음) | 동일 계산을 Workflow가 가져도 결과는 같음 | **Yes** |
| 4. 결제수단 insert(276~288행, 트랜잭션 내부) | Drift insert | 없음 | **No** — insert는 항상 Repository(ADR-001) |
| 5. 품목 조회(290~292행, 트랜잭션 내부) | Drift 조회 | 없음 | **No** |
| 6. `StaffEarningEngine.calcEarnings()` 호출(301행, 트랜잭션 내부) | 없음(Engine 호출 자체는 순수 계산) | 호출 시점/순서 결정은 가질 수 있음 | **Partial** — Engine 호출은 Drift와 무관하지만, 그 결과를 곧바로 같은 트랜잭션 안에서 insert해야 한다는 제약(ADR-007) 때문에 호출과 저장을 떼어낼 수 없음(A-13.5에서 이미 확인된 결합) |
| 7. Ledger insert(303~317행, 트랜잭션 내부) | Drift insert | 없음 | **No** |
| 8. 상태 변경(320~325행, 트랜잭션 내부) | Drift update | 없음 | **No** |
| 9. 재조회(328~330행) | Drift 조회 | 없음 | **No**(분리해도 실익 없음) |

본 PART는 A-13.5 PART2의 결론을 `closeSession()` 9단계에 그대로 재적용한 것이며, 새로운 분류 기준을 추가하지 않았다.

---

## PART 4 — Engine 의존 관계 재검증

| Engine | 현재 의존성 | Workflow 도입 후 영향 | 변경 필요 여부 |
|---|---|---|---|
| `PricingEngine` | `SessionRepository`가 `PricingRuleRepository`를 통해 호출(`calcSuggestedTimeFee()` 내부) — `closeSession()`과는 무관(코드 확인, A-13.5 PART2에서 재확인된 사실) | 영향 없음 — `closeSession()` 흐름 자체에 포함되지 않으므로 Workflow가 도입돼도 이 호출 경로는 그대로 | **No** |
| `PromotionEngine` | `SessionRepository`가 `PromotionRuleRepository`를 통해 호출(`calcSuggestedDiscount()` 내부) — `closeSession()`과 무관 | 영향 없음(위와 동일한 이유) | **No** |
| `SettlementEngine` | **별도 클래스로 존재하지 않음** — 결제수단 합계 검증(265~268행)은 `closeSession()` 본문에 인라인 로직으로만 존재(A-12.5/A-12.6에서 이미 확인된 사실) | PART3에서 "Yes"(분리 가능)로 표시된 항목이지만, 분리하더라도 그 결과(검증 통과 여부)는 트랜잭션 시작 전에 확정되어야 하므로 Workflow 도입이 이 로직의 **존재 위치**를 강제로 바꿀 이유는 없음 | **No**(현재 코드 기준 — 별도 클래스화 여부는 A-14 이후의 별개 결정) |
| `StaffEarningEngine` | `SessionRepository`가 생성자에서 직접 보유, `closeSession()` 내부에서 직접 호출(301행) | Engine 자신은 Repository도 Workflow도 모르는 순수 클래스(ADR-001) — "누가 호출하는가"가 바뀌어도 Engine이 의존하는 대상은 없으므로 의존 **방향** 자체는 불변 | **No** |

**종합**: 4개 Engine 모두 "변경 필요 없음"으로 확인됐다 — Workflow 계층이 도입되어도 Engine은 항상 "아무것도 의존하지 않고, 누군가에게 호출당하는" 위치를 유지한다(ADR-001의 불변량).

---

## PART 5 — Workflow 확장성 확인(결론 미확정, 표만)

| 후보 기능 | 현재 구조와 충돌 여부 | 추가 검토 필요 여부 |
|---|---|---|
| Receipt | **No** — A-12.5/A-12.6에서 이미 "DB 트랜잭션 밖의 외부 연동"으로 분류됨(`docs/A13_TRANSACTION_BOUNDARY_REVIEW.md` PART1, `docs/A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md` PART5) — 현재 트랜잭션 경계(PART3) 안에 들어갈 필요가 없는 구조라 구조적 충돌이 없다. | **Yes** — 언제/어떻게 트리거할지(동기/비동기, 실패 시 재시도 방식)는 여전히 미정. |
| Sync | **No** — 위와 동일한 분류(트랜잭션 밖 외부 연동), 추가로 이 앱에는 현재 Sync 대상 자체가 없음(여러 선행 문서에서 반복 확인). | **Yes** — 기능 자체가 아직 없어 트리거 방식뿐 아니라 존재 여부 자체도 미정. |

---

## PART 6 — A-14 구현 준비 최종 확인

| 확인 항목 | 결과 |
|---|---|
| Workflow 인터페이스를 정의하는 데 부족한 정보가 있는가 | **있다.** PART3의 6단계(Engine 호출)가 "Partial"로 남아 있다 — Engine 호출과 그 결과의 즉시 저장이 트랜잭션으로 결합돼 있어, "조율만 하는" Workflow 인터페이스의 정확한 모양(예: Repository가 콜백을 받는 형태인지, Workflow가 트랜잭션 전체를 통째로 위임하는 형태인지)이 아직 정의되지 않았다. |
| Workflow 분리를 막는 구조적 문제가 있는가 | **있다.** A-13.5에서 식별된 것과 동일한 문제 — ADR-007의 Transaction 경계가 "Settlement~상태변경"을 한 코드 블록으로 강제하므로, 이를 깨지 않는 한 Workflow가 세분화된 단계별 호출을 할 수 없다. |
| Repository 책임 충돌이 있는가 | **없다.** PART3에서 Repository 책임으로 분류된 항목(4/5/7/8/9단계, 전부 Drift 직접 호출)은 Workflow 도입 여부와 무관하게 일관되게 Repository에 남는다. |
| Engine 책임 충돌이 있는가 | **없다.** PART4에서 4개 Engine 전부 "변경 필요 없음"으로 확인됨. |

### 결론

부족한 정보(Engine 호출-저장 결합을 어떻게 인터페이스로 표현할지)와 구조적 제약(Transaction 경계)이 둘 다 존재하므로, **"A-14 Workflow 구현 착수 가능"을 무조건 명시하지 않는다.** Repository/Engine 책임 충돌이 없다는 점에서 토대는 마련돼 있으나, PART6에서 식별된 두 항목(Workflow 인터페이스의 구체적 형태, Transaction 경계를 보존하는 방법)이 A-14 설계 단계에서 먼저 해결되어야 한다 — 이는 A-13.5의 결론과 일치하며, 본 문서가 그 결론을 입력/출력 관점에서 더 구체화한 것이다.

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | Workflow Input 분석 | ✅ PART 1 — 7개 데이터, 실질적 입력은 2개(`sessionId`/`paymentMethods`)로 좁혀짐 |
| 2 | Workflow Output 분석 | ✅ PART 2 — 4개 결과, 실질적 출력은 2개(반환값/예외)로 좁혀짐, 새 Result 객체 제안 없음 |
| 3 | Workflow 책임 경계 검증 | ✅ PART 3 — 9단계, A-13.5 결론 재적용 |
| 4 | Engine 의존 관계 재검증 | ✅ PART 4 — 4개 Engine 전부 변경 불필요 |
| 5 | Workflow 확장성 확인 | ✅ PART 5 — Receipt/Sync 둘 다 충돌 없음, 추가 검토 필요(결론 미확정) |
| 6 | A-14 구현 착수 가능 여부 확인 | ✅ PART 6 — **조건부**(인터페이스 형태/트랜잭션 경계 선결 필요), 무조건적 착수 가능 선언 안 함 |
| 7 | 코드/DB/테스트/ADR 변경 없음 확인 | 아래 git status로 확인 |
