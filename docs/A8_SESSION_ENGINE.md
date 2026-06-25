# A-8: SESSION ENGINE 설계 문서

> **목적**: 살롱/카라오케/이자카야 공통으로 동작하는 POS 엔진 코어 "세션(전표)" 레이어.
> **시점**: A-1~A-7(Staff/Booking/Payment/InventoryItem/InventoryLog/Visit 도메인) 완료 이후, 완전 리디자인(v2 POS) 1단계.
> **제약**: 기존 테이블/컬럼 수정 금지(신규 테이블만 추가), 기존 테스트 263건 회귀 없음, 금액은 int(엔/원 단위, 소수점 없음), `closed` 세션은 immutable.
> 작성일: 2026-06-25

---

## 1. 배경 및 기존 도메인과의 관계

A-1~A-7로 구축된 `Booking`/`Order`/`Payment`/`VisitRecord`/`InventoryItem`/`InventoryLog`/`Staff`는 **단일 살롱 업종**을 전제로 설계됐다(예: `Order`가 가게당 한 줄짜리 주문이라는 가정, `VisitRecord`가 1회 시술=1회 방문이라는 가정). 카라오케(룸 단위 시간과금)·이자카야(테이블 단위 다품목 합산) 같은 업종은 이 가정이 맞지 않는다.

A-8은 이 셋 모두에 공통으로 적용 가능한 **"세션(전표)"** 개념을 새 레이어로 도입한다. 기존 테이블은 건드리지 않고, **완전히 새로운 4개 테이블**만 추가한다 — 기존 도메인과는 FK로 강하게 묶지 않고, `ref_type`/`ref_id`로 느슨하게만 연결할 수 있는 자리를 마련해 둔다(예: 살롱에서 예약을 세션으로 전환할 때 `ref_type='booking'`, `ref_id=<Booking.id>`).

이는 `A6_FLOW_INTEGRATION_DESIGN.md`/`A7_FLOW_STABILITY_DESIGN.md`가 정립한 "권한자 분리" 원칙과도 일치한다 — `SessionRepository`는 새로운 독립된 권한자이며, 기존 4개 권한자(Payment/Booking/Staff/Inventory)의 쓰기 영역을 침범하지 않는다.

---

## 2. 테이블 설계

### `payment_session` — 전표 헤더
| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | INTEGER PK AUTOINCREMENT | (기존 모듈은 UUID TEXT, 본 엔진만 정수 — §6 참조) |
| session_no | TEXT UNIQUE | 사람이 보는 전표번호, `"연도-4자리순번"`(연도별로 0001부터 재시작) |
| shop_id | INTEGER, 기본 1 | 다지점 확장을 염두에 둔 자리(현재 단일매장 전제는 유지, 강제 사용 안 함) |
| business_type | TEXT | `'salon'｜'karaoke'｜'izakaya'` |
| customer_id | INTEGER, nullable | **비FK** — 기존 `Customers.id`는 UUID TEXT라 직접 연결 불가(§6) |
| staff_id_primary | TEXT, nullable | 기존 `Staff.id`(UUID)와 같은 타입, 비FK |
| room_id | INTEGER, nullable | 카라오케/이자카야의 룸·테이블(향후 엔티티, 현재는 단순 정수) |
| status | TEXT, 기본 `'open'` | `'open'｜'closed'｜'cancelled'` |
| start_at / end_at | DATETIME | 종료는 마감 시점에만 채워짐 |
| total_amount / discount_amount / tax_amount / final_amount | INTEGER | §4 계산식 참조 |
| created_at / updated_at | DATETIME | |

### `payment_session_item` — 전표 품목(라인)
`item_type`(`service`/`product`/`time`/`staff_fee`/`discount`/`surcharge`), `ref_type`/`ref_id`(과거 도메인 느슨한 참조), `item_name`(스냅샷, 원본이 바뀌어도 전표는 불변), `qty`/`unit_price`/`amount`, `staff_id`(수익 귀속), `meta_json`(야간할증 등 자유 메타).

### `staff_earning_ledger` — 직원 수익 원장
`item_type='staff_fee'`인 품목이 추가될 때 **자동으로** 1건씩 생성된다(§5). `earning_type`(`service`/`commission`/`staff_fee`/`bonus`)으로 수익 종류를 구분— 본 1차 구현은 `staff_fee`만 자동화하고, 나머지 종류는 향후 과제로 남긴다.

### `payment_method_breakdown` — 결제수단별 내역
마감(`closeSession`) 시점에만 생성되며, `method`(`cash`/`card`/`point`/`gift`/`transfer`)별 금액의 합이 반드시 `final_amount`와 일치해야 한다(§5, 검증 항목 8).

---

## 3. Dart 도메인 모델 — 별도 클래스를 만들지 않은 이유

기존 코드베이스(Booking/Order/Staff 등 전 모듈)는 **Drift가 생성하는 `XxxRow` 클래스를 그대로 도메인 모델로 사용**하며, 별도의 손으로 쓴 모델 레이어를 두지 않는다. A-8도 동일한 관례를 따른다:

- `PaymentSessionRow`, `PaymentSessionItemRow`, `StaffEarningLedgerRow`, `PaymentMethodBreakdownRow` — 요청된 필드 전부를 `@DataClassName`으로 그대로 생성(`session_tables.dart`).
- `SessionStatus` enum만 신규로 추가(`{ open, closed, cancelled }`) — 저장은 기존 관례(TEXT 컬럼+문자열 비교)를 따르되, 호출 측 타입 안전성을 위해 `.value`(문자열 변환)/`sessionStatusOf()`(역변환) 헬퍼를 둔다. 기존 모듈(Booking.status 등)이 순수 문자열 상수만 쓰는 것과는 다른 점이지만, 신규 모듈에 한정된 추가라 기존 코드에 영향이 없다.
- `getSessionSummary()`의 반환형으로만 `SessionSummary`(읍 read-only 합성 뷰, 테이블 아님)를 별도 클래스로 둔다 — 4개 테이블을 조합한 결과를 묶어 반환하기 위한 순수 데이터 홀더.

