# A-18.2: Minimal Change Resolution Analysis

> **목적**: A-18.1에서 확인된 `closeSession()`의 동시 호출(Race Condition) 가능성을, A-14~A-17 구조를 그대로 유지하면서 가장 작은 변경(Minimal Change)으로 해결 가능한 방법 1개를 선정한다. Best Design 탐색이 아니다. 분석만 수행 — 코드 수정 없음.
> **대상 코드**: `lib/features/session/data/session_repository.dart`(260~298행), `lib/features/session/workflow/session_closing_workflow.dart`
> **근거**: A-18.1(`docs/A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md`), A-12.7(`docs/A13_CONCURRENCY_VALIDATION.md`), A-12.10(`docs/A13_IMPLEMENTATION_DECISION.md`)
> 작성일: 2026-06-29

---

## PART 0 — 기준 원칙

A-14~A-18.1에서 확정된 구조(Repository/Workflow 분리, ADR-007 Transaction Scope)는 변경하지 않는다. 새 설계/패턴/계층을 추가하지 않는다. 모든 판단은 실제 코드 확인 결과만 근거로 한다.

---

## PART 1 — Race Condition 원인 확인(A-18.1 재확인, 신규 원인 추가 없음)

| 항목 | 현재 상태 | 근거 |
|---|---|---|
| `session.status` 가드가 Transaction 밖에서 수행됨 | **Confirmed** | `session_repository.dart` 273~276행(`final session = await _requireSession(sessionId); if (session.status != open) throw ...;`)이 283~288행의 `_sessionClosingWorkflow.run()` 호출(=Transaction 시작) **이전**에 위치 — 코드 재확인, A-18.1 PART1과 동일. |
| DB 레벨 UNIQUE 제약 없음 | **Confirmed** | `lib/db/app_database.dart`/`session_tables.dart` 재확인 — `payment_method_breakdowns`/`staff_earning_ledgers` 어느 컬럼에도 UNIQUE 제약 없음(A-18.1 PART3과 동일). |
| `closeSession()` 호출자가 production 코드에 없음(노출도 0) | **Confirmed** | `grep -rn "closeSession("` 재실행 결과 정의/주석 외 호출 0건, `sessionRepositoryProvider`를 참조하는 화면 0건(재확인, A-12.9/A-18.1과 동일). |

**3개 항목 모두 A-18.1에서 이미 확인된 것의 재확인이다 — 새로운 원인은 발견되지 않았다.**

---

## PART 2 — 적용 가능한 해결 방법 조사

| 해결 방법 | 적용 가능 여부 | 장점 | 단점 |
|---|---|---|---|
| **Transaction 내부 상태 재확인**(트랜잭션 콜백 안에서 `session.status`를 다시 `SELECT`해서 확인) | **Partial** | 기존 가드 로직(`status != open` 체크)을 거의 그대로 재사용 가능 — 코드 형태가 가장 친숙함. | A-12.10 PART1에서 이미 식별된 그대로, 이 방식의 안전성은 Drift/SQLite의 트랜잭션 격리 수준(`BEGIN DEFERRED` vs `IMMEDIATE`)에 의존하며, 이 격리 수준을 검증하지 않고는 "두 번째 호출이 첫 번째 호출의 커밋을 보고 정확히 차단되는지" 확신할 수 없다 — **미검증 가정에 의존**. |
| **Conditional Update**(상태 변경 쓰기에 `WHERE status='open'` 조건을 추가하고, 영향받은 행 수를 확인) | **Yes** | 단일 SQL 문(`UPDATE`)은 SQLite의 속성상 그 자체로 원자적이다 — A-12.10 PART1에서 이미 "확정 가능한 사실"로 분류됨(격리 수준과 무관하게 SQLite의 단일 쓰기자 모델이 보장). 두 호출이 동시에 같은 행을 갱신하려 해도, 하나는 반드시 먼저 적용되고 그 직후 `status`가 더 이상 `'open'`이 아니므로 두 번째 호출의 `WHERE` 조건이 거짓이 되어 **영향 행 수 0**으로 자연히 걸러진다. | 영향 행 수를 확인하는 분기(0이면 예외)를 새로 추가해야 한다 — 단, 이는 기존에 이미 존재하는 예외(`BusinessRuleException`, "이미 마감됨")를 재사용할 수 있어 새 예외 타입이 필요 없다. |
| **Optimistic Lock**(버전 컬럼 추가 후 갱신 시 버전 비교) | **No** | (해당 없음) | 새 컬럼이 필요해 **DB 변경**이 발생한다 — 본 작업의 "DB 변경 금지" 제약과 충돌, 검토 대상에서 제외. |
| **Database Lock**(명시적 테이블/행 잠금) | **No** | (해당 없음) | SQLite/Drift는 애플리케이션 레벨의 명시적 행 잠금(`SELECT ... FOR UPDATE` 류) API를 이 코드베이스에서 사용한 적이 없다(`grep` 결과 0건) — 새로운 패턴 도입에 해당해 제약과 충돌. |

