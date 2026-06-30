# A-11: Promotion Engine 구현 준비 — 최종 아키텍처 정리

> **목적**: A-11 구현 착수 전, Engine 간 공통 구조와 Rule Lifecycle을 확정한다. 본 문서는 설계/문서화 결과물이며 코드/DB 변경은 포함하지 않는다.
> **전제 문서**: `docs/A11_PROMOTION_ENGINE_DESIGN.md`(책임 경계/데이터 흐름), `docs/adr/ADR-002-discount-representation.md`, `docs/adr/ADR-003-financial-events.md`
> **이미 확정되어 재검토하지 않는 항목**: 할인 타입(`flat`/`rate`), `refType`(`coupon`/`membership`/`staff_manual`/`event`), Rule 저장 구조(`promotion_rule` 신규 테이블 + 독립 Repository), 할인 표현 방식(ADR-002), 구조 금지 사항(본 작업 지시문의 [확정된 설계 기준] 1~7 그대로 유지)
> 작성일: 2026-06-26

---

## PART 1 — Promotion Rule Lifecycle 설계

### 1-1. 저장 상태(3개) vs 논리 상태(4개) — "Lifecycle ≠ status 컬럼"

`promotion_rule.status` 컬럼에는 **`'draft' | 'active' | 'disabled'` 3개 값만 저장한다.** `Expired`는 별도 컬럼 값이 아니라, `status='active'`이면서 `endAt`이 현재 시각보다 과거인 경우를 가리키는 **계산된(derived) 논리 상태**다.

이렇게 나누는 이유:
- "자동 만료"를 구현하려면, `status` 컬럼 값을 실제로 `'expired'`로 바꿔주는 배치/크론 작업이 필요해진다. 이 앱은 오프라인 우선 SQLite 단일 인스턴스라 그런 백그라운드 작업 인프라가 없고, 만들 필요도 없다.
- 대신 "지금 이 Rule이 적용 가능한가?"를 **조회/계산 시점에 즉시 평가**하면 별도 배치가 전혀 필요 없다 — `status='active' AND now < endAt`인지를 그때그때 확인하면 그게 곧 "Expired가 아님"의 정의다.
- 이는 §3(Rule 조회 인터페이스)에서 `PricingEngine.isWithinPeakWindow()`가 이미 쓰던 것과 동일한 패턴이다(코드 상태가 아니라 "현재 시각과 Rule이 가진 시간 정보를 비교해서 즉석 판정").

지시문의 "Lifecycle을 Rule 상태로만 해석하지 말 것"이 정확히 이 지점이다 — Lifecycle은 **저장된 상태(3개) + 시간 기반 파생 판정(Expired)**의 합이며, 그 중 어느 것도 "이 Rule이 실제로 적용된 사례가 있는가"(이벤트 데이터, `PaymentSessionItem`)와는 무관하다.

### 1-2. 상태 전이도

```
                 activate()
        ┌──────────────────────────┐
        │                          ▼
[Draft] │                      [Active] ──(now ≥ endAt, 조회시점 판정)──▶ [Expired]
   │    │                          │                                        │
   │    └──(cancel before live)    │ deactivate()                  deactivate()│
   ▼                               ▼                                        ▼
[Disabled] ◀─────────────────────────────────────────────────────────────────┘
   (terminal — 모든 경로의 최종 도착지)
```

- `Draft → Active`: `activate()` 호출(명시적 승인 행위 — "만들자마자 바로 적용 가능"을 금지해 검수 단계를 강제).
- `Draft → Disabled`: 적용 전에 취소.
- `Active → Expired`: **상태 전이 메서드가 없다.** `endAt`이 지나면 조회 시점에 자동으로 "적용 불가"로 판정될 뿐, DB 행은 그대로 `status='active'`로 남아있다(§1-1).
- `Active/Expired → Disabled`: `deactivateRule()` 호출(수동 비활성, A-7 멱등성 원칙 그대로 — 이미 `Disabled`면 재호출해도 예외 없이 통과).
- `Disabled`는 **종착 상태**다 — 어디서도 되돌아오지 않는다(과거에 적용된 이벤트의 무결성을 위해, "다시 켜기"가 필요하면 새 `Draft` Rule을 만든다).

