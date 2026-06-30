# A-14 Phase 2: Workflow Dependency Validation

> **목적**: A-14 Phase 1에서 추출한 `SessionClosingWorkflow`가 실제로 의존하는 객체/책임을 확인하고, 현재 구조가 적절한지 검증한다. 새 설계/계층/패턴 제안 없음, 해결책 제안 없음 — 사실 확인만 수행한다.
> **대상 코드**: `lib/features/session/workflow/session_closing_workflow.dart`, `lib/features/session/data/session_repository.dart`
> **근거**: ADR-001~ADR-007
> 작성일: 2026-06-26

---

## PART 1 — Workflow 의존성 식별

`SessionClosingWorkflow`(23~29행, 생성자+필드)가 실제로 보유/사용하는 의존성을 전부 나열한다.

| 의존 대상 | 사용 목적 | 필수 여부 | Repository 경유 필요 여부 |
|---|---|---|---|
| `AppDatabase`(`_db`, 28행) | `_db.transaction()`, `_db.batch()`, `_db.select()`, `_db.update()` 등 — `payment_method_breakdowns`/`payment_session_items`/`staff_earning_ledgers`/`payment_sessions` 4개 테이블에 대한 모든 Drift 직접 호출(40~89행) | **필수** — 이 클래스의 모든 메서드 본문이 `_db` 없이는 동작하지 않음 | **Yes** — ADR-001("Repository만 Drift를 안다")의 표현을 그대로 적용하면, Drift 인스턴스를 직접 쥐고 있는 이 클래스는 사실상 그 자체로 "Drift를 아는 계층" 역할을 겸하고 있다. 현재 `SessionRepository`가 생성자에서 같은 `_db`를 그대로 넘겨주는 방식으로 "경유"하고 있다(58~71행, `SessionClosingWorkflow(_db, ...)`). |
| `StaffEarningEngine`(`_staffEarningEngine`, 29행) | `calcEarnings(items: earnableItems)` 호출(65행) — 직원 수익 계산 | **필수** — Ledger 생성 분기(66~82행)의 입력 | **No** — `StaffEarningEngine`은 Drift/Repository를 모르는 순수 계산 클래스(ADR-001)이며, `SessionRepository`를 거치지 않고 `SessionClosingWorkflow`가 직접 보유한다(A-12와 동일한 "선택적 매개변수, 기본값 `const StaffEarningEngine()`" 패턴, 25~26행). |
| `EarnableItem`(도메인 POJO) | `PaymentSessionItemRow → EarnableItem` 변환(57~64행) | 필수(Engine의 입력 타입) | **No** — Drift 비의존 POJO, import만 필요(4행). |
| `PaymentMethodInput`/`SessionStatus`/`SessionStatusX`(`session_repository.dart`에서 `show` import, 6행) | 매개변수 타입(`PaymentMethodInput`)과 상태 값(`SessionStatus.closed.value`, 86행) | 필수 | 해당 없음(Repository 경유 개념이 적용되지 않는 타입/상수 재사용) |

**종합**: `SessionClosingWorkflow`는 의존성이 2개(`AppDatabase`, `StaffEarningEngine`) + 보조 타입 재사용뿐이며, 그중 `AppDatabase`만 "Repository 경유 필요 여부"가 `Yes`로 판단된다. **이 판단은 현재 상태를 기록한 것이며, 수정을 제안하지 않는다**(지시대로).

---

## PART 2 — Repository 책임 재확인(`closeSession()`만 대상)

`closeSession()`(260~298행)이 Workflow를 호출하는 역할만 수행하는지 확인한다.

```
260~271행: 입력 형식 검증(결제수단/금액) — Workflow 호출 없음
272~282행: 세션 조회+가드, Settlement 합계 검증 — Workflow 호출 없음
283~288행: now 계산 + _sessionClosingWorkflow.run() 호출 ← 유일한 Workflow 호출 지점
290~292행: 재조회(반환값 준비) — Workflow 호출 없음
293~297행: 예외 처리(rethrow/wrap)
```

