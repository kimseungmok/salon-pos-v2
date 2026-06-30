# A-11: Promotion Engine 설계 문서

> **목적**: A-10.5(`ADR-002-discount-representation.md`)에서 확정된 "할인은 품목 레벨 이벤트(`itemType='discount'`)로 표현한다"는 결정을 전제로, Promotion Engine의 책임 경계·데이터 구조·전체 흐름을 확정한다. 본 문서 완성 시점에서 A-11 구현이 별도 설계 논의 없이 바로 시작 가능해야 한다.
> **범위**: 설계만 — 코드/스키마 변경 없음(본 문서 자체는 구현 전 단계).
> **선행 문서**: `docs/A10_5_DISCOUNT_ARCHITECTURE_REVIEW.md`, `docs/adr/ADR-002-discount-representation.md`, `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md`
> 작성일: 2026-06-26

---

## 1. Promotion Engine의 책임 범위 — 4가지 경계

### 1-1. Pricing Engine과의 경계

| | Pricing Engine | Promotion Engine |
|---|---|---|
| 방향 | 가격을 **올린다**(기본요금 산정, 피크 할증) | 가격을 **낮춘다**(할인 산정) |
| 입력 | `minutes`, `at`, `businessType`, `PricingRule[]` | `baseAmount`(할인 대상 금액), `businessType`, `PromotionRule[]`, (선택)고객/쿠폰 식별자 |
| 출력 | `int`(가산할 금액) | `int`(차감할 금액, 항상 0 이상 — 음수 변환은 호출자 책임) |
| 적용 방식 | 호출자가 `addItem(unitPrice: 반환값)`으로 적용 | 호출자가 `addItem(itemType: 'discount', unitPrice: -반환값)`으로 적용 |
| DB/Drift 의존 | 없음(POJO만) | 없음(POJO만, 동일 원칙) |

**경계가 갈리는 지점**: 가격 계산과 할인 계산은 "같은 패턴(Rule 조회 → 순수 계산 → `addItem()`이 적용)을 공유하지만 부호가 반대인 별개 엔진"이다. 한 엔진이 다른 엔진을 호출하지 않는다 — 둘 다 `SessionRepository`(또는 그 상위 호출자)가 각각 독립적으로 호출하고, 그 결과를 각각 별도의 `addItem()` 호출로 적용한다. Promotion Engine은 Pricing Engine이 산정한 `baseAmount`(이미 `addItem()`으로 저장된 품목의 `amount`, 또는 세션 `totalAmount`)를 **입력으로만** 참조할 수 있지만, Pricing Engine의 내부 로직(`calcTimeFee`/`calcPeakSurcharge`)을 호출하거나 알 필요는 없다.

### 1-2. Session Engine과의 관계 — 세션 상태가 할인 적용에 영향을 주는가

**영향을 준다 — 정확히 Pricing Engine과 동일한 방식으로.** `addItem()`의 기존 가드(`session.status != 'open'`이면 `BusinessRuleException`)가 할인 품목 추가에도 그대로 적용된다. 즉:

- `open` 세션에만 할인을 추가할 수 있다(새 가드 불필요 — 기존 `addItem()` 가드 재사용).
- `closed`/`cancelled` 세션에는 할인을 추가할 수 없다 — "마감 후 할인 추가로 매출이 바뀌는" 위험이 기존 immutable 규칙으로 이미 차단된다.
- Promotion Engine 자체는 세션 상태를 모른다(순수 계산 함수이므로) — 상태 검사는 항상 `SessionRepository.addItem()` �다.

### 1-3. Settlement Engine(A-13)과의 관계 — 할인이 정산에 어떻게 반영되는가

