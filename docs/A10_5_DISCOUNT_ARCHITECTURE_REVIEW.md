# A-10.5: Discount Architecture 설계 검토

> **목적**: 할인을 `payment_session.discountAmount`(세션 레벨 조정값)로 표현할지, `PaymentSessionItem(itemType='discount')`(품목 레벨 이벤트)로 표현할지 최종 결정한다.
> **범위**: 설계 검토 및 권장안 제시만 — 코드/스키마 변경 없음.
> **선행 배경**: 이 결정 자체는 A-10 구현 리뷰(HIGH-3)에서 처음 식별됐고, A-10 리팩토링·문서화(ADR-001) 단계에서도 "A-11 착수 전 반드시 해결" 항목으로 재확인된 채 미해결로 남아 있었다.
> 작성일: 2026-06-26

---

## 1. 현재 코드 상태(사실 확인)

`lib/features/session/data/session_tables.dart`:
- `PaymentSessions.discountAmount` — `IntColumn`, 기본값 0. **이 값을 설정하는 코드는 어디에도 없다.**
- `PaymentSessionItems.itemType` 허용값에 `'discount'`가 이미 포함돼 있다(`session_repository.dart`의 `_validItemTypes`). **하지만 `'discount'` 타입으로 `addItem()`을 호출하는 코드도 어디에도 없다.**

`session_repository.dart`의 `_recomputeTotals()`:
```dart
final total = items.fold<int>(0, (sum, i) => sum + i.amount);
final finalAmount = total - session.discountAmount + session.taxAmount;
```
→ **두 경로가 이미 수식 안에 공존하고 있다.** `items`의 `amount` 합(품목 레벨, `discount` 타입 품목이 음수 `amount`로 들어오면 자동으로 `total`에 반영됨)과, `session.discountAmount`(세션 레벨, 별도 차감)가 동시에 계산식에 들어가 있다. 다만 후자는 **쓰는 코드가 없어 항상 0**이라 지금은 사실상 전자(품목 레벨)만 동작하는 셈이다 — 이 사실 자체가 "결정을 미뤄온" 증거다.

## 2. 두 방식 비교

### 방식 A: `payment_session.discountAmount` 중심(세션 레벨 조정값)

전표 헤더에 할인 총액을 하나의 숫자로 기록하고, `finalAmount = totalAmount - discountAmount + taxAmount`로 계산.

**장점**
- 계산이 단순하다 — 품목을 순회할 필요 없이 헤더 컬럼 하나만 보면 "이 전표에 할인이 얼마 적용됐는가"를 알 수 있다.
- 영수증 출력 시 "소계 / 할인 / 합계" 3줄 레이아웃과 1:1로 대응된다.
- `Settlement Engine`(A-13, `closeSession()`)이 검증할 값이 늘지 않는다 — 이미 `finalAmount`만 보고 결제수단 합계를 대조하는 현재 구조와 자연스럽게 맞는다.

**단점**
- **"왜 할인됐는가"가 사라진다.** 쿠폰 1장 할인인지, 회원 등급 할인인지, 직원 임의 할인인지 구분할 자리가 없다 — 단일 숫자로 뭉쳐진다.
- **여러 할인이 동시에 적용될 때 분해가 불가능하다.** "쿠폰 500원 + 회원할인 10%"가 같은 전표에 있으면 `discountAmount`는 그 합계 하나로만 남고, 각각의 출처를 나중에 복원할 수 없다.
- **영수증 재현성이 약하다.** A-8 설계 원칙(`itemName`을 스냅샷으로 저장해 원본이 바뀌어도 전표가 불변)과 결이 다르다 — 할인 "사유"의 스냅샷이 없다.
- 품목별 할인(예: 이 서비스만 할인, 저 상품은 정가)을 표현할 수 없다 — 항상 전표 전체에 거는 단일 조정값이다.

### 방식 B: `PaymentSessionItem(itemType='discount')` 이벤트 방식(품목 레벨)

