# A-24: Booking Completion Caller Design Decision

> **목적**: A-23의 "선정 불가" 결론을 바탕으로, Booking 완료 후 Session을 생성할 호출자 구조를 설계 수준에서 확정한다. 새 아키텍처/계층/디렉터리 없음, 코드 수정 없음 — 설계 결정만 수행.
> **근거 산출물**: A-19 Baseline, A-20(`docs/A20_*.md`), A-21(`docs/A21_*.md`), A-22(`docs/A22_*.md`), A-23(`docs/A23_*.md`)
> 작성일: 2026-06-30

---

## PART 0 — 기준 원칙

A-19~A-23만 근거로 한다. 기존 구조를 우선 후보로 검토하고, 기존 구조가 설계 원칙을 만족하지 못하는 경우에만 기존 원칙을 유지하는 범위에서 단일 Caller 클래스 추가를 후보로 허용한다.

---

## PART 1 — 기존 호출 패턴 확인

| 패턴 | 구현 여부 | 근거 |
|---|---|---|
| Repository → Repository | **Implemented** | `payment_repository.dart`의 `PaymentRepository`가 `CustomerRepository.recordVisit()`(187~194행) 및 `PrepaidPassRepository.restoreUse()`(`cancelOrder()` 내부, A-12.9에서 확인된 선례)를 호출. `BookingRepository`도 생성자에서 `StaffRepository`를 직접 보유(`BookingRepository(this._db, this._staffRepository)`). |
| Workflow → Repository | **Not Implemented** | `SessionClosingWorkflow`는 `AppDatabase`와 `StaffEarningEngine`만 보유하며, 어떤 `Repository` 클래스도 의존하지 않는다(A-14 Phase 1 이후 구조 무변경). |
| Engine → Repository | **Not Implemented** | `PricingEngine`/`PromotionEngine`/`StaffEarningEngine` 전부 Drift/Repository를 모르는 순수 계산 클래스(ADR-001) — 이 패턴은 의도적으로 존재하지 않는다. |
| Screen / Provider → Repository | **Implemented** | 모든 화면이 `ref.read(xxxRepositoryProvider)` 형태로 Repository를 호출(예: `pos_order_screen.dart` 273행 `paymentRepositoryProvider.createOrder()`, `waiting_list_screen.dart` 129행 `bookingRepositoryProvider.callWaiting()`). |

---

## PART 2 — 호출자 후보 비교

| 후보 | 선택 가능 여부 | 근거 |
|---|---|---|
| 기존 Repository 확장 | **Rejected** | 세 가지 구체적 방식을 모두 검토했으나 전부 기존 원칙과 충돌: (1) `BookingRepository.completeBooking()` 자신을 확장 — A-22에서 확인된 `completeBooking()` docstring의 명시적 원칙("이 메서드 스스로 `CustomerRepository.recordVisit()`을 호출하지 않는다")과 정면으로 모순. (2) 구(舊) `PaymentRepository`를 확장 — `payment_repository.dart` 184~186행이 "예약경로 연동은 1차 범위 밖"이라 이미 명시적으로 보류했고, 구 `payment_pos` 파이프라인과 신 Session Engine은 A-12 시점부터 의도적으로 분리된 두 파이프라인이라 이 둘을 잇는 것은 기존 분리 원칙과 충돌. (3) `SessionRepository`를 확장해 `BookingRepository`에 의존하게 함 — `SessionRepository`의 기존 의존성은 전부 같은 시대(A-10~A-12)의 Pricing/Promotion/StaffEarning뿐이며, A-1~A-7 레거시 모듈(Booking 포함)에 의존한 적이 없다(`docs/A8_SESSION_ENGINE.md`의 "권한자 분리" 원칙과 결이 다름) — 새로운 역방향 의존을 만드는 셈이라 기각. |
| 기존 Workflow 확장 | **Rejected** | `SessionClosingWorkflow`는 A-15에서 "Session 종료 외 다른 목적이 없다"(`OK` 판정)로 이미 Baseline에 고정됐다 — Booking 완료라는 다른 종류의 절차를 추가하면 그 Baseline 판정을 직접 깬다. PART1에서도 Workflow→Repository 패턴 자체가 존재하지 않음을 확인. |
| 기존 Engine 확장 | **Rejected** | Engine은 Repository를 호출하지 않는다는 것이 ADR-001 이후 전 프로젝트에 걸쳐 일관된 불변량(PART1) — 위반 시 Pricing/Promotion/StaffEarning 3개 Engine 전체의 설계 근거가 흔들림. |
| 기존 Screen / Provider 확장 | **Rejected** | A-23에서 이미 확인된 대로, Booking 완료를 위한 화면/라우트 자체가 존재하지 않는다 — `PosOrderScreen`(구 파이프라인 전용)이나 `WaitingListScreen`(대기열 전용, 특정 예약 단위 동작 아님) 둘 다 의미상 맞지 않는 화면을 억지로 확장하는 것이라 기각. |
| 단일 Caller 클래스 추가 | **Selected** | 4개 조건 전부 충족: ① 기존 구조 4개 전부 위에서 Rejected(설계 원칙 만족 불가 확인됨). ② 기존 설계 원칙 유지 — `BookingRepository`/`SessionRepository`의 기존 메서드(`completeBooking()`/`createSession()`/`addItem()`)를 그대로 순서대로 호출할 뿐, 어느 것도 수정하지 않음. ③ 단일 책임 — "Booking 완료 후 Session 생성"이라는 절차 조율 하나만 수행. ④ 새 아키텍처 아님 — PART1에서 이미 확인된 "Repository → Repository" 패턴(예: `PaymentRepository → CustomerRepository`)과 구조적으로 동일한 모양이며, 단지 그 호출이 `BookingRepository` 자신의 메서드 안이 아니라 별도의 얇은 클래스로 옮겨진 것뿐 — A-22에서 확인된 "완료 메서드 자신이 아니라 그 호출자가 책임진다"는 기존 원칙을 그대로 따른 결과다. |