`closeSession()`은 한 글자도 바뀌지 않는다. 할인 품목이 추가되면 `_recomputeTotals()`가 그 음수 `amount`를 포함해 `totalAmount`/`finalAmount`를 재계산하고, `closeSession()`은 여전히 `paidTotal == finalAmount`만 검증한다. **Settlement Engine 관점에서 "할인이 적용된 세션"과 "할인 없는 세션"은 구분되지 않는다** — 둘 다 그냥 `finalAmount`라는 숫자 하나로 들어온다. 이는 의도된 단순성이다: 정산 단계는 "얼마를 받아야 하는가"만 알면 되고, "왜 그 금액이 됐는가"는 영수증(품목 리스트)이 책임진다.

### 1-4. Staff Earning Engine(A-12)과의 관계 — 할인이 급여 계산 기준에 영향을 주는가

**영향을 줄 수 있다 — 이것이 A-10 리뷰에서 식별된 "StaffEarningLedger staleness" 리스크(HIGH-2)가 실체화되는 지점이다.** 현재 `addItem()`은 `itemType=='staff_fee'`일 때 그 즉시(`amount` 확정 시점) `staff_earning_ledger`에 같은 금액을 기록한다. 할인이 **그 이후에** 같은 세션에 추가되면:

- `staff_fee` 품목의 `amount`(따라서 `staff_earning_ledger`의 기록값)는 **갱신되지 않는다** — 할인 적용 전 금액이 그대로 남는다.
- 즉 "할인 적용 전 매출 기준 수익"과 "할인 적용 후 매출 기준 수익" 중 어느 것을 직원 수익으로 인정할지를 A-12가 명시적으로 정해야 한다. 본 문서는 그 정책을 결정하지 않는다(A-12 범위) — 다만 **A-11은 이 질문에 답할 수 있는 데이터(할인 품목의 `refId`/`refType`/`sessionItemId`)를 충분히 남겨야 한다**는 제약을 설계에 반영한다(§5 참조).

## 2. 종합 — 엔진 경계 다이어그램

```
                    ┌─────────────────────┐
                    │   PricingRule(POJO)  │
                    │ ruleType: time_base, │
                    │           peak       │
                    └──────────┬───────────┘
                               │ 조회
                    ┌──────────▼───────────┐
                    │    PricingEngine      │  가격을 올림(+)
                    │ calcTimeFee()          │
                    │ calcPeakSurcharge()    │
                    │ calcTotal()            │
                    └──────────┬───────────┘
                               │ 반환값(양수)
┌──────────────────┐          ▼
│  PromotionRule    │   SessionRepository.addItem(unitPrice: 반환값)
│ (POJO, §6에서      │          ▲
│  구조 확정)        │          │ 반환값(음수로 변환)
└──────────┬────────┘          │
           │ 조회      ┌────────┴────────┐
           ▼           │ PromotionEngine  │  가격을 낮춤(−)
                        │ calcDiscount()   │
                        └─────────────────┘
```

두 엔진 모두 "Rule 조회 → 순수 계산 → 호출자가 `addItem()`으로 적용"이라는 동일한 파이프라인을 따른다. 둘 사이에 직접 호출 관계는 없다.

## 3. discountAmount / refType 확정(PART 1에서 미뤄둔 항목)

### 3-1. `payment_session.discountAmount` 컬럼 — **deprecated 확정**

**결정**: 이 컬럼은 향후에도 쓰지 않는다. 스키마에서 즉시 제거하지는 않되(기존 마이그레이션 무손실 원칙 — `docs/A9_ID_UNIFICATION.md`/`app_database.dart` 주석과 동일한 정책), `session_tables.dart`의 컬럼 주석에 "deprecated, 항상 0, 쓰지 말 것"을 명시하는 것을 A-11 구현 1단계의 작업 항목으로 포함한다(본 설계 문서 시점에는 코드 수정 금지이므로 실제 주석 수정은 A-11 구현 착수 시 수행).

