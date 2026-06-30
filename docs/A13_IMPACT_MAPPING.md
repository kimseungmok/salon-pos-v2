# A-12.9: A-13 Impact Mapping

> **목적**: A-13 구현 시 실제로 변경될 범위를 코드 기준으로 정확히 식별한다. 새 설계/해결책 없음. 코드/DB/테스트/ADR 변경 없음.
> **조사 방법**: 실제 코드 grep/읍기 기준(추측 없음).
> **선행 문서**: `docs/A13_TRANSACTION_BOUNDARY_REVIEW.md`(A-12.5), `docs/A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md`(A-12.6), `docs/A13_CONCURRENCY_VALIDATION.md`(A-12.7)
> 작성일: 2026-06-26

---

## PART 1 — 변경 대상 파일 식별

### 조사로 확인된 사실(추측 없음)

- `closeSession(` 호출은 **production 코드(`lib/`) 어디에도 없다** — `grep -rn "closeSession(" lib/` 결과, 정의(`session_repository.dart`)와 주석 1건(`staff_earning_engine.dart:13`, 문서 주석) 외에는 0건.
- `sessionRepositoryProvider`/`SessionRepository(`를 참조하는 화면(screen)/위젯 코드가 **lib/ 전체에 0건**이다(`grep -rln "sessionRepositoryProvider\|SessionRepository(" lib/`에서 `providers.dart`/`session_repository.dart` 자기 자신 외 결과 없음). **즉 Session Engine(A-8~A-12)은 아직 어떤 화면에도 연결되지 않은 상태다.**
- `_db.transaction()`의 실제 사용 사례가 이미 코드베이스에 1건 존재한다: `lib/features/payment_pos/data/payment_repository.dart:262`의 `cancelOrder()` — 조회→상태 분기→복수 쓰기(다른 Repository 호출 포함)를 전부 트랜잭션으로 감싸는 정확한 선례.

### 파일별 표

| 파일 | 변경 예상 이유 | 변경 예상 수준 | 변경 필수 여부 |
|---|---|---|---|
| `lib/features/session/data/session_repository.dart` | `closeSession()` 본문이 A-13의 직접 대상(Transaction Boundary/Idempotency 적용 지점) | **High** | **Yes** |
| `lib/db/app_database.dart` | A-13에서 DB Constraint(예: UNIQUE)를 채택하면 `PromotionRules` 추가 때와 같은 패턴(테이블 컬럼/제약 추가 + `schemaVersion` 증가 + `onUpgrade`)이 필요해질 수 있음 | Low~Medium(제약 채택 여부에 따라 다름) | **Unknown** — A-13이 DB Constraint를 택하는지에 전적으로 의존(`A13_CONCURRENCY_VALIDATION.md` PART4, 미확정) |
| `lib/db/app_database.g.dart` | 위 변경이 일어나면 Drift 코드 재생성 필요 | 위와 동일 | **Unknown**(위와 연동) |
| `lib/features/session/providers.dart` | `closeSession()`이 새 의존성(예: 별도 `SettlementEngine`/`ReceiptService` 클래스)을 받게 되면 Provider 와이어링 추가 필요 — 단, A-12.6/A-12.7 모두 새 클래스 분리를 "결정하지 않음"으로 남겼으므로 현재로서는 **확정된 변경 사항이 없음** | Low(필요해진다면) | **Unknown** — Workflow/Engine 분리 여부(PART3)에 의존 |
| `test/features/session/session_repository_test.dart` | `closeSession()`을 호출하는 기존 테스트 14건이 동작 변화의 영향을 받을 수 있음(PART5에서 상세) | Medium | **Yes**(최소 1건 이상 수정 또는 검증 필요 — PART5) |
| `lib/features/staff_earning/logic/staff_earning_engine.dart` | A-13이 `closeSession()` 흐름을 바꿔도, 이 Engine 자체는 순수 계산 클래스라 **호출 시점/방식이 바뀌어도 내부 로직은 무관** | **Low**(호출부만 바뀔 뿐, 이 파일 자체 수정 필요성은 낮음) | **No**(현재 설계 문서 기준으로 이 파일을 고칠 이유가 식별되지 않음) |
| `lib/features/pricing/**`, `lib/features/promotion/**` | A-13의 논의 범위(Settlement/Ledger/Transaction)와 무관 — `closeSession()`이 이 두 Engine을 호출하지 않음(코드 확인: `closeSession()` 본문에 `_pricingEngine`/`_promotionEngine` 참조 없음) | **None** | **No** |
| `lib/features/session/data/session_tables.dart` | `payment_sessions`/`payment_session_items` 테이블 자체의 컬럼 변경은 현재 어떤 A-13 선행 문서에서도 요구되지 않음(논의된 건 "쓰는 순서"와 "쓰는 방식"이지 "스키마 형태") | None~Low | **No**(단, DB Constraint 후보가 구체화되면 재검토 필요 — 위 `app_database.dart` 행과 연동) |
| (화면/Widget 코드 — `lib/features/session/screens/` 등) | **조사 결과 이런 디렉터리/파일 자체가 존재하지 않는다** — Session Engine을 사용하는 화면이 아직 없다 | 해당 없음 | **No**(영향받을 화면이 없음) |

