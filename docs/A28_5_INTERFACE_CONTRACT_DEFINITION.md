# A-28.5: Interface Contract Definition (Milestone 2)

> 이 문서는 Milestone 2 구현 전에 필요한 Interface Contract를 정의한다.
> **제약**: Interface Contract 정의만 수행. 코드 수정 금지. 구현 금지. 새로운 Requirement 생성 금지. 구현 전략 결정 금지.
> **기준 자료**: `docs/A28_DESIGN_DEFINITION.md`, `docs/A27_REQUIREMENT_ANALYSIS.md`, `docs/A26_REQUIREMENT_DEFINITION.md`, `docs/ARCHITECTURE_SUMMARY.md`, `docs/DECISION_HISTORY.md`, 실제 코드, ADR
> 작성일: 2026-07-05

---

## PART 0.5 — Design Baseline Verification

A-28 PART 7에서 확인된 Design 상태:

| Design Decision | 상태 | Contract 포함 여부 |
|---|---|---|
| **D-1** `BookingCompletionCaller` Provider 등록 | 일부 정의됨 | 포함 — 확인된 범위 안에서 |
| **D-2** 예약 완료 UI 화면 신규 파일 | 일부 정의됨 | 포함 — 확인된 범위 안에서 |
| **D-3** 라우트 추가 | 일부 정의됨 | 포함 — 확인된 범위 안에서 |
| **D-4** `WaitingListScreen` 완료 액션 연결 | 일부 정의됨 | 포함 — 확인된 범위 안에서 |
| **D-5** 회귀 Baseline 문서 작성 | 일부 정의됨 | 포함 — 확인된 범위 안에서 |
| **D-6** 운영자용 흐름 문서 작성 | 일부 정의됨 | 포함 — 확인된 범위 안에서 |
| **D-7** `BookingRepository.getBookingById()` 추가 | 정의됨 | 포함 |
| **D-8** `addItem()` 순차 → `Future.wait()` 병렬화 | 정의됨 | 포함 |
| **D-9** silent skip → 명시적 정책 | 일부 정의됨 | 포함 — 확인된 범위 안에서 |

---

## PART 1 — Interface Contract Inventory

| Design Decision | 관련 Requirement | Contract 대상 Interface | 상태 |
|---|---|---|---|
| **D-1** `BookingCompletionCaller` Provider | REQ-A26 | `bookingCompletionCallerProvider` — `Provider<BookingCompletionCaller>` | 일부 정의됨 |
| **D-4** 완료 액션 → Caller 호출 | REQ-A26 | `BookingCompletionCaller.complete({required BookingRow, required String businessType})` | 일부 정의됨 |
| **D-7** `getBookingById()` | REQ-M2-1 | `BookingRepository.getBookingById(int id)` | 정의됨 |
| **D-8** `addItem()` 병렬화 | REQ-M2-2 | `BookingCompletionCaller.complete()` — 외부 관찰 계약(호출자 관점) | 정의됨 |
| **D-9** 미매칭 상품 명시적 정책 | REQ-M2-3 | `BookingCompletionCaller.complete()` — 미매칭 상품 처리 외부 계약 | 일부 정의됨 |

> D-2(화면 파일), D-3(라우트), D-5(Baseline 문서), D-6(운영자 문서): Interface가 아닌 파일/문서 산출물이므로 이 목록에 포함하지 않는다.

---

## PART 2 — Interface Contract Definition

### IC-1: `bookingCompletionCallerProvider`

| 항목 | 내용 |
|---|---|
| **Interface** | `bookingCompletionCallerProvider` |
| **입력** | 없음 (Riverpod `Provider<T>` — DI로 의존 자동 주입) |
| **출력** | `BookingCompletionCaller` 인스턴스 |
| **반환형** | `Provider<BookingCompletionCaller>` |
| **Nullable 여부** | Non-nullable |
| **호출 주체** | UI 위젯 또는 화면(`WidgetRef.read(bookingCompletionCallerProvider)`) |
| **호출 대상** | Riverpod Provider container |
| **근거** | `lib/features/booking/data/booking_completion_caller.dart`: `BookingCompletionCaller` 생성자 3개 주입(`BookingRepository`, `SessionRepository`, `ProductRepository`). `lib/features/booking/providers.dart`: `bookingRepositoryProvider` 패턴 현존. |

### IC-2: `BookingCompletionCaller.complete()`