### 1-3. 상태별 정의

| 상태 | 생성 가능 | 수정 가능 | 삭제 가능 | 적용 가능 | 상태 전이 |
|---|---|---|---|---|---|
| **Draft** | ✅ (`addRule()`은 항상 `status='draft'`로 시작) | ✅ 전체 필드 자유 수정(아직 누구도 참조 안 함) | ✅ 하드 삭제 허용(적용 이력 없음 보장) | ❌ (`getRules(activeOnly: true)`에서 제외) | → Active(`activate()`) / → Disabled(취소) |
| **Active** | ❌ (Draft를 거치지 않은 직접 생성 금지) | ⚠️ 제한적 — `priority`/`endAt`(기간 연장)만 허용, `discountType`/`value`는 **금지**(이미 발생한 이벤트의 의미가 사후 변경되는 걸 막기 위함 — 이벤트는 적용 당시 스냅샷을 `itemName`에 보존하므로 Rule 자체가 바뀌어도 과거 이벤트는 안전하지만, "운영 중 Rule을 슬쩍 바꾸는" 행위 자체를 금지해 정책 투명성을 지킨다) | ❌ 하드 삭제 금지(이미 이벤트가 `refId`로 참조했을 수 있음) | ✅ (조건: `now < endAt` 또는 `endAt` null) | → Expired(시간 경과, 전이 메서드 없음) / → Disabled(수동) |
| **Expired** | ❌ | ❌ (전부 동결 — 과거 적용 이력의 근거가 되는 데이터이므로 어떤 필드도 바꾸지 않는다) | ❌ | ❌ | → Disabled(정리/아카이브 목적, 수동) |
| **Disabled** | ❌ | ❌ | ❌ | ❌ | (없음, 종착) |

### 1-4. 추가 정책

- **시작일/종료일 기반 자동 만료**: `startAt`/`endAt`은 `promotion_rule`의 컬럼(둘 다 nullable — null이면 "그 경계 없음"). "자동"의 의미는 §1-1대로 **조회 시점 즉시 판정**이며, 별도 배치 작업이 존재하지 않는다.
- **수동 비활성 처리 방식**: `PromotionRuleRepository.deactivateRule(id)` — `PricingRuleRepository.deactivateRule()`과 동일한 패턴(하드 삭제 대신 `status='disabled'`로 전환, 이미 `disabled`면 멱등하게 무동작).
- **기간 외 Rule 적용 금지 여부**: **금지한다.** 단, 이 판정을 어디서 하는지가 중요하다 — `PromotionRuleRepository.getRules()`는 SQL `WHERE`로 값싼 필터(`shopId`/`businessType`/`status='active'`)만 거르고, `startAt`/`endAt`과 "지금"을 비교하는 판정은 **`PromotionEngine`이 매칭 단계에서 수행**한다(§3에서 근거 설명, Peak Rule 처리와 동일한 선례).

---

## PART 2 — Engine 공통 구조 정리

### 2-1. `PricingRule` vs `PromotionRule`

