# A-23: Booking Completion Orchestrator Analysis

> **목적**: A-22에서 확정한 Booking → Session 연결 지점("`completeBooking()`을 호출하는 지점")을 기준으로, Booking 완료를 담당하는 상위 호출자(Orchestrator)를 현재 코드에 이미 존재하는 구조 중에서 하나 확정한다. 새 구조 제안 없음, 구현 없음, 분석만 수행.
> **대상 코드**: `lib/features/booking/screens/`, `lib/features/payment_pos/screens/`, `lib/core/router.dart`, `lib/features/session/workflow/session_closing_workflow.dart`
> **근거**: A-19 Baseline, A-20~A-22(`docs/A20~A22_*.md`)
> 작성일: 2026-06-30

---

## PART 0 — 기준 원칙

A-19 Baseline을 기준으로, A-20~A-22의 결론(Booking 7개 이벤트 전부 Session 미연결, `refType='booking'`은 `PaymentSessionItems` 레벨 설계, Session 생성 호출 위치는 "`completeBooking()`을 호출하는 지점"으로 확정됨)을 전제로 하고 반복 분석하지 않는다. 추론으로 새 흐름을 만들지 않는다.

---

## PART 1 — 기존 Completion 호출 패턴 확인

| 단계 | 구현 여부 | 근거 |
|---|---|---|
| `completeBooking()` 존재 여부 | **Implemented** | `booking_repository.dart` 304행, `Future<void> completeBooking(int bookingId)`. |
| Booking 완료 처리 존재 여부 | **Implemented** | 같은 메서드가 `Bookings.status`를 `'completed'`로 전환(A-22에서 이미 확인). |
| Payment 완료 처리 존재 여부 | **Implemented**(단, 구(舊) `payment_pos` 파이프라인) | `lib/features/payment_pos/screens/pos_order_screen.dart` 273행 `paymentRepositoryProvider.createOrder()`, 287행 `.pay()` — `Orders`/`Payments` 테이블 기반의 기존 파이프라인. **Session Engine(`SessionRepository`)과는 무관**(A-12 시점부터 "두 결제 파이프라인이 완전히 분리돼 있다"는 사실이 이미 확인돼 있던 것의 재확인). |
| Session 생성 호출 존재 여부 | **Not Implemented** | `createSession()` 호출 0건(A-20~A-22에서 반복 확인된 그대로, 본 turn에서도 재확인). |

---

## PART 2 — `completeBooking()` 호출 위치 확인

| 항목 | 상태 | 근거 |
|---|---|---|
| `completeBooking()` 정의 위치 | **Present** | `booking_repository.dart` 304행. |
| `completeBooking()` 실제 호출 수 | **0** | `grep -rn "completeBooking(" lib/` 결과 정의 1건 외 호출부 없음. `lib/features/booking/screens/waiting_list_screen.dart`(유일한 booking 화면)는 `callWaiting()`/`cancelWaiting()`/`addWaiting()`만 호출하며 `completeBooking()`은 호출하지 않는다. |
| 상위 호출 흐름 존재 여부 | **Not Present** | `lib/core/router.dart`(라우트 정의)에 Booking 완료/체크아웃/"来店完了"에 해당하는 라우트가 없다(정의된 라우트: `/pos`, `/products`, `/staff`, `/customers`, `/waiting`, `/prepaid-pass`, `/coupons`, `/store-open`, `/inventory`, `/sales-report` — Booking 완료 화면 없음). |

---

## PART 3 — A-8 설계와의 일치 여부 확인

| 항목 | 결과 | 근거 |
|---|---|---|
| Booking → Session 연결 방식 정의 여부 | **Match** | A-8(`docs/A8_SESSION_ENGINE.md` 14행)이 `refType='booking'`/`refId=<Booking.id>` 연결 방식을 이미 정의(A-21에서 확정). |
| 현재 코드와 A-8 연결 방식 일치 여부 | **Match** | `PaymentSessionItems.refType`/`refId` 컬럼이 `'booking'`을 허용값으로 이미 포함(`session_tables.dart` 57~59행, A-21 재확인) — 스키마 차원의 불일치 없음. |
| `addItem()` 기반 연결 방식 일치 여부 | **Match** | `addItem()`의 기존 매개변수(`refType`/`refId`, `session_repository.dart` 168행 시그니처)가 A-8 설계와 그대로 부합(A-21 재확인). |

A-8 설계 자체와의 불일치는 없다 — 미구현인 것은 설계와의 충돌이 아니라 "아직 연결되지 않았다"는 사실이다.

---

## PART 4 — Phase 1 Orchestrator 선정

**선정 불가.**