---

## PART 2 — `closeSession()` 책임 분해(코드 기준, A-12.6의 9단계를 기능 단위로 재그룹)

| 단계 | 담당 책임 | 외부 호출 | 독립 함수 분리 가능 여부 |
|---|---|---|---|
| **Validation**(251~258행) | `paymentMethods` 입력값 검증(허용 결제수단, 금액 양수) | 없음(순수 로직) | **Yes** — 이미 입력만으로 동작하는 순수 함수라 그대로 추출 가능. |
| **상태 확인**(260~263행) | `_requireSession()` 호출 + `status == open` 가드 | `_requireSession()`(같은 클래스의 private 메서드, `_db.select` 1회) | **일부 수정 필요** — `_requireSession()` 자체는 이미 분리돼 있으나, "가드 통과 여부 판단"은 `closeSession()` 본문에 인라인돼 있어 별도 함수로 빼려면 예외 던지는 방식(현재 `BusinessRuleException` throw)을 그대로 유지할지 반환값으로 바꿀지 결정 필요. |
| **Settlement 검증**(265~268행) | `paidTotal == finalAmount` 비교 | 없음(메모리 내 계산) | **Yes** — 순수 함수로 그대로 추출 가능(입력: `paymentMethods`, `finalAmount` → 출력: `bool` 또는 예외). |
| **Payment 처리**(270~283행) | `payment_method_breakdowns` insert(`_db.batch()`) | `_db.batch()`, `_db.paymentMethodBreakdowns` | **구조 변경 필요** — 현재 `_db`(Drift 인스턴스)에 직접 묶여 있어, 독립 함수로 빼려면 `_db`를 매개변수로 받거나 별도 클래스가 `_db`를 들고 있어야 함(즉 단순 함수 추출이 아니라 클래스 경계 재설계가 필요). |
| **Staff Ledger**(285~313행) | `payment_session_items` 조회 → `EarnableItem` 변환 → `StaffEarningEngine.calcEarnings()` 호출 → `staff_earning_ledgers` insert(조건부) | `_db.select()`, `_staffEarningEngine.calcEarnings()`(순수 계산), `_db.batch()` | **일부 수정 필요** — 계산 부분(`calcEarnings()`)은 이미 완전히 분리된 순수 함수다. 조회/insert(DB 접근) 부분만 Payment 처리와 같은 이유로 "Repository 경계 안에 있어야 하는" 책임이라 완전한 독립 함수 추출은 제한적. |
| **Session 상태 변경**(315~320행) | `payment_sessions.status='closed'` 갱신 | `_db.update()` | **구조 변경 필요** — A-12.7에서 식별된 "상태 확인과 상태 변경 사이의 TOCTOU" 문제의 당사자라, 이 단계를 단순히 "추출"하는 것을 넘어 "상태 확인과 합치는" 재설계가 논의 중(미확정, `A13_CONCURRENCY_VALIDATION.md` PART4). |
| **재조회**(322~324행) | 갱신된 `PaymentSessionRow` 반환 | `_db.select()` | **Yes** — 단순 조회, 다른 단계에 영향 없이 분리 가능. |

---

## PART 3 — Engine/Workflow 이동 가능성(새 설계 없음, 분류만)

