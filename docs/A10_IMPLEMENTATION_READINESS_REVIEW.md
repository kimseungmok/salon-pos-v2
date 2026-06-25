# A-10 Implementation Readiness Review

> 코드 수정 없음, 구현 없음 — 설계 검토 문서만 작성. 모든 판단은 실제 코드/문서를 읽은 결과에 근거하며, 추측한 내용은 그렇게 명시한다.
> 작성일: 2026-06-25

---

## 1. 분석 대상 파일 목록 (실제 읽은 파일만)

**테이블 정의**: `lib/features/session/data/session_tables.dart`, `lib/db/app_database.dart`, `lib/features/staff/data/staff_tables.dart`, `lib/features/booking/data/booking_tables.dart`, `lib/features/payment_pos/data/payment_tables.dart`, `lib/features/inventory/data/inventory_tables.dart`, `lib/features/customer/data/customer_tables.dart`, `lib/features/product/data/product_tables.dart`, `lib/features/prepaid_pass/data/prepaid_pass_tables.dart`, `lib/features/marketing/data/marketing_tables.dart`, `lib/features/cash_management/data/cash_tables.dart`

**Repository**: `lib/features/session/data/session_repository.dart`, `lib/features/payment_pos/data/payment_repository.dart`, `lib/features/staff/data/staff_repository.dart`, `lib/features/booking/data/booking_repository.dart`

**기존 설계 문서**: `docs/A8_SESSION_ENGINE.md`, `docs/A9_ID_UNIFICATION.md`, `docs/ID_CONVENTION.md`, `design/spec/v3/00_overview.md`, `design/spec/v3/IMPLEMENTATION_PLAN.md`

**추가 검증**(읍 grep, 추측 방지용): `grep -rl "pricing_rule\|PricingRule\|rule_type\|ruleType" lib/ docs/ design/` → **0건**. `grep -rl "Pricing\|Promotion\|Settlement\|Staff Earning" design/spec/v3/*.md docs/*.md` → **0건**. 즉 **"Pricing/Promotion/Settlement/Staff Earning Engine"이라는 명칭과 "pricing_rule/rule_type" 설계는 본 A-10 작업 지시서가 처음 도입한 개념이며, 코드베이스/기존 문서 어디에도 선행 설계가 존재하지 않는다.** 이는 검토4에서 "기존 설계와 비교"가 아니라 "백지 상태에서의 분류"로 다시 정의해야 함을 뜻한다 — 추측으로 채우지 않고 사실 그대로 기록한다.

---

## 2. 엔진 경계 분석

| 엔진 | 생성하는 데이터 | 소비하는 데이터 | 현재 코드에서의 책임 위치 |
|---|---|---|---|
| **Pricing Engine (A-10)** | (목표) `PaymentSessionItems.unitPrice`/`amount` | `Products.price`/`allowCustomPrice`, (목표) `pricing_rule`(미존재) | **없음.** `SessionRepository.addItem()`은 호출자가 넘긴 `unitPrice`를 그대로 신뢰하고 `amount = unitPrice * qty`만 계산한다(`session_repository.dart` 143~144행). 가격을 "산출"하는 로직 자체가 코드에 없다 — 화면이 가격을 입력해 넘기는 구조 |
| **Promotion Engine (A-11 예정)** | (구모듈) `Orders.discountAmount`/`pointsUsed`; (신모듈, 목표) `PaymentSessions.discountAmount` 또는 `itemType='discount'` 품목 | `Coupons`/`Campaigns`/`PointPolicies`, `Customers.points` | **구모듈에만 부분 존재.** `marketing_logic.dart`(`computeEarnedPoints()`, `applyCouponDiscount()`)가 `Orders` 기준으로 동작. **SESSION ENGINE 쪽은 완전히 비어있다** — `PaymentSessions.discountAmount` 필드는 있지만 이를 채우는 메서드가 `SessionRepository`에 하나도 없음(`_recomputeTotals()`는 기존 값을 읍기만 함, 143~206행 확인) |
| **Staff Earning Engine (A-12 예정)** | `StaffEarningLedgers` 행 | `PaymentSessionItems.amount`/`staffId` | **부분 자동화, 별도 엔진 아님.** `SessionRepository.addItem()` 161~172행에 인라인으로 박혀있다 — `itemType=='staff_fee' && staffId!=null`일 때만 `earningType:'staff_fee'`로 1건 자동 INSERT. `'service'/'commission'/'bonus'` earningType은 테이블 주석(`session_tables.dart` 85행)에 정의돼 있으나 **이를 생성하는 코드 경로는 코드베이스에 0건** |
| **Settlement Engine (A-13 예정)** | `PaymentSessions.status='closed'`/`endAt`, `PaymentMethodBreakdowns` | `PaymentSessions.finalAmount`, 결제수단별 입력값 | **이미 구현되어 있다(A-13이 "신규 구현"이 아님).** `SessionRepository.closeSession()`(213~266행)이 정산 검증(결제수단 합계==`finalAmount`)과 마감 처리를 전부 수행. **단, 구모듈에 병렬로 존재하는 `CashManagementRepository`(개점/폐점 시재 카운트, 매장 단위)와는 완전히 분리**되어 있어, "이 세션들의 현금 합계가 오늘 폐점 시재와 맞는지"를 연결할 방법이 없음 |

