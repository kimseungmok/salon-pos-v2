# A-13.7: Workflow Contract Validation

> **목적**: A-14 Workflow Extraction 구현 전, ADR-001~ADR-007과 실제 코드가 하나의 일관된 Workflow Contract를 형성하는지 최종 검증한다. 새 설계/계층 없음.
> **대상 코드**: `lib/features/session/data/session_repository.dart`(A-13 Transaction 적용 후 최종 상태)
> **선행 문서**: `docs/A14_WORKFLOW_EXTRACTION_READY.md`(A-13.5), `docs/A14_WORKFLOW_INTERFACE_READY.md`(A-13.6)
> **명칭 주의**: 본 문서에서 사용하는 모든 함수/클래스/메서드명은 실제 코드(`session_repository.dart`, `staff_earning_engine.dart` 등)에 존재하는 명칭만 사용한다. "Settlement"는 코드 안에 별도 클래스로 존재하지 않으며 `closeSession()` 내부의 인라인 검증 로직(265~268행)을 가리키는 서술적 표현일 뿐이다 — 새 클래스명으로 오인하지 않도록 매 항목에서 실제 위치를 병기한다.
> 작성일: 2026-06-26

---

## PART 1 — Workflow Contract 검증

| Contract | 현재 근거 | 충돌 여부 |
|---|---|---|
| **Input** | A-13.6 PART1 — 실질적 입력은 `sessionId`/`paymentMethods`(`closeSession()`의 실제 매개변수) 2개뿐. `session`/`sessionItems`/`earnableItems`는 모두 Repository 내부에서 생성되는 중간 데이터로 분류됨(Drift Row이거나 트랜잭션 결합으로 외부 노출 불필요). | **OK** |
| **Output** | A-13.6 PART2 — `closeSession()`의 반환값(`PaymentSessionRow`, 328~330행에서 재조회 후 반환)과 예외(`ValidationException`/`BusinessRuleException`/`DatabaseException`, 331~335행) 2가지로 좁혀짐. 새 Result 객체 불필요로 확인됨. | **OK** |
| **Exception** | `closeSession()`의 `try { ... } on AppException { rethrow; } catch (e) { throw DatabaseException.writeFailed('$e'); }` 구조(259행, 331~335행) — A-13 작업의 PART5("새로운 retry/catch/rollback/logging 추가 없음, Transaction이 제공하는 기본 rollback만 사용")에서 이미 무수정으로 확정. | **OK** |
| **Transaction Scope** | ADR-007 + 실제 구현(`_db.transaction(() async { ... })`, 275~326행) — A-13.5/A-13.6 양쪽 분석이 모두 이 경계를 전제로 수행됨(Settlement insert~Session 상태 변경이 한 콜백 안). | **OK** |
| **Repository Responsibility** | ADR-001("Repository만 Drift를 안다") + A-13.5 PART4(`session_repository.dart` 안의 모든 `select`/`insert`/`update`/`batch` 호출 나열) — A-13.6 PART3/PART4와 일치. | **OK** |
| **Engine Responsibility** | ADR-001 + A-13.6 PART4(`PricingEngine`/`PromotionEngine`/`StaffEarningEngine` 3개 모두 "변경 필요 없음"으로 확인 — `closeSession()` 내부에서 실제 Engine 호출은 `StaffEarningEngine.calcEarnings()`(301행) 1곳뿐). | **OK** |

**종합**: 6개 Contract 항목 전부 `OK` — A-13.5와 A-13.6이 서로 다른 관점(책임 분류 vs 입출력 분석)에서 독립적으로 도출한 결론이 서로 충돌 없이 일치한다는 점이, Contract 자체의 일관성을 뒷받침한다.

---

## PART 2 — ADR 정합성 확인

