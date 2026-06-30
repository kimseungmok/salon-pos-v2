# A-13.5: Workflow Extraction Readiness

> **목적**: `SessionRepository`가 수행 중인 Workflow Coordination 책임을 향후 별도 Workflow 계층으로 분리할 수 있는지 실제 코드 기준으로 검증한다. 새 설계/계층/코드 없음.
> **대상 코드**: `lib/features/session/data/session_repository.dart`(A-13 Transaction 적용 후 최종 상태, 1~466행)
> **근거 문서**: `docs/A12_IMPLEMENTATION_READY.md` PART2(`SessionRepository`의 임시 Workflow 책임 정의), ADR-001(Repository만 Drift를 안다), ADR-007(A-13 Transaction Scope)
> 작성일: 2026-06-26

---

## PART 1 — Workflow 책임 식별

| 코드 영역 | Repository 책임 | Workflow 책임 | 분리 가능 여부 |
|---|---|---|---|
| `createSession()`(96~128행) | `payment_sessions` insert, 조회 | `businessType` 검증 → `_nextSessionNo()` 계산 → insert → 재조회의 **순서 조율** | **No** — 검증/번호생성/insert가 전부 같은 트랜잭션 없는 단순 흐름이고, 분리해도 얻는 이득이 없다(이미 한 단계짜리 절차). |
| `addItem()`(161~212행) | `payment_session_items` insert, `_recomputeTotals()` 호출 | 세션 상태 가드(`open`인지 확인) → insert → 합계 재계산의 **순서 조율** | **Partial** — "가드 확인 후 insert"라는 순서 자체는 Workflow적 성격이 있으나, 가드(`_requireSession()`)와 insert가 모두 Drift 직접 호출이라 Repository 경계를 벗어날 수 없다(ADR-001). 순서 조율만 떼어내려 해도 그 사이에 낄 "계산"이 없어(단순 위임) 분리 실익이 낮다. |
| `_recomputeTotals()`(221~234행) | `payment_session_items` 합계 조회 + `payment_sessions` 갱신 | 없음 — 순수 집계 후 단일 쓰기 | **No** — 이미 private 헬퍼로 충분히 작고, Workflow라 부를 만한 "여러 외부 컴포넌트 조율"이 없다. |
| `closeSession()` — 검증 구간(251~268행) | 없음(DB 미접근, 260행의 `_requireSession()` 호출 제외) | 입력 검증 → 세션 조회/가드 → Settlement 계산의 **순서 조율** | **Yes** — 251~258행(입력검증)과 265~268행(Settlement 계산)은 순수 로직이라 그대로 추출 가능. 260~263행(세션 조회+가드)은 `_requireSession()` 자체가 Drift 호출이라 Repository에 남아야 하지만, "그 결과로 무엇을 할지 분기하는" 조율 책임은 별도 위치로 옮길 수 있다. |
| `closeSession()` — Transaction 구간(270~326행) | `payment_method_breakdowns` insert, `payment_session_items` 조회, `staff_earning_ledgers` insert, `payment_sessions` 상태 갱신 | **`StaffEarningEngine.calcEarnings()`를 "언제 호출할지"의 순서 조율**(296행) — Settlement insert 다음, 상태 변경 이전이라는 위치 결정 | **Partial** — Engine 호출(계산) 자체는 이미 Repository를 모르는 순수 함수(ADR-001)라 "무엇을 계산하는지"는 Workflow와 무관하다. 그러나 "그 계산 결과를 즉시 같은 트랜잭션 안에서 insert해야 한다"는 제약(ADR-007) 때문에, 호출 순서 결정과 DB 쓰기가 한 트랜잭션 콜백 안에 강하게 결합돼 있다 — 이 결합을 풀지 않고는 "순서 조율만" 깨끗이 분리할 수 없다. |
| `closeSession()` — 재조회(328~330행) | `payment_sessions` 조회 | 없음 | **No** — 단순 반환값 준비, 조율이라 부를 게 없다. |
| `cancelSession()`(343~363행) | `payment_sessions` 조회/갱신 | 상태 가드(이미 cancelled면 멱등 반환, closed면 예외) → 갱신의 **순서 조율** | **Partial** — `addItem()`과 동일한 이유로, 가드 판단 로직 자체(분기)는 추출 가능해 보이나 그 가드가 참조하는 데이터(`session.status`)가 Drift 조회 결과라 완전히 떼어내기 어렵다. |
| `getSessionSummary()`(366~389행) | 4개 테이블 조회 + 조합 | 없음(병렬적 조회 후 단순 묶기, 의사결정 없음) | **No** — "조율"이라 부를 분기/순서 결정이 없다. |
| `calcSuggestedTimeFee()`/`calcSuggestedDiscount()`(402~461행) | `PricingRuleRepository`/`PromotionRuleRepository` 조회 | Rule 조회 → Engine 계산의 **순서 조율**(이미 Engine은 Repository와 분리돼 있음) | **Yes** — 이 두 메서드 자체가 "Repository 조회 → Engine 계산 → 결과 반환"이라는 작은 Workflow다. 이미 `addItem()`/`closeSession()` 본체와 분리된 별도 메서드이므로, 그 호출 순서를 그대로 다른 위치(예: 화면 레이어)로 옮겨도 `SessionRepository` 자체의 다른 메서드에 영향이 없다 — 실제로 현재도 "호출자가 선택적으로 사용"하는 구조(391~396행, 439~445행 주석)라 이미 부분적으로 분리되어 있다. |

