# A-11.5: Promotion Engine 확장 준비

> **목적**: A-11 MVP(단일 Rule 적용)를 깨뜨리지 않으면서, 향후 복수 할인을 안전하게 추가할 수 있는 구조를 미리 검토한다. **복수 할인 계산을 구현하지 않는다** — 구조 설계와 근거만 정리한다.
> **전제 문서**: `docs/A11_PROMOTION_ENGINE_DESIGN.md`, `docs/A11_IMPLEMENTATION_PLAN.md`, `ADR-002`/`ADR-003`/`ADR-004`
> **구현 범위**: 없음(코드/DB 변경 0건, 본 문서로 검증)
> 작성일: 2026-06-26

---

## 전제 — A-11 완료 보고에서 식별된 3가지(본 단계에서 구현하지 않음, 전체 분석에 반영)

1. **`staff_earning_ledger` 타이밍 문제** — 할인이 추가돼도 이미 기록된 ledger 금액은 갱신되지 않음.
2. **`refId` 연결 부재** — 할인 품목이 특정 `staff_fee` 품목을 타겟팅할 방법이 없음(세션 단위 추적만 가능).
3. **중첩 정책 전제** — 현재는 `priority` 최우선 Rule 1개만 적용.

이 3가지는 아래 모든 PART, 특히 §PART5(A-12 영향 분석)에서 반복적으로 등장한다 — 복수 Promotion을 지원하면 이 3가지 문제가 **사라지지 않고 오히려 증폭**된다는 것이 본 문서의 핵심 결론 중 하나다.

---

## PART 1 — 다중 Promotion 적용 구조 검토: 데이터 흐름

> 아래 5가지 경우는 모두 **가상의 미래 시나리오**다. 현재 `PromotionEngine.calcDiscount()`는 1번(Rule 하나 적용)만 실제로 동작한다. 2~5번은 "만약 다중 적용을 지원한다면 어떤 정보가 오가야 하는가"를 보여주기 위한 설계용 흐름이다.

### 1. Rule 하나 적용(현재 A-11 MVP, 실제 동작)

```
입력: subtotal=3000, at=now, rules=[Coupon(flat,500,priority=1)]
  ↓ PromotionEngine.calcDiscount()
적용됨: Coupon(id=1)
적용 안 됨: (후보가 1개뿐이라 해당 없음)
최종 할인액: 500
호출자가 충분히 알 수 있는가: 예 — appliedRuleId=1, discountAmount=500로 전부 설명됨.
```

### 2. 여러 Rule 적용(동일 `discountType`/카테고리, 가상)

```
입력: subtotal=3000, rules=[Coupon500(priority=1), Coupon300(priority=2)]
  ↓ (가상) 다중 적용 로직
적용됨: Coupon500, Coupon300 둘 다(가정)
적용 안 됨: 없음
최종 할인액: ??? — 두 가지 계산 기준이 충돌한다:
   (a) 동일 기준: 500 + 300 = 800 (둘 다 원래 subtotal 3000 기준)
   (b) 순차 감소 기준: 500 적용 후 남은 2500에 300 적용 → 여전히 800(flat은 기준과 무관)
   → flat+flat은 기준 차이가 없지만, rate가 섞이면 §1-3에서 보듯 결과가 달라진다.
호출자가 충분히 알 수 있는가: 아니오 — 현재 PromotionResult(appliedRuleId 1개)로는
   "어떤 2개가 적용됐는지"를 표현할 수 없다(→ PART 2의 근거).
```

### 3. Coupon + Membership(서로 다른 카테고리, 가상)

```
입력: subtotal=3000, rules=[Coupon(flat,500), Membership(rate,10%)]
적용됨: Coupon, Membership(가정 — 서로 다른 카테고리라 동시 허용한다고 가정)
적용 안 됨: 없음
최종 할인액: 계산 기준에 따라 다르다:
   (a) 동일 기준(둘 다 원금 3000 기준): 500 + 300 = 800
   (b) 순차 감소(Coupon 먼저 적용 후 남은 2500에 Membership 10%): 500 + 250 = 750
   → (a)와 (b)가 50원 차이 — **이 기준을 정하는 것이 정책(Policy)의 역할**(PART 4).
호출자가 충분히 알 수 있는가: 아니오 — 적용 순서/기준에 대한 정보가 없으면
   영수증에 "왜 750원(혹은 800원)인지" 설명할 수 없다.
```

