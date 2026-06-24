# A-4 코드 적용 전 전체 시스템 영향 검증

> **기준 문서**: `STAFF_ACCOUNT_STATUS_SPEC.md`(확정 규격), `A4_A5_PAYMENT_FLOW_VERIFICATION.md`, `A3_PREFLIGHT_REVIEW.md`(실제 구현된 `updateBooking()` 코드 기준)
> **목적**: `STAFF_ACCOUNT_STATUS_SPEC.md`의 규칙을 **실제 코드(Booking/Payment/Visit/Inventory)에 적용하기 직전**, 적용 지점을 정밀하게 좁히고 부작용을 사전에 찾는다.
> **범위 제한**: 설계 검토만 수행. 코드/SQL 생성·수정, 테이블/컬럼 변경 없음.
> 작성일: 2026-06-24

---

## 1. Booking 영향

### 1-1. 신규 예약 가능 조건(`!= '退職済み'`) 확정 적용 여부
`createBooking()`은 `staffId`가 주어지면 항상 **새로운 배정**이므로, `_assertStaffAvailable()` 호출 경로에 `accountStatus` 검증을 추가하는 것이 **그대로 안전하게 적용 가능**하다.

### 1-2. 기존 예약 수정/조회 영향 여부 — **여기서 충돌이 발견된다**
A-3에서 실제로 구현된 `updateBooking()`의 동작을 다시 보면:

```
final newStaffId = staffId ?? booking.staffId;   // staffId 매개변수를 안 주면 기존값 유지
if (newStaffId != null) {
  await _assertStaffAvailable(newStaffId, newStartAt, newEndAt, excludeBookingId: bookingId);
}
```

`A3_PREFLIGHT_REVIEW.md` §3이 의도적으로 정한 "부분변경이라도 항상 전체 재검사"라는 정책 때문에, **`staffId`를 안 바꾸고 시간만 바꾸는 호출이어도 `_assertStaffAvailable()`이 매번 호출된다.**

**문제**: 만약 `accountStatus` 검증을 `_assertStaffAvailable()` **내부에 일괄로** 넣으면 — 예약을 만들 당시엔 재직 중이던 담당자가 그 사이 퇴사 처리됐고, 누군가 그 예약의 **시간만** 바꾸려 하면(담당자는 안 바꿈), 검증이 매번 재실행되면서 "퇴사한 담당자라서" 시간 변경조차 막히는 **의도하지 않은 부작용**이 발생한다. 이는 §2-1(`STAFF_ACCOUNT_STATUS_SPEC.md`)이 의도한 "**신규 배정만** 차단"이 아니라 "**이미 배정된 예약의 모든 수정**"까지 막는 것이라 정책 의도를 벗어난다.

**결론**: 검증을 걸어야 할 대상은 "**`staffId`가 실제로 새 값으로 바뀌는 경우**"뿐이다 — 기존 `staffId`를 그대로 유지한 채 시간만 바꾸는 호출은 검증 대상이 아니어야 한다.

---

## 2. Payment 영향

### 2-1. 결제 시 `staffId` 유효성 검증 필요 여부
**불필요 — `STAFF_ACCOUNT_STATUS_SPEC.md` §2-2의 결론 그대로 재확인.** `pay()`는 `accountStatus`를 절대 조회하지 않는다. 본 검증에서도 이 원칙을 흔들 새로운 근거는 발견되지 않았다.

### 2-2. 퇴사 직원 결제 기록 처리 방식
**변경 없음.** `OrderItem.staffId`에 퇴사 직원의 ID가 들어있어도 `pay()`/`_staffIdOf()`/`recordVisit()`은 그 값을 그대로 처리한다 — §1에서 발견한 문제(Booking)와 달리, Payment 쪽은 "이미 정해진 값을 그대로 정산"하는 단계라 §1과 같은 재검증 구조 자체가 없어 동일한 부작용이 생기지 않는다.

---

## 3. Visit 영향

### 3-1. 방문 기록 조회 시 퇴사 직원 표시 방식
`VisitRecord.staffId`는 그대로 보존되고, 조회 시 `accountStatus` 필터를 적용하지 않는다(`STAFF_ACCOUNT_STATUS_SPEC.md` §2-3 재확인). 화면에서 이름을 표시할 때 `Staff` 테이블을 조인해야 하는데, A-4가 "삭제 대신 상태전환"을 채택하므로 `Staff` 행 자체는 남아있어 **이름 조회 자체는 항상 성공한다** — 화면이 "(退職)" 같은 표식을 추가로 붙일지는 순수 UI 정책이라 본 검증의 데이터 영향 범위 밖이다.

### 3-2. `staffId` null/invalid 데이터 방어 로직 필요 여부
- **`null`**: 이미 `nullable`로 처리되고 있어 방어 로직이 이미 존재(워크인 등 담당자 미지정 케이스) — 추가 조치 불필요.
- **invalid(가리키는 `Staff` 행이 존재하지 않는 경우)**: `null`/`'待機中'` 상태에서 하드 삭제된 직원의 `staffId`가 과거 `VisitRecord`에 남아있을 가능성이 이론상 있다(§1-3의 "극단적 예외"와 동일 종류). 이 경우 조인 결과가 없어 화면에 이름이 비게 된다 — **데이터/스키마 차원의 방어는 필요 없지만, 화면 레벨에서 "이름 조회 실패 시 대체 표시"를 권장**(코드/컬럼 변경 아님, 화면 구현 시 권장사항으로만 기록).

