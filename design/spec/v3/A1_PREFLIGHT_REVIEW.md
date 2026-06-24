# A-1 구현 전 최종 점검 — recordVisit 연결

> **기준 문서**: `MVP_IMPACT_MAP.md` §A-1, `A1_A2_BOUNDARY.md`, `BUSINESS_RULES_TO_DECIDE.md` §1-1/§1-2/§2-2
> **목적**: A-1(`recordVisit()` 호출 연결) 착수 전, 실제 코드(`PaymentRepository`/`BookingRepository`/`CustomerRepository`)를 다시 확인해 영향범위와 미결정 사항을 좁힌다.
> **범위 제한**: 검토만 한다. 코드/SQL 생성·수정 없음.
> 작성일: 2026-06-23

---

## 1. `recordVisit` 현재 호출 위치

`grep` 기준 확인 결과:

| 위치 | 내용 |
|---|---|
| `lib/features/customer/data/customer_repository.dart:138` | `recordVisit()` 정의부(메서드 본체) — 변경 대상 아님 |
| `test/features/customer/customer_repository_test.dart` | 테스트에서 직접 호출(단위테스트 목적) |
| **그 외 `lib/` 전체** | **호출하는 코드가 없음** — `PaymentRepository`, `BookingRepository` 어디에서도 호출되지 않음(A-2 구현 시 `completeBooking()`에도 의도적으로 넣지 않았음, `A1_A2_BOUNDARY.md` §3 원칙) |

**확인 결과**: A2_PREFLIGHT 시점과 달라진 것이 없다 — `completeBooking()`이 추가된 뒤에도 `recordVisit()` 호출 공백은 그대로 남아있다. A-1의 작업은 정확히 이 공백을 메우는 것이다.

---

## 2. `PaymentRepository` 영향 범위

현재 생성자: `PaymentRepository(this._db, this._customerRepository, this._prepaidPassRepository)` — `BookingRepository`는 주입되어 있지 않다.

| 메서드 | 영향 내용 |
|---|---|
| `createOrder()` | `Order.status`는 항상 `'pending'`으로 시작 — 직접 영향 없음. 다만 §4(0원 주문)의 분기점이 될 후보 |
| `pay()` | **핵심 영향 지점.** `newPaidTotal >= netTotal`이면 `newStatus = 'completed'`로 전환하는 분기가 이미 존재 — 이 지점이 `recordVisit()`(및 조건부 `completeBooking()`)을 호출할 유일한 자리(§A1_A2_BOUNDARY §3 원칙) |
| `cancelOrder()` | `recordVisit()`을 직접 호출하지는 않지만, 환불 시 이미 적재된 `VisitRecord`를 어떻게 다룰지가 §6에서 다루는 별도 결정 사안 |

**구조적 변경 필요 여부**: `pay()`가 `BookingRepository.completeBooking()`을 함께 호출하려면 `PaymentRepository` 생성자에 `BookingRepository`를 주입해야 한다(신규 Repository 생성이 아니라 **기존 Repository 간 의존성 추가** — M6에서 `PrepaidPassRepository`를 추가 주입했던 것과 동일한 종류의 변경). 이는 생성자 시그니처가 3개→4개 인자로 늘어나는 변경이라, **호출하는 모든 곳(Provider, 테스트 `setUp()`)을 동시에 수정**해야 한다.

---

## 3. `BookingRepository`와의 경계

`A1_A2_BOUNDARY.md`가 이미 정한 원칙을 재확인:

- `BookingRepository`는 `completeBooking()`을 **공개 메서드로만 제공**하고, 스스로 누구를 호출하지 않는다(역할: "요청을 받는 쪽")
- `PaymentRepository.pay()`가 **bookingId를 전달받았을 때만** `completeBooking()`을 호출한다

**여기서 새로 드러나는 문제**: `Order` 테이블에 `bookingId` 컬럼이 없다(`SCREENS_ERD_TABLES.md`에서 이미 확인된 사실, 컬럼 추가 금지 범위 안에서는 해결 불가). 따라서 `bookingId`는 **DB에 저장되지 않고, 호출 시점에 매개변수로만 전달**되어야 한다. 분할결제처럼 `pay()`가 여러 번 호출되는 경우, **화면이 매 호출마다 같은 bookingId를 반복해서 들고 있다가 전달해야** 하며, 중간에 화면이 그 값을 잃어버리면(예: 화면 재진입) 마지막 결제 완결 시점에 `completeBooking()`이 호출되지 않고 조용히 누락된다. 이는 §9(리스크)에서 다시 다룬다.

---

## 4. 0원 주문 처리 방식

`BUSINESS_RULES_TO_DECIDE.md` §1-2에서 이미 "즉시결정 필요"로 분류된 사안이며, **아직 결정되지 않았다.**