---

## PART 2 — Engine 호출 흐름 분석(`closeSession()` 내부, 현재 코드 기준)

| 단계 | 호출 대상 | 입력 | 출력 | 다음 단계 의존 여부 |
|---|---|---|---|---|
| 1 | (Engine 호출 없음) — 입력 검증(251~258행) | `paymentMethods` | 예외 또는 통과 | 다음 단계가 이 통과를 전제로 함(의존) |
| 2 | (Engine 호출 없음) — `_requireSession()`(260행) | `sessionId` | `PaymentSessionRow` | 이후 모든 단계가 `session.finalAmount`/`session.status`를 사용(의존) |
| 3 | (Engine 호출 없음) — Settlement 계산(265~268행, 인라인) | `paymentMethods`, `session.finalAmount` | `bool`(통과/예외) | 통과해야 트랜잭션 진입(의존) |
| 4 | (Engine 호출 없음) — `payment_method_breakdowns` insert(276~288행) | `paymentMethods` | (부수효과만, 반환값 없음) | 독립적(다음 단계는 이 insert 결과를 입력으로 쓰지 않음 — 단, 같은 트랜잭션 안이라는 점에서만 결합) |
| 5 | (Engine 호출 없음) — `payment_session_items` 조회(290~292행) | `sessionId` | `List<PaymentSessionItemRow>` | 6단계의 입력(직접 의존) |
| 6 | **`StaffEarningEngine.calcEarnings()`**(301행) | `List<EarnableItem>`(5단계 결과를 변환) | `List<StaffEarningResult>` | 7단계의 입력 여부 결정(의존 — `earnings.isNotEmpty`로 7단계 실행 여부가 갈림) |
| 7 | (Engine 호출 없음) — `staff_earning_ledgers` insert(303~317행, 조건부) | 6단계 출력 | (부수효과만) | 8단계와 독립적(같은 트랜잭션 안이라는 점에서만 결합) |
| 8 | (Engine 호출 없음) — `payment_sessions` 상태 갱신(320~325행) | `sessionId`, `now` | (부수효과만) | 없음(이 단계가 워크플로의 마지막 쓰기) |
| 9 | (Engine 호출 없음) — 재조회(328~330행) | `sessionId` | `PaymentSessionRow`(반환값) | 8단계 완료(커밋)에 의존 |