---

## PART 3 — 기존 구조 영향도 확인

| 해결 방법 | 구조 영향 | 이유 |
|---|---|---|
| Transaction 내부 상태 재확인 | **Partial** | `SessionClosingWorkflow.run()` 내부에 새로운 조회(`_db.select()`) 1줄과 분기가 추가된다 — Repository/Workflow의 책임 경계(A-14 Phase 2/3/4에서 확정된 "Trade-off로 Accepted된 경계")는 그대로 유지되나, Workflow 내부 로직의 단계 수가 늘어난다. |
| Conditional Update | **None** | 기존에 이미 존재하는 단일 `UPDATE` 문(84~89행)의 `WHERE` 절에 조건 1개를 추가하고, 그 문장의 반환값(영향 행 수)을 확인하는 분기만 추가한다 — 새로운 조회, 새로운 메서드, 새로운 클래스가 전혀 필요 없다. Repository/Workflow 경계, Transaction Scope(ADR-007), Engine 호출 순서 모두 무영향. |
| Optimistic Lock | **Large**(검토 대상 제외) | 새 컬럼 추가 → 마이그레이션 → 모든 갱신 경로에서 버전 비교 로직 추가 — 영향 범위가 가장 크다. |
| Database Lock | **Large**(검토 대상 제외) | 이 코드베이스에 없는 새로운 동시성 제어 패턴을 도입해야 하므로 영향 범위를 가늠하기조차 어렵다. |

---

## PART 4 — 변경 범위 확인(수정은 수행하지 않음, 대상 파일만 식별)

| 파일 | 영향 여부 | 변경 예상 범위 |
|---|---|---|
| `lib/features/session/workflow/session_closing_workflow.dart` | **있음**(Conditional Update 채택 시) | 84~89행의 `_db.update(_db.paymentSessions)..where((s) => s.id.equals(sessionId))).write(...)` 한 문장의 `where` 절에 `& s.status.equals(SessionStatus.open.value)` 조건 추가, 반환값(영향 행 수) 확인 후 0이면 예외 throw 분기 추가 — **이 파일 하나, 한 메서드의 마지막 문장 근처**만 영향받는다. |
| `lib/features/session/data/session_repository.dart` | **없음** | `closeSession()`의 기존 가드(273~276행)는 그대로 둔다(이미 "순차 재시도"를 막는 역할을 충실히 하고 있으므로 제거할 이유가 없다, A-18.1 PART1) — Conditional Update는 이 파일을 건드리지 않고도 동시 호출 문제를 해결한다. |
| 그 외 파일(Engine/Provider/테스트/ADR) | **없음** | Conditional Update는 Engine 계산, Provider 구조, Public Interface(`closeSession()` 시그니처/반환값/예외 타입) 어느 것도 바꾸지 않는다 — 영향 범위에서 제외. |

**Conditional Update를 택할 경우, 실제 수정 대상은 단 1개 파일, 단 1개 문장이다.**

---

## PART 5 — Minimal Change 비교