---

## PART 3 — A-8 설계와의 일치 여부

| 항목 | 결과 | 근거 |
|---|---|---|
| Booking 완료 후 Session 생성 구조와 일치 | **Match** | Caller는 `createSession()`/`addItem()`의 기존 시그니처를 그대로 호출할 뿐 새 매개변수나 새 분기를 요구하지 않는다(A-21/A-22에서 이미 확인된 시그니처 그대로). |
| `addItem(refType='booking')` 설계와 일치 | **Match** | `PaymentSessionItems.refType`/`refId`가 이미 `'booking'`을 허용값으로 가지고 있음(A-21 재확인) — Caller는 이 기존 매개변수에 `Booking.id`를 그대로 전달하기만 하면 된다. |
| 기존 Domain Boundary와 충돌 없음 | **Match** | Caller는 `BookingRepository`/`SessionRepository`의 내부 구현(Drift 직접 호출 등)을 건드리지 않고 두 Repository의 public 메서드만 호출한다 — `docs/A8_SESSION_ENGINE.md`의 "SessionRepository는 기존 4개 권한자의 쓰기 영역을 침범하지 않는다"는 원칙도 그대로 유지된다(Caller가 두 Repository "사이"에 있을 뿐, 어느 한쪽이 다른 쪽의 쓰기 영역에 침범하지 않음). |

---

## PART 4 — Phase 1 구현 구조 확정

| 선정된 호출자 | 파일 위치 | 선정 근거 |
|---|---|---|
| 단일 Caller 클래스(가칭 `BookingCompletionCaller`) | `lib/features/booking/data/booking_completion_caller.dart`(신규 파일 — `booking_repository.dart`와 같은 기존 `lib/features/booking/data/` 디렉터리, 새 디렉터리/계층 생성 없음) | PART2에서 "단일 Caller 클래스 추가"가 유일하게 `Selected`로 판정됨. 위치는 `lib/features/booking/data/`로 정한다 — Booking 완료라는 트리거 이벤트를 "소비"하는 지점이라는 점에서 기존 `BookingRepository`와 같은 디렉터리에 두는 것이 PaymentRepository(트리거를 소유한 쪽이 호출 코드를 보유)의 기존 배치 관례와 가장 가깝다. `BookingRepository`/`SessionRepository` 두 클래스를 생성자로 받아 `completeBooking()` → `createSession()` → `addItem()` 순서로 호출하는 것 외의 책임은 갖지 않는다. |

---

## PART 5 — Baseline 영향 확인

| Baseline | 결과 | 근거 |
|---|---|---|
| Session Closing Baseline | **No Impact** | Caller는 `createSession()`/`addItem()`만 호출하며, `closeSession()`/`SessionClosingWorkflow`/Transaction Boundary 중 어느 것도 참조하지 않는다 — A-21/A-23에서 이미 확정된 분리가 그대로 유지된다. |
| Booking Baseline | **No Impact**(해당 문서 없음) | `docs/baseline/`에는 `SESSION_CLOSING_BASELINE.md` 1개만 존재(A-23에서 이미 확인) — 별도 "Booking Baseline" 문서가 없어 영향을 평가할 대상 자체가 없다. |

---

## PART 6 — 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **369건 전부 통과**(`All tests passed!`) — 코드 변경 없음, 설계 결정 과정에서 어떤 코드도 수정되지 않았음을 확인. |

---

## PART 7 — 최종 결론

| 확인 항목 | 결과 |
|---|---|
| 호출자 구조가 하나로 결정되었는가 | 그렇다 — 단일 Caller 클래스(PART4) |
| 기존 프로젝트 구조와 충돌하지 않는가 | 충돌 없음(PART2의 Rejected 사유들이 곧 "기존 구조를 침범하지 않기 위한" 판단 근거였고, Selected안은 그 침범을 피한 결과) |
| Minimal Change 기준을 만족하는가 | 만족 — 신규 파일 1개, 기존 클래스/메서드 무수정 |
| Baseline에 영향을 주지 않는가 | 영향 없음(PART5) |
| A-25에서 구현할 파일 위치가 특정되었는가 | 특정됨 — `lib/features/booking/data/booking_completion_caller.dart` |
| A-25에서 호출해야 할 메서드 목록이 확정되었는가 | 확정됨 — `BookingRepository.completeBooking(bookingId)` → `SessionRepository.createSession(businessType, staffId, customerId, roomId)` → `SessionRepository.addItem(sessionId, itemType, refType: 'booking', refId: '<Booking.id>', ...)` |

**"Booking Completion Caller Design Established"**