| 검토한 후보 | 선정 불가 사유 |
|---|---|
| `completeBooking()` 자신 | A-22에서 이미 확정 — 완료 처리 메서드 자신이 다른 도메인을 호출하지 않는다는 기존 원칙(`A1_A2_BOUNDARY.md`, `payment_repository.dart` 180~195행 선례)과 어긋나 후보에서 제외됨. |
| `WaitingListScreen`(`lib/features/booking/screens/waiting_list_screen.dart`) | `callWaiting()`/`cancelWaiting()`/`addWaiting()`만 호출하는 대기열 전용 화면(F-BOOK-03, `Bookings`와 FK 없는 별개 도메인, A-20에서 이미 확인) — Booking 완료나 Payment/Session과 무관. |
| `PosOrderScreen`(`lib/features/payment_pos/screens/pos_order_screen.dart`) | `paymentRepositoryProvider.createOrder()`/`.pay()`만 호출 — 구 `payment_pos` 파이프라인(`Orders`/`Payments`)이며 `SessionRepository`를 전혀 참조하지 않는다. Booking과의 연결 코드도 없다(`payment_repository.dart` 184~186행 주석이 "예약경로 연동은 1차 범위 밖"이라고 명시적으로 보류한 사실 그대로). |
| `SessionClosingWorkflow`(`lib/features/session/workflow/session_closing_workflow.dart`) | Session **마감**(`closeSession()`) 절차 전용 — Booking 완료(세션 생성 **이전** 단계)와는 방향이 반대라 후보가 될 수 없다. |
| Orchestrator/Coordinator/UseCase/Service류 클래스 | 코드베이스 전체에 이런 이름의 클래스가 **0개**(`grep` 결과) — 이 프로젝트는 지금까지 Repository/Engine/Workflow 3종 구조만 사용해 왔고(ADR-001 등), 그 어떤 기존 패턴도 "Booking 완료 + Session 생성"을 동시에 조율하는 위치로 적합하지 않다. |

**선정 기준("현재 코드에 이미 존재하는 구조 중에서") 자체를 만족하는 후보가 코드에 없다.** 이는 분석 미비가 아니라, 실제로 그런 호출자가 아직 만들어지지 않았다는 사실의 확인이다.

---

## PART 5 — Baseline 영향 확인

| Baseline | 영향 여부 | 근거 |
|---|---|---|
| Session Closing Baseline(`docs/baseline/SESSION_CLOSING_BASELINE.md`) | **No Impact** | PART1~4에서 조사한 모든 코드(`BookingRepository`, `WaitingListScreen`, `PosOrderScreen`)가 `SessionRepository.closeSession()`/`SessionClosingWorkflow`/Transaction Boundary 중 어느 것도 참조하지 않는다 — A-21에서 이미 확정된 결론 재확인. |
| Booking Baseline | **해당 문서 없음**(영향 평가 대상 자체가 존재하지 않음) | `docs/baseline/` 디렉터리에는 `SESSION_CLOSING_BASELINE.md` 1개 파일만 존재한다(`ls docs/baseline/` 확인) — "Booking Baseline"이라는 별도 확정 문서가 아직 만들어지지 않았으므로, "영향 여부"를 판정할 대상 자체가 없다. |

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
| 호출자 후보가 하나로 확정되었는가 | **아니오** — PART4에서 검토한 5개 후보 전부 선정 불가로 확인됨. |
| 기존 구조와 충돌하지 않는가 | 충돌 없음(선정한 것이 없으므로 충돌도 없음) |
| Minimal Change 기준을 만족하는가 | 평가 대상 없음(선정된 후보가 없어 적용할 수 없음) |
| Baseline에 영향을 주지 않는가 | 영향 없음(PART5) |
| A-24에서 수정할 파일 위치가 특정되었는가 | **아니오** — 기존 파일 중 "여기를 고치면 된다"고 가리킬 위치가 없다(PART4의 5개 후보 전부 부적합). |
| A-24에서 호출해야 할 메서드 목록이 확정되었는가 | **부분적으로만** — 호출할 메서드 자체(`completeBooking()`→`createSession()`→`addItem(refType='booking', refId=...)`)는 A-22에서 이미 확정돼 있으나(시그니처는 PART1~3에서 재확인됨), 그 메서드들을 **어디서** 호출할지(호출자)는 여전히 미정이다. |

### 결론

PART4의 결과가 "선정 불가"이므로, **본 문서는 "Booking Completion Orchestrator Analysis Completed"를 명시하지 않는다.** 지시문 PART4가 명시적으로 이 가능성을 예상하고 절차("선정하지 말고 선정 불가 사유만 기록")를 제공했으므로, 이는 분석이 실패한 것이 아니라 **"현재 코드에는 이 역할을 할 기존 구조가 없다"는 사실이 근거를 갖고 확인된 것**이다.

**정확한 결론**: Booking 완료와 Session 생성을 연결할 호출 메서드 자체(무엇을, 어떤 순서로)는 A-21/A-22에서 이미 확정됐으나, 그것을 호출할 **위치(누가)**는 기존 코드 어디에도 없다 — A-24는 "기존 호출자 안에 코드를 추가하는 작업"이 아니라 **"새 호출자를 어떤 형태로 만들지 결정하는 작업"**으로 범위를 좁혀야 한다(단, 이는 본 문서가 제안하는 것이 아니라, PART4의 사실 확인이 가리키는 다음 단계일 뿐이다).