**근거**:
- ADR-002에서 이미 "할인은 품목 레벨 이벤트"로 확정했고, `_recomputeTotals()`의 `finalAmount = total - discountAmount + taxAmount` 수식에서 `discountAmount` 항은 항상 0인 상태로 유지된다 — 수식 자체를 단순화(`discountAmount` 항 제거)하는 것은 **코드 수정**이라 본 설계 문서 범위 밖이며, A-11 구현 시점에 함께 정리한다.
- 컬럼을 즉시 DROP하면 마이그레이션 정책(무손실 원칙)과 충돌하고, 향후 "전표 전체에 거는 수동 조정"(예: 점장 권한의 임의 차감) 같은 별도 용도가 필요해질 가능성을 완전히 닫아버린다. deprecated 표시만으로 "현재는 미사용"이라는 사실을 코드 차원에서 명확히 하면서, 컬럼 자체는 보존한다.

### 3-2. 두 축의 분리 — `discountType`(계산 방식) vs `refType`(출처/사유)

요청에서 나열한 6가지(정액 할인/정률 할인/쿠폰/회원 할인/직원 할인/이벤트 할인)를 하나의 `refType` 목록으로 합치기 전에, 기존 모델을 다시 보면 **이미 두 개의 독립된 축이 있다**:

- **`PricingRule.ruleType`과 동일한 위치의 개념** = "할인을 어떻게 계산하는가"(정액/정률) → 이것은 `PromotionRule.discountType`(§6에서 구조 확정)에 해당한다.
- **`PaymentSessionItem.refType`** = "이 품목이 어떤 과거 도메인/사유에서 왔는가"(A-8 때부터 `'booking'|'plu'|'staff'|'manual'`로 이미 존재) → 쿠폰/회원할인/직원할인/이벤트할인은 이 축에 해당한다.

이 둘을 하나의 목록으로 합치면 "정액 할인이면서 쿠폰"(정액 쿠폰) 같은 조합을 표현할 수 없게 된다. **두 축을 분리해 확정한다**:

| 축 | 위치 | 확정 목록 |
|---|---|---|
| 계산 방식(`discountType`) | `PromotionRule.discountType`(신규, §6) | `flat`(정액 할인) \| `rate`(정률 할인) |
| 출처/사유(`refType`) | `PaymentSessionItem.refType`(기존 컬럼 재사용) | `coupon`(쿠폰) \| `membership`(회원 할인) \| `staff_manual`(직원 할인) \| `event`(이벤트 할인) |

**동일한 이벤트 모델로 표현 가능한가**: 가능하다. 할인 1건은 항상 `PaymentSessionItem(itemType='discount', refType=<출처>, amount=-계산된금액)` 한 행이며, 그 금액이 정액이었는지 정률이었는지는 `refId`로 참조되는 `PromotionRule.discountType`을 통해 사후에도 추적 가능하다(품목 자체에 `discountType`을 중복 저장하지 않음 — `refId` → Rule 조회로 충분, A-8의 `refType`/`refId` 느슨한 참조 패턴 그대로 재사용).

## 4. Promotion Rule 구조 비교

### 옵션 A: `pricing_rule` 테이블 확장

기존 `pricing_rule.ruleType`에 `'discount_flat'`/`'discount_rate'`를 추가하고, `value` 컬럼을 그대로 재사용(정액=금액, 정률=%).

- 충돌 여부: `peakStartHour`/`peakEndHour` 컬럼이 할인 규칙에는 의미가 없는데도 테이블에 그대로 남아 모든 할인 규칙 행에 무의미한 기본값(22/6)이 따라붙는다 — 스키마 오염. 향후 할인에만 필요한 필드(예: 최소 주문금액, 유효기간)가 생기면 `pricing_rule`에 점점 더 무관한 컬럼이 누적된다.
- A-12/A-13 영향: 없음(어느 옵션이든 동일 — Session/Settlement은 `PaymentSessionItem`만 본다).
- 업종 확장성: `shopId`/`businessType` 필터링은 이미 있어 재사용 가능하나, 테이블이 "가격 산정용"과 "할인용"이라는 서로 다른 책임을 한 곳에 떠안게 됨.