**Engine 호출은 정확히 1곳(6단계, `StaffEarningEngine.calcEarnings()`)뿐이다.** `PricingEngine`/`PromotionEngine`은 `closeSession()` 본문에 전혀 등장하지 않는다(코드 확인 — `_pricingEngine`/`_promotionEngine` 참조 없음, A-12.9/A-12.11에서 이미 확인된 사실의 재확인).

---

## PART 3 — Workflow 경계 확인

| 데이터 | 현재 생성 위치 | Workflow 전달 가능 여부 | 이유 |
|---|---|---|---|
| `paymentMethods`(입력) | 호출자(`closeSession()` 매개변수) | **가능** | 이미 외부에서 주어지는 입력값 — Repository 내부에서 생성되지 않는다. |
| `session`(`PaymentSessionRow`) | `_requireSession()`(Drift 조회, 260행) | **가능(조회 결과로서)** | 데이터 자체(필드 값)는 평범한 값 객체라 Workflow에 전달해도 문제없다. 단, 이 데이터를 **얻는 행위**(Drift 쿼리 실행)는 Repository 안에 남아야 한다(ADR-001) — "이미 조회된 결과"를 넘기는 것과 "조회 자체를 Workflow가 수행"하는 것은 다른 이야기다. |
| `paidTotal`(계산값) | `closeSession()` 본문 내 `fold()`(265행) | **가능** | 순수 계산 결과(정수) — Workflow가 직접 계산해도 되고, Repository가 계산해서 넘겨도 된다(현재는 후자). |
| `sessionItems`(`List<PaymentSessionItemRow>`) | `_db.select()`(290~292행) | **가능(조회 결과로서)** | `session`과 동일한 이유 — 값은 전달 가능하나 조회 행위는 Repository 책임. |
| `earnableItems`(`List<EarnableItem>`) | `closeSession()` 본문 내 변환(293~300행) | **가능** | 이미 Drift 비의존 POJO(ADR-001)로 변환된 뒤라, Workflow에 그대로 넘겨도 Drift 의존이 새지 않는다. |
| `earnings`(`List<StaffEarningResult>`) | `StaffEarningEngine.calcEarnings()`(301행) | **가능** | Engine의 출력 자체가 이미 Drift 비의존 POJO — Workflow가 이 값을 받아 "다음에 뭘 할지" 결정해도 무방. |
| `now`(`DateTime.now()`, 270행) | `closeSession()` 본문 | **가능** | 단순 시각 값 — 어디서 생성되든 동일. 단, **현재 코드는 이 값 하나를 결제수단 insert/Ledger insert/상태 갱신 3곳에서 동일하게 재사용한다**(270, 284, 313, 323, 324행) — Workflow로 분리해도 "같은 `now`를 여러 쓰기에 일관되게 써야 한다"는 제약은 그대로 유지해야 한다. |
| `_db`(Drift 인스턴스) | `SessionRepository` 생성자 | **불가능** | Drift 인스턴스 자체는 Repository만 알아야 한다(ADR-001 — "Repository만 Drift를 안다"는 원칙이 Pricing/Promotion Engine 설계 전체에서 일관되게 적용됨, `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md` §6). Workflow가 `_db`를 직접 들고 있게 되면 이 원칙이 깨진다. |
| Transaction 콜백 자체(`_db.transaction(() async {...})`) | `closeSession()` 본문(275~326행) | **불가능(그대로는)** | ADR-007이 확정한 범위(Settlement~상태변경)가 트랜잭션 경계와 정확히 일치하므로, 이 경계를 깨지 않으려면 Insert/갱신 호출들이 한 트랜잭션 콜백 안에 같이 있어야 한다 — Workflow가 "순서만 정하고" Repository가 "각자 따로" 실행하면 트랜잭션이 깨진다. **이게 PART1에서 "Partial"로 표시한 항목들의 공통 원인이다.** |

