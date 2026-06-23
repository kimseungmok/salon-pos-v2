# salon-pos-v2 — 구현 계획서 (Implementation Plan)

> v3 정의서(10개 영역, 30개 문서 + `CROSS_VALIDATION.md`)가 "무엇을 만들지"를 확정했다면, 이 문서는 **"어떤 순서로, 어떤 구조로, 무엇부터" 만들지**를 정의한다. 코드를 쓰기 전 마지막 단계.
> 작성일: 2026-06-23

---

## 1. 기술 스택 (확정 — README.md 기준 승계)

| 항목 | 선택 | 비고 |
|---|---|---|
| 프레임워크 | Flutter (Dart), iOS 12+ | 전부 무료 오픈소스만 사용, 유료 라이브러리 금지 |
| 상태관리 | Riverpod | |
| 로컬 DB | SQLite + Drift ORM | **오프라인 우선** — 인터넷 끊겨도 POS는 동작해야 함 |
| 라우팅 | go_router | |
| 타겟 기기 | iPad Air 2 (2014), iPadOS 16, 2048×1536 | 모크업 기준 1024×768 논리 포인트(4:3) |
| 차트 | fl_chart | 売上レポート(F-SALES-02) 보너스 영역용 |

### 폴더 구조

```
lib/
  core/                  공통 유틸(날짜 포맷, ¥ 포맷, toPastel() 등 v3 정의서의 산출 로직)
  db/                    Drift 테이블 정의 + DAO
  features/
    customer/            F-CUST (09/10)
    prepaid_pass/         F-PP  (27/28, 신규)
    payment_pos/          F-PAY (02/03/04/05)
    cash_management/      F-CASH (22/23)
    booking/              F-BOOK (06/07/08)
    staff/                F-STAFF (11/12/13/33)
    product/              F-PROD (25/26)
    inventory/             F-INV (14/15, 독자기능)
    sales_report/          F-SALES (17)
    marketing/             F-MKT (19/20/21)
  shared_widgets/        공통 UI(파스텔 타일, 칩 선택기, PIN 게이트 등)
```

> `design/spec/v3/` 폴더명과 `lib/features/` 폴더명을 **1:1 동일하게** 맞춘다 — 정의서 찾아가기/코드 찾아가기가 항상 같은 이름이어야 헤맬 일이 없다.

---

## 2. 데이터베이스 스키마 도출 (v3 data_spec → Drift 테이블)

각 영역 `data_spec.md`의 "엔티티" 절을 그대로 Drift 테이블로 옮긴다. 매핑표:

| v3 엔티티 (data_spec.md) | Drift 테이블 | 비고 |
|---|---|---|
| Customer | `customers` | groupOf()는 **테이블 컬럼이 아니라 쿼리 시점 계산** — 저장하지 않음(F-CUST-01 주의사항 그대로) |
| VisitRecord | `visit_records` | |
| PrepaidPassMenu | `prepaid_pass_menus` | |
| PrepaidPassBalance | `prepaid_pass_balances` | |
| PrepaidPassTransaction | `prepaid_pass_transactions` | |
| Order / OrderItem | `orders` / `order_items` | |
| Payment | `payments` | `status`(completed/refunded) 컬럼 포함 |
| CashCount | `cash_counts` | |
| ClosingChecklistItem | `closing_checklist_items` | |
| Booking | `bookings` | |
| WaitingEntry | `waiting_entries` | |
| Staff / Shift | `staff` / `shifts` | |
| Category / Product / OptionGroup | `categories` / `products` / `option_groups` | |
| InventoryItem / InventoryLog | `inventory_items` / `inventory_logs` | F-INV-00: FK로 Product와 연결하지 않음 |
| Coupon / Campaign / PointPolicy | `coupons` / `campaigns` / `point_policy`(단일 row) | |

### 산출 로직(함수)의 구현 위치

각 `data_spec.md`의 "산출 로직" 코드 블록은 **순수 함수(pure function)**로 그대로 Dart에 옮긴다 — DB나 위젯에 의존하지 않게 작성해 단위 테스트가 쉬워야 한다.

| 산출 로직 | 위치 |
|---|---|
| `groupOf()` | `lib/features/customer/group_of.dart` |
| `computeChange()`, `applyCoupon()` | `lib/features/payment_pos/...` |
| `applyPrepaidPayment()`, `voidChargeTransaction()` | `lib/features/prepaid_pass/...` |
| `computeTotal()`(시재) | `lib/features/cash_management/...` |
| `computeEndAt()`, `staffAvailability()` | `lib/features/booking/...`(staffAvailability는 staff 모듈 함수를 import) |
| `cancelOrder()`, `refundPayment()` | `lib/features/payment_pos/...` |
| `cancelBooking()` | `lib/features/booking/...`(payment_pos의 refundPayment() import) |
| `computeEarnedPoints()`, `restorePoints()` | `lib/features/marketing/...` |

---

## 3. 의존성 그래프 (구현 순서 결정용)

`CROSS_VALIDATION.md`에서 확인된 영역 간 참조 관계를 그대로 의존성 순서로 사용한다 — **참조받는 쪽을 먼저 구현**.

