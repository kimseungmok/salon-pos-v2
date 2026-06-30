# A-20: Booking Engine Domain Analysis

> **목적**: Booking Engine 구현 전, 현재 도메인 구조를 분석하고 `docs/baseline/SESSION_CLOSING_BASELINE.md`와의 연계 방식을 확정한다. 새 기능/구현 없음, Baseline 무수정, 분석만 수행.
> **대상 코드**: `lib/features/booking/**`, `lib/features/session/data/session_tables.dart`, `docs/A8_SESSION_ENGINE.md`
> **근거**: A-19 Baseline(`docs/baseline/SESSION_CLOSING_BASELINE.md`), `docs/A8_SESSION_ENGINE.md`
> 작성일: 2026-06-30

---

## PART 0 — 기준 원칙

A-19 Session Closing Baseline을 그대로 전제로 하고 변경하지 않는다. 모든 판단은 실제 코드/문서 확인 결과만 근거로 한다. 일반적인 예약 시스템의 통념이 아니라, **이 프로젝트에 이미 존재하는 코드**를 기준으로 분석한다.

---

## PART 1 — Booking Domain 확인

| 요소 | 존재 여부 | 근거 |
|---|---|---|
| Booking Entity(`Bookings` 테이블) | **Implemented** | `lib/features/booking/data/booking_tables.dart` 17~47행. 컬럼: `id`/`customerId`/`staffId`/`productIdsCsv`/`startAt`/`endAt`/`depositEnabled`/`depositMethod`/`depositAmount`/`depositReceived`/`depositRefunded`/`refundNote`/`repeatRule`/`memo`/`requiresApproval`/`status`(기본값 `'confirmed'`). |
| Booking Repository | **Implemented** | `BookingRepository`(`lib/features/booking/data/booking_repository.dart` 12행). Public 메서드 8개: `watchBookings()`/`createBooking()`/`updateBooking()`/`cancelBooking()`/`completeBooking()`/`watchWaiting()`/`addWaiting()`/`callWaiting()`/`cancelWaiting()`. |
| Booking Service/Engine(순수 계산 계층) | **Implemented**(부분적, 별도 클래스 아님) | `lib/features/booking/logic/booking_logic.dart` — `computeEndAt()`(메뉴 소요시간 합산), `waitColor()`(대기시간 색상 판정), `overlaps()`(시간 겹침 판정) 3개 함수. Pricing/Promotion/StaffEarning처럼 `XxxEngine` 클래스 형태는 아니지만, DB 비의존 순수 함수라는 점에서 같은 성격을 가진다. |
| Booking Workflow | **Not Implemented** | `lib/features/booking/`에 `workflow/` 디렉터리나 `XxxWorkflow` 클래스가 없다(Session Engine의 `SessionClosingWorkflow`에 대응하는 것이 없음). `createBooking()`/`cancelBooking()`/`completeBooking()` 전부 `BookingRepository` 메서드 안에 절차가 인라인으로 존재한다. |
| WaitingEntry(대기열) | **Implemented**(Booking과 별개 기능) | `WaitingEntries` 테이블(`booking_tables.dart` 49~63행). `Bookings`와 FK 관계 없음 — 독립된 테이블(F-BOOK-03, "토스 근거 없는 살롱 고유 자산"). |
| Booking ↔ Session 연결 코드 | **Not Implemented** | 아래 PART2에서 상세. |

---

## PART 2 — Session과의 관계 분석(현재 코드 기준)

| 확인 항목 | 현재 상태 | 근거 |
|---|---|---|
| Session 생성 시점 | **코드상 정의돼 있으나 호출되는 곳이 없음** | `SessionRepository.createSession()`이 정의돼 있지만(`session_repository.dart`), `grep -rn "createSession("` 결과 정의 1건 외에 호출부가 lib/ 전체에 0건. |
| Booking 종료 시점 | `completeBooking()`이 `Bookings.status`를 `'completed'`로 갱신 | `booking_repository.dart` 304~326행. 이 메서드는 `SessionRepository`를 전혀 참조하지 않는다(import 없음, 호출 없음). |
| Session Closing 호출 조건 | **해당 없음 — Booking 쪽에서 Session Closing을 트리거하는 코드가 없다** | `BookingRepository`의 어떤 메서드도 `SessionRepository.closeSession()`을 호출하지 않는다(코드 전체 검색 기준). |
| Booking 상태 변화 | `'confirmed'`(생성 시 기본값) → `'completed'`(`completeBooking()`) / `'cancelled'`·`'noshow'`(`cancelBooking()`, `reason`에 따라 분기) | `booking_tables.dart` 45~46행 주석, `booking_repository.dart` 243~326행. |

**설계 의도와 실제 구현의 차이**: `docs/A8_SESSION_ENGINE.md` 14행은 "살롱에서 예약을 세션으로 전환할 때 `ref_type='booking'`, `ref_id=<Booking.id>`"라는 설계 의도를 명시하고 있고, `session_tables.dart` 57행의 `refType` 컬럼 주석에도 `'booking'`이 허용값으로 이미 포함되어 있다. **그러나 이 자리(컬럼/허용값)만 마련되어 있을 뿐, 실제로 `addItem(refType: 'booking', ...)`을 호출하는 코드는 현재 0건이다.** 즉 Booking→Session 연결은 "스키마 차원에서 자리만 예약된 상태"이며 "구현된 연결"은 아니다.

---

