# A-21: Booking → Session Integration Point Analysis

> **목적**: A-20 결과를 바탕으로 Booking Domain과 Session Engine을 연결해야 하는 정확한 Integration Point를 확정한다. 새 설계/계층 없음, Business Logic 변경 없음, 구현 없음(분석만).
> **대상 코드**: `lib/features/booking/data/booking_repository.dart`, `lib/features/session/data/session_repository.dart`, `lib/features/session/data/session_tables.dart`, `docs/A8_SESSION_ENGINE.md`
> **근거**: A-19 Baseline(`docs/baseline/SESSION_CLOSING_BASELINE.md`), A-20(`docs/A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md`)
> 작성일: 2026-06-30

---

## PART 0 — 기준 원칙

A-19 Session Closing Baseline은 변경하지 않는다. A-20에서 이미 확인된 내용(`BookingRepository`의 8개 메서드 존재, `createSession()` 호출 0건, Booking Workflow 불필요 등)은 본 문서에서 반복 분석하지 않고 결론만 인용한다. 추론으로 새 흐름을 만들지 않고, 현재 코드와 `docs/A8_SESSION_ENGINE.md`만 근거로 한다.

---

## PART 1 — Booking Event 및 Session 생성 관계 확인

| Booking Event | 구현 여부 | Session 생성 여부 | 근거 |
|---|---|---|---|
| `createBooking()`(예약 생성) | Implemented | No | `booking_repository.dart` 32~105행 — `Bookings` insert만 수행, `SessionRepository` 참조 없음(import 0건). |
| `updateBooking()`(예약 변경) | Implemented | No | 159~239행 — `Bookings` update만 수행. |
| `cancelBooking()`(예약 취소) | Implemented | No | 243~285행 — `Bookings.status`를 `'cancelled'`/`'noshow'`로 갱신만 수행. |
| `completeBooking()`(예약 완료) | Implemented | No | 304~326행 — `Bookings.status`를 `'completed'`로 갱신만 수행. A-20에서 이미 확인된 대로 "Check-out"에 가장 가까운 개념이지만 Session 생성 호출은 없음. |
| `addWaiting()`/`callWaiting()`/`cancelWaiting()`(대기열) | Implemented | No | 336~399행 — `WaitingEntries` 테이블만 다룸, `Bookings`와 FK 없음(A-20에서 이미 확인된 별개 도메인). |

**종합**: Booking 도메인의 7개 이벤트 전부 구현돼 있으나, 어느 것도 `SessionRepository`를 호출하지 않는다 — Session 생성은 현재 Booking 이벤트 중 어디에도 연결돼 있지 않다.

---

## PART 2 — `createSession()` 연결 지점 확인

| 항목 | 상태 | 근거 |
|---|---|---|
| `createSession()` 정의 위치 | **Present** | `lib/features/session/data/session_repository.dart`(101~135행) — `createSession({required businessType, staffId, customerId, roomId})`. |
| `createSession()` 호출 횟수 | **0건** | `grep -rn "createSession(" lib/` 결과, 정의(메서드 시그니처) 1건 외 호출부 없음(A-20 확인 사실의 재확인, 본 turn에서도 재실행해 동일 결과). |
| A-8 문서 기준 연결 지점 | **Present(단, 정확한 위치는 `PaymentSession`이 아니라 `PaymentSessionItem`)** | `docs/A8_SESSION_ENGINE.md` 14행이 "예약을 세션으로 전환할 때 `ref_type='booking'`, `ref_id=<Booking.id>`"라 명시하지만, **`refType`/`refId` 컬럼은 `PaymentSessions` 테이블이 아니라 `PaymentSessionItems` 테이블에만 존재한다**(`session_tables.dart` 57~59행). `createSession()`의 매개변수(`businessType`/`staffId`/`customerId`/`roomId`, 103~107행)에는 `refType`/`refId`에 해당하는 자리가 없다 — A-8이 명시한 느슨한 참조는 `addItem()` 호출 시점(품목 추가)에 적용되는 설계이지, `createSession()`(세션 헤더 생성) 시점의 설계가 아니다. |

---

## PART 3 — Baseline 영향 확인

