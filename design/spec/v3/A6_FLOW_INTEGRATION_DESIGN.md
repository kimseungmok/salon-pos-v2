# A-6 — Booking → Payment → Visit 통합 흐름 검증 설계

> **기준 문서**: `A1_A2_BOUNDARY.md`, `A1_PREFLIGHT_REVIEW.md`, `A3_PREFLIGHT_REVIEW.md`, `A4_A5_PAYMENT_FLOW_VERIFICATION.md`, `STAFF_ACCOUNT_STATUS_SPEC.md`, `A5_PREFLIGHT_REVIEW_FINAL.md`
> **시점**: A-1~A-5 전부 구현 완료. 본 문서는 흩어져 있던 결정들을 **실제 코드(`lib/features/{booking,payment_pos,staff,customer,inventory}/data/*.dart`)를 다시 추적**해 하나의 트랜잭션 모델로 통합한다.
> **목표**: "POS 엔진 내부 상태 흐름을 하나의 일관된 트랜잭션 모델로 정리"
> **범위 제한**: 설계 문서만 작성. 코드/SQL 생성·수정, 테이블/컬럼 변경 없음.
> 작성일: 2026-06-25

---

## 1. Booking → Payment → Visit 전체 상태 전이 검증 — 정확한 트리거 시점 재정리

세 테이블의 상태 전이를 실제 호출 경로 기준으로 다시 그린다.

```
Booking.status:  'confirmed' ──createBooking()──> (시작)
                 'confirmed' ──completeBooking()──> 'completed'   [A-2, 구현됨]
                 'confirmed' ──cancelBooking()──> 'cancelled'|'noshow'
                 'confirmed' ──updateBooking()──> 'confirmed'(필드만 갱신)

Order.status:    'pending' ──createOrder()──> (시작)
                 'pending'/'partially_paid' ──pay()──> 'partially_paid'|'completed'
                 (모든 상태) ──cancelOrder()──> 'cancelled'

VisitRecord:     (행 자체가 없음) ──pay() 내부, newStatus=='completed' 분기──> INSERT 1건  [A-1]
```

**가장 중요한 사실 확인(코드 추적 결과)**: `completeBooking()`을 실제로 호출하는 코드는 `lib/` 전체에 **0건**이다(`grep` 재확인 — 정의부만 존재, `payment_repository.dart`에는 "왜 연동하지 않았는지"를 설명하는 주석만 있을 뿐 실제 호출이 없음). `recordVisit()`을 호출하는 코드는 **정확히 1곳**, `payment_repository.dart:194`(`pay()` 내부)뿐이다.

**따라서 정확한 트리거 시점은 다음과 같이 정리된다**:

| 단계 | 정확한 트리거 | 비고 |
|---|---|---|
| 방문확정(`VisitRecord` 생성) | `PaymentRepository.pay()`에서 `Order.status`가 처음으로 `'completed'`가 되는 순간(§2) | **유일한 트리거**, 워크인/예약 구분 없이 동일 |
| 예약완료(`Booking.status='completed'`) | `BookingRepository.completeBooking()`이 **외부에서 호출될 때** | 현재 호출자가 없어 **휴면 기능**(dormant capability) — 06/07 화면 또는 향후 연동 코드가 호출해야 비로소 동작 |

이 둘은 **서로 독립적으로 존재하는 두 개의 트리거**이며, A1_A2_BOUNDARY.md가 정한 원칙("`completeBooking()`은 bookingId가 전달된 경우에만 같은 트리거에서 부수 호출")은 **설계 의도일 뿐 아직 코드로 연결되지 않았다.** 본 절이 본 문서 전체의 출발점이다 — 이후 §3/§5의 "불일치 케이스"는 전부 이 미연결 상태에서 파생된다.

---

## 2. Payment 완료 시 Visit 생성 시점 검증 — 중복 생성 방지 규칙

`pay()`의 실제 로직을 다시 추적:

```
paidSoFar = 이미 완료된 Payment 합계
netTotal  = Order.totalAmount - Order.discountAmount
if (paidSoFar + amount > netTotal) throw BusinessRuleException  // 초과결제 차단
...
newStatus = (paidSoFar + amount >= netTotal) ? 'completed' : 'partially_paid'
...
if (newStatus == 'completed' && order.customerId != null) {
  recordVisit(...)  // ← 유일한 호출 지점
}
```

