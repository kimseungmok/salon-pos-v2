# A-17: Architecture Operational Stability Check

> **목적**: A-16에서 확정된 `SessionRepository`/`SessionClosingWorkflow` 구조가 실제 실행 환경 기준에서 안정적으로 동작하는지 확인한다(설계 검증이 아니라 운영 관점). 새 설계/계층 없음, Business Logic 변경 없음, 구현 없음(분석+실행 확인만).
> **대상 코드**: `lib/features/session/data/session_repository.dart`, `lib/features/session/workflow/session_closing_workflow.dart`(A-14 Phase 1 이후 무변경)
> **근거**: A-16(`docs/A16_ARCHITECTURE_FINALIZATION.md`)을 "기준 구조"로 간주, ADR-001~ADR-007
> **검증 방법상의 제약(먼저 명시)**: 이번 오더는 "테스트 추가 금지"이므로, 실제 실패를 주입해 rollback을 직접 관찰하는 새 테스트는 작성하지 않았다. 아래 PART2/3의 "실행 중 동작" 관련 항목은 (a) 코드를 직접 읍어 확인 가능한 사실(예외 전파 경로 등)과 (b) Drift/SQLite가 문서화하여 보장하는 메커니즘(트랜잭션 콜백 예외 시 자동 rollback)을 근거로 판단했다 — **이 둘을 명확히 구분해 표기한다.**
> 작성일: 2026-06-26

---

## PART 0 — 기준 원칙

A-14~A-16에서 확정된 구조는 설계 기준으로 변경하지 않고 그대로 유지한다. A-16의 결론(`Architecture Finalization Completed`)을 "기준 구조"로 간주하고, 본 문서는 그 구조가 **실행 시점**에도 유효한지만 추가로 확인한다.

---

## PART 1 — 실제 실행 흐름 검증(Runtime Flow)

| 항목 | 상태 | 근거 |
|---|---|---|
| 실행 순서 역전 여부 | **OK** | 코드 직접 확인(`session_repository.dart` 264~292행) — 입력검증 → 세션조회/가드 → Settlement계산 → `_sessionClosingWorkflow.run()` 호출 → 재조회 순서가 소스 코드의 줄 순서 그대로다. Dart는 `await` 지점마다 순차 실행을 보장하므로(단일 isolate 내 협력적 동시성, `docs/A13_CONCURRENCY_VALIDATION.md`에서 이미 정리된 실행 모델), 코드에 적힌 순서와 실제 실행 순서가 어긋날 가능성이 없다. |
| Transaction 범위 유지 여부 | **OK** | 코드 직접 확인 — `SessionClosingWorkflow.run()`(34~91행) 전체가 `_db.transaction(() async { ... })`(39~90행) 콜백 안에 있고, 이 메서드를 호출하는 `closeSession()`도 그 호출을 `await`로 기다린 뒤에야 재조회로 넘어간다 — 콜백이 끝나기 전에 다음 단계가 실행될 수 없다. |
| Workflow 호출 실패 가능 지점 | **확인됨, OK(목록화)** | 코드 직접 확인 — `run()` 내부에 `try`/`catch`가 전혀 없다(grep 결과 0건). 즉 실패 가능 지점은 (1) `_db.batch()`(결제수단 insert), (2) `_db.select()`(품목조회), (3) `_staffEarningEngine.calcEarnings()`(순수 계산 — 입력이 정상 범위면 예외를 던지지 않음, 음수 방지 로직이 `clamp()`로 항상 안전한 값을 반환하도록 설계됨, A-12에서 확인), (4) `_db.batch()`(Ledger insert), (5) `_db.update()`(상태변경) — 이 5곳 중 (3)을 제외한 4곳은 모두 Drift I/O이며, 실패하면 즉시 예외가 던져진다(`catch` 없이 그대로 전파, PART3에서 상세). |

---

## PART 2 — Transaction 실제 안정성 확인(ADR-007 범위)

| 항목 | 실행 중 실패 가능성 | rollback 보장 여부 |
|---|---|---|
| Settlement(`payment_method_breakdowns` insert) | 있음(디스크 I/O 오류, 제약 위반 등 — 코드상 막연한 가능성, 현재 테스트에서 실제 발생 사례는 없음) | **보장됨(Drift `_db.transaction()`의 문서화된 동작)** — 콜백 내부에서 예외가 발생하면 그 콜백 전체가 자동 rollback된다. 이 보장은 같은 코드베이스의 `payment_repository.dart:262`(`cancelOrder()`)가 이미 동일한 메커니즘에 의존하고 있다는 선례로 추가 확인된다(`docs/A13_IMPACT_MAPPING.md` PART4에서 이미 인용된 선례). |
| `StaffEarningEngine` 호출 | **매우 낮음** — 순수 계산이며 DB/외부 I/O가 없고, 모든 분기(음수 방지 `clamp`, 빈 리스트 처리)가 예외 없이 값을 반환하도록 구현돼 있다(코드 확인, `staff_earning_engine.dart`에 `throw` 0건) | 해당 없음(실패 자체가 사실상 발생하지 않는 지점이라 rollback 시나리오가 적용될 일이 거의 없음) |
| Ledger insert(조건부) | 있음(Settlement과 동일한 종류의 I/O 실패 가능성) | **보장됨**(위와 동일한 근거) |
| Session 상태 변경 | 있음(동일한 종류) | **보장됨**(위와 동일한 근거, 콜백의 마지막 쓰기이므로 실패 시 그 직전까지의 쓰기도 함께 rollback됨) |