---

## PART 4 — Repository 책임 검증(Workflow 분리 후에도 남아야 하는 것)

추가/삭제 없이, 현재 코드에서 **Drift를 직접 호출하는 모든 지점**을 그대로 나열한다 — 이는 ADR-001 원칙상 Workflow가 아무리 분리되어도 변하지 않는다.

- `payment_sessions`/`payment_session_items`/`staff_earning_ledgers`/`payment_method_breakdowns` 4개 테이블에 대한 모든 `select`/`insert`/`update`/`batch` 호출(`createSession`/`addItem`/`_recomputeTotals`/`closeSession`/`cancelSession`/`getSessionSummary` 전체).
- `_db.transaction(() async {...})` 콜백의 시작/종료 그 자체(ADR-007의 범위를 Repository가 보장).
- `PricingRuleRepository`/`PromotionRuleRepository` 인스턴스 보유 및 그 둘을 통한 조회 호출(`calcSuggestedTimeFee`/`calcSuggestedDiscount` 내부) — 이 두 Repository도 각자 Drift를 아는 계층이므로, `SessionRepository`가 이들을 직접 들고 호출하는 현재 구조는 "Repository가 다른 Repository를 합성하는" 패턴으로 유지돼야 한다(Workflow가 끼어들 필요가 없는 부분).
- `_requireSession()`/`_nextSessionNo()`/`_recomputeTotals()` 3개의 private 헬퍼(Drift 조회/계산이 섞여 있어 그대로 Repository 안에 남는다).

---

## PART 5 — 분리 영향도 분석(가정: Workflow를 별도 계층으로 이동)

| 파일 | 영향 여부 | 변경 예상 범위 |
|---|---|---|
| `lib/features/session/data/session_repository.dart` | **영향 있음** | PART1에서 "Yes"/"Partial"로 표시된 영역(`closeSession()`의 검증 구간 순서 조율, `calcSuggestedTimeFee`/`calcSuggestedDiscount`)이 잠재적 이동 대상 — 그러나 PART3에서 확인했듯 Transaction 콜백(270~326행) 자체는 Repository에 남아야 하므로, `closeSession()`의 핵심부는 **이동이 아니라 그대로 유지**된다. |
| `lib/features/session/providers.dart` | **영향 있음** | Workflow가 별도 클래스가 되면 그 클래스를 위한 Provider가 추가될 가능성이 있으나, 현재 코드 기준으로는 추측이며 PART1~4에서 "어떤 클래스가 될지" 자체가 정해지지 않았다. |
| `lib/features/staff_earning/logic/staff_earning_engine.dart` | **영향 없음** | 이미 Repository/Workflow 어느 쪽도 모르는 순수 계산 클래스(ADR-001) — 호출 위치가 바뀌어도 이 파일은 무관(A-12.9에서 이미 확인된 사실의 재확인). |
| `lib/features/pricing/**`, `lib/features/promotion/**` | **영향 없음** | `closeSession()`이 이 두 Engine을 호출하지 않음(PART2에서 코드로 재확인) — Workflow 분리 논의와 무관. |
| `test/features/session/session_repository_test.dart` | **영향 있음(가능성)** | `closeSession()`의 외부 시그니처(매개변수/반환값)가 바뀌지 않는 한 테스트 자체는 영향받지 않을 수 있으나, 만약 Workflow가 `closeSession()`을 대체/감싸는 새 진입점이 된다면 테스트가 그 새 진입점을 호출하도록 바뀔 가능성이 있다 — 현재 코드만으로는 "그렇게 될 것이다"라고 확정할 수 없어 가능성으로만 기록한다. |

**그 외 파일은 현재 코드 기준으로 영향을 받을 근거가 없다.**

---

## PART 6 — A-14 준비 상태 확인