| ADR | 관련 내용 | 충돌 여부 | 추가 조치 필요 여부 |
|---|---|---|---|
| ADR-001(Pricing Engine Domain Isolation) | "Repository만 Drift를 안다" 원칙 — `PricingEngine` 사례로 확립, 이후 `PromotionEngine`/`StaffEarningEngine`에도 동일 적용 | 없음 | 불필요(A-13.6 PART4에서 이미 전부 재확인) |
| ADR-002(Discount Representation) | 할인은 `PaymentSessionItem(itemType='discount')` 이벤트 — `addItem()`의 책임, `closeSession()`은 이 품목을 별도로 다루지 않음 | 없음 | 불필요(`closeSession()`/Workflow 분리와 직접 연관 없음) |
| ADR-003(Financial Events) | 이벤트(`PaymentSessionItem` 등)와 파생 스냅샷(`StaffEarningLedger`)의 구분 | 없음 | 불필요(Workflow 분리는 "누가 호출하는가"의 문제이며, 이 구분 자체는 그대로 유지됨) |
| ADR-004(Promotion Rule Lifecycle) | `PromotionRule`의 상태 모델(`draft`/`active`/`disabled`) | 없음 | 불필요(`closeSession()`/Workflow와 직접 관련 없음) |
| ADR-005(Promotion Stacking Policy) | **존재하지 않음** — A-11.5에서 권장안은 제시했으나 정책 미확정으로 ADR 작성을 보류한 채 종료(`docs/A11_5_PROMOTION_EXPANSION_PLAN.md` 결과물 절) | 검토 대상 아님 | 해당 없음 |
| ADR-006(Staff Earning Policy) | 할인 전 금액 기준 계산 + `closeSession()` 시점 1회 확정(Ledger Snapshot) | 없음 — 오히려 **PART1의 "Partial" 분류(A-13.5/A-13.6에서 식별된 6단계 `StaffEarningEngine` 호출)는 정확히 이 ADR을 코드가 충실히 구현하고 있다는 증거**다(할인 전 기준이므로 Engine이 별도 입력을 더 받을 필요가 없고, `closeSession()` 시점에만 호출되므로 트랜잭션과 결합돼 있음) | **Yes(설계 시 준수 확인 차원)** — A-14가 Workflow를 어떤 형태로 만들든, "Engine은 `closeSession()`이 호출하는 시점에만, 할인 전 금액으로 계산한다"는 본 ADR의 결정을 그대로 유지해야 한다. ADR 자체를 수정할 필요는 없다. |
| ADR-007(A-13 MVP Transaction Scope) | Settlement insert~Session 상태 변경을 단일 Transaction으로 | 없음 — A-13 구현이 이미 이 ADR을 그대로 적용했고, A-13.5/A-13.6 양쪽 분석이 이 경계를 전제로 수행됨 | **Yes(설계 시 준수 확인 차원)** — A-14의 Workflow 형태가 무엇이든 이 Transaction 경계(콜백이 한 곳에서 통째로 실행되어야 함)를 보존해야 한다. ADR 자체를 수정할 필요는 없다. |

**종합**: 7개 ADR(존재하는 6개 + 미존재 1개 확인) 중 어느 것도 현재 Workflow Contract와 **충돌**하지 않는다. ADR-006/007에 대해 "추가 조치 필요"로 표시한 것은 ADR 수정이 아니라, **A-14의 설계 결과물이 이 두 ADR의 결정을 위반하지 않는지 확인하는 절차적 조치**를 가리킨다.

---

## PART 3 — 구현 전제 확인(이미 확정된 내용만)

- **Transaction Boundary 유지**(ADR-007) — `closeSession()`의 `_db.transaction(() async { ... })`(275~326행) 범위는 A-14 구현 후에도 그대로 유지된다.
- **Engine 순수성 유지**(ADR-001) — `PricingEngine`/`PromotionEngine`/`StaffEarningEngine`은 Drift도, Repository도, (향후 생길) Workflow도 모르는 상태를 유지한다.
- **Repository 책임 유지**(ADR-001, A-13.5 PART4) — `session_repository.dart`의 모든 Drift 직접 호출(select/insert/update/batch)은 그 파일 안에 남는다.
- **Workflow Coordination은 임시 책임**(`docs/A12_IMPLEMENTATION_READY.md` PART2) — `SessionRepository`가 현재 겸하고 있는 절차 조율 책임은 "분리 대상"으로 이미 합의돼 있으나, 그 분리의 구체적 형태(어떤 이름의 무엇이 될지)는 A-14 자체가 결정할 사안으로 합의돼 있다.
- **할인 전 금액 기준 계산**(ADR-006) — `StaffEarningEngine.calcEarnings()`의 계산 정책은 변경 대상이 아니다.
- **Ledger는 `closeSession()` 시점에만 생성**(ADR-006) — `addItem()`에서는 생성하지 않는다는 결정 그대로.

