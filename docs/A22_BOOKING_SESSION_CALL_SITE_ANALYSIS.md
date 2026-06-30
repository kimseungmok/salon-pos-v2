# A-22: Booking Session Call Site Analysis

> **목적**: A-20/A-21 결론을 기준으로, Booking 완료 이후 `createSession()` → `addItem(refType='booking', refId=...)`를 실제로 어느 위치에서 호출해야 하는지 현재 코드 기준 호출 지점 1개를 확정한다. 새 설계/구현 없음, 분석만 수행.
> **대상 코드**: `lib/features/booking/data/booking_repository.dart`, `lib/features/payment_pos/data/payment_repository.dart`
> **근거**: A-20(`docs/A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md`), A-21(`docs/A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md`), `design/spec/v3/A1_A2_BOUNDARY.md`(코드 주석으로 인용됨)
> 작성일: 2026-06-30

---

## PART 0 — 기준 원칙

A-20/A-21의 결론(Booking 7개 이벤트 전부 Session 생성 미연결, `refType='booking'`은 `PaymentSessionItems` 레벨 설계, Baseline 영향 없음)을 전제로 하고 반복 분석하지 않는다. 추론으로 새 호출 흐름을 만들지 않고, 현재 코드와 코드에 이미 인용된 기존 설계 문서(`A1_A2_BOUNDARY.md`)만 근거로 한다.

---

## PART 1 — Booking 완료 흐름 추적

| 단계 | 구현 여부 | 근거 |
|---|---|---|
| `completeBooking()` 존재 여부 | **Implemented** | `booking_repository.dart` 304~326행 — `Bookings.status`를 `'completed'`로 전환. |
| Booking 상태 확정 처리 | **Implemented** | 같은 메서드 내 가드(이미 `completed`/`cancelled`/`noshow`면 차단)와 단일 `update` 문(319~320행)으로 상태 확정. |
| Payment 연결 여부 | **Not Implemented**(명시적으로 보류된 결정) | `payment_repository.dart` 184~186행 주석: "예약경로(`completeBooking()` 연동)는 1차 범위에 포함하지 않음(`Order`에 `bookingId`를 저장할 컬럼이 없어 후속작업으로 분리)" — 구(舊) `payment_pos` 모듈이 Booking과 연결되지 않는다는 사실이 코드 주석으로 이미 명시돼 있다. |
| Session 생성 호출 여부 | **Not Implemented** | A-20/A-21에서 이미 확인된 그대로 — `completeBooking()`은 `SessionRepository`를 import하지 않으며 호출도 없다. |

---

## PART 2 — Session 호출 가능 지점 확인

| 항목 | 상태 | 근거 |
|---|---|---|
| Booking 완료 처리 위치 | **Present** | `completeBooking()`(304~326행) — 이 메서드 안에서 `booking` 변수(고객/직원 정보 포함)에 이미 접근 가능한 상태. |
| `createSession()` 호출 가능 여부 | **Yes**(기술적으로는) | `completeBooking()`이 조회한 `booking.staffId`/`booking` 관련 정보를 `createSession()`의 매개변수(`businessType`/`staffId`/`customerId`/`roomId`)로 매핑하는 것 자체는 코드 구조상 막힘이 없다. |
| `addItem()` 호출 가능 여부 | **Yes**(기술적으로는, `createSession()` 호출 후 `sessionId`를 얻은 다음) | 마찬가지로 코드 구조상 막힘이 없다. |

**단, "기술적으로 가능"과 "이 위치가 맞다"는 다른 질문이다 — PART3/4에서 구분한다.**

---

## PART 3 — A-8 설계와의 일치 여부 확인

| 항목 | 결과 | 근거 |
|---|---|---|
| A-8 Booking → Session 연결 방식 정의 | (참고) `refType='booking'`, `refId=<Booking.id>`를 **`PaymentSessionItems`** 레벨에서 사용(A-21에서 이미 확정) | `docs/A8_SESSION_ENGINE.md` 14행, `session_tables.dart` 57~59행 |
| `PaymentSessionItems.refType`/`refId`와 A-8 설계 일치 여부 | **Match** | 스키마가 이미 `'booking'`을 허용값으로 포함(A-21 재확인) — 추가 변경 불필요. |
| `addItem()` 설계 방식 일치 여부 | **Match** | `addItem()`의 기존 매개변수(`refType`/`refId`)가 A-8이 의도한 그대로 이미 존재(A-21 재확인). |

**A-8 설계 자체와의 충돌은 없다.** 다만 본 PART와 별개로, **"어디서 호출해야 하는가"**(누가 호출 책임을 갖는가)에 대해서는 A-8이 정의하지 않은 사항이 있고, 이는 PART4에서 다른 기존 설계 문서(아래)로 보완해 판단한다.

### 추가로 확인된, 직접 적용 가능한 기존 원칙(A-8 범위 밖이지만 코드에 이미 존재)