| 항목 | PricingRule | PromotionRule | 공통화? |
|---|---|---|---|
| 공통 필드 | `id`/`shopId`/`businessType`/`priority`/`isActive` | `id`/`shopId`/`businessType`/`priority`/(`status`로 표현, `isActive`라는 단순 bool이 아님) | **공통화하지 않음** — `PromotionRule`은 3단계 상태(`draft`/`active`/`disabled`)가 필요해 단순 `bool isActive`로 표현 불가능. 억지로 같은 필드셋을 강제하면 `PricingRule`도 굳이 `status` enum으로 바꿔야 하는데 그럴 필요가 없다. |
| 계산방식 구분자 | `ruleType`(`time_base`/`peak`) | `discountType`(`flat`/`rate`) | **이름을 통일하지 않음** — 같은 "역할"(계산 분기)이지만 각 도메인의 용어를 그대로 쓰는 게 가독성이 좋다. `ruleType`이라는 이름을 `PromotionRule`에도 강제하면 오히려 "왜 할인인데 ruleType이라고 부르나"라는 혼란이 생긴다. |
| 시간 관련 필드 | `peakStartHour`/`peakEndHour`(시각의 시(hour), 0~23, 자정 넘김 가능) | `startAt`/`endAt`(절대 날짜시각, 자정 넘김 개념 없음) | **공통화하지 않음** — 전혀 다른 데이터 모양(hour-of-day 반복 패턴 vs 절대 기간)이라 같은 필드/로직으로 표현할 수 없다. |

**결론**: 두 POJO는 "Rule이라는 개념"을 공유할 뿐, 필드 구조는 의도적으로 다르다. 공통 인터페이스(`abstract class Rule`)를 추출하지 않는다 — 사례가 2개뿐이고, 공유할 수 있는 필드가 거의 없어 추상화의 이득이 비용(불필요한 계층)보다 작다(YAGNI).

### 2-2. `PricingRuleRepository` vs `PromotionRuleRepository`

| 항목 | 공통 패턴(코드는 공유 안 함, 관례만 공유) |
|---|---|
| Drift Row ↔ POJO 변환 책임 | 둘 다 Repository 내부의 private `_toDomain()`에서만 수행(ADR-001) |
| `shopId`+`businessType` 필터 | 둘 다 `getRules()`의 필수/기본 매개변수 |
| 명시적 `ORDER BY` | 둘 다 `priority ASC, id ASC`(§3에서 강제) |
| 활성 여부 필터 | `PricingRuleRepository`는 `isActive.equals(true)`, `PromotionRuleRepository`는 `status.equals('active')` — **다른 컬럼/다른 타입이지만 같은 역할** |
| 비활성화 멱등성 | 둘 다 `deactivateRule()`이 이미 비활성 상태면 무동작 |

**공통화 여부**: 패턴은 동일하지만, **공유 베이스 클래스(`abstract class RuleRepository<T>`)는 만들지 않는다.** 이유:
1. `getRules()`의 활성 필터 컬럼명/타입이 다르다(`isActive: bool` vs `status: String`) — 제네릭으로 묶으려면 추상 메서드가 생기고, 구현체 2개에 비해 추상화 코드량이 더 커진다.
2. 지금 시점에 "세 번째 사례"(A-12의 Rule 비슷한 것)가 아직 없다 — 사례가 2개일 때 추상화하면 그 추상화가 실제로 옳은 모양인지 검증할 수 없다(추상화는 보통 3번째 사례에서 패턴이 확실해진 뒤 추출하는 게 안전하다).
3. 일관성은 **문서**(본 문서 + ADR-001/003)로 강제한다 — 코드 추상화가 아니어도 "새 Repository를 만들 때 이 표를 보고 따라간다"는 규율로 충분하다.

### 2-3. `PricingEngine` vs `PromotionEngine`

| 항목 | 공통 패턴 |
|---|---|
| 입력 | `List<POJO>`(Drift 비의존) |
| 출력 | `int`(금액) 또는 `bool`(판정) |
| 부수효과 | 없음(순수 함수, `const` 생성자) |
| 매칭 로직 | "businessType+ruleType(or discountType)으로 후보를 거르고, priority가 가장 작은 것 1개를 선택" — `_bestRule()` 패턴 동일 |
| 시간 판정 위치 | Peak 시간대 판정(`isWithinPeakWindow`)과 Promotion 기간 판정(§1-4) 모두 **Engine 내부**에서 수행 — Repository가 아니라 |

