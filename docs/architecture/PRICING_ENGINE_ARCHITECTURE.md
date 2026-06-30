# Pricing Engine 아키텍처

> **목적**: A-10 Pricing Engine MVP의 최종 구조를 문서화하여, A-11(Promotion)/A-12(Staff Earning)/A-13(Settlement)가 동일한 설계 원칙을 그대로 따를 수 있게 한다.
> **범위**: `lib/features/pricing/` 전체(`domain/`, `data/`, `logic/`) + `SessionRepository`와의 연동 지점.
> **시점**: A-10 MVP 구현 → A-10 리뷰 → 리팩토링(R1, Drift 의존 제거) 완료 이후.
> 작성일: 2026-06-26

---

## 1. Pricing Engine의 책임

"가격을 계산하는 방법"만 안다. 구체적으로:

- 분당 요금(`time_base`)으로 이용시간에 대한 기본요금 계산(`calcTimeFee`)
- 피크 시간대 할증(`peak`) 계산(`calcPeakSurcharge`)
- 위 둘을 더한 합계 계산(`calcTotal`)
- 임의의 시각이 임의의 시간대 범위 안에 있는지 판정(`isWithinPeakWindow`)

"가격 규칙(`PricingRule`) 리스트를 입력으로 받아 숫자를 출력하는 함수 모음"이라고 보면 정확하다.

## 2. Pricing Engine이 하지 않는 일

- **규칙을 저장하거나 조회하지 않는다** — DB/Drift를 전혀 모른다.
- **어떤 시간대가 "피크"인지 결정하지 않는다** — 매칭된 `PricingRule.peakStartHour`/`peakEndHour`를 그대로 해석만 한다.
- **세션(전표)을 만들거나 고치지 않는다** — `PaymentSession`/`PaymentSessionItem`을 전혀 모른다.
- **할인을 계산하지 않는다**(A-11 Promotion Engine의 책임).
- **직원 수익을 배분하지 않는다**(A-12 Staff Earning Engine의 책임).
- **결제수단/마감을 검증하지 않는다**(A-13 Settlement Engine, 이미 `SessionRepository.closeSession()`에 구현됨).
- **UI를 모른다** — Riverpod/Flutter Widget에 대한 의존이 없다.

## 3. Session Engine과의 관계

`SessionRepository`(A-8)와 Pricing Engine은 **단방향 의존**이다: `SessionRepository → Pricing`, 역방향은 없다. `pricing_engine.dart`/`pricing_rule_repository.dart` 어디에도 `session_repository.dart`에 대한 import가 없다.

연동 지점은 `SessionRepository.calcSuggestedTimeFee()` 하나뿐이며, 다음 특징을 가진다:

- **`addItem()`을 호출하지 않는다** — 호출자가 이 메서드의 반환값을 `addItem(unitPrice: ...)`에 그대로 넘기는 "선택적 헬퍼" 패턴.
- **`addItem()`의 `amount = unitPrice * qty` 계산식은 이 메서드와 무관하게 그대로 유지된다** — 중복 계산이 발생할 수 없는 구조.
- `SessionRepository`의 생성자는 `PricingRuleRepository`/`PricingEngine`을 **선택적(optional) 매개변수**로 받는다 — 기존 `SessionRepository(db)` 호출부가 전부 무수정으로 컴파일된다.

```
SessionRepository.calcSuggestedTimeFee()
        │
        ├─ PricingRuleRepository.getRules(ruleType: time_base) ─┐
        │                                                         ├─ PricingEngine.calcTimeFee()
        ├─ PricingRuleRepository.getRules(ruleType: peak) ───────┤
        │                                                         ├─ PricingEngine.calcPeakSurcharge()
        └─────────────────────────────────────────────────────────┴─ PricingEngine.calcTotal()
```

## 4. PricingRuleRepository의 책임

- `pricing_rule` 테이블에 대한 CRUD(`addRule`/`getRules`/`deactivateRule`).
- **Drift Row ↔ `PricingRule`(POJO) 변환**(`_toDomain()`) — 이 변환을 수행하는 유일한 지점.
- 입력 검증(`businessType`/`ruleType`/`value`/피크 시간대 범위).
- 삭제 대신 `isActive=false` 비활성화(하드 삭제 없음, A-4/A-5와 동일한 관례), 멱등 처리(A-7 원칙).
- `shopId`/`priority` 기반 조회 범위 좁히기(§8 참조).

## 5. `PricingRule`(POJO)를 사용하는 이유

`PricingEngine`이 계산에 필요로 하는 건 "값들의 묶음"(`businessType`/`ruleType`/`value`/`priority`/`isActive`/`peakStartHour`/`peakEndHour`)뿐이다. 이 묶음을 Drift가 생성한 `PricingRuleRow`로 직접 주고받으면, Engine이 사실상 Drift 패키지에 컴파일 의존을 갖게 되어 "순수 계산 계층"이라는 말이 무색해진다. `PricingRule`은 의존성이 전혀 없는 평범한 Dart 클래스로, Engine이 어떤 데이터 소스(Drift, 향후 다른 ORM, 테스트 픽스처)에서 와도 동일하게 동작하게 한다.

