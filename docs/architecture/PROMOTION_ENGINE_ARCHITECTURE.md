# Promotion Engine 아키텍처

> **목적**: A-11 Promotion Engine의 구조를 `PRICING_ENGINE_ARCHITECTURE.md`와 같은 형식으로 문서화한다 — 구현 착수 전 최종 참조 문서.
> **전제**: `docs/A11_PROMOTION_ENGINE_DESIGN.md`(책임 경계/Rule 구조 비교), `docs/A11_IMPLEMENTATION_PLAN.md`(Lifecycle/조회 인터페이스/MVP 범위), `ADR-002`/`ADR-003`/`ADR-004`
> 작성일: 2026-06-26

---

## 1. Promotion Engine의 책임

- `flat`(정액)/`rate`(정률) 할인액 계산(`calcDiscount()`)
- 여러 `PromotionRule` 후보 중 `businessType`+`discountType`에 매칭되고, 우선순위가 가장 높고, **현재 시각이 유효 기간 안에 있는** 1개를 선택
- 위 매칭에 필요한 시간 판정(`startAt`/`endAt` 비교)

## 2. Promotion Engine이 하지 않는 일

- Rule을 저장/조회하지 않는다(DB/Drift 미접근, `PromotionRuleRepository`의 책임).
- Rule의 Lifecycle 전이(`activate()`/`deactivateRule()`)를 수행하지 않는다 — 이는 Repository의 책임이며, Engine은 이미 "조회된" Rule만 받는다.
- 세션/품목을 만들거나 고치지 않는다(`SessionRepository`의 책임).
- 가격을 올리는 계산을 하지 않는다(Pricing Engine의 책임, 역방향 의존 없음).
- 직원 수익을 재계산하지 않는다(A-12 책임 — 할인이 `staff_earning_ledger`에 미치는 영향은 A-12가 결정).
- 할인 중첩(여러 Rule 동시 적용) 정책을 결정하지 않는다 — MVP는 "최우선 1개만 적용"으로 단순화(`A11_IMPLEMENTATION_PLAN.md` PART 6).

## 3. Session Engine과의 관계

Pricing Engine과 동일한 단방향 의존(`SessionRepository → Promotion`)과 동일한 연동 패턴(선택적 헬퍼 → `addItem()` 호출자가 직접 적용)을 따른다. `addItem()`의 기존 `open` 세션 가드가 할인 품목 추가에도 그대로 적용되어, Promotion Engine을 위한 새 가드를 추가하지 않는다.

## 4. PromotionRuleRepository의 책임

- `promotion_rule` 테이블 CRUD(`addRule`/`getRules`/`activate`/`deactivateRule`).
- Drift Row ↔ `PromotionRule`(POJO) 변환(ADR-001 패턴 재사용).
- `shopId`/`businessType`/`discountType`/`status='active'` 필터(SQL `WHERE`, 값싈 컬럼 비교만).
- `priority ASC, id ASC` 명시적 정렬(A-10 M1 재발 방지, `A11_IMPLEMENTATION_PLAN.md` PART 3).
- **`startAt`/`endAt` 시간 판정은 하지 않는다** — Engine에 위임(§6 근거 참조).

## 5. `PromotionRule`(POJO)을 사용하는 이유 / Repository만 Drift를 아는 구조

`PricingRule`과 동일한 이유(ADR-001) — `PromotionEngine`이 Drift 생성 타입에 의존하면 "순수 계산 계층"이 무색해진다. `PromotionRuleRepository`만 `drift`/`app_database.dart`를 import하고, `domain/promotion_rule.dart`와 `logic/promotion_engine.dart`는 의존성이 없다.

## 6. PromotionEngine이 순수 계산 계층인 이유 / Peak Rule과 동일한 시간 판정 위치

`calcDiscount()`는 `List<PromotionRule>`과 `now`(또는 `at`)를 입력으로 받아 `int`를 반환하는 순수 함수다. **유효기간(`startAt`/`endAt`) 판정을 Repository가 아니라 Engine에서 하는 이유**는 Pricing Engine의 Peak Rule 처리(`isWithinPeakWindow`)와 정확히 같다 — "여러 후보 Rule 중 지금 이 순간 유효한 것을 고르는" 작업은 시간 입력이 필요한 **계산**이므로, "Repository는 값싼 필터만, Engine은 정책 해석"이라는 기존 경계를 그대로 재사용한다.

## 7. Rule Lifecycle과 Engine의 관계

Engine은 Lifecycle의 저장 상태(`draft`/`active`/`disabled`)를 모른다 — `PromotionRuleRepository.getRules(activeOnly: true)`가 이미 `status='active'`인 것만 넘겨주기 때문이다. Engine이 다루는 유일한 "상태스러운" 판정은 파생 상태인 `Expired`(`now ≥ endAt`)뿐이며, 이것도 "상태"가 아니라 "지금 이 Rule을 써도 되는가"라는 매칭 조건으로 다뤄진다(ADR-004).

## 8. Financial Event 원칙(ADR-003)과의 관계

할인 적용은 Promotion Engine의 계산 결과가 아니라, 호출자가 그 결과를 `addItem(itemType='discount', unitPrice=-금액)`으로 적용하는 시점에 비로소 "사실"이 된다. Promotion Engine 자신은 이벤트를 생성하지 않는다 — 숫자만 계산해서 반환한다. 이벤트 생성·저장은 항상 `SessionRepository.addItem()`을 통해서만 일어난다(`A11_IMPLEMENTATION_PLAN.md` PART 4에서 4개 엔진 전체 검토 완료).

## 9. 데이터 흐름 / 전체 아키텍처 다이어그램

`A11_PROMOTION_ENGINE_DESIGN.md` §5(데이터 흐름)/§6(다이어그램)을 그대로 참조 — 본 문서에서 중복 작성하지 않는다.

## 10. 현재 범위(MVP) / 후속 이관

`A11_IMPLEMENTATION_PLAN.md` PART 6을 정본으로 한다. 요약: `calcDiscount()` 1개 메서드, Rule당 1개만 매칭·적용(중첩 정책 제외), Staff Earning/Settlement 영향 포인트는 A-12/A-13으로 이관.