| 항목 | 내용 |
|---|---|
| **Interface** | `BookingCompletionCaller.complete({required BookingRow booking, required String businessType})` |
| **입력 1** | `booking`: `BookingRow` (required, non-nullable) — 완료 처리할 예약 엔티티. 호출자가 사전 조회 후 전달. |
| **입력 2** | `businessType`: `String` (required, non-nullable) — 세션 생성에 사용할 업종 유형. 호출자가 외부에서 전달. |
| **출력** | 없음 (`Future<void>`) |
| **반환형** | `Future<void>` |
| **Nullable 여부** | 반환값 없음 |
| **호출 주체** | UI 위젯(예약 완료 화면 또는 `WaitingListScreen`) |
| **호출 대상** | `BookingCompletionCaller` |
| **예외 가능** | `NotFoundException`, `BusinessRuleException`, `DatabaseException` — `BookingRepository.completeBooking()` 및 `SessionRepository.createSession()`/`addItem()`이 throw하는 예외가 전파됨(`booking_completion_caller.dart` 내 try-catch 없음 확인) |
| **근거** | `booking_completion_caller.dart:31~35`: 시그니처 확인. `ARCHITECTURE_SUMMARY.md` §4: "`businessType`은 외부 주입". `DECISION_HISTORY.md` A-24.5: "`businessType`=외부주입 — 내부 결정/하드코딩은 계약 위반". |

### IC-3: `BookingRepository.getBookingById(int id)`

| 항목 | 내용 |
|---|---|
| **Interface** | `BookingRepository.getBookingById(int id)` |
| **입력** | `id`: `int` (non-nullable) — 조회할 `BookingRow.id` |
| **출력** | 해당 `id`를 가진 `BookingRow`. 존재하지 않으면 `null`. |
| **반환형** | `Future<BookingRow?>` |
| **Nullable 여부** | 반환값 nullable (`BookingRow?`) |
| **호출 주체** | UI 위젯 또는 `BookingCompletionCaller`의 호출자 |
| **호출 대상** | `BookingRepository` |
| **근거** | `A28_DESIGN_DEFINITION.md` D-7: "메서드 시그니처 형태(`Future<BookingRow?> getBookingById(int id)`) 정의됨". `MARK2_IDEAS.md` (Repository 분류): "ID 기준 단건 조회 메서드가 없어 호출자가 pre-fetch해야 한다". `booking_repository.dart:18`: 기존 `watchBookings()` Stream 반환 패턴 참조. |

### IC-4: `BookingCompletionCaller.complete()` — 호출자 관점 계약 (D-8 관련)

| 항목 | 내용 |
|---|---|
| **Interface** | `BookingCompletionCaller.complete()` — 외부에서 관찰 가능한 계약 (D-8 병렬화 후에도 유지) |
| **입력** | IC-2와 동일 |
| **출력** | `Future<void>` — 모든 `addItem()` 완료 후 resolve |
| **반환형** | `Future<void>` |
| **Nullable 여부** | 반환값 없음 |
| **호출 주체** | UI 위젯 |
| **호출 대상** | `BookingCompletionCaller` |
| **계약 유지 조건** | D-8(`Future.wait()` 병렬화) 구현 후에도 이 Interface의 입력/출력/반환형/Nullable 여부는 변경되지 않는다. |
| **근거** | `A28_DESIGN_DEFINITION.md` D-8: "for loop await → `Future.wait(futures)` 형태로 변경" — 내부 구현 변경이며 외부 시그니처는 IC-2와 동일하게 유지. `DECISION_HISTORY.md` A-25: "병렬화는 MARK2 아이디어로 이관" — 계약 변경 없이 내부만 변경. |

### IC-5: `BookingCompletionCaller.complete()` — 미매칭 상품 처리 외부 계약 (D-9 관련)