| 확인 항목 | 결과 |
|---|---|
| Workflow 분리를 막는 요소가 있는가 | **있다 — Transaction 경계(ADR-007)와 Workflow 분리가 구조적으로 긴장 관계에 있다.** PART3에서 확인한 그대로, "Settlement~상태변경을 한 트랜잭션으로"라는 ADR-007의 확정 사항은 그 세 단계가 물리적으로 한 코드 블록(같은 트랜잭션 콜백) 안에 있어야 함을 요구한다. Workflow가 "순서만 정하고 각 단계를 Repository에 따로 위임"하는 형태가 되면, 트랜잭션이 여러 개의 독립 트랜잭션으로 쪼개져 A-13에서 막은 부분 실패 문제가 재발할 위험이 있다. 이는 "Workflow 분리가 불가능하다"는 뜻이 아니라, **"Repository가 트랜잭션 콜백 전체를 받는 단일 메서드(현재의 `closeSession()`)를 계속 제공해야 하고, Workflow는 그 메서드를 통째로 호출하는 형태여야 한다"**는 제약이 생긴다는 뜻이다 — 이 제약 자체가 향후 Workflow 설계 시 반드시 고려해야 할 요소다. |
| Engine 책임 충돌이 있는가 | **없다.** PART2에서 확인한 대로 Engine 호출은 1곳(`StaffEarningEngine.calcEarnings()`)뿐이고, 이미 완전히 순수 계산으로 분리돼 있어(ADR-001) Workflow 분리와 충돌하지 않는다. |
| Repository 책임 충돌이 있는가 | **없다.** PART4에서 정리한 책임(Drift 직접 호출 전부)은 Workflow 분리 여부와 무관하게 항상 Repository에 남으므로, 책임 경계 자체에 충돌이 없다. |
| 추가 설계가 필요한가 | **그렇다.** 위 "Workflow 분리를 막는 요소"에서 식별된 제약(트랜잭션 콜백의 원자성을 유지하면서 Workflow가 "조율"만 하려면 어떤 인터페이스가 필요한지)은 본 문서가 답하지 않는다 — 이는 새로운 설계이므로 A-14 자체의 설계 단계에서 다룰 사안이다. |

### 결론

**A-14 Workflow Extraction 착수는 가능하나, 조건이 있다.** Engine/Repository 책임 자체에는 충돌이 없어 분리를 시도할 토대는 마련되어 있다. 다만 ADR-007의 Transaction 경계를 깨지 않는 Workflow 형태가 무엇인지는 **추가 설계가 필요한 미결 사항**으로 남아 있으며, 이를 해결하지 않고 Workflow를 분리하면 A-13에서 막은 문제가 재발할 위험이 있다. 따라서 "A-14 Workflow Extraction 착수 가능"이라고 무조건 명시하지 않고, **"PART6에서 식별된 추가 설계(트랜잭션 경계를 보존하는 Workflow 인터페이스)가 선행되어야 착수 가능"**으로 정확히 기록한다.

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | Workflow 책임 식별 | ✅ PART 1 — 8개 코드 영역, Yes/Partial/No 분류 |
| 2 | Engine 호출 흐름 정리 | ✅ PART 2 — 9단계, Engine 호출 1곳만 확인 |
| 3 | Workflow 경계 확인 | ✅ PART 3 — 9개 데이터 항목, 전달 가능 여부와 이유 |
| 4 | Repository 책임 검증 | ✅ PART 4 — Drift 직접 호출 전부 나열(추가/삭제 없음) |
| 5 | 영향 범위 분석 | ✅ PART 5 — 5개 파일(영향 있음 2건 확정, 1건 가능성) |
| 6 | A-14 착수 가능 여부 확인 | ✅ PART 6 — **조건부 가능**(추가 설계 선행 필요) |
| 7 | 코드/DB/테스트/ADR 변경 없음 확인 | 아래 git status로 확인 |