**중복 생성 방지가 성립하는 이유**: `Order`가 한 번 `'completed'`가 되면, `paidSoFar == netTotal`이 되어 그 이후의 **모든** `pay()` 호출은 `paidSoFar + amount(어떤 양수든) > netTotal`이 되어 무조건 `BusinessRuleException`으로 막힌다. 즉 **"완결 전환"이 일어날 수 있는 시점이 같은 주문에서 단 한 번뿐**이라는 사실이, 별도의 중복방지 플래그 없이도 `recordVisit()` 중복 호출을 구조적으로 차단한다.

**검증 결론**: 이 규칙은 코드 추가 없이 이미 성립해 있다 — A-1 구현 시점에 의도된 설계가 그대로 유효함을 재확인.

---

## 3. 예약 상태와 방문 상태의 불일치 케이스 정의

§1에서 확인한 "두 트리거의 미연결"을 전제로, 실제로 발생 가능한 불일치를 전부 나열한다.

| # | 케이스 | 발생 가능 여부 | 원인 |
|---|---|---|---|
| 1 | **예약 완료(`Booking.status='completed'`)인데 그 예약에 대응하는 `VisitRecord`가 없음** | **항상 발생한다(현재 시스템의 기본 동작)** | §1에서 확인했듯 `completeBooking()`은 `recordVisit()`을 절대 호출하지 않음. 06/07 화면이 없어 이 메서드를 호출할 곳 자체가 없으므로, 지금 이 메서드를 호출해도 방문기록은 따로 안 남음 |
| 2 | **`VisitRecord`가 있는데 그 방문에 대응하는 결제(`Payment`)가 없음** | **불가능(설계상 발생할 수 없음)** | `VisitRecord`는 오직 `pay()`의 결제완결 분기 안에서만 생성되므로, 그 존재 자체가 "결제가 완료됐다"는 사실의 증거다 |
| 3 | **`Booking`이 `'confirmed'`로 영원히 남아있는데, 실제로는 결제(별도 워크인성 `Order`)가 끝나 방문은 이미 확정됨** | **발생 가능** | `Booking`과 `Order` 사이에 FK가 없어(`A1_PREFLIGHT_REVIEW.md` §3에서 이미 확인), 직원이 예약 내용을 보고 02번 화면에서 별개의 `Order`로 결제하면 예약은 그 사실을 알 방법이 없음 |
| 4 | **결제완료 흔적 자체가 없는 방문(0원 주문)** | **발생 가능** | `pay()`는 `amount<=0`을 거부해, `netTotal=0`인 주문은 `'pending'`에 영원히 머무름(`A1_PREFLIGHT_REVIEW.md` §4에서 이미 식별, 아직 미결정) |
| 5 | **워크인 결제가 끝났는데 `customerId`가 끝까지 null이라 `VisitRecord` 자체가 안 생김** | **발생 가능(설계상 허용된 한계)** | `recordVisit()`은 `customerId` 필수라 익명 결제는 방문 통계에서 원천적으로 빠짐 |

**가장 우선순위가 높은 불일치는 #1이다** — 다른 4개는 전부 "예외적 시나리오"인데, #1은 **시스템이 정상적으로 동작할 때도 항상 일어나는 기본 상태**이기 때문이다.

---

## 4. 직원 상태(퇴사/활성)가 흐름 중간에 바뀌는 경우 처리 정의

A-4 구현(`StaffRepository.assertNotRetired()`, `BookingRepository`의 신규배정 시점 검증)이 실제로 이 요구사항을 어떻게 충족하는지 재확인한다.

- **검증이 일어나는 지점은 정확히 2곳뿐**: `createBooking()`(`staffId != null`이면 항상), `updateBooking()`(`staffId`가 기존값과 실제로 다를 때만, `isStaffChanging` 분기).
- **검증이 일어나지 않는 지점**: `pay()`/`recordVisit()`/`cancelBooking()`/`completeBooking()`/`watchBookings()` — 전부 "이미 정해진 과거 사실을 처리"하는 단계이므로 의도적으로 검증을 넣지 않음.
- **"이미 완료된 거래에는 영향 금지"가 데이터 레벨로 보장되는 이유**: `removeStaff()`(상태 전환)는 `Staff` 테이블의 해당 행 **하나만** 갱신하고, `Booking.staffId`/`OrderItem.staffId`/`VisitRecord.staffId`/`InventoryLog.staffId`에 어떤 연쇄 갱신(cascade update)도 일으키지 않는다(코드에 그런 갱신문 자체가 없음) — "영향을 주지 않는다"는 것이 검증으로 막는 것이 아니라, **애초에 그런 갱신 코드가 존재하지 않는다는 사실**로 보장된다.