**구조적으로 가장 중요한 발견**: `payment_pos`(구, `Orders`/`Payments`)와 SESSION ENGINE(`PaymentSessions`/`PaymentSessionItems`)이 **완전히 분리된 두 개의 결제 파이프라인**으로 코드에 동시에 존재한다(상호 FK/참조 없음, `grep` 결과 서로를 import하지 않음). 4개 엔진을 SESSION ENGINE 위에 쌓아도, 구모듈 경로로 발생하는 매출은 그 엔진들의 눈에 보이지 않는다.

---

## 3. amount 필드 구조 권고

`PaymentSessions`의 실제 필드(코드 확인): `totalAmount`, `discountAmount`, `taxAmount`, `finalAmount` — **이미 4개 필드가 존재한다.** 질문에 제시된 "1단계/2단계/3단계" 선택지는 현재 코드 상태와 맞지 않는다(이미 그보다 많음) — 추측으로 끼워맞추지 않고 사실을 그대로 보고한다.

**Q1(total 하나로 충분한가) / Q2(subtotal·total·final 3단계) / Q3(total·final 2단계)에 대한 답**: 셋 다 "필드 개수"를 다시 설계할 필요는 없다. 실제 문제는 필드 개수가 아니라 **이미 있는 필드를 채우는 로직이 없다는 것**이다.

- `_recomputeTotals()`(`session_repository.dart` 193~206행) 공식: `finalAmount = totalAmount - discountAmount + taxAmount`. `discountAmount`/`taxAmount`를 설정하는 메서드가 없어 항상 0 — 즉 **`finalAmount`는 항상 `totalAmount`와 같다**(A-8 문서 §4가 이미 인지한 사실, 코드로 재확인됨).
- `closeSession()`(213~266행)은 정확히 `finalAmount`를 기준으로 결제수단 합계를 검증한다 — **A-13 관점에서는 이미 "가장 마지막 확정 금액"을 보고 있어 옳다.**
- **새로 발견한 위험**: 할인을 표현하는 경로가 **이미 두 가지**로 동시에 존재한다 — ① `PaymentSessionItems`에 `itemType='discount'`인 품목을 음수 `amount`로 추가(이 경우 `totalAmount`(품목 합계)에 자동 반영됨), ② 세션 레벨 `discountAmount` 필드를 직접 채움(품목 합계와 독립). A-11이 둘 중 하나만 쓸지, 둘 다 쓸지, 어떤 기준으로 나눌지 **코드에도 문서에도 결정된 바가 없다.**

**권고**: 필드를 늘리거나 줄이지 말고(이미 충분), **A-11 착수 전에 "할인은 어느 경로로만 들어가는가"를 먼저 결정**해야 한다. 이 결정 없이 A-11을 시작하면 같은 할인이 두 경로로 동시에 반영되거나(이중할인), 한쪽 경로로 넣은 할인이 다른 쪽 계산에서 누락되는 위험이 있다.

---

## 4. A-11~A-13 실행 순서 권고

**현재 제안 순서**: A-11 Promotion → A-12 Staff Earning → A-13 Settlement