### 4. Coupon + Event(가상)

```
입력: subtotal=3000, rules=[Coupon(flat,500), Event(flat,200)]
적용됨: Coupon, Event(가정 — Event는 일반적으로 다른 할인과 누적 허용되는 카테고리로 가정)
적용 안 됨: 없음
최종 할인액: 500 + 200 = 700(flat+flat이라 기준 문제 없음)
호출자가 충분히 알 수 있는가: 아니오 — discountAmount=700이라는 숫자만으로는
   "Coupon이 얼마, Event가 얼마인지" 분해할 수 없다(영수증 표시·정산 추적성 손실).
```

### 5. Coupon + Membership + Event(3중, 가상)

```
입력: subtotal=3000, rules=[Coupon(flat,500), Membership(rate,10%), Event(flat,200)]
적용됨: 정책에 따라 다르다 — 만약 "Membership과 Coupon은 동시 적용 불가"라는
   배타 정책이 있다면, Membership 또는 Coupon 중 하나만 적용되고 나머지는
   "적용 안 됨(거부 사유: 정책 충돌)"으로 분류돼야 한다.
적용 안 됨: 위 배타 정책에 걸린 Rule(예: Membership) — **이걸 단순히 무시하면
   안 되고, 호출자/운영자에게 "왜 빠졌는지" 알려야 한다.**
최종 할인액: 적용된 Rule들의 합(기준 문제는 §3과 동일하게 발생)
호출자가 충분히 알 수 있는가: **현재 구조로는 절대 불가능** — 이 시나리오가
   PromotionResult 확장(PART 2)과 Policy 계층(PART 4)이 왜 필요한지를
   가장 명확하게 보여준다.
```

**PART 1 결론**: 시나리오 1(현재 구현)을 제외한 4개 모두 (a) 적용 순서/계산 기준이라는 **아직 결정되지 않은 정책 질문**과 (b) 현재 `PromotionResult`로는 표현 불가능한 **정보 부족 문제**에 부딛힌다. 둘 다 본 문서의 다음 PART에서 다룬다.

---

## PART 2 — PromotionResult 확장 설계

### 현재 구조의 한계(PART 1에서 드러난 그대로)

`{applied: bool, discountAmount: int, appliedRuleId: int?}` — "1개 Rule이 적용됐는지, 얼마였는지"만 표현 가능하다. 시나리오 2~5는 이 구조로 표현할 방법이 없다.

### 검토 항목별 필요성

| 필드 | 필요성 | 근거 |
|---|---|---|
| `totalDiscount` | **필요** | 여러 Rule이 동시에 적용되면 "합계"라는 개념이 `discountAmount`(단일값)와 별도로 있어야 한다. 다만 Rule이 1개일 때는 `totalDiscount == discountAmount`이므로, MVP의 `discountAmount`를 완전히 대체하기보다는 "복수 적용 시의 합계"라는 의미로 추가하는 것이 하위호환에 유리하다(§하위호환 참조). |
| `appliedRules` | **필요** | `appliedRuleId`(단일 int)는 "1개"를 전제로 한 설계다. `List<AppliedRuleInfo{ruleId, discountAmount, order}>`로 바뀌어야 "어떤 Rule들이 각각 얼마를 차감했는지"를 표현할 수 있다 — 영수증에 "クーポン -500円 / 会員割引 -250円"처럼 줄별로 보여주려면 이 정보가 필수다. |
| `skippedRules` | **필요(중첩 정책 도입 시점부터)** | 시나리오 5처럼 "후보였지만 정책 충돌로 제외된 Rule"이 생기는 순간부터, 이걸 침묵 처리하면 안 된다. `List<SkippedRuleInfo{ruleId, reason}>`로 "왜 빠졌는지"를 호출자가 알 수 있어야 운영자가 "왜 이 쿠폰이 안 먹히지?"라는 문의에 답할 수 있다. |
| `warnings` | **필요 — 단, 단순 로그가 아니라 구조화된 객체여야 한다** | 아래 별도 절에서 검토. |
| `appliedAt` | **필요(약함, 그러나 권장)** | "이 계산이 평가된 시각"을 기록해두면, `startAt`/`endAt` 경계값 근처에서 계산된 결과를 사후에 검증할 때(예: "23:59:59에 평가됐는데 왜 적용 안 됐지?") 추적이 쉬워진다. A-8의 "이벤트는 발생 시점 스냅샷을 남긴다"는 원칙(ADR-003)과 결을 같이 한다 — 가벼운 필드라 추가 비용이 거의 없다. |