## 6. Repository만 Drift를 아는 구조

```
PricingRuleRow(Drift) ──[PricingRuleRepository._toDomain()]──▶ PricingRule(POJO) ──▶ PricingEngine
        ▲                          │
        └──────────[Drift만 아는 경계선]──────────┘
```

`lib/features/pricing/logic/`과 `lib/features/pricing/domain/`에는 `drift` 패키지 import나 `app_database.dart` import가 **0건**이다(`grep -rn "drift\|app_database" lib/features/pricing/logic/ lib/features/pricing/domain/` 로 검증 가능). Drift를 아는 파일은 `lib/features/pricing/data/pricing_rule_repository.dart`(와 테이블 정의 `pricing_rule_tables.dart`) 뿐이다.

## 7. PricingEngine이 순수 계산 계층인 이유

- 모든 메서드가 **입력(매개변수) → 출력(반환값)** 형태이고, 숨은 부수효과(DB 쓰기, 전역 상태 변경)가 없다.
- `const PricingEngine()`으로 생성 가능 — 내부 상태가 전혀 없다.
- 동일 입력은 항상 동일 출력(결정적) — 테스트가 DB 없이 순수 단위테스트로만 구성된다(`pricing_engine_test.dart`).
- "어떤 시간대가 피크인가"(정책) 같은 결정은 Rule 데이터(`PricingRule.peakStartHour/peakEndHour`)에 있고, Engine은 그 값을 "해석"만 한다 — 정책을 내장하지 않는다.

## 8. shopId 기반 Rule 조회 구조

40개 이상 지점이 서로 다른 가격/피크 정책을 가질 수 있다는 전제 위에서:

- `pricing_rule` 테이블은 처음부터 `shopId` 컬럼을 가지고 있었다(기본값 1).
- `PricingRuleRepository.getRules({required businessType, shopId = 1, ruleType, activeOnly = true})`가 `shopId` + `businessType`(+선택적 `ruleType`)로 좁혀서 조회한다.
- `shopId`로 조회 범위가 이미 좁혀진 뒤 Engine에 전달되므로, **`PricingEngine`은 `shopId`라는 개념 자체를 모른다** — 지점 분리는 Repository(데이터 계층)의 책임이고, Engine은 "이미 한 지점으로 좁혀진 규칙 목록"만 받는다(역할 분리 유지).
- `shopId` 매개변수는 기본값 1로 단일 지점 호출부의 동작을 그대로 보존한다(회귀 없음).

## 9. Peak Rule 처리 방식

- 피크 시간대(`peakStartHour`/`peakEndHour`)는 더 이상 `PricingEngine`의 코드 상수가 아니라 **매칭된 `PricingRule` 자신이 들고 있는 값**이다.
- `calcPeakSurcharge()`는 `businessType`+`ruleType='peak'`로 매칭되는 규칙을 찾고, 그 규칙의 `peakStartHour`/`peakEndHour`로 `isWithinPeakWindow(at, ...)`를 호출해 할증 여부를 판정한다.
- `isWithinPeakWindow()`는 자정을 넘는 구간(`startHour > endHour`, 예: 22~06시)과 넘지 않는 구간(예: 12~14시 점심 피크)을 동일한 로직으로 처리한다 — 특정 시간대를 하드코딩하지 않는다.
- 기본값(22~06시)은 DB 컬럼 기본값으로 남아있어, 별도로 규칙을 만들 때 값을 지정하지 않으면 기존 동작(A-10 MVP 초기 하드코딩)과 동일하게 동작한다.

## 10. `total_amount` 계산 흐름

Pricing Engine은 `PaymentSession.totalAmount`를 직접 쓰지 않는다(`_recomputeTotals()`는 여전히 `SessionRepository`의 책임). Pricing Engine이 제공하는 건 "이 항목에 얼마를 청구할지"에 대한 **제안값**뿐이다:

```
1. (선택) SessionRepository.calcSuggestedTimeFee(businessType, minutes, at?, shopId?)
       → PricingRuleRepository.getRules() + PricingEngine.calcTimeFee/calcPeakSurcharge/calcTotal
       → int 반환(시간요금 [+ 피크할증])
2. 호출자가 그 반환값을 SessionRepository.addItem(unitPrice: <반환값>, ...)에 그대로 전달
3. addItem() 내부의 amount = unitPrice * qty 계산(기존 그대로, Pricing Engine과 무관)
4. SessionRepository._recomputeTotals()가 모든 품목의 amount를 합산해 PaymentSession.totalAmount/finalAmount 갱신(기존 그대로)
```

