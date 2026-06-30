# ADR-002: Discount Representation

- **상태**: Accepted
- **시점**: A-10.5 Discount Architecture 검토 → 공식화
- **관련 문서**: `docs/A10_5_DISCOUNT_ARCHITECTURE_REVIEW.md`(상세 비교 분석), `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md` §할인 처리 방식, `docs/A11_PROMOTION_ENGINE_DESIGN.md`

> **번호 안내**: 본래 요청은 `ADR-001-discount-representation.md`였으나, `ADR-001`은 이미 `pricing-engine-domain-isolation`(A-10 리팩토링 R1)에 사용 중이라 번호 충돌을 피해 `ADR-002`로 부여했다. 내용은 요청 그대로다.

## 배경(Context)

`SessionRepository._recomputeTotals()`는 이미 다음 수식을 갖고 있다.

```dart
final total = items.fold<int>(0, (sum, i) => sum + i.amount);
final finalAmount = total - session.discountAmount + session.taxAmount;
```

이 한 줄에 **두 가지 할인 표현 경로가 동시에 존재**한다 — `items`의 `amount` 합(품목 레벨, `itemType='discount'`인 행이 음수 `amount`로 들어오면 자동 반영) 과 `session.discountAmount`(세션 헤더의 별도 차감값)다. 그러나 `PaymentSessions.discountAmount`를 실제로 갱신하는 코드는 `addRule`/`addItem`/`closeSession`/`cancelSession`/`_recomputeTotals` 어디에도 없다 — 기본값 0에서 한 번도 바뀌지 않는다. 반면 `PaymentSessionItems.itemType`의 허용값 집합(`_validItemTypes`)에는 `'discount'`가 A-8 때부터 이미 포함돼 있었으나, 그 타입으로 `addItem()`을 호출하는 코드 역시 없었다.

즉 **수식은 두 경로를 모두 지원하도록 작성돼 있지만, 실제로 동작 가능한 경로는 품목 레벨(`itemType='discount'`) 하나뿐이었다** — 세션 레벨 경로는 "쓰는 코드가 없어 항상 0"이라는 이유로 사실상 죽은 코드였다. 이 결정 미룸 상태는 A-10 구현 리뷰(HIGH-3)에서 처음 식별됐고, A-10 리팩토링 이후에도 "A-11 착수 전 반드시 해결" 항목으로 재확인됐다.

## 검토한 두 방식

### 방식 A: `payment_session.discountAmount` 컬럼 중심(세션 레벨 조정값)

전표 헤더에 할인 총액을 단일 숫자로 기록.

- 장점: 계산이 단순(헤더 컬럼 하나), 영수증 "소계/할인/합계" 레이아웃과 직결, `closeSession()`의 기존 비교식과 자연스럽게 맞음.
- 단점: 할인의 "출처/사유"가 사라짐(쿠폰/회원등급/직원할인 구분 불가), 복수 할인 동시 적용 시 분해 불가능, 품목 단위 할인(특정 서비스만 할인) 표현 불가, A-8의 "품목 스냅샷으로 영수증 재현" 원칙과 결이 다름.

### 방식 B: `PaymentSessionItem(itemType='discount')` 이벤트 방식(품목 레벨)

할인 1건마다 음수 `amount`를 가진 품목 행을 생성.

- 장점: A-8의 품목 스냅샷 원칙과 정확히 일치, `_recomputeTotals()`의 기존 합산 로직을 그대로 재사용(추가 로직 불필요), 복수 할인이 각각 독립 행으로 자연 누적, 품목 단위/전표 단위 할인을 동일 메커니즘으로 표현 가능, Pricing Engine의 "계산기 → `addItem()`이 그대로 적용" 패턴과 일관.
- 단점: 할인 1건마다 행이 늘어남(실질적 오버헤드는 미미), `discountAmount` 컬럼이 스키마에 남아있으면 "어느 게 진짜인가"라는 혼란이 계속됨(→ 본 ADR의 결정 사항으로 해소).

(상세 비교는 `docs/A10_5_DISCOUNT_ARCHITECTURE_REVIEW.md` §2~§6 참조)

## 결정(Decision)

**방식 B(`PaymentSessionItem(itemType='discount')` 이벤트 방식)를 채택한다.**

할인은 전표 헤더의 단일 조정값이 아니라, 다른 품목(서비스/상품/시간요금)과 동일한 자격으로 `PaymentSessionItem` 테이블에 음수 `amount`를 가진 행으로 기록된다.

## 결정 근거

1. **A-8 품목 스냅샷 원칙과의 일관성 유지** — `itemName`이 그 시점의 스냅샷이라는 원칙(원본이 나중에 바뀌어도 전표는 불변)을 할인에도 동일하게 적용한다. "어떤 할인이, 왜 적용됐는지"가 전표에 영구 기록된다.
2. **`closeSession()`(Settlement Engine, A-13) 무수정 유지** — `finalAmount`는 여전히 `_recomputeTotals()`의 품목 합산에서 나오므로, 결제수단 합계 대조 로직을 한 글자도 바꾸지 않는다.
3. **업종별 할인 단위 차이를 같은 메커니즘으로 표현 가능** — 살롱(시술 1건 단위 할인), 카라오케(룸 이용시간 전체 할인), 이자카야(영수증 전체 쿠폰)를 모두 "품목 행 추가"라는 동일한 동작으로 표현한다. 세션 레벨 단일 컬럼으로는 품목 단위 할인 자체를 표현할 수 없다.
4. **복수 할인 동시 적용 시 자연 누적** — 쿠폰 + 회원등급 할인이 동시에 걸려도 각각 독립된 품목 행으로 추가되면 끝이다. "여러 할인을 어떻게 합산할지"에 대한 별도 정책(더하기/곱하기/한도)을 Session Engine 쪽에 새로 만들 필요가 없다.

## 미결 사항 처리 방침

- **`payment_session.discountAmount` 컬럼의 deprecated 처리 여부** → 본 ADR에서는 결정하지 않는다. PART 2(`docs/A11_PROMOTION_ENGINE_DESIGN.md` §5)에서 확정한다.
- **`refType` 허용값 목록**(쿠폰/회원할인/직원할인/이벤트할인 등 구분자) → 본 ADR에서는 결정하지 않는다. PART 2(`docs/A11_PROMOTION_ENGINE_DESIGN.md` §5)에서 확정한다.

## 결과(Consequences)

**장점**
- A-11 Promotion Engine은 새로운 쓰기 경로(예: `discountAmount` 갱신 메서드)를 `SessionRepository`에 추가할 필요 없이, 기존 `addItem()` 호출만으로 구현 가능하다.
- 영수증/리포트가 할인의 출처를 그대로 복원할 수 있다.

**비용/트레이드오프**
- `payment_session.discountAmount` 컬럼이 스키마에 남는 동안은 "왜 안 쓰이는 컬럼이 있는가"를 설명할 문서(본 ADR + A11 설계서)가 필요하다.
- 할인 종류별 분류(`refType`)를 운영 전에 미리 합의해 둘 필요가 있다(PART 2에서 확정).