### `warnings`는 로그가 아니라 호출자(UI/운영자)를 위한 구조

`warnings: List<String>`처럼 자유 문자열로 두면, 결국 화면에 그 문자열을 그대로 띄우거나(다국어 불가, 일본어 앱인데 내부 디버그 메시지가 그대로 노출될 위험) 파싱해서 분기해야 하는(취약함) 상황이 생긴다. 대신 **구조화된 경고 객체**가 필요하다:

```dart
class PromotionWarning {
  final String code;       // 'POLICY_CONFLICT' | 'STACKING_REJECTED' | 'RULE_EXCLUDED' 등
  final String message;    // 사람이 읽을 메시지(다국어 키로 대체 가능)
  final int? relatedRuleId;
}
```

이렇게 해야 화면이 `code`로 분기해 적절한 UI(예: 토스트/배지)를 띄우고, `message`는 운영자용 상세 설명으로만 쓸 수 있다. **단순 로그 문자열 리스트로는 "정책 충돌"과 "단순 정보성 메시지"를 구분할 방법이 없다** — 구조화가 필요하다는 결론이다.

### 하위호환 방향(설계만, 구현 안 함)

기존 `applied`/`discountAmount`/`appliedRuleId`는 그대로 유지하고, Rule이 정확히 1개 적용된 경우 `appliedRules.single`로부터 동일한 값이 계산되도록 둔다(파생 getter). 이렇게 하면 A-11 MVP를 호출하는 기존 코드(`SessionRepository.calcSuggestedDiscount()` 호출부)가 확장 이후에도 무수정으로 동작한다 — **본 PART는 "확장 가능하다"는 것을 보여주는 것이 목적이며, 지금 구현하지 않는다.**

---

## PART 3 — 할인 중첩 정책 비교

| 방식 | 장점 | 단점 | 확장성 | 운영 편의성 | A-12 영향 |
|---|---|---|---|---|---|
| **1. 최우선 1개만**(현행) | 계산이 항상 명확(기준 문제 없음), Ledger/정산 추적이 단순 | 마케팅 유연성 낮음(쿠폰+회원할인 동시 불가) | 낮음 | 매우 높음(설명하기 쉬움) | **최소** — 항상 1개의 할인 소스만 존재 |
| **2. 복수 Rule 모두 적용** | 마케팅 자유도 최대 | 계산 기준(동일/순차) 결정 필요, 할인 과다 누적으로 마진 침식 위험, 정책 가드 없으면 남용 가능 | 높으나 회계 부담 큼 | 낮음(예측 어려움, "왜 이렇게 많이 깎였지" 문의 증가) | **최대** — 중첩될수록 §PART5의 모든 문제가 배수로 증폭 |
| **3. RuleType(카테고리)별 최대 1개** | 실제 업계 관행과 일치(쿠폰 중복은 막되 쿠폰+멤버십은 허용), 계산 기준 문제가 카테고리 수(2~3개)로 제한돼 다루기 쉬움 | 그래도 순서/기준 결정은 필요(카테고리가 2개 이상일 때) | 중상 | 중상(카테고리 단위라 설명 가능) | 중 — 최대 적용 가능 Rule 수가 `refType` 종류 수로 상한선이 생김(`coupon`/`membership`/`staff_manual`/`event` 4종) |
| **4. Rule 자체의 `stackable` 플래그** | Rule 단위로 세밀하게 제어 가능(특정 고액 쿠폰만 단독 적용 강제 등), 코드 변경 없이 운영자가 정책 조정 가능 | 스키마 필드 추가 필요, 여러 stackable Rule이 동시에 후보일 때 "어떤 조합을 선택할지" 결정 알고리즘이 필요(조합 탐색 복잡도 증가) | 가장 높음 | 중(관리자 화면에서 플래그를 잘못 설정하면 예측 못한 중첩 발생 가능) | 높음 — 데이터에 따라 케이스가 가변적이라 일반화된 정책 수립이 어려움 |