| 항목 | 분류 | 근거(한 줄) |
|---|---|---|
| `paymentMethods` 입력 검증 | **아직 판단 불가** | 순수 로직이라 어디에 둬도 동작하지만, Workflow 계층의 형태(`A12_IMPLEMENTATION_READY.md` PART2에서 "A-13 이후 결정"으로 명시)가 정해지지 않아 "이동 가능"이라고 말할 대상(Workflow)이 아직 구체적으로 존재하지 않음. |
| `_requireSession()`/상태 가드 | **Repository에 남아야 하는 책임** | `payment_sessions` 테이블 조회는 Drift `_db`를 직접 다루는 행위이며, ADR-001(Repository만 Drift를 안다)의 원칙상 Repository 경계를 벗어나면 안 됨. |
| Settlement 검증(`paidTotal == finalAmount`) | **아직 판단 불가** | 순수 계산이라 어디든 옮길 수 있지만(Pricing/Promotion Engine과 같은 성격), `A13_TRANSACTION_BOUNDARY_REVIEW.md` PART4에서 "별도 클래스로 분리할지는 Workflow 도입 여부와 함께 결정"으로 이미 미결로 남겨둔 사안 — 본 PART에서 새로 결론 내지 않음. |
| Payment/Ledger DB insert | **Repository에 남아야 하는 책임** | `_db.batch()`/`_db.into()` 같은 Drift 호출 자체가 Repository의 정의(ADR-001) — Workflow가 생기더라도 이 insert 호출은 여전히 Repository 메서드 안에서 일어나야 함(Workflow는 "언제 부를지"만 결정, "어떻게 쓸지"는 Repository 책임이라는 게 지금까지의 일관된 원칙, `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md` §4~§6과 동일한 논리). |
| `StaffEarningEngine.calcEarnings()` 호출 자체(계산) | **Workflow로 이동 가능한 책임** | 이미 Repository를 모르는 순수 계산 클래스(A-12, ADR-001)이므로, "언제 호출할지" 결정 자체는 Workflow가 가져도 Engine 코드는 무관(PART1에서 확인 — 호출 시점이 바뀌어도 Engine 파일은 안 바뀜). 단, 그 계산 결과를 **DB에 쓰는 것**은 여전히 Repository 책임(위 행과 같음). |
| Session 상태 변경(`status='closed'`) | **아직 판단 불가** | A-12.7에서 이 단계가 "확인"과 묶여야 할 가능성이 제기됐는데, 그 결합 방식(조건부 UPDATE 등)이 Repository 내부 구현 디테일일지, Workflow가 "재시도/거부"를 판단하는 자리일지 아직 정해지지 않음. |

---

## PART 4 — Transaction 적용 범위 확인(가능 여부만, 구현 안 함)

### 같은 Database 인스턴스를 쓰는가?

**예.** `AppDatabase`는 싱글톤(`lib/db/app_database.dart`의 `static AppDatabase? _instance`, `factory AppDatabase()`)이고, `SessionRepository`는 생성자에서 받은 `_db: AppDatabase` 하나만 사용한다(`PricingRuleRepository`/`PromotionRuleRepository`도 모두 같은 `_db`를 받아 생성됨 — `SessionRepository` 생성자 56~68행에서 `pricingRuleRepository ?? PricingRuleRepository(_db)` 형태로 동일 `_db`를 전달). **`closeSession()` 안에서 일어나는 모든 DB 호출(결제수단 insert, 품목 조회, Ledger insert, 상태 변경, 재조회)이 전부 같은 `_db` 인스턴스를 통한다 — 트랜잭션으로 묶는 데 기술적 장애물이 없다.**

### `await` 때문에 분리되는 부분이 있는가?

**현재 코드 구조상으로는 없다** — `closeSession()` 본문의 모든 `await`(269, 285, 296행 부근의 batch/select 호출들)는 전부 같은 함수 안에서 같은 `_db`를 대상으로 순차 실행된다. `_db.transaction(() async { ... })`로 전체를 감싸면, 그 안의 `await`들은 트랜잭션 콜백 내부의 순차 실행이 되어 Drift가 정상적으로 지원하는 패턴이다(아래 선례 참조).

### Repository 호출 구조상 제약이 있는가?

**없음 — 오히려 정확한 선례가 이미 존재한다.** `lib/features/payment_pos/data/payment_repository.dart:262`의 `cancelOrder()`는 `_db.transaction(() async { ... })` 안에서 (1) `_db.select()`로 조회, (2) 상태 분기 후 `BusinessRuleException` throw, (3) **다른 Repository(`_customerRepository`, `_prepaidPassRepository`) 호출**까지 전부 수행한다. 이는 `closeSession()`이 같은 패턴(조회→분기→복수 insert→상태 갱신)을 트랜잭션으로 감싸는 것이 이 코드베이스에서 **이미 검증된, 새롭지 않은 방식**임을 보여준다.