- 현재 `pay()`는 `amount <= 0`이면 무조건 `ValidationException`을 던진다 — `netTotal=0`인 주문(전액 할인)은 `pay()`를 호출할 수도 없고 호출할 필요도 없다.
- 따라서 `createOrder()`만으로 끝나는 0원 주문은 `Order.status`가 영원히 `'pending'`에 머물고, §2에서 식별한 `recordVisit()` 트리거 지점(`pay()` 내부)을 통과할 일이 없다.
- **A-1을 지금 구현하면, 이 결정이 없는 상태로 "0원 주문은 방문 미기록"이 암묵적으로 확정되어 버린다** — `BUSINESS_RULES_TO_DECIDE.md`가 권장한 (a)(0원도 방문 인정) 안을 채택하려면 `createOrder()`가 `netTotal<=0`일 때 별도 분기로 즉시 `'completed'` 처리하고 `recordVisit()`을 호출하는 **두 번째 트리거 지점**이 필요해지는데, 이는 §A1_A2_BOUNDARY가 정한 "단일 트리거(`pay()`)" 원칙에 예외가 하나 더 생기는 것과 같다.

**점검 결론**: 이 결정 없이 A-1을 구현하면 §A1_A2_BOUNDARY의 "경계 밖" 항목이 의사결정 없이 기본값으로 굳어진다 — 구현 착수 전 재확인이 필요하다.

---

## 5. 환불 처리 방식

`BUSINESS_RULES_TO_DECIDE.md` §2-2(구현 중 결정 가능)에서 이미 다룬 사안이며, `A1_A2_BOUNDARY.md`도 "경계 밖"으로 명시했다.

- `cancelOrder()`는 트랜잭션 내에서 포인트 환원·선불권 환원·`Payment`/`Order` 상태 갱신을 처리하지만, **`VisitRecord`에는 손대지 않는다**(코드 확인 결과 그대로).
- A-1 구현 시점에 두 가지 선택이 있다: (a) 그대로 유지(환불돼도 방문기록은 남음) / (b) `cancelOrder()`도 `VisitRecord.status`를 `'cancelled'`로 갱신.
- **점검 결론**: `BUSINESS_RULES_TO_DECIDE.md`가 권장한 대로 **(a)로 시작하는 것이 A-1의 1차 범위에 적합** — `cancelOrder()`를 수정하지 않아도 되므로 A-1의 변경범위가 `pay()` 하나로 좁게 유지된다. (b)로 가면 `CustomerRepository`에 `VisitRecord` 상태를 갱신하는 새 메서드가 필요해져 A-1의 범위가 커진다.

---

## 6. 중복 방문 기록 방지 방식

`A1_A2_BOUNDARY.md` §4의 3중 방어선을 코드 차원에서 재확인:

1. **호출 지점 단일화**: `pay()` 내부 한 곳에서만 호출 — 점검 결과 §2에서 확인한 분기(`newStatus='completed'`)가 정확히 이 한 곳.
2. **"최초 완결 전환"에서만 발생**: `pay()`는 이미 `paidSoFar + amount > netTotal`이면 초과결제로 차단한다 — 즉 **한 번 `'completed'`가 된 주문은 같은 주문에 대해 `pay()`가 다시 성공할 수 없다**(재호출하면 `paidSoFar == netTotal`이라 어떤 추가 `amount`도 초과로 판정되어 예외 발생). 이 기존 검증 로직이 그대로 중복 방지 장치로 작동함을 코드 레벨에서 재확인했다.
3. **환불해도 `VisitRecord`를 지우지 않음**: §5에서 (a)를 채택하면 자동으로 충족.

**점검 결론**: 추가 코드 없이도 기존 초과결제 차단 로직이 중복 호출을 막아준다 — 이 부분은 새로운 위험이 없음을 확인.

---

## 7. 영향받는 테스트

| 테스트 파일 | 영향 내용 |
|---|---|
| `test/features/payment_pos/payment_repository_test.dart` | **직접 영향.** `setUp()`의 `PaymentRepository(db, customerRepo, prepaidPassRepo)` 생성자 호출에 `BookingRepository`가 추가되면 인자 4개로 변경 필요(M6에서 `PrepaidPassRepository` 추가 시 겪은 것과 동일한 종류의 수정). `group('pay')` 안에 "주문 완결 시 고객의 방문이력이 1건 적재된다"를 검증하는 신규 테스트 케이스 필요 |
| `test/features/customer/customer_repository_test.dart` | **직접 영향 없음.** `recordVisit()` 자체의 단위테스트는 그대로 유효 — A-1은 "누가 부르는가"만 바꾸므로 이 파일은 수정 불필요 |
| `test/features/booking/booking_repository_test.dart` | **직접 영향 없음.** `completeBooking()` 자체 테스트(A-2에서 이미 추가됨)는 그대로 유효. `bookingId`를 받아 `completeBooking()`을 호출하는 통합 검증은 `payment_repository_test.dart` 쪽에 추가하는 것이 더 적절(호출 주체가 `PaymentRepository`이므로) |
| `test/app_smoke_test.dart`, `test/routing_test.dart` | **영향 없음.** 화면 레벨 변경이 없으므로 라우팅/스모크 테스트는 그대로 통과 |

---

## 8. 구현 순서