### 코드 기준 의존성 분석
- `closeSession()`(Settlement)은 **이미 구현되어 있고**, `finalAmount`(Promotion의 결과물이 들어갈 자리)를 그대로 소비한다 — Settlement는 "맨 마지막에 만들 것"이 아니라 **이미 만들어진 채로 다른 두 엔진의 결과를 기다리고 있는 상태**다.
- Staff Earning의 유일한 기존 동작(`addItem()`의 자동 INSERT)은 **품목이 추가되는 즉시** 발생한다 — Promotion이 나중에 세션/품목 금액을 변경해도 **이미 적힌 `StaffEarningLedger` 행은 재계산되지 않는다**(그런 메커니즘이 코드에 없음, `useAmountBalance`류의 되돌림 패턴과 달리 Earning Ledger를 되돌리는 메서드 자체가 없음). 즉 **Staff Earning이 Promotion보다 시간적으로 먼저 발생하는 현재 구조 자체가, Promotion이 나중에 도입되면 정합성 문제를 만든다.**

### 결론: 제안된 순서(Promotion→Staff Earning→Settlement)는 데이터 의존성 방향과는 맞지만, **"순서"만으로는 위 위험을 해결하지 못한다.**

**더 나은 순서/접근**: 순서 자체는 유지하되, **A-11(Promotion) 범위에 다음을 반드시 포함**해야 한다 — ① §3에서 식별한 할인 경로 단일화 결정, ② **Staff Earning Ledger 기록 시점을 "품목 추가 즉시"에서 "세션 마감(closeSession) 직전"으로 옮길지 여부 결정**(옮기지 않으면 할인 적용 후 직원 수익이 틀어지는 문제가 A-12를 아무리 잘 만들어도 해소되지 않음). 이 결정이 A-11 범위에 포함돼야, A-12(Staff Earning)가 "이미 정해진 올바른 시점"을 기준으로 만들어질 수 있다. A-13(Settlement)은 **신규 구현이 아니라, A-11/A-12가 끝난 뒤 `closeSession()`이 이 둘의 최종 결과(확정된 discountAmount, 확정된 earning ledger)를 올바르게 반영하는지 재검증하는 단계**로 범위를 재정의하는 것을 권고한다.

---

## 5. 누락된 가격 정책 분류표

> 전제: §1에서 확인했듯 `pricing_rule`/`rule_type` 자체가 코드에 없으므로, "현재 설계와 비교"가 아니라 **현재 SESSION ENGINE이 제공하는 우회수단(수동 입력, `itemType` 범용 분류) 유무를 기준으로 분류**했다.

| 항목 | 분류 | 근거 |
|---|---|---|
| 주말 요금 | **나중에 추가** | 고정가로도 운영 가능(차등을 안 줄 뿐), `addItem()`이 매번 수동 `unitPrice`를 받아 우회 가능 |
| 공휴일 요금 | **나중에 추가** | 동일 근거 |
| 회원 등급 요금 | **나중에 추가** | `Customers` 테이블에 등급 개념 자체가 없어(필드 없음) 더 근본적인 선행 설계가 필요 — A-10 범위를 벗어남 |
| 룸/좌석별 요금 | **나중에 추가(우선순위 상)** | `PaymentSessions.roomId`가 이미 존재(nullable int, 현재 미사용)해 향후 연결 여지는 마련돼 있으나, 그 룸에 연결된 요금표는 없음 — `addItem()` 수동입력으로 당장 운영은 가능하나, 카라오케 업종에서는 8개 항목 중 체감 우선순위가 가장 높음 |
| 지점별 요금 | **나중에 추가(우선순위 하)** | `PaymentSessions.shopId`가 이미 존재(기본값 1, 강제 미사용) — 프로젝트 전체가 단일매장 전제(이전 세션 기록 기준)라 당장 필요성 낮음 |
| 인원 추가 요금(카라오케) | **나중에 추가** | `itemType='surcharge'`가 이미 범용 메커니즘으로 존재 — "인원추가" 품목을 수동으로 추가하면 오늘 당장도 가능 |
| 음료 무제한 옵션(카라오케) | **나중에 추가** | `itemType='product'`/`'service'`로 고정가 품목 추가가 이미 가능 — 별도 "옵션" 개념 없이도 운영 가능 |
| 쿠폰/포인트 할인 | **POS 엔진 필수** | 구모듈(`marketing`, 19번 화면 ✅ 구현됨)에서 **이미 실사용 중인 기능**이다 — SESSION ENGINE으로 전환하면서 이 기능이 빠지면 기존에 되던 운영이 안 되는 회귀(regression)가 발생한다. "나중에 추가 가능한 기능"이 아니라 "이미 있던 기능을 이어받아야 하는 항목" |