**확인 결과**: `closeSession()`은 Workflow "호출"만 수행하지 않는다 — **호출 전(검증)과 호출 후(재조회) 처리도 여전히 `closeSession()` 자신이 직접 수행한다.** "Workflow를 호출하는 역할만"이라는 표현을 엄밀히 적용하면, 현재 `closeSession()`은 (1) 검증 (2) Workflow 호출 (3) 재조회+예외처리, 3가지 책임을 갖고 있다 — 그중 (2)만 Phase 1에서 새로 생긴 것이고 (1)/(3)은 A-13 이전부터 있던 책임이다.

### `SessionRepository`의 다른 메서드 — 현재 책임만 기록(변경 대상 아님)

| 메서드 | 현재 책임 | Workflow 이전 대상 여부 |
|---|---|---|
| `createSession()`(103~135행) | 업종 검증 → `sessionNo` 생성 → insert → 재조회 | 아니오(이번 검증 대상은 `closeSession()`뿐 — 지시대로 다른 메서드는 분석하되 "이전"을 판단하지 않음. 단, A-13.5 PART1에서 이미 "No, 분리 실익 낮음"으로 분류된 사실을 재확인) |
| `_nextSessionNo()`(137~145행) | 연도별 순번 조회+계산(private 헬퍼) | 아니오 |
| `_requireSession()`(148~156행) | 세션 단건 조회+존재 가드(private 헬퍼) | 아니오 |
| `addItem()`(168~219행) | 검증 → 가드 → insert → `_recomputeTotals()` 호출 → 재조회 | 아니오(A-13.5 PART1에서 "Partial"로 분류됐으나, 이번 Phase 2의 검증 대상은 `closeSession()`뿐이라 본 PART에서 재판단하지 않음) |
| `_recomputeTotals()`(228~241행) | 합계 조회+계산+단일 갱신(private 헬퍼) | 아니오 |
| `closeSession()`(260~298행) | 검증 → **Workflow 호출** → 재조회 | (이미 Phase 1에서 부분 이전됨 — 위 본문 참조) |
| `cancelSession()`(305~325행) | 가드(멱등/closed 체크) → 갱신 | 아니오 |
| `getSessionSummary()`(328~351행) | 4개 테이블 조회+조합 | 아니오 |
| `calcSuggestedTimeFee()`/`calcSuggestedDiscount()`(364행~) | Rule 조회 → Engine 계산 → 반환 | 아니오(이미 독립된 선택적 헬퍼로 존재, A-10/A-11에서부터 구조 동일) |

---

## PART 3 — Workflow 내부 책임 검증

| 책임 | 현재 구현 위치 | 현재 적절성 |
|---|---|---|
| 데이터 조회 | `_db.select(_db.paymentSessionItems)`(54~56행) | **OK** — 이 조회는 6행 뒤 Engine 호출(65행)의 입력을 만들기 위한 것이며, A-13 이전부터 같은 위치(당시 `closeSession()` 본문)에 있던 그대로 옮겨졌을 뿐이다. |
| Engine 호출 | `_staffEarningEngine.calcEarnings(items: earnableItems)`(65행) | **OK** — Engine은 Drift/Repository/Workflow 어느 것도 모르는 순수 함수(ADR-001)이며, 호출 위치가 `SessionRepository`에서 `SessionClosingWorkflow`로 옮겨진 것 외에는 호출 방식 자체가 변하지 않았다. |
| DB 저장 | `_db.batch()` 2곳(40~52행 결제수단, 67~81행 Ledger) | **OK** — A-13에서 이미 트랜잭션으로 묶여 있던 동일 코드, 위치만 이동. |
| 상태 변경 | `_db.update(_db.paymentSessions)...write(status: closed, ...)`(84~89행) | **OK** — 위와 동일한 이유. |
| Transaction 관리 | `_db.transaction(() async { ... })`(39~90행, 메서드 본문 전체를 감싸는 단일 콜백) | **Review** — ADR-007이 "Settlement~상태변경을 단일 Transaction"으로 확정했고 현재 구현이 그 범위를 정확히 지키고 있다는 점에서 **틀리지 않다.** 다만 "Transaction을 시작/관리하는 책임"이 Repository가 아니라 Workflow 쪽 코드(`SessionClosingWorkflow.run()`)에 위치하게 된 것은, ADR-001이 명시한 "Repository만 Drift를 안다"는 표현과 정확히 일치하는지 **재검토할 지점**이다 — `SessionClosingWorkflow`가 `_db.transaction()`을 직접 호출한다는 것은 이 클래스도 Drift API(트랜잭션 메서드 포함)를 직접 다루고 있다는 뜻이기 때문이다. (해결책은 제시하지 않는다 — 현재 상태의 기록만.) |

