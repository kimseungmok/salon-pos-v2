# A-12.11: A-13 Transaction Implementation Readiness

> **목적**: ADR-007에서 확정한 Transaction 범위를 현재 코드 구조에 안전하게 적용할 수 있는지 최종 검증한다. 새 설계/해결책 없음. 코드/DB/테스트/ADR 변경 없음.
> **대상 코드**: `lib/features/session/data/session_repository.dart`(247~330행, `closeSession()`)
> **근거 문서**: ADR-001~ADR-007, `docs/A13_IMPLEMENTATION_DECISION.md`(A-12.10), `docs/A13_IMPACT_MAPPING.md`(A-12.9)
> 작성일: 2026-06-26

---

## PART 1 — 실제 수정 대상 식별

| 항목 | 현재 위치 | 수정 필요 여부 | 수정 이유 |
|---|---|---|---|
| `closeSession()` 본문 전체 | `session_repository.dart` 247~330행 | **Yes** | ADR-007의 Transaction 범위(Settlement~상태변경)를 감싸는 코드(`_db.transaction(() async { ... })`)를 추가해야 하므로, 이 메서드 자체를 수정해야 한다. |
| Settlement 저장(`payment_method_breakdowns` insert) | 271~283행(`_db.batch()`) | **No** | 삽입 로직 자체(어떤 데이터를 어떻게 넣는지)는 그대로다 — Transaction으로 "감싸지는" 것뿐, 이 블록 내부의 코드는 한 글자도 바뀌지 않는다. |
| Ledger Snapshot 저장 | 285~313행(품목 조회 + `StaffEarningEngine.calcEarnings()` + `_db.batch()`) | **No** | 위와 동일한 이유 — 계산/삽입 로직 자체는 무변경, Transaction 범위 안으로 들어갈 뿐. |
| Session 상태 변경 | 315~320행(`_db.update()`) | **No** | 위와 동일한 이유. |

**결론**: 실제로 "내용이 바뀌는" 코드는 없다 — `closeSession()`이라는 함수 경계 자체에 `_db.transaction()` 래퍼 1개를 추가하는 것이 유일한 수정이며, 그 안의 3개 처리(Settlement/Ledger/상태변경)는 기존 코드를 그대로 그 래퍼 안으로 옮기는 것뿐이다.

---

## PART 2 — Transaction 적용 범위 검증

ADR-007이 확정한 범위(`A13_IMPLEMENTATION_DECISION.md` PART3과 동일, 새 범위 없음)를 현재 코드 라인에 그대로 대응시킨다.

| 항목 | 현재 코드 기준 위치 |
|---|---|
| **Transaction 시작 위치** | 265~268행(Settlement 검증, `paidTotal == finalAmount`) 통과 직후 — 즉 270행(`final now = DateTime.now();`) 또는 271행(`_db.batch()` 시작) 지점. |
| **Transaction 종료 위치** | 315~320행(상태 변경 `_db.update()`) 완료 직후. |
| **Transaction 내부 처리** | 결제수단 insert(271~283행), 품목 조회(285~287행), `EarnableItem` 변환(288~295행, DB 미접근이나 같은 스코프), `StaffEarningEngine.calcEarnings()` 호출(296행, 순수 계산), Ledger insert(297~313행), 상태 변경(315~320행). |
| **Transaction 외부 처리** | 입력 검증(251~258행), 세션 조회+가드(260~263행), Settlement 검증 계산(265~268행), 재조회(322~324행). |

### Rollback 영향 범위

| 처리 | Rollback 대상인가 |
|---|---|
| 결제수단 insert(271~283행) | **대상** — Transaction 내부, 실패 시 자동 rollback |
| 품목 조회(285~287행) | 조회 자체는 rollback 대상이 아니나(쓰기 없음), Transaction 내부에 위치하므로 그 시점의 데이터 가시성은 Transaction 격리 범위에 속함 |
| `StaffEarningEngine.calcEarnings()`(296행) | **대상 아님** — DB 접근이 없는 순수 계산(ADR-001), rollback 개념 자체가 적용되지 않음 |
| Ledger insert(297~313행) | **대상** — Transaction 내부, 실패 시 자동 rollback |
| 상태 변경(315~320행) | **대상** — Transaction 내부, 실패 시 자동 rollback |
| 입력 검증(251~258행) | **대상 아님** — Transaction 시작 전이며 DB 쓰기가 없음(예외만 던짐) |
| 세션 조회+가드(260~263행) | **대상 아님** — Transaction 시작 전, 조회만(쓰기 없음) |
| 재조회(322~324행) | **대상 아님** — Transaction 종료(커밋) 후의 읍기, 이미 확정된 데이터를 다시 보는 것뿐 |