### 옵션 B: `promotion_rule` 신규 테이블 + 신규 `PromotionRuleRepository`

할인 전용 테이블을 새로 만들고(`discountType`/`value`/`minAmount`/`validFrom`/`validTo`/`businessType`/`shopId`/`priority`/`isActive`), 전용 Repository를 둔다.

- 충돌 여부: 없음 — `pricing_rule`/`PricingRuleRepository`는 그대로, 새 테이블·새 클래스가 독립적으로 추가된다(A-10 리뷰가 정립한 "신규 모듈은 기존 테이블을 건드리지 않는다" 원칙과 일치).
- A-12/A-13 영향: 최소 — `PaymentSessionItem.refId`가 이 새 테이블의 PK를 가리키기만 하면 되고, A-12/A-13은 이 테이블의 존재 자체를 몰라도 동작한다.
- 업종 확장성: 할인 전용 필드(유효기간, 최소주문금액)를 자유롭게 추가해도 Pricing Engine 쪽에 영향이 없다 — 업종별 캠페인 설계가 독립적으로 진화 가능.

### 옵션 C: 같은 테이블(또는 신규 테이블)을 공유 추상화(예: `RuleRepository` 인터페이스) 위에서 구성

`PricingRuleRepository`/`PromotionRuleRepository`가 공통 인터페이스를 구현하도록 미리 추상화 계층을 둔다.

- 충돌 여부: 없음(설계상으로는).
- A-12/A-13 영향: 없음.
- 업종 확장성: 동일.
- 단점: **지금 시점에 일반화할 근거가 부족하다** — 공유 추상화가 실제로 필요해지는 신호(예: A-12/A-13도 "Rule 조회" 패턴을 또 필요로 함)가 아직 없다. 이 프로젝트의 진행 방식(작업 메모리: 불필요한 추상화를 미리 만들지 않는다, "세 줄의 비슷한 코드가 섣부른 추상화보다 낫다")과도 맞지 않는다.

### 권장: **옵션 B(`promotion_rule` 신규 테이블 + 독립 `PromotionRuleRepository`)**

비교 기준 3가지(기존 엔진과의 충돌 여부, A-12/A-13 영향 최소화, 업종 확장성) 전부에서 옵션 A보다 우월하고, 옵션 C의 추상화 비용 없이 같은 효과(독립성)를 얻는다. 두 엔진이 우연히 비슷한 구조(Rule 조회 → 순수 계산)를 갖더라도, **그 구조가 같다는 사실 자체를 강제하는 공유 코드는 만들지 않는다** — A-12에서 또 비슷한 패턴이 필요해지면, 그때 가서 셋의 공통점을 보고 추상화 여부를 판단한다(YAGNI).

### `PromotionRule`(POJO, 설계 초안 — 구현 시 확정)

```dart
class PromotionRule {
  final int id;
  final int shopId;
  final String businessType;     // 'salon' | 'karaoke' | 'izakaya'
  final String discountType;     // 'flat' | 'rate'
  final int value;               // flat: 금액(원), rate: %(정수)
  final int minAmount;           // 이 금액 이상일 때만 적용(0 = 제한 없음)
  final int priority;
  final bool isActive;
  // validFrom/validTo(캠페인 기간) 등은 A-11 구현 착수 시 실제 요구사항에 맞춰 확정
}
```

`PricingRule`과 마찬가지로 Drift 의존이 없는 순수 Dart 클래스이며, `PromotionRuleRepository`가 Drift Row ↔ POJO 변환을 전담한다(ADR-001의 원칙을 그대로 적용).

## 5. Promotion Engine 전체 데이터 흐름