**중요한 구분**: "rollback 보장 여부"는 **Drift/SQLite가 제공하는 트랜잭션 메커니즘에 대한 신뢰**에 근거한 판단이며, 본 문서가 실제로 디스크 오류 등을 주입해 rollback이 일어나는 것을 직접 관찰한 것은 아니다(이번 오더의 "테스트 추가 금지" 제약 안에서는 그런 실증이 불가능하다) — 이 한계를 PART7에서 다시 명시한다.

---

## PART 3 — Workflow 실행 안정성 확인

| 항목 | 결과 | 근거 |
|---|---|---|
| 실패 시 rollback 동작 정상 여부 | **OK(이론적 근거, 실증 아님)** | PART2와 동일한 근거 — Drift `_db.transaction()`의 표준 동작에 의존. 코드가 이 메커니즘을 올바르게 사용하고 있는지(콜백 범위가 정확한지)는 PART1에서 직접 코드로 확인했다. |
| partial execution 발생 여부 | **OK(구조상 불가능)** | 4개 쓰기(Settlement/Ledger/상태변경, 그리고 그 사이의 조회)가 전부 같은 `_db.transaction()` 콜백 안에 있으므로, SQLite의 단일 트랜잭션 원자성 보장상 "일부만 커밋되는" 상태가 발생할 수 없다 — 이는 A-13에서 ADR-007을 도입한 목적 그 자체이며, A-14 Phase 1에서 코드 위치만 이동했을 뿐 이 보장은 그대로 유지된다. |
| 예외 propagation 정상 여부 | **OK(코드로 직접 확인)** | `SessionClosingWorkflow.run()`에 `try`/`catch`가 없으므로(grep 0건), 콜백 내부에서 발생한 어떤 예외든 `run()`을 그대로 빠져나가 `closeSession()`의 `try { ... } on AppException { rethrow; } catch (e) { throw DatabaseException.writeFailed('$e'); }`(295~297행 부근)로 전달된다 — A-13 이전부터 있던 이 예외 처리 구조가 Workflow 추출 이후에도 한 글자도 바뀌지 않았다(A-14 Phase 1~4, A-15에서 반복 확인된 사실). |

---

## PART 4 — Repository Runtime 영향 확인

| 항목 | 영향 여부 | 설명 |
|---|---|---|
| Workflow 도입 이후 latency 증가 | **No**(구조상 증가 없음 — 단, ms 단위 실측은 수행하지 않음) | A-14 Phase 1 전후 코드를 비교하면, DB 호출 횟수(batch 2회+select 1회+update 1회) 자체는 동일하고 추가된 것은 메서드 호출 1단계(`closeSession()` → `_sessionClosingWorkflow.run()`)뿐이다 — Dart의 함수 호출 오버헤드는 무시할 수준이라 통상적인 의미의 "latency 증가"는 구조적으로 발생하지 않는다. 다만 본 문서는 실제 프로파일러로 ms 단위를 측정하지 않았다 — 이는 "기준선 확인"(PART6, analyze/test 통과 여부)의 범위를 넘는 별도 성능 측정 작업이며, 이번 오더가 요구하는 항목(실행 안정성 확인)과는 다른 종류의 검증이다. |
| 호출 경로 변경 | **Yes**(이미 A-14 Phase 1에서 발생, 새로운 변경 아님) | `closeSession()` → `SessionClosingWorkflow.run()` → Drift라는 경로가 A-14 Phase 1부터 존재하며, A-16까지 이 경로 자체는 변경되지 않았다(이전과 동일 — 본 PART는 "변경이 있었다"는 사실을 한 번 더 확인했을 뿐, 새로운 변경을 보고하는 것이 아니다). |
| side effect 증가 | **No** | `SessionClosingWorkflow`가 수행하는 DB 쓰기(결제수단/Ledger/상태)는 A-13 이전 `closeSession()`이 직접 수행하던 것과 정확히 동일한 3종이다 — Workflow 추출은 "누가 쓰는가"만 바꿨을 뿐 "무엇을 쓰는가"는 그대로다(A-14 Phase 1~4에서 반복 확인된 "Business Logic 무변경" 사실의 runtime 관점 재확인). |