### 결론(가능 여부만)

**`closeSession()`의 251~324행 전체(또는 적어도 A-12.6이 식별한 위험 구간인 결제수단 insert~상태 변경)를 `_db.transaction()`으로 감싸는 것은 기술적으로 가능하다.** 같은 DB 인스턴스, 같은 함수 스코프, 이미 검증된 선례까지 갖춰져 있다. **다만 "감싸는 것이 가능하다"는 것과 "그것만으로 A-12.7의 동시성 문제가 해결되는가"는 별개 질문이며(`A13_CONCURRENCY_VALIDATION.md` PART2/PART4에서 이미 "Transaction만으로는 동시 실행을 막지 못한다"로 분석됨), 본 PART는 그 분석을 재론하지 않고 "적용 가능 범위"만 확인한다.**

---

## PART 5 — 테스트 영향 분석

| 테스트 파일 | 영향도 | 수정 예상 이유 |
|---|---|---|
| `test/features/session/session_repository_test.dart` | **High** | `closeSession()`을 호출하는 테스트 14건이 전부 이 파일에 있다(`createSession`/`addItem`/`closeSession`/`cancelSession`/`getSessionSummary`/`Staff Earning Ledger` 그룹에 걸쳐 분포). A-13이 `closeSession()`의 내부 동작(트랜잭션 경계, 상태 확인 방식)을 바꾸면 **이 파일의 기존 단언(assertion)들이 여전히 성립하는지 전부 재검증이 필요**하다 — 특히 "이미 closed인 세션 재마감 시도 → BusinessRuleException"(현재 205행 부근) 같은 테스트는 A-13이 "조건부 UPDATE" 방식으로 바뀌면 예외 발생 메커니즘 자체가 달라질 수 있어 면밀히 봐야 한다. |
| `test/features/staff_earning/staff_earning_engine_test.dart` | **None** | 이 테스트는 `StaffEarningEngine.calcEarnings()`만 직접 호출하며 `SessionRepository`/`closeSession()`을 전혀 참조하지 않는다(조사 결과 확인) — Engine 자체 로직이 안 바뀌면 영향 없음. |
| `test/features/pricing/pricing_engine_test.dart`, `test/features/pricing/pricing_rule_repository_test.dart` | **None** | `closeSession()`과 무관(`PricingEngine`은 `closeSession()` 본문에서 호출되지 않음, PART1에서 코드로 확인). |
| `test/features/promotion/promotion_engine_test.dart`, `test/features/promotion/promotion_rule_repository_test.dart` | **None** | 위와 동일한 이유. |

---

## PART 6 — 구현 난이도 평가

| 분류 | 작업 | 예상 변경 파일 수 | 위험 요소 | 선행 조건 |
|---|---|---|---|---|
| **쉬운 작업** | `closeSession()` 251~324행을 `_db.transaction()`으로 감싸기(부분 실패 방지, A-12.6 권장 방향) | 1개(`session_repository.dart`) — 이미 검증된 선례(`payment_repository.dart`)와 동일 패턴이라 구현 자체는 단순 | 낮음 — 기존 14개 테스트 대부분은 "전부 성공" 경로만 검증하므로 트랜잭션으로 감싸도 결과는 동일할 가능성이 높음(단, PART5에서 짚은 재마감 테스트는 확인 필요) | 없음(A-12.5/A-12.6에서 이미 방향 제시됨) |
| **보통 작업** | 상태 확인과 상태 변경을 하나의 원자적 연산으로 합치기(조건부 UPDATE 등, A-12.7에서 제기된 방향) | 1개(`session_repository.dart`) — 단, 워크플로 순서 자체를 바꿔야 함(현재 "확인 먼저, 쓰기는 맨 마지막" → "확인+쓰기를 합쳐서 먼저") | 중간 — 순서를 바꾸면 "확인 실패 시 어떤 예외를 던질지"(현재 `BusinessRuleException`)를 조건부 UPDATE의 "영향받은 행 수=0" 결과로부터 똑같이 재현해야 하고, 이 변경이 PART5의 거의 모든 테스트(특히 가드 동작을 검증하는 것들)에 영향을 줄 수 있음 | A-12.7 PART4가 "결론 미도출"로 남긴 사안의 확정이 먼저 필요 |
| **어려운 작업** | DB Constraint(UNIQUE 등) 추가 + Ledger/Settlement 테이블 설계 변경 | 2개 이상(`app_database.dart`, `.g.dart`, 관련 테이블 정의 파일) — 마이그레이션 포함 | 높음 — A-12.6에서 이미 "분할결제(Settlement)는 같은 `method`가 정상적으로 여러 행일 수 있어 단순 UNIQUE가 부적합할 가능성"이 식별됨, 제약 설계 자체가 별도 검토 과제 | A-13에서 "DB Constraint가 정말 필요한가"부터 재확정해야 함(A-12.7 PART4가 "이 문서의 분석상 필요"라고 했으나 구체적 키 설계는 미정) |