**공통화 여부**: `_bestRule()` 매칭 로직(필터+정렬+첫 항목 선택)이 두 Engine에서 거의 동일한 모양이 될 가능성이 높다. 그럼에도 **지금은 공유 유틸로 추출하지 않는다** — 매칭 대상 필드명이 다르고(`ruleType` vs `discountType`), 강제로 함수 시그니처를 맞추려면 `String Function(T) classifier` 같은 콜백을 받는 제네릭 헬퍼가 필요해져 코드가 오히려 읽기 어려워진다. **두 Engine 파일에 비슷한 10줄짜리 private 메서드가 각각 있는 것이 지금 시점에는 옳다**(YAGNI — "세 줄의 비슷한 코드가 섣부른 추상화보다 낫다"는 판단을 여기서도 동일하게 적용).

---

## PART 3 — Rule 조회 인터페이스 설계

```dart
Future<List<PromotionRule>> getRules({
  required String businessType,
  int shopId = 1,
  String? discountType,      // 'flat' | 'rate' — null이면 둘 다
  bool activeOnly = true,    // status == 'active' 인 것만(컬럼 필터, 날짜 판정 아님)
}) async {
  final query = _db.select(_db.promotionRules)
    ..where((r) => r.shopId.equals(shopId))
    ..where((r) => r.businessType.equals(businessType));
  if (discountType != null) {
    query.where((r) => r.discountType.equals(discountType));
  }
  if (activeOnly) {
    query.where((r) => r.status.equals('active'));
  }
  query.orderBy([
    (r) => OrderingTerm.asc(r.priority),
    (r) => OrderingTerm.asc(r.id),
  ]); // ← A-10 M1 재발 방지: 반드시 명시적으로 작성한다
  final rows = await query.get();
  return rows.map(_toDomain).toList();
}
```

| 비교 기준 | 처리 위치 | 근거 |
|---|---|---|
| `shopId` | Repository(SQL `WHERE`) | `PricingRuleRepository`와 동일(§A-10 리뷰, 40개 지점 지원) |
| `businessType` | Repository(SQL `WHERE`) | 동일 |
| `discountType`(`ruleType`에 대응) | Repository(SQL `WHERE`, 선택적) | 동일 |
| `priority` 명시적 `ORDER BY` | **Repository, 반드시 명시** | **A-10에서 `ORDER BY` 누락으로 M1(우선순위 동률 시 행 순서가 우연에 의존) 이슈가 발생했던 이력 — 본 설계는 처음부터 `priority ASC, id ASC`를 코드에 명시해 동일 실수를 구조적으로 차단한다.** |
| 활성 여부(`status`) | Repository(SQL `WHERE`, `status='active'`만 — 리터럴 비교, 날짜 무관) | 값싼 컬럼 필터는 SQL로, 비싼/가변적 판정(시간)은 Engine으로 분리 |
| 적용 기간(`startAt`/`endAt`) | **Engine**(매칭 시점에 `now`와 비교) | Peak Rule 처리(§PART1-4, §A11 설계서)와 동일한 선례 — "여러 후보 Rule 중 지금 이 순간 유효한 것을 고르는" 작업은 계산(시간 입력 필요)이라 Engine의 몫 |
| 확장 가능성(요일/시간대/회원등급 등) | **Engine**(향후 Rule에 nullable 필드 추가 시 같은 방식으로 확장) | `peakStartHour`/`peakEndHour`가 이미 증명한 패턴 — Repository는 그대로 두고 Engine의 매칭 로직만 그 필드를 추가로 해석하면 됨. 회원등급처럼 "Rule이 아니라 호출 컨텍스트(고객 정보)에 의존하는" 조건은 `calcDiscount()`의 매개변수로 받아 Engine이 판정(Repository는 모르는 채로 유지) |

---

## PART 4 — Financial Event 원칙(ADR-003) 적용 검토