| 항목 | 영향 | 근거 |
|---|---|---|
| Booking → Session 연결(향후 `createSession()`/`addItem()` 호출 추가) | **No Baseline Impact** | A-19 Baseline이 고정한 4개 요소(`SessionRepository.closeSession()`/`SessionClosingWorkflow`/`StaffEarningEngine`/Transaction Boundary)는 모두 **세션이 이미 존재하는 이후** 단계(마감 절차)를 다룬다. `createSession()`/`addItem()`은 세션 생성·품목 추가 단계로, Baseline이 다루는 `closeSession()` 흐름과 코드상 분리돼 있다(`closeSession()`은 `createSession()`/`addItem()`을 호출하지 않음, `session_repository.dart` 전체 구조 확인). Booking이 `createSession()`/`addItem()`을 호출하게 되어도 Transaction Boundary나 Conditional Update 메커니즘에는 어떤 코드 경로도 닿지 않는다. |

---

## PART 4 — Phase 1 Integration 범위 정의(A-20과 중복되지 않는 신규 확인 사항만)

| 항목 | 필요 여부 | 근거 |
|---|---|---|
| 새 Repository 추가 | **Not Required** | `SessionRepository.createSession()`/`addItem()`과 `BookingRepository`가 이미 둘 다 존재한다 — 연결을 위한 제3의 Repository가 필요하다는 근거가 코드에 없다. |
| 새 Workflow 추가 | **Not Required** | `createSession()`은 단일 insert+재조회(101~135행)로 끝나는 절차이며, `closeSession()`처럼 여러 단계가 Transaction으로 묶여야 할 이유가 없다(A-20에서 이미 같은 결론, 본 PART에서 `createSession()` 코드 구조로 재확인됨). |
| 새 Engine 추가 | **Not Required** | Booking→Session 연결에 필요한 것은 `Booking` 행의 필드(`customerId`/`staffId` 등)를 `createSession()`의 매개변수로 옮기는 매핑이지, 새로운 계산 로직이 아니다. |
| 새 Table 추가 | **Not Required** | `PaymentSessionItems.refType`/`refId`가 이미 `'booking'` 값을 허용하도록 설계돼 있다(57~59행) — 연결을 위한 신규 컬럼/테이블이 필요하지 않다. |
| 기존 `createSession()` 호출만으로 가능 | **Required**(단, `addItem()`도 함께 필요) | `createSession()`의 기존 시그니처(`businessType`/`staffId`/`customerId`/`roomId`)만으로 `Booking` 행의 데이터를 세션 헤더로 옮기는 것은 충분하다. 다만 PART2에서 확인한 대로 `ref_type='booking'` 연결 자체는 `createSession()`이 아니라 **`addItem()` 호출 시점**에 적용되는 설계이므로, "Integration Point"는 `createSession()` 단독이 아니라 `createSession()` → `addItem(refType='booking', refId=<Booking.id>)`로 이어지는 **두 메서드의 조합**이다. 두 메서드 모두 이미 존재하는 기존 메서드이며, 새로운 메서드 추가는 필요하지 않다. |

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
| Booking Event 확인 완료 | 완료(PART1, 7개 이벤트 전부 Session 생성 No) |
| Session 생성 시점 확정 완료 | 확정됨 — 현재 코드에는 Session 생성 시점이 **존재하지 않는다**(어느 Booking 이벤트도 트리거하지 않음). Integration 시 가장 유력한 후보는 PART1에서 확인한 `completeBooking()`(Check-out에 가장 가까운 개념)이나, 이는 향후 구현 시 결정할 사안이며 본 분석은 "현재 어디에도 없다"는 사실만 확정한다. |
| `createSession()` 연결 지점 확인 완료 | 완료(PART2) — 정의는 있으나 호출 0건, A-8의 `refType` 설계는 `PaymentSessionItems`(즉 `addItem()`) 레벨임을 정확히 확인 |
| Baseline 영향 없음 확인 완료 | 완료(PART3, No Baseline Impact) |
| Phase 1 Integration 범위 정의 완료 | 완료(PART4) — 새 Repository/Workflow/Engine/Table 전부 불필요, 기존 `createSession()`+`addItem()` 조합만으로 가능 |

**"Booking Session Integration Point Analysis Completed"**