---

## PART 7 — 구현 준비 최종 확인

### 현재 설계 문서만으로 구현 가능한가?

**부분적으로 가능하다.** "쉬운 작업"(PART6 — 트랜잭션으로 감싸기)은 A-12.5/A-12.6의 권장 방향과 PART4의 기술적 가능성 확인만으로 바로 착수 가능하다. 그러나 "보통/어려운 작업"(상태-확인 통합, DB Constraint)은 A-12.7이 **명시적으로 결론을 내지 않은 채** 마무리됐으므로, 그 부분은 추가 결정 없이는 구현할 수 없다.

### 아직 결정이 필요한 사항이 남아 있는가?

**예, 다음 3가지가 미결이다(모두 A-12.5/A-12.6/A-12.7에서 의도적으로 미룬 것들, 본 문서가 새로 발견한 것은 아님):**

1. State Machine 후보(①현행/②`CLOSING` 추가/③별도 마커, `A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md` PART3) 중 어느 것을 택할지.
2. 동시성 방지를 위한 구체적 메커니즘(조건부 UPDATE의 정확한 SQL, 또는 DB Constraint의 키 설계, `A13_CONCURRENCY_VALIDATION.md` PART4).
3. Workflow 계층의 구체적 형태(UseCase/Application Service/Command Handler 중 무엇인지, `A12_IMPLEMENTATION_READY.md` PART2) — 본 PART3에서도 "아직 판단 불가"로 재확인됨.

### A-13 착수를 막는 요소가 있는가?

**전면적으로 막는 요소는 없다.** PART6의 "쉬운 작업"부터 점진적으로 착수 가능하며, 이는 그 자체로 의미 있는 개선(A-12.6의 부분 실패 문제 해소)이다. 다만 위 3가지 미결 사항이 해소되지 않은 채로 "보통/어려운 작업"까지 한 번에 구현하려 하면, 구현 중간에 다시 설계 논의로 돌아가야 할 위험이 있다.

### 구현 전에 반드시 수정해야 하는 문서가 있는가?

**없다.** 기존 ADR(001~006)과 A-12.5/A-12.6/A-12.7 설계 문서는 모두 "확정된 부분"과 "미확정으로 남긴 부분"을 명확히 구분해 기록했고, 본 PART1~6의 조사 결과도 그 구분과 충돌하지 않는다 — 새로 발견된 불일치나 누락이 없으므로 기존 문서를 고칠 필요가 없다(지시대로 ADR 수정도 하지 않았다).

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | A-13 변경 대상 파일 식별 | ✅ PART 1 — 9개 파일/디렉터리, Yes/No/Unknown 명시 |
| 2 | `closeSession()` 책임 분해 | ✅ PART 2 — 7단계, 분리 가능 여부 3단계 평가 |
| 3 | Workflow 이동 가능 책임 분류 | ✅ PART 3 — 6항목, 3분류(새 설계 없음) |
| 4 | Transaction 적용 가능 범위 확인 | ✅ PART 4 — 가능(선례 확인), 동시성 해결 여부는 별개임을 재확인 |
| 5 | 테스트 영향 분석 | ✅ PART 5 — 5개 파일, High 1건/None 4건 |
| 6 | 구현 난이도 평가 | ✅ PART 6 — 쉬움/보통/어려움 3단계 |
| 7 | A-13 착수 가능 여부 | ✅ PART 7 — **부분 착수 가능**(쉬운 작업부터), 전면 차단 요소 없음 |
| 8 | 코드/DB/테스트/ADR 변경 없음 확인 | 아래 git status로 확인 |