---

## PART 4 — Engine 의존성 재검증(ADR-001 원칙과의 일치 여부)

| Engine | 호출만 수행 | Engine 수정 필요 | 계약 위반 여부 |
|---|---|---|---|
| `PricingEngine` | 해당 없음 — `SessionClosingWorkflow`는 이 Engine을 전혀 참조하지 않는다(파일 전체에 `PricingEngine` 등장 0건, import도 없음) | **No** | **No** |
| `PromotionEngine` | 해당 없음 — 위와 동일(참조 0건) | **No** | **No** |
| `StaffEarningEngine` | **Yes** — `calcEarnings()` 호출(65행) 1회뿐, 그 외에 이 Engine의 내부 로직/필드에 접근하지 않음 | **No** | **No** — `StaffEarningEngine`은 `SessionClosingWorkflow`를 모르고(import 없음, 역참조 없음), `SessionClosingWorkflow`는 이 Engine을 생성자 주입으로만 받아 메서드 호출만 한다(ADR-001의 "Engine은 누구에게도 의존하지 않고 호출만 당한다"는 불변량과 일치). |
| `SettlementEngine`(예시 명칭, 실제 코드에 이 이름의 클래스는 존재하지 않음) | 해당 없음 — 결제수단 합계 검증(278~280행)은 `closeSession()` 본문의 인라인 로직일 뿐, `SessionClosingWorkflow` 내부에는 이 검증 로직 자체가 없다(검증은 Workflow 호출 **전**에 이미 끝나 있음, PART2 참조) | 해당 없음(클래스 자체가 없어 "수정"이라는 개념이 적용되지 않음) | 해당 없음 |

**종합**: `SessionClosingWorkflow`가 실제로 호출하는 Engine은 `StaffEarningEngine` 1개뿐이며, 그 호출 방식(생성자 주입 + 메서드 호출만)이 ADR-001과 충돌하지 않는다.

---

## PART 5 — 현재 구조 유지 가능성 확인(향후 확장성은 근거로 사용하지 않음)

| 항목 | 현재 필요 여부 | 근거 |
|---|---|---|
| Workflow Interface(추상 클래스/인터페이스) | **Not Required** | 현재 `SessionClosingWorkflow`를 호출하는 곳은 `SessionRepository.closeSession()` 1곳뿐이고(코드 전체 검색 기준), 구현체가 1개뿐인 상태에서 인터페이스를 둘 근거(예: 여러 구현체 교체, 테스트용 Mock 등)가 현재 코드에 없다. |
| Workflow Provider(Riverpod) | **Not Required** | `lib/features/session/providers.dart`를 확인한 결과, `SessionClosingWorkflow`는 별도 Provider 없이 `SessionRepository` 생성자 내부에서 직접 생성된다(`session_repository.dart` 68~71행) — 현재 어떤 화면/Provider도 `SessionClosingWorkflow`를 독립적으로 주입받지 않으므로 별도 Provider가 필요한 사용처가 없다. |
| Workflow Repository(별도 데이터 접근 클래스) | **Not Required** | `SessionClosingWorkflow`가 다루는 4개 테이블은 모두 기존 `session_tables.dart`(A-8)에 정의된 것이고, 새로운 영속 데이터를 위한 별도 Repository가 필요하다는 근거가 현재 코드/ADR 어디에도 없다. |