```
1. Rule 조회
   PromotionRuleRepository.getRules(businessType, shopId, discountType?)
   → List<PromotionRule> (Drift Row를 이미 POJO로 변환해 반환 — ADR-001 패턴)

2. 할인 계산
   PromotionEngine.calcDiscount({
     baseAmount: <할인 대상 금액 — 세션 totalAmount 또는 특정 품목 amount>,
     businessType,
     rules: List<PromotionRule>,
   }) → int(차감할 금액, 항상 0 이상, 순수 함수 — DB/Drift 미접근)

3. Discount Event 생성
   호출자(화면/유스케이스 레이어)가 계산된 금액을 음수로 변환하고
   itemName(스냅샷, 예: "会員10%割引")과 refType(coupon/membership/staff_manual/event)을 결정

4. PaymentSessionItem 저장
   SessionRepository.addItem(
     sessionId, itemType: 'discount', itemName, unitPrice: -계산된금액,
     qty: 1, refType: <출처>, refId: <PromotionRule.id 또는 쿠폰 코드 등>,
   )
   → addItem()의 기존 가드(open 세션만) + amount=unitPrice*qty 계산 그대로 적용

5. total_amount 재계산
   SessionRepository._recomputeTotals() (기존 코드, 무수정)
   → total = SUM(items.amount) — 할인 품목의 음수가 자동 반영
   → finalAmount = total - discountAmount(항상 0, deprecated) + taxAmount
```

| 단계 | 책임 컴포넌트 | DB/Drift 접근 |
|---|---|---|
| 1. Rule 조회 | `PromotionRuleRepository` | 있음(이 계층만) |
| 2. 할인 계산 | `PromotionEngine` | 없음(순수 계산) |
| 3. Discount Event 생성 | 호출자(화면/유스케이스) | 없음 |
| 4. 저장 | `SessionRepository.addItem()`(기존, 무수정) | 있음 |
| 5. 합산 | `SessionRepository._recomputeTotals()`(기존, 무수정) | 있음 |

## 6. A-11 완료 시점 전체 아키텍처(다이어그램)

```
┌────────────────────────────────────────────────────────────────────┐
│                         호출자(화면/유스케이스)                      │
└───────────┬───────────────────────────────┬────────────────────────┘
            │ 가격 제안 요청                  │ 할인 제안 요청
            ▼                               ▼
┌───────────────────────┐       ┌───────────────────────┐
│   PricingEngine         │       │  PromotionEngine(A-11)  │
│  calcTimeFee()           │       │  calcDiscount()          │
│  calcPeakSurcharge()     │       │                           │
│  calcTotal()             │       │                           │
│  (순수 계산, Drift 비의존) │       │  (순수 계산, Drift 비의존) │
└───────────┬─────────────┘       └───────────┬───────────────┘
            ▲                                 ▲
            │ List<PricingRule>                │ List<PromotionRule>
┌───────────┴─────────────┐       ┌───────────┴───────────────┐
│ PricingRuleRepository    │       │ PromotionRuleRepository(A-11)│
│ (Drift↔POJO 변환 담당)    │       │ (Drift↔POJO 변환 담당)        │
└───────────┬─────────────┘       └───────────┬───────────────┘
            │                                 │
            ▼                                 ▼
   pricing_rule(테이블)              promotion_rule(테이블, 신규)


            │ 계산된 금액(양수)                │ 계산된 금액(양수→음수 변환)
            ▼                                 ▼
┌──────────────────────────────────────────────────────────────────┐
│                    SessionRepository(A-8, 무수정)                  │
│  addItem(itemType: 'time'|'service'|...|'discount', unitPrice)     │
│       → amount = unitPrice * qty (기존 그대로)                     │
│  _recomputeTotals() → totalAmount/finalAmount 갱신(기존 그대로)     │
│  closeSession() → 결제수단 합계 검증(기존 그대로, A-13)             │
└──────────────────────────────────────────────────────────────────┘
            │
            ▼
   payment_session / payment_session_item / payment_method_breakdown
```