1. §4(0원 주문)·§5(환불 처리) 결정을 먼저 확정 — 둘 다 "1차 범위를 좁게" 가는 방향(0원 주문은 일단 미기록 유지 또는 별도 결정, 환불은 `VisitRecord` 비침범)으로 정해야 아래 단계들이 단순해짐
2. `PaymentRepository` 생성자에 `BookingRepository` 의존성 추가(예약경로 지원이 필요하다고 결정된 경우에만 — 워크인 경로만 우선 지원하고 예약경로는 다음 단계로 미루는 것도 선택 가능)
3. `pay()`의 기존 `newStatus == 'completed'` 분기 안에서 `order.customerId != null`이면 `_customerRepository.recordVisit()` 호출
4. (예약경로를 함께 지원하는 경우) 같은 분기에서 `bookingId`가 전달됐다면 `_bookingRepository.completeBooking(bookingId)` 호출 — 단, `completeBooking()`이 던질 수 있는 예외(이미 cancelled/noshow인 예약 등)를 결제 트랜잭션 실패로 취급할지 별도 결정 필요(§9 리스크 참조)
5. `payment_repository_test.dart`의 `setUp()`/관련 테스트 갱신, 신규 케이스 추가
6. 전체 테스트 스위트 회귀 확인

---

## 9. 예상 리스크

| 리스크 | 설명 |
|---|---|
| **`bookingId`를 DB에 저장할 곳이 없어, 화면이 분할결제 내내 직접 들고 다녀야 함** | §3에서 식별. 화면 구현(06/07/02 연동) 시점에 상태관리 실수가 있으면 마지막 결제 완결 시점에 `bookingId`가 빠져 `completeBooking()` 호출이 조용히 누락 — 예외도 안 나고 그냥 안 불림 |
| **생성자 시그니처 변경의 파급** | `PaymentRepository`를 생성하는 모든 곳(Provider 1곳, 테스트 `setUp()` 다수)을 동시에 고쳐야 함 — M6 때 한 차례 경험한 변경이라 절차는 알지만, 빠뜨리면 컴파일 자체가 깨짐(런타임 버그가 아니라 빌드 실패라는 점은 오히려 안전) |
| **`completeBooking()` 예외가 결제 트랜잭션을 실패시킬 위험** | 예약이 이미 취소/노쇼 상태인데 화면이 잘못된 `bookingId`를 넘기면, `completeBooking()`이 `BusinessRuleException`을 던진다 — 이걸 `pay()`가 그대로 전파하면 **결제 자체가 성공했는데 예외로 보여 화면이 실패로 오인할 위험**이 있음. "결제는 성공시키고 예약 상태 갱신만 별도로 실패 처리"할지, "둘 다 한 트랜잭션으로 묶어 같이 롤백"할지는 A-1 구현 전에 결정이 필요(현재 `cancelOrder()`는 `_db.transaction()`을 쓰지만 `pay()`는 트랜잭션을 쓰지 않음 — 이 비대칭도 함께 고려해야 함) |
| **0원 주문 결정 미확정 상태로 구현 시, 결정을 내린 것처럼 굳어짐** | §4에서 다룸 — 가장 시급한 리스크. 코드를 짜는 순간 "0원 주문은 방문 미기록"이 사실상 기정사실이 되어, 나중에 뒤집으려면 §4에서 설명한 "두 번째 트리거 지점" 추가가 필요해 재작업 비용이 발생 |
| **워크인 경로만 먼저 구현하고 예약경로(§3, §8-2/4)를 다음 단계로 미루는 선택이 "임시"인지 "확정"인지 불명확해질 위험** | 06/07 화면이 아직 없어 예약경로 검증 자체가 불가능하다는 점은 `A2_PREFLIGHT_REVIEW.md`에서도 이미 지적됨 — A-1을 워크인 경로만으로 먼저 출시할 경우, 그 사실을 README/문서에 명확히 남기지 않으면 "A-1은 끝났다"고 오인되어 예약경로 누락이 한참 뒤에야 발견될 위험 |

---

## 종합 결론

A-1의 핵심 구현(워크인 경로, `recordVisit()`만 호출)은 §6에서 확인했듯 기존 초과결제 차단 로직이 중복 호출을 막아줘서 비교적 안전하다. 그러나 **예약경로(`completeBooking()` 연동)는 `bookingId`를 저장할 컬럼이 없다는 구조적 제약 때문에, "화면이 책임지고 들고 다닌다"는 전제가 깨지면 조용히 누락되는 위험을 안고 있다.** §4(0원 주문)와 §5(환불 처리)는 둘 다 결정을 미뤄도 A-1의 범위를 좁게 유지할 수 있는 방향(미기록/비침범)이 있어, 이번 구현에서는 그 방향으로 시작하는 것이 재작업 위험을 줄인다. 구현 착수 직전 가장 먼저 확정해야 할 것은 **"이번 A-1에 예약경로(`completeBooking()` 연동)를 포함시킬지, 워크인 경로만 먼저 출시할지"** 하나다 — 이 선택에 따라 §2의 생성자 변경 여부, §8의 단계 수가 전부 달라진다.