세 항목 모두 "향후 확장 가능성"이 아니라, **현재 코드에 그것을 요구하는 사용처/근거가 없다는 사실**만으로 판단했다(지시대로).

---

## PART 6 — Phase 2 결론

| 확인 항목 | 결과 |
|---|---|
| Workflow 책임이 명확한가 | **명확하다** — PART3에서 5가지 책임(조회/Engine호출/DB저장/상태변경/Transaction관리) 전부 위치가 식별됐고, 4가지는 `OK`, 1가지(Transaction 관리)만 `Review`로 표시됐다. |
| Repository 책임과 충돌이 없는가 | **충돌 없음** — PART2에서 확인한 대로 `closeSession()`의 검증/재조회 책임과 `SessionClosingWorkflow`의 절차 수행 책임이 명확히 나뉘어 있다(다만 PART2에서 "Workflow 호출만 수행"이라는 표현이 정확히는 "검증→호출→재조회"의 3단계 중 하나라는 점도 사실로 기록했다). |
| Engine 책임과 충돌이 없는가 | **충돌 없음** — PART4에서 4개 Engine(3개 무관, 1개 호출만) 전부 확인. |
| 현재 구현을 막는 구조적 문제가 있는가 | PART3/PART1에서 식별된 사항(Workflow가 `AppDatabase`를 직접 보유하고 `_db.transaction()`을 직접 호출 — ADR-001의 "Repository만 Drift를 안다"는 표현과 엄밀히 일치하는지 재검토 지점)이 있다. **그러나 이는 ADR-007이 확정한 Transaction Scope를 정확히 지키기 위한 현재 구현의 결과이며, 실제 동작(A-14 Phase 1에서 확인된 회귀 0건)을 막지 않는다.** 지시문 기준("A-14 범위 안에서 해결 가능한 사항은 착수를 막는 사유로 간주하지 않는다")에 따라, 이는 착수를 막는 구조적 문제가 아니라 **현재 구현이 의식적으로 받아들인 트레이드오프**로 기록한다. |

### 결론

구조적 개선 가능성(PART3의 `Review` 1건, PART1의 `Yes` 1건)이 존재하지만, 둘 다 ADR-007의 Transaction Scope를 보존하기 위한 현재 구현의 직접적 결과이고 실제 동작을 막지 않으므로 — **"현재 구조 유지 권장"**으로 판단한다.

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | Workflow 의존성 확인 | ✅ PART 1 — 4개 항목, `AppDatabase`만 Repository 경유 필요=Yes |
| 2 | Repository 책임 재확인 | ✅ PART 2 — `closeSession()`은 호출만이 아니라 검증/호출/재조회 3단계, 다른 8개 메서드 현재 책임 기록 |
| 3 | Workflow 내부 책임 검증 | ✅ PART 3 — 5개 책임, OK 4건/Review 1건 |
| 4 | Engine 계약 재검증 | ✅ PART 4 — 4개 Engine(명칭 예시 1건 포함), 계약 위반 0건 |
| 5 | 현재 구조 유지 가능 여부 확인 | ✅ PART 5 — Interface/Provider/Repository 3개 전부 Not Required |
| 6 | 구조적 문제 존재 여부 확인 | ✅ PART 6 — 1건 식별, 착수를 막는 문제 아님으로 판단, **현재 구조 유지 권장** |
| 7 | 코드/DB/테스트/ADR 변경 없음 확인 | 아래 git status로 확인 |