```
product (Category/Product)          ← 가장 먼저(다른 모든 영역이 참조)
   ↓
staff (Staff/Shift)                  ← booking이 참조
   ↓
customer (Customer/groupOf)          ← booking, sales_report가 참조
   ↓
booking (Booking/WaitingEntry)       ← staff·customer·product 의존
   ↓
payment_pos (Order/Payment)          ← product·customer·prepaid_pass·marketing 의존
   ↓
prepaid_pass (신규)                   ← customer·payment_pos와 상호의존(F-PP-03↔F-PAY-02)
   ↓
marketing (Coupon/PointPolicy)       ← payment_pos가 호출
   ↓
cash_management                      ← payment_pos(현금매출 집계) 의존
   ↓
inventory                            ← 독립적(F-INV-00, 의존 없음 — 아무 때나 구현 가능)
   ↓
sales_report                         ← 거의 전 영역 집계(가장 마지막)
```

> `payment_pos`↔`prepaid_pass`는 상호참조(결제수단 그리드에 선불권 옵션 vs 선불권 사용이 결제 흐름 호출)이므로, 두 모듈의 **인터페이스(함수 시그니처)를 먼저 합의**하고 동시에 작업하거나, payment_pos의 결제수단 그리드를 먼저 틀만 잡고 prepaid_pass를 채우는 순서로 진행한다.

---

## 4. 구현 순서 / 마일스톤

| 단계 | 영역 | 목표 | 완료 기준 |
|---|---|---|---|
| M1 | product | 카테고리/상품 CRUD + 색상 고정 매핑 | 25 화면에서 상품 등록 → DB 저장 확인 |
| M2 | staff | 직원 목록/시프트 + 33 초대(모킹) | 11/13/33 화면 동작 |
| M3 | customer | 고객 CRUD + groupOf() 단위테스트 | 09/10 화면, 그룹 자동분류 정확성 검증 |
| M4 | booking | 예약 등록/캘린더/웨이팅 + F-BOOK-04 취소처리 | 06/07/08 화면, 담당자 가용여부 연동 |
| M5 | payment_pos | 주문→결제→완료→이력, F-PAY-04 분할결제 | 02/03/04/05 화면, 거스름돈/분할결제 정확성 |
| M6 | prepaid_pass | 27/28 신규 화면 + 결제수단 그리드 연동 | 생성→충전→사용 전체 플로우 동작 |
| M7 | marketing | 쿠폰/캠페인/포인트 정책 + 결제 연동 | 19/20/21 화면, 쿠폰 적용 시 결제금액 정확성 |
| M8 | cash_management | 22/23 시재관리 | 권종 카운트, 개점/폐점 차액 계산 |
| M9 | inventory | 14/15 재고관리(독립 기능) | 수량 조정 → 이력 자동기록 |
| M10 | sales_report | 17 매출 리포트(전 영역 집계) | F-SALES-01 핵심화면 + 보너스 영역 |

각 단계 종료 시 해당 영역의 `screen_spec.md` 화면을 **실제 Flutter 위젯 트리로 1:1 매칭**했는지 체크리스트로 확인(Zone 구조 누락 없이).

---

## 5. 테스트 전략

| 대상 | 방법 |
|---|---|
| 산출 로직(순수함수) | Dart unit test — `groupOf()`, `computeChange()`, `applyPrepaidPayment()` 등 `data_spec.md`의 모든 함수에 대해 표(F-xxx 규칙)에 명시된 경계값 케이스를 그대로 테스트 케이스로 사용 |
| 화면 | Flutter widget test — `screen_spec.md`의 Zone 구조를 기준으로 각 Zone이 올바른 위젯을 렌더링하는지 |
| 교차 영역 흐름 | 통합테스트 — 예약등록(F-BOOK-02)→결제(F-PAY)→취소(F-PAY-05/F-BOOK-04) 같은 여러 영역을 가로지르는 시나리오 |
| 일본 현지화 | 모든 화면의 텍스트 리소스를 일본어로만 채우고, 한국어 잔존 여부를 별도 린트/그렙 스크립트로 검사(`grep -P '[가-힣]'` 등) — `[[project_salon_pos_v2_principles]]` 원칙 준수 확인 |

---

## 6. 리스크 / 주의사항

| 리스크 | 대응 |
|---|---|
| `payment_pos`↔`prepaid_pass` 상호의존으로 인터페이스 불일치 위험 | M5/M6 착수 전 두 모듈의 함수 시그니처를 먼저 합의(본 문서 §3 참조), 변경 시 양쪽 `data_spec.md` 동시 갱신 |
| 오프라인 우선(SQLite) 정책과 알림톡/LINE 발송 같은 외부 연동의 충돌 | 알림 발송은 네트워크 가능 시에만 큐 처리, 오프라인 시 로컬에 pending 상태로 저장 후 재연결 시 발송(F-BOOK-02a, F-PP-01b 관련) |
| F-INV-00(재고는 product/payment와 미연동)을 구현 중 실수로 연결해버릴 위험 | 코드 리뷰 체크리스트에 "InventoryItem에 대한 FK가 Product/OrderItem에 추가되지 않았는지" 항목 추가 |
| 화면 정의서가 실제 구현과 어긋나는 드리프트 | 화면 구현 PR마다 해당 `screen_spec.md`를 함께 갱신(또는 변경 없음 확인) — 정의서를 "한번 쓰고 버리는 문서"로 만들지 않는다 |

---

## 7. 다음 액션

1. `lib/db/` Drift 스키마 파일 생성(§2 매핑표 기준)
2. M1(product) 착수