| 항목 | 내용 |
|---|---|
| **Interface** | `BookingCompletionCaller.complete()` — 미매칭 상품 처리 외부 관찰 계약 |
| **입력** | IC-2와 동일 |
| **출력** | `Future<void>` |
| **반환형** | `Future<void>` |
| **Nullable 여부** | 반환값 없음 |
| **호출 주체** | UI 위젯 |
| **호출 대상** | `BookingCompletionCaller` |
| **미확인 항목** | `productIdsCsv`에 없는 Product ID 존재 시 외부에서 관찰 가능한 계약 — throw인지 silent인지 문서에서 확인되지 않음 (`MARK2_IDEAS.md`: "로깅/예외" 두 가지 언급, 선택 미확인). 구체적 정책 형태는 PART 5에 기재. |
| **근거** | `A28_DESIGN_DEFINITION.md` D-9: "변경 위치 정의됨. 구체적 정책 형태 미확인". `MARK2_IDEAS.md` (Technical Debt): "로깅/예외가 없어 운영 시 추적이 어렵다". `booking_completion_caller.dart:57~59`: 현재 `if (product == null) continue;` |

---

## PART 3 — Responsibility Definition

| Component | 책임 | 근거 |
|---|---|---|
| **`bookingCompletionCallerProvider`** | `BookingCompletionCaller` 인스턴스를 Riverpod container에서 제공. 3개 의존(`bookingRepositoryProvider`, `sessionRepositoryProvider`, `productRepositoryProvider`)을 주입. | `lib/features/booking/providers.dart` 패턴 — `bookingRepositoryProvider` 생성자 주입 방식. `booking_completion_caller.dart:21~33`: 생성자 3개 주입 확인. |
| **`BookingCompletionCaller`** | `complete()` 메서드를 통해 예약 완료 처리 흐름을 조율. 3개 Repository(`BookingRepository`, `SessionRepository`, `ProductRepository`) 호출 순서 조율. 내부 처리 오류가 발생하면 그대로 예외 전파. | `ARCHITECTURE_SUMMARY.md` §3: "Caller는 두 Repository와 ProductRepository를 생성자 주입으로 받아 순서대로 호출하기만 한다." `booking_completion_caller.dart`: try-catch 없음, 예외 전파 구조 확인. |
| **`BookingRepository`** | `completeBooking(int id)`: 예약 상태를 'completed'로 변경. 예약 미존재/이미 완료/취소·노쇼 상태인 경우 예외 throw. `getBookingById(int id)`: ID 기준 단건 예약 조회, 미존재 시 null 반환. | `booking_repository.dart:304~328`: `completeBooking()` 구현 확인. `A28_DESIGN_DEFINITION.md` D-7: `getBookingById()` 추가 설계. |
| **`SessionRepository`** | `createSession()`: 세션 생성 및 `PaymentSessionRow` 반환. `addItem()`: 지정 세션에 품목 추가. `status='open'`인 세션에만 허용. | `session_repository.dart:103~135`: `createSession()`. `session_repository.dart:168~`: `addItem()`. |
| **`ProductRepository`** | `watchProducts()`: 전체 상품 Stream 제공. `.first`로 현재 시점의 전체 상품 목록 1회 조회에 사용. | `lib/features/product/providers.dart:13`: `productRepositoryProvider`. `ARCHITECTURE_SUMMARY.md` §6: "`watchProducts().first` + 메모리 매칭 전략". |
| **예약 완료 UI 화면** | 사용자 액션으로 `bookingCompletionCallerProvider`를 통해 `complete(booking, businessType)` 호출. `businessType`을 외부에서 결정해 전달. | `A28_DESIGN_DEFINITION.md` D-2/D-4. `ARCHITECTURE_SUMMARY.md` §4: "`businessType` 외부 주입 — required String". |

---

## PART 4 — Contract Traceability