---

## PART 3 — 영향 범위 재확인(영향 있는 파일만)

| 파일 | 수정 여부 | 영향 내용 |
|---|---|---|
| `lib/features/session/data/session_repository.dart` | **Yes** | `closeSession()` 본문에 `_db.transaction(() async { ... })` 래퍼 추가(PART1/PART2 그대로). |

**그 외 파일은 영향이 없다.** `A13_IMPACT_MAPPING.md` PART1에서 이미 확인된 사실(`closeSession()`이 `PricingEngine`/`PromotionEngine`을 호출하지 않음, 이 메서드를 호출하는 화면이 production에 0건, `app_database.dart`/`.g.dart`는 ADR-007이 DB Constraint를 요구하지 않으므로 무관) 그대로 — 본 PART는 새로 조사하지 않고 그 결과를 재확인한다.

---

## PART 4 — Business Logic Preservation

| 항목 | 변경 여부 | 확인 결과 |
|---|---|---|
| Settlement 계산 결과(`paidTotal == finalAmount` 검증식) | **No** | 265~268행의 계산식 자체는 Transaction 범위 밖(검증은 시작 전)에 있으며, Transaction 도입으로 이 비교 로직이 바뀔 이유가 없다. |
| StaffEarning 계산 결과(`StaffEarningEngine.calcEarnings()`) | **No** | 이 Engine은 순수 계산 클래스(ADR-001)라 호출 위치가 함수 안의 어느 스코프(Transaction 내부/외부)에 있는지와 무관하게 입력→출력 매핑이 동일하다. |
| Ledger Snapshot 생성 조건(`itemType == 'staff_fee' && staffId != null`, Engine 내부 필터) | **No** | 이 조건은 `StaffEarningEngine.calcEarnings()` 내부 로직이며 Transaction과 무관 — 호출 시점이 바뀌어도 조건문 자체는 그대로다. |
| `closeSession()` 반환값(`PaymentSessionRow`) | **No** | 322~324행의 재조회+반환 로직은 Transaction 종료(커밋) **이후**에 위치하므로, 반환되는 데이터의 내용과 시점(커밋된 최종 상태)이 기존과 동일하다. |
| Repository 공개 인터페이스(`closeSession()`의 시그니처: 매개변수/반환 타입) | **No** | Transaction 도입은 메서드 내부 구현 디테일이며, 매개변수(`sessionId`, `paymentMethods`)나 반환 타입(`Future<PaymentSessionRow>`)을 바꿀 이유가 없다. |
| Engine 계산 결과(`PricingEngine`/`PromotionEngine` 포함) | **No** | PART3에서 확인한 그대로, `closeSession()`은 이 두 Engine을 호출하지 않으므로 영향 자체가 없다. |

**Business Logic 변경이 필요한 항목은 발견되지 않았다.** A-13 범위 밖으로 기록할 항목이 없다.

---

## PART 5 — 테스트 영향 분석

`test/features/session/session_repository_test.dart`에서 `closeSession()`을 호출하는 테스트(`A13_IMPACT_MAPPING.md` PART5에서 이미 식별된 14개 호출 지점 기준)를 그룹 단위로 정리한다.