### 신규 발견 — `removeStaff()`의 멱등성 결함(§6과 직결)
`removeStaff()`의 분기 조건을 다시 보면:

```
if (staff.accountStatus == '連結済み') { 상태전환 } else { 하드삭제 }
```

**이미 `'退職済み'`로 전환된 직원에게 `removeStaff()`를 다시 호출하면, `accountStatus`가 `'連結済み'`가 아니므로 `else` 분기로 빠져 하드 삭제된다.** 이는 §4의 "이미 완료된 거래에는 영향 금지" 원칙을 깨뜨릴 수 있는 잠재 결함이다 — 퇴사 처리된 직원을 실수로 한 번 더 "삭제" 처리하면, A-4가 보존하려던 이력 참조용 `Staff` 행이 그 순간 사라져 `Booking`/`VisitRecord` 등의 고아참조 문제가 재발한다. **본 문서가 새로 발견한 이슈이며, §6(idempotency)에서 정식으로 다룬다.**

---

## 5. 재고 차감 시점 정의(아직 실제 연결 없음)

`A4_A5_PAYMENT_FLOW_VERIFICATION.md`/`A5_PREFLIGHT_REVIEW_FINAL.md`의 결론을 본 통합 설계에서 최종 확정한다.

**확정**: **Payment 기준이다.** "Visit 기준인지 Payment 기준인지"라는 질문 자체가 §1에서 이미 정리했듯 **둘은 같은 지점**이다(`VisitRecord` 생성 = `pay()`의 완결 분기). 재고차감이 생긴다면 같은 분기 안에 들어가야 하며, `Booking.completeBooking()` 시점에 연동하면 §3-#3과 같은 종류의 "결제 전에 재고가 먼저 빠지는" 시간차 불일치가 새로 생긴다.

**여전히 실행 불가능한 이유(재확인)**: `OrderItem.productId` → `InventoryItem.id` 매핑이 데이터에 없다. "기준 시점"은 확정됐지만 "무엇을 차감할지"를 알 방법이 없어, A-6 범위에서도 실제 연동은 보류한다 — 이 결정은 A-6+(매핑 엔티티 추가) 이후로 명시적으로 분리된 채로 유지된다.

---

## 6. 모든 흐름에서 재실행(idempotency) 기준 정의

각 진입점을 "두 번 호출했을 때 결과가 같은가"로 점검한다.

| 메서드 | 멱등성 | 보장 방식 |
|---|---|---|
| `pay()` | ✅ 안전 | §2에서 확인 — 완결 후 재호출은 초과결제 차단으로 항상 실패, `recordVisit()` 중복 없음 |
| `completeBooking()` | ✅ 안전 | 이미 `'completed'`면 `BusinessRuleException`으로 명시적 차단(기존 구현) |
| `cancelBooking()` | ✅ 안전 | 이미 `'cancelled'`/`'noshow'`면 명시적 차단(기존 구현) |
| `updateBooking()` | ✅ 안전(다른 의미로) | 상태전이가 아니라 필드 갱신이라 "재실행"의 의미가 다름 — 같은 값으로 두 번 호출해도 결과가 같음(자연 멱등) |
| `deleteItem()` | ✅ 안전 | 이력 있는 품목은 매번 동일하게 거부, 이력 없는 품목은 1회 성공 후 2회차는 `NotFoundException`(자연스러운 종결 상태) |
| **`removeStaff()`** | **❌ 위험 — §4에서 발견한 결함** | **2회 연속 호출 시 1회차(전환)와 2회차(하드삭제)의 결과가 다름.** 이는 "재실행해도 안전"이라는 멱등성 정의를 위반한다 |
| `adjustQuantity()` | ⚠️ 의도적으로 비멱등 | 재고변동은 "사건의 누적"이라 같은 호출을 두 번 하면 의도적으로 두 번 반영되어야 정상(예: 5개 사용 후 5개 더 사용) — 단, 네트워크 재시도 등 "의도하지 않은 중복 호출"을 구분할 멱등키가 없다는 점은 별도 한계로 인지(A-6+ 과제, `A5_PREFLIGHT_REVIEW_FINAL.md` §2와 동일 계열 문제) |