### 배타(exclusive) 정책 — 위 4가지와 독립된 별도 축

"Membership끼리 동시 적용 불가", "VIP와 Membership 동시 적용 불가", "직원 할인은 다른 할인과 동시 적용 불가" 같은 규칙은 **위 1~4번 중 어떤 방식을 택해도 추가로 필요한 별도 레이어**다 — 예를 들어 방식 3(카테고리별 최대 1개)을 택해도 "VIP와 Membership"이 같은 카테고리(`membership`)가 아니라면 이 배타 규칙은 카테고리 단위 제한으로 커버되지 않는다. 즉 **배타 정책은 항상 명시적인 "Rule 쌍(pair) 또는 카테고리 쌍의 제외 매트릭스"로 별도 관리해야 한다** — 이건 Engine의 계산 로직이 아니라 PART 4의 Policy 계층이 들고 있어야 할 데이터다.

### 권장안

**MVP 이후 1차 확장 단계로 방식 3(RuleType별 최대 1개)을 권장한다.** 이유:
- 방식 1(현행)보다 실질적 마케팅 가치가 생기는 첫 단계이면서, 방식 2/4의 복잡도(계산 기준 모호성 폭증, stackable 조합 탐색)를 아직 짊어지지 않는다.
- `refType` 분류(`coupon`/`membership`/`staff_manual`/`event`)가 A-11에서 이미 확정돼 있어, "카테고리"라는 개념을 새로 설계할 필요 없이 그대로 재사용 가능하다.
- 배타 매트릭스(예: VIP-Membership)는 방식 3을 채택해도 별도로 필요하므로, 이 권장안이 배타 정책 설계를 막지 않는다.

**단, 이 권장안은 "1로 확정"이 아니라 "다음 단계로 가장 안전한 방향"이라는 의미다.** 계산 기준(동일 기준 vs 순차 감소 기준, §PART1-3)과 배타 매트릭스의 구체적 내용은 여전히 결정되지 않았다 — 이 두 가지가 정해지기 전에는 ADR로 확정하지 않는다(결과물 절 참조).

---

## PART 4 — Policy 계층 분리 설계

### 옵션 A: Engine 위에 별도 `PromotionPolicy` 클래스(전용 계층)

```
Caller → PromotionRuleRepository.getRules() → List<PromotionRule>(이미 fetch됨)
       → PromotionPolicy.selectRulesToApply(candidates, context)  ← 적용 여부/순서만 결정
       → PromotionEngine.calcDiscount(selectedRules, ...)         ← 계산만 수행
```

- **장점**: `PricingEngine`/`PricingRuleRepository`처럼 이 코드베이스가 일관되게 써온 "단일 책임 클래스" 패턴과 맞는다. `PromotionPolicy`를 독립적으로 단위테스트할 수 있다(배타 매트릭스 같은 정책 로직이 계산/DB와 분리되어 테스트가 쉬움). 향후 호출 지점이 여러 곳(예: 미리보기 화면 + 실제 적용 흐름)으로 늘어나도 정책 로직이 한 곳에 있어 일관성이 보장된다.
- **단점**: 파일/클래스가 하나 늘어난다 — 정책 로직이 아주 단순한 동안에는 과한 레이어일 수 있다.

### 옵션 B: Application Service(호출자/오케스트레이션 코드) 안에 정책 로직을 둠

```
Caller(예: SessionRepository.calcSuggestedDiscount() 또는 향후 UseCase 클래스)
   내부에서 직접 "이 Rule들 중 뭘 적용할지" 판단 → PromotionEngine 호출
```

- **장점**: 파일이 늘지 않는다 — 정책이 한두 가지 규칙(예: "카테고리당 1개")뿐인 동안에는 빠르게 구현 가능.
- **단점**: 정책 로직이 오케스트레이션 코드(`SessionRepository` 또는 향후 UseCase)에 섞여, "기존 흐름 변경 금지" 제약과 충돌할 위험이 있다(`SessionRepository`에 정책 로직을 추가하는 것 자체가 그 클래스의 책임을 넘는 변경). 호출 지점이 늘어나면 같은 정책 판단 로직이 여러 곳에 중복될 위험.