| 테스트 파일 | 수정 필요 여부 | Transaction 영향 가능성 | 이유 |
|---|---|---|---|
| `test/features/session/session_repository_test.dart` — `closeSession` 그룹(`'4. status == closed 확인'`, `'5. closeSession 후 addItem → ...'`, `'8. 결제수단 합계 != final_amount → ...'`, `'분할결제 ...'`, `'이미 closed인 세션 재마감 시도 → ...'`) | **No** | **Yes** | 전부 "성공 또는 예상된 예외" 경로만 검증하며, Transaction 도입 후에도 **최종 결과**(상태값, 예외 타입, 저장된 행 수)는 동일해야 한다(PART4에서 확인). 다만 내부적으로 단일 트랜잭션 커밋으로 바뀌므로, 테스트가 중간 상태를 들여다보는 방식이라면(예: insert 직후 즉시 조회) 타이밍이 달라질 수 있어 회귀 확인 대상으로 표시한다. |
| 같은 파일 — `Staff Earning Ledger (A-12, ADR-006 연동)` 그룹(`'closeSession()에서 staff_fee 품목의 ledger가 생성됨'`, `'할인 전 금액 기준 ...'`, `'Snapshot 불변성 ...'`, `'Rule(EarningRule) 변경 이후에도 ...'`) | **No** | **Yes** | `closeSession()` 전후로 Ledger 유무를 직접 비교하는 테스트들이라, Transaction의 원자성 자체와는 충돌하지 않지만(최종 결과는 동일) "내부적으로 insert가 일어나는 방식"이 바뀌므로 회귀 확인 대상으로 표시한다. |
| 같은 파일 — `cancelSession` 그룹 중 `'7. closed 세션에 cancelSession → BusinessRuleException'`(설정으로 `closeSession()` 호출 포함) | **No** | **Yes** | `closeSession()`을 선행 단계로만 사용하며 그 반환/부수효과를 직접 검증하지 않지만, 선행 단계의 내부 구현이 바뀌므로 회귀 확인 대상으로 표시한다. |
| 같은 파일 — `getSessionSummary` 그룹(`'session + items + earning + payment 전부 조합'`) | **No** | **Yes** | `closeSession()` 호출 후 `getSessionSummary()`로 4개 테이블을 조합 조회 — Transaction 커밋 이후에 조회하므로 결과는 동일해야 하나, `closeSession()`의 내부 동작이 바뀌므로 회귀 확인 대상으로 표시한다. |
| `test/features/staff_earning/staff_earning_engine_test.dart` | **No** | **No** | `StaffEarningEngine.calcEarnings()`만 직접 호출하며 `SessionRepository`/`closeSession()`을 전혀 참조하지 않는다(A-12.9에서 확인). |
| `test/features/pricing/*.dart`, `test/features/promotion/*.dart` | **No** | **No** | `closeSession()`과 무관(A-12.9 PART5에서 확인 — 본 PART는 그 결과를 재확인). |

**이 표 전체는 A-13 완료 후 Regression 확인 대상 목록으로 사용한다 — 지금 어떤 테스트도 수정하지 않는다.**

---

## PART 6 — 구현 순서 검증

```
1. closeSession()의 Transaction 범위(PART2에서 확정된 경계)를 _db.transaction(() async { ... })로 감싼다.
2. (이동 작업 없음 — Settlement/Ledger/상태변경 코드는 이미 그 안에 순서대로 존재하므로, "옮기는" 단계가 따로 필요하지 않다. PART1에서 확인한 그대로, 내부 코드는 그대로 둔 채 바깥에 래퍼만 씌운다.)
3. flutter analyze
4. PART5에서 식별된 "Transaction 영향 가능성 Yes" 테스트들을 실행해 회귀가 없는지 확인(수정이 아니라 실행/확인)
5. 전체 테스트 실행
```

### 지시문 예시(1~7단계, "Settlement 저장 이동" / "Ledger Snapshot 저장 이동" / "Session 상태 변경 이동")와 다른 점

**현재 코드 구조에서는 "이동" 단계 자체가 불필요하다.** PART1/PART2에서 확인했듯, Settlement→Ledger→상태변경은 **이미 코드 순서상 연속된 블록**(271~320행)으로 존재한다 — 이 셋을 트랜잭션으로 묶기 위해 다른 위치에 있던 코드를 끌어모을 필요가 없다. 따라서 "더 안전한 구현 순서"는 지시문 예시의 2~4단계(개별 이동)를 **생략하고 1단계(래퍼 추가)로 통합**하는 것이다 — 코드를 이동시키는 단계가 늘어날수록 그 과정에서 실수로 순서가 바뀌거나 누락될 위험이 생기는데, 현재 구조는 그런 위험 자체가 없다.

---

## PART 7 — A-13 착수 최종 확인

| 확인 항목 | 결과 |
|---|---|
| 구현을 막는 미결 사항이 있는가 | **없음** — PART1~6에서 확인된 대로, ADR-007이 확정한 범위는 코드 이동 없이 래퍼 1개만 추가하면 되는 수준이며, Business Logic 변경도 발견되지 않았다. |
| ADR 간 충돌이 있는가 | **없음** — `A13_IMPLEMENTATION_DECISION.md`(A-12.10)에서 이미 ADR-002/003/004/006과의 정합성이 확인됐고, ADR-007 자체가 그 분석의 결과물이다. 본 문서는 새로운 ADR 비교를 수행하지 않았으며 충돌 가능성을 새로 발견하지도 않았다. |
| 추가 설계 문서가 필요한가 | **없음** — Transaction 범위(PART2)와 구현 순서(PART6)가 현재 코드만으로 명확히 도출되며, 별도 설계 결정을 요구하는 모호한 지점이 없다. |
| A-13에서 Business Logic 변경이 필요한 항목이 있는가 | **없음**(PART4) |

### 결론

**A-13 구현 착수 가능.**