| 엔진 | Event 기반 구조 적용 여부 | 예외 존재 여부 | 예외 이유 / 책임 엔진 |
|---|---|---|---|
| **Pricing Engine**(A-10) | ✅ 적용됨 — 계산 결과는 항상 `addItem()`을 통해 `PaymentSessionItem` 행으로 기록, 헤더 컬럼 직접 갱신 없음 | 없음 | — |
| **Promotion Engine**(A-11) | ✅ 적용 예정 — ADR-002가 이미 이 원칙의 구체적 사례로 결정됨(`itemType='discount'`) | 없음 | — |
| **Staff Earning Engine**(A-12, future) | ✅ 적용됨(이미 존재) — `staff_earning_ledger`가 append-only 원장 | ⚠️ **있음** — `addItem()`이 `staff_fee` 품목 추가 **즉시** ledger 행을 1건 생성하는데, 이후 같은 세션에 할인이 추가돼도 그 ledger 행의 `amount`는 재계산되지 않는다. 이건 "이벤트 모델 자체를 어긴 예외"가 아니라 **"이벤트를 언제 확정할지(타이밍 정책)가 아직 결정되지 않은" 미해결 사항**이다(즉시 확정 vs `closeSession()` 시점에 최종 확정, 둘 다 이벤트 모델 안에서 가능한 선택지). | **책임 엔진: A-12.** Promotion Engine(A-11)은 이 타이밍을 결정하지 않는다 — `A11_PROMOTION_ENGINE_DESIGN.md` §1-4/§7에서 이미 "A-12가 정책을 정해야 한다"로 위임됨. |
| **Settlement Engine**(`closeSession()`, A-13) | ✅ 적용됨 — `PaymentMethodBreakdown` 행 생성(결제수단별 수령 기록)도 이벤트이며, 헤더의 `status`/`endAt`만 전이시키고 금액 자체는 새로 계산하지 않음(이미 이벤트들로부터 파생된 `finalAmount`를 그대로 검증) | 없음 | — |

**종합**: 4개 엔진 모두 ADR-003 원칙을 어기지 않는다. 유일한 "예외처럼 보이는" 지점(Staff Earning Ledger 타이밍)은 원칙 위반이 아니라 **아직 결정되지 않은 정책**이며, 그 결정의 책임은 명시적으로 A-12에 있다. Promotion Engine 구현이 이 문제를 해결하거나 회피하려 시도하지 않는다 — A-11은 자신의 책임(할인 이벤트 생성)만 정확히 수행하고, ledger staleness는 손대지 않은 채로 둔다.

---

## PART 5 — A-11 구현 준비 점검

### 구현 순서

1. `promotion_rule` 테이블 정의(`lib/features/promotion/data/promotion_rule_tables.dart`) — `id`/`shopId`/`businessType`/`discountType`/`value`/`priority`/`status`/`startAt`/`endAt`
2. `app_database.dart`에 테이블 등록, `schemaVersion` 증가, `onUpgrade`에 순수 추가형(`createTable`) 마이그레이션
3. `PromotionRule` POJO(`lib/features/promotion/domain/promotion_rule.dart`) — Drift 비의존
4. `PromotionRuleRepository`(`lib/features/promotion/data/promotion_rule_repository.dart`) — `addRule()`/`getRules()`(§PART3 시그니처)/`activate()`/`deactivateRule()`, `_toDomain()` 변환
5. `PromotionEngine`(`lib/features/promotion/logic/promotion_engine.dart`) — `calcDiscount()`(매칭 + flat/rate 분기 + 기간 판정), 내부 `_bestRule()`
6. `SessionRepository`에 선택적 헬퍼 추가(`calcSuggestedTimeFee()`와 동일한 패턴, **`addItem()` 본문은 무수정**) — 예: `calcSuggestedDiscount()`
7. `docs/A9_ID_UNIFICATION.md` 스타일을 따라 `session_tables.dart`의 `discountAmount` 컬럼 주석에 deprecated 명시(코드 변경이지만 주석뿐 — 영향 0)
8. 테스트 작성(§테스트 전략)
9. `flutter analyze` + 전체 테스트(317건 이상 유지) 확인

### 선행 조건(이미 충족됨)