즉 Pricing Engine은 **2단계 이전에서 끝난다** — `totalAmount`/`finalAmount` 갱신 로직에는 관여하지 않는다.

## 10.5. 할인 처리 방식(A-10.5, ADR-002)

할인은 **Pricing Engine의 책임이 아니다.** Pricing Engine은 가격을 "올리는"(시간요금/피크할증) 계산만 담당하고, 가격을 "낮추는" 계산(할인)은 Promotion Engine(A-11)의 책임이다 — 이 경계는 §1/§2에서 이미 정한 그대로다.

다만 할인이 **세션에 어떻게 반영되는가**는 Pricing Engine과 동일한 패턴을 따른다(ADR-002에서 확정):

- 할인은 `payment_session.discountAmount`(세션 헤더의 단일 조정값)가 아니라, **`PaymentSessionItem(itemType='discount')`** — 다른 품목과 동일한 자격의 음수 `amount` 행으로 기록된다.
- 흐름은 Pricing Engine의 `calcSuggestedTimeFee()` → `addItem()` 패턴과 동형이다: Promotion Engine이 할인액을 계산해서 반환하면, 호출자가 그 값을 음수로 만들어 `addItem(itemType: 'discount', unitPrice: -계산값, ...)`로 그대로 적용한다. **Pricing Engine과 Promotion Engine 둘 다 "계산만 하고, 적용은 `addItem()`에 맡긴다"는 동일한 책임 분리를 따른다.**
- `_recomputeTotals()`의 `total = SUM(items.amount)` 합산 로직이 할인 품목의 음수를 자동으로 반영하므로, 할인 전용 합산 로직을 Session Engine에 추가하지 않는다.
- `payment_session.discountAmount` 컬럼은 deprecated로 표시한다(미사용 확정, 근거는 ADR-002 및 `docs/A11_PROMOTION_ENGINE_DESIGN.md` §5 참조).

상세 비교·근거는 `docs/A10_5_DISCOUNT_ARCHITECTURE_REVIEW.md`와 `docs/adr/ADR-002-discount-representation.md`를 참조.

## 11. 현재 A-10 범위

| 포함 | 미포함(범위 밖) |
|---|---|
| `pricing_rule` 테이블(`time_base`/`peak` 2종) | `discount_rate`/`discount_flat` 등 할인 규칙 |
| `PricingRuleRepository`(CRUD + shopId 조회) | Promotion Engine 전체(A-11) |
| `PricingEngine`(순수 계산: 시간요금/피크할증/합계) | Staff Earning Engine 전체(A-12, 기존 `addItem()`의 1줄 자동 ledger 삽입은 A-8부터 있던 별개 코드) |
| `SessionRepository.calcSuggestedTimeFee()`(선택적 연동 헬퍼) | Settlement Engine(A-13, 기존 `closeSession()`은 이미 구현됨, A-10에서 무수정) |
| `PricingRule` POJO, Drift 의존 분리(R1) | `taxAmount` 컬럼에 값을 쓰는 로직(여전히 항상 0). `discountAmount`는 §10.5/ADR-002에서 deprecated(영구 미사용)로 확정 — "범위 밖"이 아니라 "쓰지 않기로 결정됨" |

## 12. A-11 / A-12 / A-13에서 확장될 영역

- **A-11 Promotion Engine**: Rule 저장 구조(`pricing_rule` 확장/`promotion_rule` 신규/별도 Repository)와 세부 데이터 흐름·다이어그램은 `docs/A11_PROMOTION_ENGINE_DESIGN.md`에서 확정한다. 할인을 세션에 반영하는 방식은 §10.5/ADR-002에서 이미 확정됐다(품목 레벨 `itemType='discount'` 이벤트) — A-11은 이 결정을 전제로 설계를 시작한다.
- **A-12 Staff Earning Engine**: 현재 `addItem()`의 `staff_fee` 자동 ledger 삽입은 Pricing Engine과 무관한 별도 로직이다. A-12가 이를 정식 엔진으로 분리할 때도, Pricing Engine의 출력(계산된 금액)을 입력으로 받는 것 외에는 Pricing Engine 내부를 알 필요가 없어야 한다(단방향 의존 유지).
- **A-13 Settlement Engine**: `closeSession()`이 이미 결제수단 합계와 `finalAmount`를 비교한다. Pricing Engine이 제공하는 금액은 어디까지나 `addItem()` 호출 전의 "제안값"이므로, Settlement 단계에서는 Pricing Engine을 다시 호출할 필요가 없다(이미 `PaymentSessionItem.amount`에 반영되어 있음).
- 모든 신규 엔진은 본 문서 §6~§9에서 정립된 원칙(POJO로만 주고받기, Repository만 Drift를 알기, Engine은 정책을 결정하지 않고 Rule을 해석하기)을 동일하게 따라야 한다 — `docs/adr/ADR-001-pricing-engine-domain-isolation.md` 참조.