---

## 6. 설계 리스크 (HIGH/MEDIUM/LOW)

### HIGH
1. **`staffId` 타입 불일치**: `PaymentSessions.staffIdPrimary`, `PaymentSessionItems.staffId`, `StaffEarningLedgers.staffId`가 전부 `TextColumn`이다(`session_tables.dart` 32/69/83행). 그러나 A-9 이후 실제 `Staff.id`는 `IntColumn`이다(`staff_tables.dart` 10행). 두 시스템이 서로 참조하지 않아 지금은 컴파일/실행에 문제가 없지만, **A-12(Staff Earning)가 실제 `Staff` 테이블과 연결을 시도하는 순간(예: 직원 이름 조회, 퇴사 검증) 즉시 타입 불일치로 막힌다.**
2. **Staff Earning Ledger의 기록 시점과 할인 적용 시점의 충돌**: `addItem()` 즉시 기록되는 ledger 금액이, 이후 Promotion이 세션 금액을 깎아도 재계산되지 않는다(§4에서 상세). 돈과 직결된 정합성 문제라 HIGH로 분류.
3. **할인 표현 경로 이중화**: 품목레벨(`itemType='discount'`) vs 세션레벨(`discountAmount` 필드)가 동시에 존재하고 우선순위/배타관계가 정의돼 있지 않다(§3). A-11 착수 전 미결정 시 이중할인 위험.

### MEDIUM
4. **신/구 결제 파이프라인 완전 분리**: `Orders`/`Payments`(구)와 `PaymentSessions`/`PaymentSessionItems`(신)가 서로 참조하지 않는다 — `sales_report` 모듈은 구모듈만 집계하므로 SESSION ENGINE 매출이 매출 리포트에 보이지 않는다(코드 확인: `payment_repository.dart`와 `session_repository.dart`가 서로 import하지 않음).
5. **`pricing_rule` 백지 상태**: A-10이라는 이름이 이미 부여돼 있지만 그 기반이 될 테이블/로직이 전혀 없다(§1). 설계 결함이 아니라 "아직 시작 전" 상태이지만, 이번 리뷰가 전제한 "기존 설계와 비교"라는 틀 자체가 성립하지 않는다는 점을 인지해야 한다.
6. **문서 staleness**: `docs/A8_SESSION_ENGINE.md` §6의 "`staff_id_primary`는 기존 `Staff.id`(UUID)와 같은 타입"이라는 서술이 A-9(Staff.id를 INTEGER로 변경) 이후 더 이상 사실이 아니다 — 문서가 코드 변경을 따라가지 못한 사례.

### LOW
7. `roomId`/`shopId` 필드가 이미 있지만 미사용 — 당장 위험은 아니나 룸/지점별 요금 도입 시 의미를 재확인해야 함.
8. `session_no` 동시성(TOCTOU) — A-8 문서가 이미 인지하고 후속과제로 명시한 기존 리스크(재확인만, 신규 발견 아님).

---

## 7. A-10 진행 전 반드시 결정해야 할 사항

1. **`staffId` 계열 컬럼의 타입 정합성을 언제 맞출지** — A-10/A-11 착수 전인지, A-12에서 실제로 `Staff` 테이블 연결이 필요해지는 시점인지 결정 필요(§6 HIGH-1).
2. **`StaffEarningLedger` 기록 시점을 "품목추가 즉시"로 유지할지, "세션마감 직전"으로 옮길지** — A-11 범위에 포함해 결정(§4, §6 HIGH-2).
3. **할인 표현 경로(품목레벨 vs 세션레벨)를 단일화하거나, 둘의 관계(배타/병행)를 명시적으로 정의** — A-11 착수의 선행조건(§3, §6 HIGH-3).
4. **신/구 결제 파이프라인을 통합할지, 영구 분리 상태로 둘지** — 적어도 `sales_report`가 SESSION ENGINE 매출을 누락하고 있다는 사실은 지금 결정하지 않더라도 인지하고 넘어가야 함(§6 MEDIUM-4).
5. **`pricing_rule`의 최소 스펙(허용되는 `rule_type` 목록)을 A-10에서 처음부터 새로 정의** — 참고할 기존 설계가 없다는 사실을 전제로 시작해야 함(§1, §6 MEDIUM-5).