---

## 4. Inventory 영향 (잠재)

### 4-1. `staffId` 기반 재고 기록이 있을 경우 영향 여부
`InventoryLog.staffId`는 이미 존재하지만(컬럼 변경 아님, 기존 컬럼), **현재 어떤 코드도 이 값에 `accountStatus` 검증을 적용하지 않는다.** §2(Payment)와 같은 성격(과거 기록을 그대로 적재)이라, A-4 규칙을 적용해도 **Inventory 쪽 코드는 전혀 손댈 필요가 없다.**

### 4-2. future-proof 검증
향후 "재고 처리 권한자 검증"(예: 퇴사 직원은 재고 입출고 기록을 새로 못 남기게)이 추가되더라도, 그 시점에는 §1(Booking)과 같은 분류(신규 작업 발생 시점)에 속하므로 **동일한 단일 조건(`!= '退職済み'`)을 재사용**하면 된다. 다만 §1-2에서 발견한 "신규 배정 vs 기존 데이터 재검증" 구분이 그때도 동일하게 적용돼야 한다는 점을 미리 표시해 둔다(`InventoryLog`는 매번 새 행을 추가하는 구조라 Booking의 "부분수정" 같은 애매한 경우가 구조적으로 없어, 오히려 Booking보다 적용이 단순할 것으로 예상).

---

## 5. 시스템 일관성

### 5-1. `accountStatus` 단일 조건 규칙 적용 가능 여부
**조건식 자체(`!= '退職済み'`)는 단일하게 유지 가능하다.** 그러나 §1-2에서 확인했듯, **"이 조건을 어디서 평가하느냐"는 모듈마다 다르게 판단해야 한다** — Payment/Visit/Inventory(현재)는 "절대 평가하지 않음"이 맞고, Booking은 "신규 배정 시점에만 평가"가 맞다. **단일 조건식 + 모듈별로 다른 적용 시점**이라는 두 층위를 구분해야 한다는 것이 본 검증의 핵심 결론이다.

### 5-2. "퇴사만 차단" 정책 유지 시 충돌 지점
**충돌 지점은 정확히 1곳, §1-2다.** "퇴사한 사람에게 새 일을 안 맡긴다"는 정책 의도와, "이미 맡겨진 일의 사소한 수정도 매번 재검증한다"는 A-3의 기존 구현 방식이 한 함수(`_assertStaffAvailable()`) 안에서 만나면서 의도하지 않은 충돌이 발생한다. **검증 책임을 함수 내부가 아니라 호출자(`createBooking()`/`updateBooking()`)가 "이번 호출이 신규 배정인가"를 먼저 판단하는 쪽으로 옮겨야** 이 충돌이 해소된다.

---

## 종합 — 출력 형식

### 바로 적용 가능한 영역
- **Payment**: 변경 없음(검증 자체를 추가하지 않는 것이 적용 내용)
- **Visit**: 변경 없음(비필터링 원칙 유지가 적용 내용)
- **Inventory**: 변경 없음(현재 미연결 상태 그대로 유지)
- **`createBooking()`**: `staffId`가 주어진 모든 신규 생성 호출은 항상 "신규 배정"이므로, 검증 추가가 부작용 없이 안전

### 적용하면 위험한 영역
- **`_assertStaffAvailable()` 함수 내부에 `accountStatus` 검증을 일괄로 넣는 것** — `updateBooking()`의 "부분변경도 전체 재검사" 정책과 충돌해, 퇴사 후 단순 시간변경조차 차단되는 의도치 않은 부작용 발생(§1-2)
- **`VisitRecord` 조회 경로에 `accountStatus` 필터를 끼워넣는 것** — 이미 확정된 "과거기록 비필터링" 원칙을 깨뜨림

### 적용 시 반드시 수정해야 하는 코드 지점
| 위치 | 수정 방향 |
|---|---|
| `BookingRepository.createBooking()` | `staffId != null`일 때 `_assertStaffAvailable()` 호출 **전 또는 그 안에** `accountStatus` 검증 추가 — 항상 신규 배정이라 위험 없음 |
| `BookingRepository.updateBooking()` | `staffId`(매개변수, 호출자가 명시적으로 새 값을 넘긴 경우)와 `booking.staffId`(기존 값)를 비교해, **"실제로 담당자가 바뀌는 경우"에만** `accountStatus` 검증을 적용하도록 호출 분기를 분리 — 기존 담당자를 유지한 채 시간만 바꾸는 호출은 검증을 건너뜀(§1-2/§5-2 핵심 수정 지점) |
| `StaffRepository.removeStaff()` | `STAFF_ACCOUNT_STATUS_SPEC.md` §3-2의 이원화 분기(`null`/`'待機中'`→하드삭제, `'連結済み'`→상태전환) 적용 |
| `BookingRepository` 그 외 | `cancelBooking()`/`completeBooking()`/조회용 `watchBookings()`는 `staffId` 신규 배정과 무관하므로 수정 대상 아님 |

### A-5와의 충돌 여부
**없음.** §4에서 확인한 대로 Inventory는 현재 어떤 코드 수정도 필요 없고, 향후 확장 시에도 같은 조건식을 재사용할 수 있다는 결론이 그대로 유지된다.