| 기준 | Transaction 내부 상태 재확인 | Conditional Update |
|---|---|---|
| Business Logic 영향 | 없음(상태 비교 로직 자체는 동일) | 없음(동일) |
| Transaction Boundary 유지 여부 | 유지됨(같은 콜백 안에 조회 추가) | 유지됨(같은 콜백 안의 기존 문장만 수정) |
| 테스트 영향 | "이미 closed인 세션 재마감 시도" 테스트의 통과 여부는 동일하게 유지될 것으로 예상되나, 새 조회 결과에 따른 분기 경로가 하나 늘어나 검증 포인트가 늘어남 | 기존 "이미 closed인 세션 재마감 시도 → `BusinessRuleException`" 테스트(`session_repository_test.dart`)가 이미 같은 예외 타입을 검증하고 있어, 회귀 검증 대상이 명확하고 좁음 |
| 구현 난이도 | 중간(격리 수준에 대한 이해와 검증이 추가로 필요 — A-12.10에서 "미검증"으로 분류된 영역) | 낮음(SQLite의 잘 알려진 단일 문장 원자성에만 의존, 추가 검증 불필요) |
| 변경 범위 | 1개 파일, 조회 1줄+분기 추가 | 1개 파일, 기존 문장의 `where` 절+반환값 확인 추가 |

---

## PART 6 — Minimal Change 방식 선정

**선정: Conditional Update(상태 변경 쓰기에 `WHERE status='open'` 조건 추가 + 영향 행 수 확인)**

**선정 이유**:
1. **변경 범위가 가장 좁다**(PART4) — 1개 파일, 기존에 이미 존재하는 단일 문장의 조건과 반환값 확인만 추가하면 된다. 새 조회, 새 메서드, 새 클래스, 새 컬럼이 전혀 필요 없다.
2. **이미 이 프로젝트의 분석 문서(A-12.10 PART1 ②)에서 "확정 가능한 사실"로 분류된 보장**(SQLite 단일 `UPDATE` 문의 원자성)에만 의존한다 — "Transaction 내부 상태 재확인"이 의존하는 격리 수준은 같은 문서에서 "미검증"으로 명시적으로 보류된 가정이다. 더 적은 가정으로 같은 목적을 달성할 수 있는 쪽이 Minimal Change 기준에 더 부합한다.
3. **기존 예외 타입을 그대로 재사용 가능하다** — "영향 행 수 0"을 "이미 마감됨"과 동일하게 취급해 기존 `BusinessRuleException`(273~276행에서 이미 쓰이는 것과 같은 의미)을 그대로 던지면 되므로, 새로운 예외 클래스나 에러 코드를 만들 필요가 없다.
4. **A-14~A-17이 확정한 구조(Repository/Workflow 경계, ADR-007 Transaction Scope)를 전혀 건드리지 않는다**(PART3에서 "구조 영향: None"으로 확인) — Best Design을 새로 설계하는 것이 아니라, 기존 구조 안의 기존 문장 하나를 더 안전하게 만드는 것에 그친다.

(본 항목은 분석/선정까지만 수행하며, 실제 코드 수정은 본 오더 범위 밖이다.)

---

## PART 7 — 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **368건 전부 통과**(`All tests passed!`) — A-18.1과 동일 건수, 회귀 없음 |

이 결과는 현재 상태 확인용 기준선으로만 사용한다 — 코드를 수정하지 않았으므로 A-18.1 시점과 동일한 상태의 재확인이다.

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | Race Condition 원인 확인 | ✅ PART 1 — 3개 항목 전부 `Confirmed`(신규 원인 없음) |
| 2 | 적용 가능한 해결 방법 조사 | ✅ PART 2 — 4개 방법, Yes 1건/Partial 1건/No 2건 |
| 3 | 기존 구조 영향도 확인 | ✅ PART 3 — Conditional Update만 `None` |
| 4 | 변경 범위 확인 | ✅ PART 4 — 1개 파일, 1개 문장 |
| 5 | Minimal Change 비교 | ✅ PART 5 |
| 6 | Minimal Change 방식 선정 | ✅ PART 6 — **Conditional Update** |
| 7 | `flutter analyze`/`test` 기준선 기록 | ✅ PART 7 |