**기준 정의(결론)**: 본 시스템의 멱등성 원칙은 **"상태 전이 메서드는 같은 입력으로 두 번 불러도 두 번째는 명시적 예외로 실패해야 한다"**이며, `removeStaff()`만 이 원칙에서 벗어나 있다. 이는 코드 수정 없이 본 설계 문서로 **결함으로 등록**하고, 다음 구현 사이클에서 수정 대상으로 지정한다(본 문서는 코드 수정 금지 범위이므로 수정하지 않고 식별만 한다).

---

## 종합 — 하나의 트랜잭션 모델

```
[예약경로]                                [워크인/일반결제 경로]
Booking(confirmed)                        (예약 없음)
   │                                            │
   │  (수동, 화면에서 별도 Order 생성 — FK 없음)      │
   ▼                                            ▼
Order(pending) ──createOrder()──┐    Order(pending) ──createOrder()──┐
                                 │                                    │
                                 ▼                                    ▼
                          pay() 1회 이상 호출 ──(완결시 1회만)──> VisitRecord 생성
                                 │
                                 ▼
                    Order.status = 'completed'  ← 단일 신뢰 지점

[예약완료 처리 — 독립적, 현재 미연결]
Booking.completeBooking() ──(호출자 없음, 휴면)──> Booking.status = 'completed'

[직원 상태 — 위 흐름과 분리]
Staff.removeStaff() ──(連結済み만)──> '退職済み' (신규배정만 차단, 과거기록 비침범)
                     ──(그 외, 결함)──> 하드삭제 (§4/§6 결함)

[재고 — 위 흐름과 완전 분리, F-INV-00]
InventoryRepository (Product/Order/Payment를 참조하지 않음)
```

**책임 경계 요약**:
- **방문확정의 단일 권한자**: `PaymentRepository`(트리거), `CustomerRepository`(저장)
- **예약상태의 단일 권한자**: `BookingRepository`(자기 완결형, 외부와 미연동)
- **직원상태의 단일 권한자**: `StaffRepository`(신규배정 검증만 외부 노출, 그 외 모듈은 조회만)
- **재고의 단일 권한자**: `InventoryRepository`(완전 독립, 외부 권한자 없음)

이 네 권한자는 서로 **쓰기 권한을 침범하지 않으며**, 유일하게 모듈을 가로지르는 쓰기는 `PaymentRepository.pay()`가 `CustomerRepository.recordVisit()`을 호출하는 한 곳뿐이다 — 이것이 본 시스템 전체에서 "하나의 일관된 트랜잭션 모델"이라 부를 수 있는 유일한 교차점이다.

---

## 검증 항목 결과

| 검증 항목 | 결과 |
|---|---|
| Booking → Payment → Visit 흐름 충돌 없음 | **부분 충족** — 충돌은 없으나(§1) 연결이 없어 §3-#1 불일치가 상시 발생 |
| 중복 호출에도 데이터 안정성 유지 | **대부분 충족** — `removeStaff()` 1건 결함 발견(§4/§6) |
| 직원 상태 변경이 과거 데이터에 영향 없음 | **충족** — 연쇄갱신 코드 자체가 없음을 코드 추적으로 확인 |
| 재고/결제/예약 간 책임 경계 명확화 | **충족** — 종합 다이어그램의 4개 권한자로 명확히 분리됨, 유일한 교차점(`pay()`→`recordVisit()`)도 단일 지점 |

## 발견된 결함(코드 수정 없이 등록만)
- **`removeStaff()`의 비멱등성**: `'退職済み'` 상태에 대해 2차 호출 시 하드 삭제로 빠지는 분기 결함. 다음 구현 사이클에서 `if (accountStatus == '連結済み')`를 `if (accountStatus != null && accountStatus != '待機中' && accountStatus != '退職済み')`(또는 이미 `'退職済み'`인 경우 멱등하게 아무 동작도 하지 않는 분기 추가)로 수정 필요 — 본 문서는 수정하지 않고 식별만 한다.