할인 1건마다 음수 `amount`를 가진 품목 행을 만든다(예: `itemName='クーポン500円'`, `amount=-500`).

**장점**
- **A-8의 핵심 설계 원칙과 정확히 일치한다** — `PaymentSessionItem.itemName`이 그 시점의 스냅샷이라는 원칙을, 할인에도 그대로 적용할 수 있다("어떤 할인이 적용됐는지"가 전표에 영구 기록됨).
- 여러 할인이 동시에 적용돼도 각각이 별도 행이라 자연스럽게 분해/추적 가능하다.
- `_recomputeTotals()`의 `total = items.fold(...)` 계산식을 **그대로** 재사용한다 — 별도의 할인 합산 로직이 필요 없다(이미 동작하는 경로).
- 품목 단위 할인(특정 서비스에만 할인)과 전표 단위 할인(쿠폰) 둘 다 같은 메커니즘으로 표현 가능 — 표현력이 더 넓다.
- A-12(Staff Earning)와의 연결이 자연스럽다 — `sessionItemId`로 "이 할인이 어떤 직원의 매출에 영향을 줬는지" 같은 추적이 같은 패턴(품목 단위 참조)으로 가능해진다.

**단점**
- 할인 1건마다 행이 늘어나므로, "전표 전체에 5% 할인" 같은 단순한 케이스에서도 별도 품목 행을 만들어야 한다(약간의 오버헤드, 실질적으로는 미미함).
- `payment_session.discountAmount` 컬럼이 그대로 남아 있으면 "두 경로 중 어느 게 진짜인가"라는 혼란이 계속된다(현재 상태 그 자체) — 이 방식을 채택하면 해당 컬럼의 용도를 명확히 폐기(deprecated) 선언해야 한다.

## 3. 현재 구조와의 적합성 — 방식 B를 제안

**Session Engine과의 적합성**: A-8은 "전표 = 품목들의 합"이라는 모델을 일관되게 쓴다(`totalAmount`도 품목 합산, `staff_earning_ledger`도 품목 단위로 연결). 할인만 예외적으로 헤더 레벨 단일값으로 다루면 모델이 깨진다. 방식 B는 기존 모델을 그대로 확장한다.

**Pricing Engine과의 적합성**: `PricingEngine.calcTimeFee()`/`calcPeakSurcharge()`는 둘 다 "숫자를 계산해서 반환"하는 순수 함수이고, 그 반환값은 호출자가 `addItem(unitPrice: ...)`에 그대로 넘기는 패턴이다(`SessionRepository.calcSuggestedTimeFee()` 참조). 미래의 `calcDiscount()`도 똑같이 "할인액을 계산해서 반환"하면, 호출자가 그 값을 음수로 만들어 `addItem(itemType: 'discount', unitPrice: -계산값, qty: 1, ...)`로 넘기는 동일한 패턴을 그대로 재사용할 수 있다. 방식 A를 택하면 `calcDiscount()`의 반환값을 받아 `PaymentSessions.discountAmount`를 직접 갱신하는 **새로운 쓰기 경로**를 `SessionRepository`에 추가해야 하므로, 기존에 정립된 "addItem()을 통하지 않는 별도 갱신 메서드는 만들지 않는다"는 흐름과 어긋난다.

## 4. A-11 / A-12 / A-13에 미치는 영향

### A-11 Promotion Engine
- 방식 B를 택하면 Promotion Engine의 출력은 "할인 금액(들)"이고, 그 각각이 `addItem(itemType='discount', unitPrice=-금액)`으로 흘러간다 — Pricing Engine의 `calcSuggestedTimeFee()`와 동일한 "계산기 → addItem() 호출자가 직접 적용" 패턴이 그대로 재사용된다. 새 메서드를 추가할 필요가 거의 없다.
- 방식 A를 택하면 Promotion Engine은 `discountAmount`라는 단일 슬롯에 쓰기 경합이 생긴다 — 쿠폰 할인과 회원등급 할인이 동시에 있으면 "더할지 덮어쓸지"를 Promotion Engine이 결정해야 하고, 이 로직이 Session Engine 쪽(`_recomputeTotals()`)에 새로 추가돼야 한다.