| Contract | Requirement | Analysis | Design | 근거 코드 | 근거 Commit |
|---|---|---|---|---|---|
| **IC-1** `bookingCompletionCallerProvider` | REQ-A26: `MILESTONE_1` §7 "Provider 미등록 — A-26에서 검토" | `A27_REQUIREMENT_ANALYSIS.md` PART 2: "Provider 없음 확인" | `A28_DESIGN_DEFINITION.md` D-1 | `lib/features/booking/providers.dart:1~17` | 미확인 |
| **IC-2** `complete()` 시그니처 | REQ-A26: `MILESTONE_1` §7 "UI 연동 미구현" | `A27_REQUIREMENT_ANALYSIS.md` PART 2: "completeBooking() UI 호출 0건" | `A28_DESIGN_DEFINITION.md` D-4 | `booking_completion_caller.dart:31~35` | `a12190b` (A-25 구현 커밋) |
| **IC-3** `getBookingById()` | REQ-M2-1: `MARK2_IDEAS.md` "단건 조회 메서드 없음" | `A27_REQUIREMENT_ANALYSIS.md` PART 2: "메서드 목록 확인됨, 해당 메서드 없음" | `A28_DESIGN_DEFINITION.md` D-7 | `booking_repository.dart` 공개 메서드 목록 | 미확인 |
| **IC-4** `complete()` 병렬화 외부 계약 | REQ-M2-2: `MARK2_IDEAS.md` "Future.wait() 병렬화" | `A27_REQUIREMENT_ANALYSIS.md` PART 2: "순차 for loop 존재, 보류 사유 확인" | `A28_DESIGN_DEFINITION.md` D-8 | `booking_completion_caller.dart:51~65` | `a12190b` (A-25 구현, DECISION_HISTORY A-25 병렬화 MARK2 이관 기재) |
| **IC-5** `complete()` 미매칭 외부 계약 | REQ-M2-3: `MARK2_IDEAS.md` "로깅/예외 없어 추적 어렵다" | `A27_REQUIREMENT_ANALYSIS.md` PART 2: "silent skip 존재, 보류 사유 확인" | `A28_DESIGN_DEFINITION.md` D-9 | `booking_completion_caller.dart:57~59` | `a12190b` (A-25 구현, DECISION_HISTORY A-25 로직 추가 금지 MARK2 이관 기재) |

---

## PART 5 — Interface Evidence Missing Observation

| Interface | 미확인 항목 | 근거 |
|---|---|---|
| **IC-1** `bookingCompletionCallerProvider` | Provider 타입(`Provider<T>` vs `AutoDisposeProvider<T>`) — 어느 것을 사용할지 기존 Provider 패턴 비교 가능하나 명시적 결정 문서 없음 | `lib/features/booking/providers.dart:7`: `bookingRepositoryProvider`가 `Provider<BookingRepository>` (non-autodispose). 다른 providers.dart도 동일 패턴이나 A-28에서 명시 결정 없음. |
| **IC-2** `complete()` | `businessType` 전달 값 — 어떤 값을 사용해야 하는지 문서에 명시되지 않음 | `A28_DESIGN_DEFINITION.md` PART 6: "`businessType` 전달 값 미확인". `A27_REQUIREMENT_ANALYSIS.md` PART 4: 미확인 항목. |
| **IC-2** `complete()` | 어떤 UI 이벤트가 `complete()`를 호출해야 하는지 — 호출 트리거 미정 | `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8: "어떤 UI 이벤트가 `complete()`를 호출해야 하는지" 미정. `A28_DESIGN_DEFINITION.md` PART 6 기재. |
| **IC-5** `complete()` 미매칭 처리 | 미매칭 상품 발생 시 외부 관찰 가능한 동작 — throw 여부, 어떤 예외 타입인지 미확인 | `MARK2_IDEAS.md`: "로깅/예외" 두 가지 언급, 어느 것인지 미결정. `A28_DESIGN_DEFINITION.md` D-9: "구체적 정책 형태(로깅 vs 예외) 미확인". |

---

## PART 6 — Contract Completeness Observation

| Interface | 상태 | 근거 |
|---|---|---|
| **IC-1** `bookingCompletionCallerProvider` | 일부 정의됨 | 입력/출력/반환형 정의됨. Provider 타입(`AutoDispose` 여부) 미확인. |
| **IC-2** `BookingCompletionCaller.complete()` 시그니처 | 일부 정의됨 | 입력/출력/반환형/예외 정의됨. `businessType` 전달 값, 호출 트리거(UI 이벤트) 미확인. |
| **IC-3** `BookingRepository.getBookingById()` | 정의됨 | 입력/출력/반환형/Nullable 여부 전부 정의됨. |
| **IC-4** `complete()` 병렬화 외부 계약 | 정의됨 | D-8 이후에도 IC-2와 동일한 외부 계약 유지됨. 내부 구현 변경이므로 외부 관찰 계약 변화 없음. |
| **IC-5** `complete()` 미매칭 처리 외부 계약 | 일부 정의됨 | 변경 위치 정의됨. 미매칭 발생 시 throw 여부(외부 관찰 동작) 미확인. |

---

## Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found!
```

결과: **Pass**

### flutter test

```
+372: All tests passed!
```

결과: **Pass (372건)**

코드 변경 없음. 이 문서는 순수 Interface Contract 정의 작업이다.

---

**"Interface Contract Definition Established"**