---

## 4. 금액 계산식

```
totalAmount = SUM(payment_session_item.amount) (해당 session_id 전체)
finalAmount = totalAmount - discountAmount + taxAmount
```

`discount`/`surcharge` 타입의 개별 품목은 이미 부호가 있는 금액(`amount`)으로 `totalAmount`에 합산된다. 세션 레벨 `discountAmount`/`taxAmount`는 전체에 거는 별도 조정값으로, 품목 합산과는 독립적으로 취급한다. 본 1차 구현(STEP3)에는 이 조정값을 설정하는 메서드가 없어 기본값 0이 유지되며, 그 결과 `finalAmount == totalAmount`가 된다 — 향후 "전체 N% 할인"/"소비세 자동계산" 같은 기능이 추가될 때 이 두 필드를 채우는 메서드를 별도로 추가하면 된다(본 설계가 미리 자리를 마련해 둠).

---

## 5. `SessionRepository` 동작 요약

| 메서드 | 핵심 동작 |
|---|---|
| `createSession()` | `business_type` 검증 → `session_no` 연도별 시퀀스 생성 → `status='open'`으로 INSERT |
| `addItem()` | `status=='open'` 가드 → 품목 INSERT → `item_type=='staff_fee' && staffId!=null`이면 `staff_earning_ledger` 자동 INSERT → `totalAmount`/`finalAmount` 재계산 |
| `closeSession()` | `status=='open'` 가드 → 결제수단 합계와 `finalAmount` 일치 검증 → `payment_method_breakdown` 일괄 INSERT → `status='closed'` 전환(이후 immutable) |
| `cancelSession()` | `status=='closed'`면 차단, `status=='cancelled'`면 **멱등(아무 동작 없이 반환)**, `status=='open'`이면 `'cancelled'`로 전환 |
| `getSessionSummary()` | session + items + earnings + payments 4종 조회를 묶어 반환 |

### 상태 전이 규칙 (STEP4 그대로)
```
open → closed     (closeSession)
open → cancelled  (cancelSession)
closed → (불변, 어떤 메서드도 상태를 바꾸지 않음)
cancelled → (불변, cancelSession 재호출은 멱등 no-op)
```

### 멱등성 — `A7_FLOW_STABILITY_DESIGN.md` 원칙의 신규 모듈 적용
A-7에서 확정한 시스템 표준("같은 요청을 반복해도 상태가 변하지 않아야 한다")을 그대로 적용했다. `cancelSession()`은 이미 `cancelled`인 세션에 재호출돼도 예외 없이 멱등하게 반환한다 — A-7이 `removeStaff()`에서 고친 것과 같은 종류의 결함을 신규 모듈에서는 처음부터 만들지 않기 위함이다.

---

## 6. 알아둘 점 / 향후 결정 필요 사항

- **id 타입 불일치(의도적)**: 본 엔진은 `INTEGER AUTOINCREMENT`를 쓰지만 기존 모듈(Customer/Staff/Booking 등)은 UUID `TEXT`를 쓴다. `customer_id`/`room_id`는 현재 **비FK 정수**로만 존재하며, 실제 `Customers`/`Staff` 테이블과 연결하는 방식(타입 변환 매핑 테이블을 만들지, 기존 테이블의 ID 체계를 바꿀지)은 본 1차 구현 범위 밖의 **별도 결정 사항**이다.
- **F-INV-00과 유사한 의도적 분리**: `SessionRepository`는 `InventoryRepository`/`PaymentRepository`/`BookingRepository`/`StaffRepository`를 import하지 않는다 — 기존 권한자의 쓰기 영역을 침범하지 않는다는 원칙(`A6_FLOW_INTEGRATION_DESIGN.md` 종합)을 신규 모듈에도 그대로 적용했다.
- **`staff_earning_ledger`의 `earning_type` 중 `'staff_fee'`만 자동화**: `'service'`/`'commission'`/`'bonus'`를 언제 어떻게 자동 기록할지는 향후 과제.
- **`session_no` 동시성**: 연도별 순번을 "현재 그 연도 행 개수+1"로 계산한다 — 단일 화면 순차 입력을 전제하며, 동시 생성 시 중복 가능성은 `A5_PREFLIGHT_REVIEW_FINAL.md`가 `adjustQuantity()`에서 식별한 것과 같은 종류의 TOCTOU 한계로 인지하되, 본 1차 구현 범위에서는 트랜잭션화하지 않았다(추후 과제로 명시).

---

## 7. 마이그레이션

`schemaVersion`을 1 → 2로 올리고, `onUpgrade`에서 `from < 2`일 때 4개 테이블을 `createTable()`로 추가하는 **순수 추가형 마이그레이션**만 작성했다(`lib/db/app_database.dart`). 기존 테이블에는 어떤 `ALTER`/`DROP`도 없다 — 기존 21개 테이블, 263건의 테스트가 전부 그대로 통과함을 확인했다(§8).

---

## 8. 완료 확인

- `flutter analyze`: 클린(이슈 0건)
- `flutter test`: **전체 280건 통과**(기존 263 + 신규 17건 — 요청된 8개 케이스를 모두 포함해 추가 케이스까지 커버)
- 기존 테이블/컬럼 수정: 없음(신규 테이블 4개 추가만)
- git commit + push: 완료(커밋 로그 참조)