`completeBooking()`의 메서드 docstring(287~303행)이 `design/spec/v3/A1_A2_BOUNDARY.md`를 인용해 다음을 명시한다:

> "이 메서드는 '예약경로' 트리거만 처리한다 — 호출 시점(언제 부를지)은 이 레포지토리의 책임이 아니라 **호출자**(향후 `PaymentRepository`, A-1 단계)의 책임이다. 이 메서드 스스로 `CustomerRepository.recordVisit()`을 호출하지 않는다."

그리고 이 원칙이 실제로 적용된 선례가 `payment_repository.dart` 180~195행에 존재한다 — `PaymentRepository`(주문 완료를 처리하는 쪽)가 `CustomerRepository.recordVisit()`(다른 도메인의 후속 효과)을 호출하지, `Order`/`Booking` 자신의 완료 메서드가 스스로 호출하지 않는다. **"완료 처리 메서드 자신이 다른 도메인을 호출하지 않고, 그 호출자가 책임진다"는 패턴이 이 코드베이스에 이미 확립돼 있다.**

---

## PART 4 — Phase 1 구현 위치 확정

| 항목 | 필요 여부 | 근거 |
|---|---|---|
| 새 Repository 추가 | **No** | `SessionRepository`/`BookingRepository` 둘 다 이미 존재(A-20/A-21 재확인). |
| 새 Workflow 추가 | **No** | `createSession()`/`addItem()` 둘 다 단일 insert+재조회 수준의 절차이며, Transaction으로 묶일 다단계 절차가 아니다(A-21 재확인). |
| 새 Engine 추가 | **No** | 매핑만 필요, 계산 로직 불필요(A-21 재확인). |
| 새 Table 추가 | **No** | `refType`/`refId` 컬럼이 이미 존재(A-21 재확인). |
| 기존 호출 위치만으로 구현 가능 | **No** | **`completeBooking()` 자체를 호출하는 곳이 현재 코드에 전혀 없다**(`grep -rn "completeBooking(" lib/` 결과 정의 1건 외 호출부 0건, 본 turn에서 확인) — 즉 "기존 호출 위치"라는 것 자체가 아직 존재하지 않는다. PART3에서 확인한 기존 원칙(완료 처리 메서드 자신이 아니라 그 호출자가 도메인 간 연결 책임을 진다)에 따르면, Session 생성 호출은 `completeBooking()` 내부가 아니라 **`completeBooking()`을 호출하는 지점**에 위치해야 하는데, 그 지점 자체가 아직 코드에 없다. |

### Phase 1 구현 위치(확정)

**`completeBooking()`을 호출하는 지점**(`completeBooking()` 호출 직후, `createSession()` → `addItem(refType='booking', refId=<Booking.id>)` 순서로 연결) — 단, 이는 기존 코드의 특정 줄을 가리키는 것이 아니라, **"어떤 위치에 두어야 하는가"라는 원칙적 위치**를 확정한 것이다. 그 호출자 자체가 A-23에서 만들어져야 할 대상이며, `completeBooking()`/`createSession()`/`addItem()` 어느 기존 메서드도 수정하지 않고 그 바깥(새 호출자)에서 순서대로 호출하는 형태가 PART3에서 확인한 기존 원칙(A1_A2_BOUNDARY.md 패턴)과 일치한다.

---

## PART 5 — 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **369건 전부 통과**(`All tests passed!`) |

---

## PART 6 — 최종 결론

| 확인 항목 | 결과 |
|---|---|
| 구현 위치가 하나로 확정되었는가 | **원칙적으로 확정됨** — "`completeBooking()`을 호출하는 지점"(PART4). 단, 그 호출 지점 자체가 현재 코드에 존재하지 않으므로, A-23의 범위는 "기존 위치에 코드를 추가하는 것"이 아니라 "그 호출 지점을 만드는 것"임을 명확히 함께 기록한다. |
| A-8 설계와 충돌하지 않는가 | 충돌 없음(PART3, `refType`/`refId` 스키마 Match) |
| Baseline에 영향이 없는가 | 영향 없음 — A-21에서 이미 확정된 근거(`closeSession()` 흐름과 코드상 완전히 분리) 그대로 유지, 본 turn에서 새로 검토한 `completeBooking()`/`PaymentRepository` 쪽 코드도 `SessionClosingWorkflow`/Transaction Boundary와 무관함을 확인(별도 모듈, 호출 관계 없음) |
| A-23 구현 범위가 명확한가 | 명확함 — "`completeBooking()` 호출 후 `createSession()`+`addItem()`을 순서대로 호출하는 새 호출자를 만드는 것"으로 좁혀짐. 기존 3개 메서드(`completeBooking`/`createSession`/`addItem`) 자체는 수정 대상이 아님. |

**"Booking Session Call Site Established"**