**핵심 불변량**: `SessionRepository`의 기존 4개 메서드(`createSession`/`addItem`/`closeSession`/`cancelSession`)는 A-11 도입 후에도 시그니처와 본문이 변경되지 않는다. Promotion Engine은 Pricing Engine과 같은 "바깥에서 계산해서 `addItem()`으로 적용"하는 방식으로만 Session Engine과 접촉한다.

## 7. A-12 / A-13에서 영향을 받을 수 있는 설계 포인트(사전 식별)

| 포인트 | 내용 | 영향받는 엔진 |
|---|---|---|
| **할인 적용 시점과 `staff_earning_ledger` 갱신 시점의 불일치** | `staff_fee` 품목 추가 시 즉시 ledger가 기록되는데, 그 이후 할인이 추가되면 ledger가 갱신되지 않는다(§1-4). A-12가 "할인 전/후 중 어느 금액을 직원 수익 기준으로 할지" 정책을 명시적으로 정해야 한다. | A-12 |
| **할인이 `staff_fee` 품목 자체에 걸리는 경우의 표현** | "이 지명료만 할인"처럼 품목 단위 할인이 발생하면, 할인 품목의 `refId`가 어떤 `PaymentSessionItem`(원본 `staff_fee` 행)을 가리키는지 연결할 방법이 현재 설계엔 없다(세션 단위로만 `refType`/`refId`를 둠). A-12 착수 전 "할인이 특정 품목을 타겟팅하는 경우"의 참조 방식(예: `refType='session_item'`, `refId=<PaymentSessionItem.id>`)을 결정해야 한다. | A-12 |
| **`closeSession()`의 검증 범위는 "이미 일어난 일"만 본다** | A-13은 할인이 정당했는지(쿠폰이 유효했는지, 정책에 맞았는지)를 재검증하지 않는다 — 그 책임은 전적으로 §5의 2단계(`PromotionEngine.calcDiscount()`)와 호출자에게 있다. A-13에서 "마감 시점에 할인 유효성을 다시 검사해야 하는가"는 운영 리스크(예: 쿠폰이 마감 직전 만료) 관점에서 A-13 설계 시 재검토가 필요하다. | A-13 |
| **`payment_session.discountAmount`(deprecated) 컬럼이 리포트/통계 코드에서 참조되고 있는지** | `sales_report` 모듈이 혹시 이 컬럼을 미리 참조해 두었다면(현재는 미사용이라 가능성 낮음) A-11 구현 시 함께 확인 필요. | A-13(정산 리포트와 맞물릴 경우) |
| **여러 할인이 동시에 적용될 때의 우선순위/중복 적용 정책** | `PromotionRule.priority`로 Rule 선택은 가능하지만, "쿠폰과 회원할인을 동시에 적용해도 되는가"(중첩 허용 여부)는 본 문서에서 결정하지 않았다 — A-11 구현 착수 시 비즈니스 규칙으로 확정해야 한다. | A-11(자체), 영향은 A-12/A-13까지 전파 |

---

## 결론 — A-11 착수 가능 여부

본 문서로 다음이 확정됐다:
- 할인의 세션 반영 방식(품목 레벨 이벤트, ADR-002) — 이미 확정, 본 문서는 이를 전제로 함
- `discountAmount` 컬럼 처리 방침(deprecated 확정)
- `discountType`(계산 방식)과 `refType`(출처) 두 축의 분리 및 각 허용값
- Rule 저장 구조(옵션 B: `promotion_rule` 신규 테이블 + 독립 Repository)
- 전체 데이터 흐름과 컴포넌트별 책임
- A-12/A-13에 영향을 줄 수 있는 5개 포인트(사전 식별, 결정은 각 엔진 설계 시점으로 위임)

A-11 구현은 본 문서를 참조해 바로 착수 가능하다. 단, §7에서 식별된 포인트 중 "할인 중첩 적용 정책"은 A-11 자체 구현 범위에 포함되므로, 구현 착수 시 가장 먼저 결정해야 한다.