## PART 3 — 도메인 책임 분석

| 책임 | 구현 여부 | 근거 |
|---|---|---|
| 예약 생성 | **Implemented** | `BookingRepository.createBooking()`(32~105행) — 고객/직원/메뉴/시간/보증금/반복규칙/승인필요여부 등을 받아 `Bookings` 행 생성. 직원 가용성 검증(`_assertStaffAvailable()`, 117~140행) 포함. |
| 예약 변경 | **Implemented** | `updateBooking()`(159~239행) — 시간/직원 변경, 겹침 재검증 포함. |
| 예약 취소 | **Implemented** | `cancelBooking()`(243~285행) — 사유(`reason`)에 따라 `'cancelled'`/`'noshow'` 분기, 보증금 환불 로직 포함. |
| Check-in | **Not Implemented**(직접적인 의미로는) | `Bookings` 테이블에 "체크인"을 나타내는 별도 상태/컬럼이 없다. 다만 `WaitingEntries`에 `checkInAt`(58행)이 있어, **대기열 기능 한정으로는** 체크인 개념이 존재한다(예약과는 별개 테이블). |
| Check-out | **Not Implemented** | `completeBooking()`이 가장 가까운 개념이나(304~326행), 이는 "예약을 완료 처리"하는 것이지 결제/퇴실을 의미하는 Check-out이 아니다 — Session Engine의 `closeSession()`(결제 마감)과는 다른 개념. |
| Session 생성 트리거(예약 → 전표 전환) | **Not Implemented** | PART2에서 확인한 대로 `createSession()` 호출부 자체가 없다. |

---

## PART 4 — Baseline 영향 확인

`docs/baseline/SESSION_CLOSING_BASELINE.md`가 Baseline으로 고정한 4개 요소(`SessionRepository`/`SessionClosingWorkflow`/`StaffEarningEngine`/Transaction Boundary)를 기준으로 점검한다.

- Booking 도메인의 어떤 코드도 `SessionRepository`/`SessionClosingWorkflow`/`StaffEarningEngine`을 참조하거나 호출하지 않는다(PART2에서 확인).
- `session_tables.dart`의 `refType` 컬럼이 `'booking'`을 이미 허용값으로 포함하고 있다는 사실은 **A-8 시점부터 있던 기존 설계**이며, 본 분석으로 새로 발견되거나 변경이 필요해진 것이 아니다.
- Booking Engine을 향후 구현하더라도, Baseline이 정의한 Transaction Boundary(Settlement~상태변경)나 Conditional Update 메커니즘에 손댈 이유가 없다 — Booking은 Session이 생성되기 **이전** 단계의 도메인이고, `closeSession()`은 Session이 생성된 **이후**의 절차이기 때문이다.

**No Baseline Impact**

---

## PART 5 — Phase 1 구현 범위 정의(분석 결과 요약, 새 기능 제안 아님)

PART1~3에서 `Not Implemented`로 확인된 항목은 다음 3가지였다:

1. Booking Workflow(별도 조율 클래스)
2. Booking ↔ Session 연결 코드(`createSession()` 호출부)
3. Check-in/Check-out(Session 의미의)

이 중 **Booking Engine Phase 1에서 반드시 필요한 최소 범위**를 PART1~3의 사실관계만으로 좁히면:

- **Booking Workflow**: 현재 `createBooking()`/`updateBooking()`/`cancelBooking()`/`completeBooking()`은 전부 `BookingRepository` 안에서 단일 메서드로 완결되며(Session Engine의 `closeSession()`처럼 여러 외부 컴포넌트—Engine 호출+Transaction 경계 보존—를 조율해야 하는 절차가 아님), 현재 코드에 Workflow 분리가 필요하다는 근거 자체가 없다. **Phase 1 범위에 포함할 근거 없음.**
- **Check-in/Check-out**: PART3에서 확인한 대로 "Check-out"에 해당할 만한 개념(`completeBooking()`)이 이미 존재하고, Session 의미의 결제 마감과는 다른 개념이다. 새 Check-in/Check-out을 추가해야 한다는 근거가 현재 코드/문서 어디에도 없다. **Phase 1 범위에 포함할 근거 없음.**
- **Booking ↔ Session 연결 코드**: 이것만이 PART1~4에서 일관되게 "설계상 자리는 있으나 구현된 적이 없다"고 확인된 유일한 항목이다(`docs/A8_SESSION_ENGINE.md`의 명시적 설계 의도 + `refType` 컬럼의 기존 허용값 + 호출부 0건이라는 사실의 조합). **Phase 1 최소 범위는 이 연결 지점 1개로 좁혀진다.**

**Phase 1 최소 범위(분석 결과 요약)**: 기존에 이미 설계돼 있던 `refType='booking'`/`refId=<Booking.id>` 연결을, 어떤 시점에 어떤 코드가 실제로 호출할 것인지를 정하는 것 — 그 외 새로운 테이블/컬럼/클래스를 요구하는 항목은 PART1~3에서 발견되지 않았다.

---

## PART 6 — 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **369건 전부 통과**(`All tests passed!`) |

---

## PART 7 — 최종 결론

| 확인 항목 | 결과 |
|---|---|
| Booking Domain 분석 완료 | 완료(PART1) |
| 구현 범위 정의 완료 | 완료(PART5) |
| Baseline 영향 분석 완료 | 완료(PART4, No Baseline Impact) |

**"Booking Engine Domain Analysis Completed"**