### A-12 Staff Earning Engine
- 방식 B는 할인이 `sessionItemId`를 가진 일반 품목이므로, "이 직원의 서비스에 할인이 걸렸을 때 수익을 어떻게 재계산할 것인가"를 `staff_earning_ledger` 쪽에서 **같은 품목 참조 메커니즘으로** 풀 수 있다(이미 A-10 리뷰에서 식별된 "StaffEarningLedger staleness" 문제와 자연스럽게 같은 해법 후보를 공유하게 됨).
- 방식 A는 할인이 어떤 품목/직원에 연결됐는지 알 길이 없어, A-12가 할인 반영 수익을 계산하려면 별도의 "이 세션의 할인을 어떻게 직원별로 분배할지"라는 새로운 정책을 처음부터 설계해야 한다.

### A-13 Settlement Engine
- 방식 B는 `closeSession()`의 기존 검증식(`paidTotal == session.finalAmount`)에 영향이 없다 — `finalAmount`는 여전히 `_recomputeTotals()`의 `total`(품목 합산, 할인 품목의 음수 포함)에서 나온다. **A-13 코드는 변경이 필요 없다.**
- 방식 A는 `finalAmount = total - discountAmount + taxAmount` 수식에서 `discountAmount`가 실제로 쓰이게 되므로, A-13이 "이 세션의 `discountAmount`가 어느 시점에 확정됐는지"(품목 추가 중간에 바뀔 수 있는지 등)를 추가로 검증해야 할 가능성이 생긴다.

## 5. 할인 적용 흐름(Flow Diagram) — 방식 B 기준

```
[Promotion Engine(A-11)]
      │  PricingRule(ruleType='discount_rate'|'discount_flat') 조회
      │  calcDiscount(rules, baseAmount, ...) → 할인액(양수로 계산)
      ▼
[호출자(화면/유스케이스 레이어)]
      │  계산된 할인액을 음수로 변환
      ▼
SessionRepository.addItem(
    sessionId: ...,
    itemType: 'discount',
    itemName: '회원등급 10%할인' 같은 스냅샷,
    unitPrice: -계산된금액,   // 음수
    qty: 1,
    refType: 'coupon'|'membership'|..., refId: <근거 ID>,
)
      │
      ▼
PaymentSessionItem 행 1건 생성(amount = unitPrice * qty, 음수)
      │
      ▼
SessionRepository._recomputeTotals()
      │  total = SUM(items.amount)  ← 할인 품목의 음수가 자동 반영
      │  finalAmount = total - session.discountAmount(항상 0, 미사용) + taxAmount
      ▼
PaymentSessions.totalAmount / finalAmount 갱신
      │
      ▼
[Settlement Engine(A-13) = closeSession()]
      │  paidTotal(결제수단 합계) == finalAmount 검증
      ▼
PaymentMethodBreakdown 기록, status='closed'
```

## 6. 할인 데이터 생명주기(Lifecycle) — 방식 B 기준

| 단계 | 발생 위치 | 데이터 상태 |
|---|---|---|
| **1. 생성(Compute)** | Promotion Engine(A-11)의 순수 계산 메서드 | 아직 DB에 없음 — 계산된 정수값만 메모리에 존재 |
| **2. 저장(Persist)** | `SessionRepository.addItem(itemType='discount')` | `PaymentSessionItem` 행 1건(음수 `amount`)으로 영속화 — 이 시점부터 영수증 재현 가능 |
| **3. 합산(Aggregate)** | `_recomputeTotals()` | 같은 세션의 모든 품목(서비스/상품/할인 등) `amount`를 합산해 `totalAmount`/`finalAmount` 갱신 — 할인은 음수라 자동으로 차감됨 |
| **4. 검증(Verify)** | `closeSession()`(A-13) | 결제수단 합계가 할인 반영된 `finalAmount`와 정확히 일치해야 마감 가능 |
| **5. 확정(Finalize)** | `closeSession()` 성공 후 | 세션이 `closed`로 전환되며 immutable — 이후 어떤 할인도 추가/취소 불가(`addItem()` 가드가 차단) |
| **6. 조회(Query)** | `getSessionSummary()` | `items` 리스트에 할인 품목이 그대로 포함돼 반환 — 영수증/리포트가 "어떤 할인이 왜 적용됐는지" 그대로 복원 가능 |