---

## PART 5 — 운영 관점 구조 안정성 판단

| 항목 | 위험 여부 | 이유 |
|---|---|---|
| 장애 발생 시 rollback 가능성 | **위험 낮음** | PART2/PART3에서 확인한 대로 Drift 트랜잭션 메커니즘에 의존하며, 이는 같은 코드베이스의 다른 곳(`payment_repository.dart`)에서도 이미 쓰이고 있는 검증된 방식이다. 다만 "위험 0"이라고 단정하지 않는다 — 실제 디스크/전원 장애 상황에서의 동작은 SQLite 자체의 신뢰성에 종속되며, 이 앱 코드가 추가로 보장할 수 있는 범위 밖이다(`docs/A13_CONCURRENCY_VALIDATION.md`에서 이미 같은 한계가 명시됨). |
| 부분 실패 시 데이터 일관성 | **위험 낮음** | PART3 "partial execution 발생 여부: OK(구조상 불가능)"와 동일한 근거 — Settlement/Ledger/상태변경이 분리된 채로 일부만 저장되는 시나리오는 현재 구조(단일 트랜잭션)에서 발생할 수 없다. |
| Workflow 단일 실패 지점(Single Point of Failure) 존재 여부 | **존재함, 위험 중간** | `SessionClosingWorkflow.run()` 1곳이 `closeSession()`의 모든 쓰기를 담당한다 — 이 메서드가 실패하면 마감 전체가 실패한다는 점에서 "단일 실패 지점"은 사실이다. 그러나 이는 ADR-007이 의도한 그대로(쓰기를 분산시키지 않고 하나로 묶어 원자성을 확보)이며, **"단일 실패 지점이 존재한다"는 사실과 "그것이 운영 위험이다"는 판단은 다르다** — 오히려 쓰기가 여러 곳에 흩어져 있었다면(A-13 이전 구조) 부분 실패 위험이 더 컸다(A-12.6에서 실제로 식별된 문제). 따라서 이 단일 실패 지점은 **의도된 설계의 결과이자, 더 큰 위험(부분 실패)을 줄이기 위한 트레이드오프**로 판단한다. |
| Transaction 경계 실효성 | **위험 낮음** | PART1/PART2/PART4에서 모두 확인된 대로, 코드상 경계(콜백 범위)와 ADR-007이 의도한 경계가 정확히 일치하며 A-14 Phase 1 이후 한 번도 어긋난 적이 없다. |

---

## PART 6 — 기준선 실행 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **368건 전부 통과**(`All tests passed!`) — A-16과 동일 건수, 회귀 없음 |

이 결과는 설계 변경 판단이 아니라 **실행 안정성 기준 데이터**로만 사용한다 — 코드를 전혀 수정하지 않았으므로 A-16 시점과 동일한 상태의 재확인이다.

---

## PART 7 — 최종 결론

| 확인 항목 | 결과 |
|---|---|
| 실제 실행 환경에서도 구조가 안정적인가 | **그렇다** — PART1(실행 순서/범위 OK), PART4(latency/side effect 구조상 증가 없음). |
| Transaction이 운영 환경에서도 유지되는가 | **그렇다** — PART2(4개 항목 전부 rollback 보장됨), PART3(partial execution 구조상 불가능). **단, 이 판단은 Drift/SQLite의 문서화된 트랜잭션 보장에 대한 신뢰에 근거하며, 실제 장애를 주입해 직접 관찰한 실증 결과는 아니다**(본 문서 서두에서 명시한 검증 방법상의 제약). |
| Workflow 도입으로 장애 가능성이 증가하지 않는가 | **증가하지 않는다** — PART4(호출 경로는 바뀌었으나 side effect/latency는 동일), PART5(단일 실패 지점은 존재하나 이는 부분 실패 위험을 줄이기 위한 의도된 트레이드오프). |
| A-16 구조가 운영 단계에서도 유효한가 | **유효하다** — PART6 기준선(analyze 클린, 테스트 368건 통과)이 A-16과 동일하게 안정적이며, PART1~5에서 새로 발견된 구조적 결함이 없다. |

### 결론

4개 항목 모두 충족되었다 — 단, "Transaction이 운영 환경에서도 유지되는가"에 대한 확신은 **이론적 근거(Drift/SQLite 보장)에 기반한 것이며, 실제 실패 주입 테스트로 실증된 것이 아니다**는 점을 결론에 포함해 명시한다.

**"Architecture Operational Stability Confirmed"**

(단서: 위 한계— 실제 장애 주입 검증은 향후 별도 작업으로 남아 있으며, 본 확인은 코드 분석과 Drift/SQLite의 문서화된 보장에 근거한다.)