- ADR-002(할인 표현 방식) 확정
- ADR-003(Financial Event 원칙) 확정
- `discountType`/`refType` 목록 확정
- Rule 저장 구조(옵션 B) 확정
- 본 문서의 Lifecycle/공통구조/조회 인터페이스 확정

### 후행 작업(A-11 구현 완료 후, A-11 범위 안에서 마무리할 것)

- `discountAmount` 컬럼 deprecated 주석 반영(위 순서 7)
- 영수증/리포트 화면이 `itemType='discount'` 품목을 어떻게 표시할지 확인(UI 영향 — 본 설계 문서는 다루지 않음, 화면 작업 시점에 별도 확인)

### 테스트 전략(A-10과 동일한 3계층 구조 재사용)

| 계층 | 파일 | 방식 |
|---|---|---|
| 순수 계산 | `test/features/promotion/promotion_engine_test.dart` | DB 없이 `PromotionRule`을 직접 생성해 `calcDiscount()` 단위테스트(flat/rate 계산, businessType 필터, priority 동률, 기간 외 판정, 매칭 규칙 없을 때 0) |
| Repository | (필요 시) `test/features/promotion/promotion_rule_repository_test.dart` | `AppDatabase.forTesting()` 기반 — `shopId` 격리, `activeOnly` 필터, `ORDER BY` 안정성(M1 재발 방지 검증), Lifecycle 전이(Draft→Active→Disabled) |
| 통합 | `test/features/session/session_repository_test.dart`에 그룹 추가 | `calcSuggestedDiscount()` → `addItem(itemType='discount')` 흐름, `_recomputeTotals()`가 음수 `amount`를 정확히 반영하는지 |

---

## PART 6 — A-11 구현 범위 확정(MVP)

### 포함 범위

- `promotion_rule` 테이블(1개), `PromotionRule` POJO, `PromotionRuleRepository`(CRUD+조회), `PromotionEngine`(`calcDiscount()` 1개 public 계산 메서드)
- Lifecycle 3상태(`draft`/`active`/`disabled`) + Expired 파생 판정
- `SessionRepository`에 선택적 헬�, 1개(`calcSuggestedDiscount()`류) — `addItem()` 연결만
- `discountAmount` 컬럼 deprecated 주석
- §테스트 전략의 최소 테스트 세트

### 제외 범위(A-11 자체에서도 구현하지 않음)

- **할인 중첩 적용 정책**(여러 Promotion이 동시에 매칭될 때 합산/한도/우선순위 외의 별도 규칙) — `A11_PROMOTION_ENGINE_DESIGN.md` §7에서 식별된 미결 사항, MVP는 "매칭되는 첫 Rule 1개만 적용"으로 단순화하고 중첩 정책은 후속 이슈로 남긴다.
- 회원등급/요일 등 §PART3에서 "확장 가능"이라고 표시한 필드의 실제 컬럼 추가(설계상 자리만 마련, 지금 만들지 않음 — YAGNI)
- 영수증/`sales_report` 화면의 할인 표시 로직 변경

### 후속(A-12/A-13) 이관 범위

- `staff_earning_ledger` 갱신 타이밍 정책(즉시 확정 vs 마감 시점 재계산) — **A-12 책임**(§PART4에서 재확인)
- 할인이 특정 `staff_fee` 품목을 타겟팅할 때의 참조 방식(`refType='session_item'` 등 신설 여부) — **A-12 책임**
- 마감(`closeSession()`) 시점에 할인 유효성을 재검증할지 여부 — **A-13 책임**

---

## 결론

본 문서로 A-11 구현에 필요한 마지막 설계 공백(Lifecycle, Repository 시그니처, Engine 간 구조적 일관성, Financial Event 원칙의 4개 엔진 적용 여부, MVP 경계)이 모두 채워졌다. 코드/DB 변경은 발생하지 않았으며, 다음 작업은 본 문서 §PART5 "구현 순서"를 그대로 따르는 A-11 구현 착수다.