### 제안: **옵션 A를 채택할 시점이 되면 옵션 A로, 그 전까지는 만들지 않는다**

방식 3(RuleType별 최대 1개, PART 3 권장안) 정도의 단순 규칙이라면 옵션 B로도 충분히 짧게 구현 가능하다 — 따라서 **"복수 Rule 적용을 실제로 구현하는 시점"에 규칙의 복잡도를 보고 A/B를 정한다.** 다만 배타 매트릭스(VIP-Membership 등)처럼 "Rule 쌍 단위의 명시적 데이터"가 필요해지는 순간부터는 그 데이터와 판단 로직을 `SessionRepository`(엄연히 Session Engine의 책임)에 두는 것은 책임 경계를 침범하므로, **그 시점부터는 옵션 A(전용 `PromotionPolicy` 클래스, `lib/features/promotion/policy/`)로 이전하는 것을 권장한다.**

어느 옵션이든 다음은 고정된다(사용자 지시 그대로):
- Policy는 계산하지 않는다 — `discountAmount` 계산은 항상 `PromotionEngine`.
- Policy는 Repository를 직접 호출하지 않는다 — 이미 fetch된 `List<PromotionRule>`만 받는다.
- Policy는 "어떤 Rule을 어떤 순서로 Engine에 넘길지"만 결정한다.

---

## PART 5 — A-12 영향 분석

### 4가지 기준 검토

| 기준 | 설명 | 복수 Promotion 도입 시 영향 |
|---|---|---|
| 할인 전 기준 Staff 수당 | `staff_fee` 품목의 원래 `amount`를 그대로 수당 기준으로 삼음 | 가장 단순하지만, "고객은 할인받았는데 직원 수당은 안 깎인다"는 정책적 선택을 명시적으로 정당화해야 함 — 복수 할인이어도 이 기준은 변하지 않아 **영향이 가장 작은 옵션** |
| 할인 후 기준 Staff 수당 | 할인이 반영된 후의 실수령 매출을 기준으로 수당 계산 | 복수 할인이 누적될수록 "어느 할인까지 반영된 시점"의 금액을 기준으로 할지 애매해짐(예: 마감 시점 vs 각 할인 추가 시점) — **영향이 가장 큰 옵션, 중첩이 늘수록 계산 타이밍 문제가 비례해 커짐** |
| 품목 단위 할인 귀속 | 할인이 특정 `staff_fee` 품목 1건을 타겟팅 | 현재 `refId` 연결 부재(전제 2번)로 **지금은 불가능** — 복수 Promotion이 각각 다른 품목을 타겟팅할 수 있게 되면 이 부재가 더 치명적으로 드러남(어느 할인이 어느 직원 매출에 영향을 줬는지 전혀 알 수 없게 됨) |
| 세션 단위 할인 귀속 | 할인을 세션 전체에 거는 것으로만 취급, 특정 품목/직원과 연결하지 않음 | 현재 구조와 일치(가능한 옵션) — 다만 세션에 여러 직원의 `staff_fee`가 동시에 있으면(예: 두 직원이 같이 시술), "세션 전체 할인을 직원별로 어떻게 나눌지"라는 새로운 배분 문제가 생김(복수 할인 도입과 무관하게 이미 잠재된 문제이나, 중첩이 생기면 배분 대상 금액 자체도 여러 조각이 됨) |

### Q1. 할인이 중첩될 경우 Staff 수당 기준은 어느 금액인가?

**현재 결정되지 않았다 — A-12가 명시적으로 정해야 한다.** 양쪽의 함의만 정리한다:
- **할인 전 기준**을 택하면: 수당 계산 자체는 중첩 여부와 무관하게 항상 단순하다(원래 `staff_fee.amount`만 보면 됨). 다만 "전표 전체 마진이 줄었는데 인건비 배분은 그대로"라는 정책을 회사가 받아들여야 한다.
- **할인 후 기준**을 택하면: 중첩된 할인 중 "이 직원의 서비스에 실제로 얼마가 배분됐는지"를 계산하는 알고리즘이 필요하다 — 할인이 세션 단위(여러 직원의 매출에 걸쳐 있음)인지 품목 단위(특정 직원만)인지에 따라 배분 방식이 완전히 달라진다. **이 알고리즘은 중첩 Rule 수가 늘수록 더 복잡해진다.**