방식 A였다면 1~3단계가 "계산값을 `discountAmount`에 직접 `write()`"로 단순화되지만, 6단계(조회)에서 "그 할인이 무엇이었는지"를 복원할 데이터가 없다는 게 근본적 한계다.

## 7. 최종 권장안

**`PaymentSessionItem(itemType='discount')` 이벤트 방식(방식 B)을 채택한다.**

### 범용 POS Platform(Salon/Karaoke/Izakaya)에 적합한 이유

1. **업종마다 할인의 "단위"가 다르다.** 살롱은 시술 1건 단위 할인(예: 이 컷만 20% 할인)이 흔하고, 이자카야는 영수증 전체 단위 할인(쿠폰)이 흔하며, 카라오케는 룸 이용시간 전체에 거는 할인이 흔하다. 품목 레벨 이벤트는 이 세 가지를 **같은 메커니즘**(품목 추가, 음수 금액)으로 표현한다 — 세션 레벨 단일 컬럼으로는 "이 시술만 할인"을 표현할 수 없다.
2. **40개 이상 지점이 서로 다른 할인 정책을 동시에 조합해 쓸 가능성이 높다.** 본사 쿠폰 + 지점 자체 회원할인이 같은 영수증에 동시에 걸리는 경우, 품목 레벨 이벤트는 각각을 독립된 행으로 누적하면 끝이지만, 세션 레벨 단일값은 "두 할인을 어떻게 합칠지"(더하기/곱하기/한도)에 대한 정책을 별도로 설계해야 한다.
3. **기존에 검증된 패턴을 재사용한다.** A-8의 "품목 스냅샷" 원칙, Pricing Engine의 "계산기 → `addItem()`이 그대로 적용" 패턴을 그대로 따르므로, A-11 구현 시 새로운 아키텍처 개념을 추가하지 않고 이미 검증된 길을 확장하는 것에 그친다 — A-10 리뷰/리팩토링에서 정립한 "Engine은 계산만, Repository는 적용만"이라는 일관성이 유지된다.
4. **`closeSession()`/Settlement Engine을 건드리지 않는다.** 기존 마감 검증 로직(`finalAmount` 대조)이 무수정으로 그대로 동작해, A-13 영역을 침범하지 않는다는 제약을 깔끔하게 만족한다.

### 후속 결정사항(이번 문서로 결론 내지 않고 A-11 착수 시 정할 것)
- `payment_session.discountAmount` 컬럼의 처리: 스키마에서 즉시 제거하지 않고 "미사용(0 고정)"으로 명시적으로 deprecated 표시만 해 둘지, 또는 향후 다른 용도(예: 영수증에 별도 표기할 "전표 단위 수동 할인" 같은 특수 케이스)로 한정해 살릴지는 A-11 설계 시점에 별도로 결정한다.
- `itemType='discount'`의 `refType` 허용값(쿠폰/회원등급/직원수동 등 구분자) 목록은 A-11이 구체적인 할인 종류를 설계할 때 함께 정의한다.

---

이 문서는 설계 결정 기록이며, 코드/스키마는 변경하지 않았다. 채택이 확정되면 A-11 구현 착수 시 `docs/adr/`에 본 권장안을 정식 ADR로 승격하는 것을 권장한다.
