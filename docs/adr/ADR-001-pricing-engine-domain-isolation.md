# ADR-001: Pricing Engine Domain Isolation

- **상태**: Accepted
- **시점**: A-10 Pricing Engine MVP 구현 → 리뷰 → 리팩토링(R1) 완료 이후
- **관련 문서**: `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md`, `docs/A10_IMPLEMENTATION_READINESS_REVIEW.md`

## 배경(Context)

A-10 Pricing Engine MVP를 처음 구현했을 때, `PricingEngine`의 계산 메서드(`calcTimeFee`/`calcPeakSurcharge`)는 Drift가 `pricing_rule` 테이블로부터 생성한 `PricingRuleRow`를 매개변수 타입으로 그대로 받았다. DB 쿼리를 직접 호출하지는 않았지만, `PricingRuleRow` 타입 자체가 Drift 패키지의 생성물이기 때문에 `PricingEngine`은 여전히 Drift에 컴파일 의존을 가지고 있었다.

이후 진행한 구조 리뷰(A-10 구현 리뷰)에서 이 의존이 "PricingEngine = 순수 계산 계층"이라는 목표와 충돌한다는 점이 지적됐고, R1 리팩토링으로 분리했다.

## 결정(Decision)

1. **Drift Row를 직접 사용하지 않는다.** `PricingEngine`/`lib/features/pricing/domain/`의 어떤 파일도 `drift` 패키지나 `app_database.dart`를 import하지 않는다.
2. **`PricingRule`이라는 평범한 Dart 클래스(POJO)를 별도로 정의한다**(`lib/features/pricing/domain/pricing_rule.dart`). 이 클래스는 Drift 어노테이션이나 생성 코드와 무관하며, 필드(`id`/`shopId`/`businessType`/`ruleType`/`value`/`priority`/`isActive`/`peakStartHour`/`peakEndHour`)만 들고 있다.
3. **변환 책임은 `PricingRuleRepository`가 가진다.** `_toDomain(PricingRuleRow) → PricingRule` 변환은 레포지토리 내부의 private 메서드 하나로만 존재하고, `addRule()`/`getRules()`의 반환 타입은 항상 `PricingRule`이다.
4. **Engine은 DB를 몰라야 한다.** `PricingEngine`의 모든 public 메서드는 `List<PricingRule>`을 입력으로 받고 `int`/`bool`을 반환한다 — 부수효과(쓰기, 전역 상태 변경)가 없다.
5. **향후 Promotion Engine(A-11)도 동일 원칙을 따른다.** 새 엔진을 추가할 때 "Repository(Drift 인지) → POJO 변환 → Engine(Drift 비인지)"의 3단 구조를 그대로 복제해야 한다.

## 왜 Drift Row를 직접 사용하지 않는가

- Drift Row 타입은 `@DataClassName`이 테이블 스키마로부터 생성한다 — 즉 Engine의 계산 시그니처가 **테이블 컬럼 구조에 종속**된다. 스키마가 바뀌면(컬럼 추가/이름 변경) Engine도 같이 흔들릴 위험이 생긴다.
- "DB 접근 없음"과 "DB 비의존"은 다르다. 전자는 쿼리를 호출하지 않는다는 뜻이고, 후자는 타입 시스템 차원에서 어떤 데이터베이스 기술을 쓰는지조차 모른다는 뜻이다. 순수 계산 계층이라는 표현은 후자를 의미한다.
- Engine을 단위테스트할 때 Drift Row를 만들려면 (간접적으로라도) Drift의 생성 패턴을 따라야 한다. POJO는 생성자 하나로 즉시 만들 수 있어 테스트가 더 단순해진다(실제로 `pricing_engine_test.dart`는 DB 없이 동작).

## 왜 POJO를 사용하는가

- 의존성이 0이다 — 어떤 계층에서도 안전하게 import할 수 있다.
- 필드가 계산에 필요한 값만 노출한다(Drift Row가 갖는 `toJson()`/`copyWith()`/`==` 등 ORM 부가 기능은 Engine에 불필요).
- 데이터 소스가 바뀌어도(Drift → 다른 ORM, 또는 테스트 픽스처) Engine 코드는 한 글자도 바꿀 필요가 없다.

## 왜 Repository가 변환 책임을 가지는가

- Repository는 이미 Drift를 알아야 하는 계층이다(쿼리를 작성하는 곳) — 변환 책임을 같은 곳에 두면 "Drift를 아는 파일"이 정확히 하나로 고정된다.
- 변환을 Engine이나 호출자(`SessionRepository`)에 맡기면, Drift를 아는 지점이 여러 곳으로 흩어지고 추후 "어디까지가 Drift 의존인가"를 추적하기 어려워진다.
- 이 경계가 하나로 고정되어 있으면, Drift를 다른 기술로 교체하는 가상의 시나리오에서도 변경 범위가 Repository 1개 파일로 한정된다.

## 왜 Engine은 DB를 몰라야 하는가

- 계산 로직(시간요금/피크할증)은 본질적으로 순수 함수다 — 입력이 같으면 출력이 같아야 하고, 부수효과가 없어야 검증과 추론이 쉽다.
- DB를 모르는 Engine은 비동기(`Future`)가 아니다 — 모든 메서드가 동기 함수라 테스트와 합성(다른 계산과 조합)이 단순해진다.
- "Engine은 정책을 결정하지 않고 Rule을 해석한다"는 원칙(`PRICING_ENGINE_ARCHITECTURE.md` §7/§9)이 DB 의존 제거와 함께 자연스럽게 강제된다 — Engine이 DB에 접근할 수 있다면 "필요하면 Engine이 직접 조회해서 정책을 결정"하는 식으로 책임이 흐려지기 쉽다.

## 향후 Promotion Engine도 동일 원칙을 따르는 이유

- A-11이 Pricing Engine과 같은 `pricing_rule` 테이블(`ruleType='discount_rate'` 등)을 재사용할 가능성이 높다 — 이미 검증된 "Repository가 변환, Engine은 POJO만" 패턴을 그대로 따르면 같은 안정성을 거의 비용 없이 얻는다.
- Promotion Engine이 별도 패턴(예: Drift Row를 직접 계산기에 흘려보내는 방식)을 택하면, 코드베이스에 "엔진마다 다른 격리 수준"이 생겨 다음 엔진(A-12/A-13)이 어느 쪽을 따라야 할지 혼란이 생긴다.
- 이 ADR을 Promotion Engine 착수 전에 먼저 정리해 두는 것 자체가 목적이다 — A-11 구현자가 "Pricing Engine은 어떻게 했지?"를 다시 코드에서 역추적하지 않고 이 문서만 보고 같은 구조를 적용할 수 있게 한다.

## 결과(Consequences)

**장점**
- `PricingEngine`/`domain/`이 어떤 외부 패키지도 import하지 않아, 향후 ORM 교체나 테스트 전략 변경에 영향받지 않는다.
- Drift를 아는 파일이 `pricing_rule_repository.dart`(+테이블 정의) 하나로 고정되어, 향후 스키마 변경의 영향 범위를 한 파일로 한정해 추론할 수 있다.

**비용/트레이드오프**
- Repository에 변환 메서드(`_toDomain`)라는 추가 단계가 생긴다 — 필드가 늘어날 때마다 POJO와 변환 메서드를 동시에 갱신해야 한다(컬럼 1개 추가 = 파일 2~3곳 동시 수정).
- 같은 데이터를 두 가지 타입(`PricingRuleRow`, `PricingRule`)으로 표현하게 되어, 처음 합류하는 개발자에게는 "왜 두 개가 있는가"를 설명할 문서(본 ADR)가 필요하다.