### Q2. `refId` 연결이 없는 현재 구조에서 품목 단위 귀속이 가능한가?

**불가능하다.** 현재 할인 품목(`PaymentSessionItem.itemType='discount'`)의 `refId`는 `PromotionRule.id`(어떤 정책이 적용됐는지)만 가리킨다 — "이 할인이 어느 `PaymentSessionItem`(예: 특정 `staff_fee` 행)을 줄였는지"를 가리키는 필드가 없다. 이를 가능하게 하려면 `refType='session_item'`, `refId=<PaymentSessionItem.id>` 같은 신규 참조 방식이 필요하다(`A11_PROMOTION_ENGINE_DESIGN.md` §7에서 이미 식별, 본 단계에서도 구현하지 않음).

### Q3. A-12 착수 전에 반드시 먼저 결정해야 하는 것은?

1. **Ledger 타이밍 정책**(즉시 확정 vs `closeSession()` 시점 재계산) — 전제 1번, A-11 완료 보고에서 이미 식별.
2. **할인 전/후 중 어느 금액을 수당 기준으로 할지**(Q1).
3. **품목 단위 귀속을 지원할지, 한다면 참조 방식을 어떻게 설계할지**(Q2).
4. **(복수 Promotion이 실제로 구현된 이후라면) 세션에 여러 직원이 걸려 있을 때, 중첩된 여러 할인을 직원별로 어떻게 배분할지의 배분 알고리즘** — 이건 본 문서에서 새로 식별된 항목으로, 단일 Rule 적용(현행 A-11)에서는 드러나지 않았던 문제가 복수 Promotion 도입과 동시에 표면화된다.

---

## PART 6 — 확장 Roadmap

```
A-11(완료) ─ 단일 Rule 적용, Lifecycle, Repository/Engine 분리
   │
A-11.5(본 문서) ─ 구조 준비만, 구현 없음
   │   먼저 결정할 것: 계산 기준(동일/순차), 배타 매트릭스 초안, PromotionResult 확장 스펙
   │
A-11.6(가상, 차기 구현 단계) ─ "RuleType별 최대 1개" 구현
   │   - PromotionResult 확장(totalDiscount/appliedRules/skippedRules/warnings) 실제 구현
   │   - 옵션 B(Application Service 내 정책) 또는 옵션 A(전용 Policy 클래스)로 시작
   │     — 이 시점에 실제 규칙 복잡도를 보고 택일
   │   먼저 결정할 것: 계산 기준 확정(ADR-005 후보)
   │
A-12 Staff Earning Engine ─ Ledger 타이밍/귀속 방식 확정 후 구현
   │   선행 조건: PART5 Q1~Q4 전부 결정
   │
A-13 Settlement Engine 재검증 ─ 복수 할인이 정산 검증(closeSession())에
   │   새로운 위험을 추가하지 않는지 재확인(이미 ADR-003에 따라 구조적으로는 안전,
   │   다만 마감 시점에 "이 전표에 몇 개의 할인이 누적됐는지"를 영수증에
   │   정확히 표시하는 화면 작업이 필요할 수 있음)
   │
Coupon Engine ─ 쿠폰 코드 입력/검증 UI+로직(refType='coupon' 구체화,
   │   기존 `marketing` 모듈의 Coupon 데이터와의 통합 여부 결정 필요)
   │
Membership Engine ─ 고객 등급 조회 연계(refType='membership')
   │
Event Engine ─ 캠페인 기간 운영 도구(refType='event')
```

### Promotion Policy / Orchestrator 계층이 필요해지는 시점

- **Policy 계층(`lib/features/promotion/policy/`)**: "RuleType별 최대 1개" 이상의 복잡도(특히 배타 매트릭스)가 필요해지는 **A-11.6 시점 또는 그 이후** — 그 전까지는 불필요(YAGNI, PART 4 결론 재확인).
- **Orchestrator 계층**(여러 Engine/Policy/Repository를 조합하는 별도 use-case 클래스): Promotion이 Pricing/Staff Earning과 **같은 호출 흐름에서 한 번에 조합**돼야 하는 요구(예: "이 화면에서 가격+할인+직원수당을 한 API 호출로 전부 계산해줘")가 생기는 시점 — 현재처럼 `SessionRepository`의 `calcSuggestedXxx()` 헬퍼들을 호출자가 순서대로 부르는 방식으로 충분한 동안에는 **만들 필요가 없다.**