본 PART는 새로운 전제를 추가하지 않았다 — 위 6개 모두 ADR 또는 선행 문서에서 이미 확정된 내용의 재나열이다.

---

## PART 4 — 구현 후 유지되어야 하는 불변 조건(현재 코드 기준)

- **계산 결과 동일**: `closeSession()` 265~268행의 결제수단 합계 검증식, `StaffEarningEngine.calcEarnings()`(301행)의 반환값 — 입력이 같으면 출력이 같아야 한다.
- **Transaction 범위 동일**: 결제수단 insert(276~288행)~Session 상태 변경(320~325행)이 여전히 하나의 `_db.transaction()` 콜백 안에 있어야 한다.
- **Engine 호출 순서 동일**: 품목 조회(290~292행) → `EarnableItem` 변환(293~300행) → `StaffEarningEngine.calcEarnings()` 호출(301행) → 조건부 Ledger insert(303~317행)라는 순서가 그대로 유지되어야 한다.
- **Repository Public Interface 동일**: `createSession()`/`addItem()`/`closeSession()`/`cancelSession()`/`getSessionSummary()`/`calcSuggestedTimeFee()`/`calcSuggestedDiscount()`의 매개변수/반환 타입이 바뀌지 않아야 한다.
- **`closeSession()` 반환값 동일**: 마감된 세션의 `PaymentSessionRow`(상태=`closed`, `endAt` 설정됨)를 그대로 반환해야 한다.
- **예외 발생 조건 동일**: `ValidationException`(결제수단 형식 오류)/`BusinessRuleException`(이미 마감됨, 합계 불일치)/`NotFoundException`(세션 없음, `_requireSession()` 경유)이 동일한 조건에서 동일하게 발생해야 한다.

---

## PART 5 — A-14 구현 체크리스트

```
□ Workflow Coordination 책임만 이동한다 — Repository의 Drift 직접 호출 코드(select/insert/update/batch)는 이동하지 않는다.
□ Repository 책임(PART1/PART3)은 그대로 유지한다.
□ PricingEngine / PromotionEngine / StaffEarningEngine을 수정하지 않는다.
□ Transaction 범위(ADR-007, closeSession()의 _db.transaction() 콜백과 동등한 범위)를 유지한다.
□ 기존 테스트(test/features/session/session_repository_test.dart)가 검증하는 동작(상태 전이, 예외 조건, Ledger 생성 시점)의 의미를 유지한다.
□ Public Interface(closeSession() 등 기존 메서드 시그니처)를 유지한다.
□ ADR-001~ADR-007 중 어느 것도 수정하지 않는다.
□ A-13.6 PART3에서 "Partial"로 표시된 6단계(StaffEarningEngine 호출-Ledger insert 결합)를 분리할 경우, ADR-007의 Transaction 경계를 깨지 않는 형태인지 확인한다.
```

본 체크리스트는 새로운 설계를 제시하지 않으며, A-13.5~A-13.7에서 이미 식별된 제약을 점검 항목으로 옮긴 것이다.

---

## PART 6 — 구현 착수 판정

| 확인 항목 | 결과 |
|---|---|
| Workflow Contract 충돌이 있는가 | **없음**(PART1, 6개 항목 전부 OK) |
| ADR 충돌이 있는가 | **없음**(PART2, 7개 ADR 전부 충돌 없음 — 2건은 "설계 시 준수 확인" 차원의 조치만 필요) |
| 구현을 막는 요소가 있는가 | A-13.5/A-13.6에서 식별된 두 가지(Engine 호출-저장 결합의 인터페이스 형태 미정, Transaction 경계를 보존하는 구체적 방법 미정)가 남아 있다. **그러나 이 두 가지는 정확히 "어떤 형태의 Workflow를 어떻게 설계할 것인가"라는 A-14 자체의 설계 작업 범위에 속한다** — 지시문 기준("A-14 범위 안에서 해결 가능한 항목은 착수 가능 여부를 막는 사유로 간주하지 않는다")에 따라, 이는 착수를 막는 외부 장애물이 아니라 A-14가 수행할 작업 그 자체다. |

### 결론

**A-14 Workflow Extraction 착수 가능.**