---

## 기존 ADR과의 충돌 여부(완료 기준 7)

| ADR | 충돌 여부 | 근거 |
|---|---|---|
| **ADR-002**(할인 표현 방식) | **충돌 없음, 오히려 강화됨** | 복수 Rule이 적용되면 각 Rule마다 별도의 `PaymentSessionItem(itemType='discount')` 행을 만드는 것이 자연스럽다 — "어떤 할인이 왜 적용됐는지"를 영수증에 그대로 남긴다는 ADR-002의 근거가 단일 적용보다 복수 적용에서 오히려 더 빛난다(한 행에 여러 정책을 뭉치면 추적성이 떨어지므로, Rule당 1행이 ADR-002와 자연히 일치). |
| **ADR-003**(Financial Events) | **충돌 없음** | `PromotionResult.totalDiscount`는 영속화되는 헤더 컬럼이 아니라 호출자에게 반환되는 메모리상의 집계값이다 — 헤더 직접 쓰기를 만들지 않는다는 원칙은 그대로 유지된다. |
| **ADR-004**(Rule Lifecycle) | **충돌 없음** | Lifecycle(`draft`/`active`/`disabled` + 파생 `Expired`)은 Rule 1건의 상태를 다루는 모델이며, "몇 개의 Rule이 동시에 선택되는가"는 Lifecycle과 무관한 별개 차원(선택 알고리즘, PART 3/4)이다. 복수 적용으로 확장해도 Lifecycle 모델 자체는 수정할 필요가 없다. |

**결론: 기존 ADR 3개 중 어느 것도 수정이 필요하지 않다.**

---

## 결과물 판단 — ADR-005 보류

지시문의 ADR 작성 기준("중첩 정책이 하나로 확정되면 ADR를 작성한다")에 따라 판단하면: 본 문서는 PART 3에서 "방식 3(RuleType별 최대 1개)"을 **권장안**으로 제시했지만, 이를 실제로 적용하기 위한 핵심 하위 질문들 — **계산 기준(동일 기준 vs 순차 감소 기준, PART 1-3에서 식별)**과 **배타 매트릭스의 구체적 내용(어떤 카테고리 쌍이 배타인지)** — 이 아직 결정되지 않았다. 권장안 제시가 "정책 확정"과 같지 않으므로, **`docs/adr/ADR-005-promotion-stacking-policy.md`는 이번 단계에서 작성하지 않는다.** 본 문서(PART 3/4의 비교 결과)가 그 결정이 내려질 때 ADR 작성의 근거 자료가 된다.

---

## 완료 기준 점검

| # | 기준 | 상태 |
|---|---|---|
| 1 | 다중 Promotion 데이터 흐름 설계 | ✅ PART 1, 5개 시나리오 |
| 2 | PromotionResult 확장 방향/warnings 필요성 | ✅ PART 2 — `totalDiscount`/`appliedRules`/`skippedRules` 필요, `warnings`는 구조화된 객체로 필요, `appliedAt` 권장 |
| 3 | 중첩 정책 4가지 비교 + 권장안 | ✅ PART 3 — 방식 3 권장(확정 아님) |
| 4 | Policy 계층 위치 결정 | ✅ PART 4 — 옵션 A(전용 클래스)를 복잡도 증가 시점에 도입, 그 전까지 보류 |
| 5 | A-12 영향 분석 + 착수 전 결정 사항 | ✅ PART 5 — Q1~Q3, 4개 결정 사항 명시 |
| 6 | Policy/Orchestrator 필요 시점 분석 | ✅ PART 6 |
| 7 | ADR-002/003/004 충돌 검토 | ✅ 충돌 없음(표 참조) |
| 8 | 확장 Roadmap | ✅ PART 6 |
| 9 | 코드/DB 변경 없음 확인 | 본 문서 작성 turn에서 `lib/`/`test/`/스키마 변경 0건(아래 보고) |
