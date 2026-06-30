# A-24.5: Booking → Session Data Ownership & Mapping Design

> **목적**: A-25 구현(`BookingCompletionCaller`)에 필요한 입력 데이터의 "소유 위치"와 "매핑 규칙"을 확정한다. A-24가 확정한 Caller 구조는 변경하지 않는다. 설계만 수행, 코드 변경 없음.
> **배경**: A-25 구현 시도 중 `createSession()`의 `businessType`(필수)과 `addItem()`의 `itemType`/`itemName`/`unitPrice`가 `Bookings` 테이블에 존재하지 않아 중단됨(추가 오더 필요로 기록) — 본 문서가 그 후속 오더.
> **근거**: A-19~A-24(`docs/A19~A24_*.md`, `docs/baseline/SESSION_CLOSING_BASELINE.md`)
> 작성일: 2026-06-30

---

## PART 0 — 기준 원칙

A-19~A-24만 근거로 한다. A-24가 확정한 Caller 구조(`BookingCompletionCaller`, `lib/features/booking/data/booking_completion_caller.dart`)는 변경 대상이 아니다. 추론으로 새 데이터 구조를 만들지 않고, 기존 코드(`Bookings`/`Products` 테이블, `createSession()`/`addItem()` 시그니처)에 실제로 존재하는 정보만 근거로 한다.

---

## PART 1 — Session 생성 필수 데이터 정의(`createSession()` 기준)

| 필드 | 필수 여부 | 현재 소스 위치(Booking 기준) | 비고 |
|---|---|---|---|
| `businessType` | Required | **Undefined in Booking** | `Bookings` 테이블(`booking_tables.dart` 17~45행)에 해당 컬럼 없음 — 계약 필요(PART5). |
| `staffId` | Optional | `Booking.staffId` | direct mapping(타입 일치: 둘 다 `int?`). |
| `customerId` | Optional | `Booking.customerId` | `Booking.customerId`는 non-nullable(`int`)이지만 `createSession()`의 `customerId`는 `int?` — 타입 호환(non-null을 nullable에 대입 가능), direct mapping. |
| `roomId` | Optional | **Not exists in Booking**(코드 확인 결과 정정) | `Bookings` 테이블에 `roomId` 컬럼 자체가 없음(salon 전용 예약 모듈이라 카라오케/이자카야의 룸 개념이 애초에 없음, A-20에서 이미 확인된 배경과 일치) — `null`로 전달하는 것이 유일한 선택지. |

---

## PART 2 — `addItem()` 데이터 정의

| 필드 | 필수 여부 | 현재 소스 위치(Booking 기준) | 비고 |
|---|---|---|---|
| `refType` | Required | 상수 `'booking'` | 고정값(A-8/A-21에서 이미 확정된 허용값). |
| `refId` | Required | `Booking.id` | direct mapping(단, `addItem()`의 `refId`는 `String?` 타입이므로 `int`→`String` 변환 필요 — 이미 기존 코드에서도 같은 변환 관례가 있음, 예: A-12 테스트의 `refId: '${rule.id}'`). |
| `itemType` | Required | **Undefined in Booking** | mapping 필요(PART3/4). |
| `itemName` | Required | **Undefined in Booking** | mapping 필요 — `Products.name`(`product_tables.dart` 24행, `TextColumn`)이 실제 소유 위치(코드 확인). |
| `unitPrice` | Required | **Undefined in Booking** | mapping 필요 — `Products.price`(`product_tables.dart` 27행, `IntColumn`)가 실제 소유 위치(코드 확인). |

---

## PART 3 — 데이터 소유권 규칙 정의

1. **`Bookings` 테이블은 "예약 원본 데이터"만 가진다** — 코드 확인 결과와 일치(고객/담당자/시간/보증금/메모 등, 가격·상품명 정보는 없음).
2. **Session 생성 필수 데이터는 Booking 외부에서 공급 가능해야 한다** — `businessType`이 정확히 이 경우에 해당.
3. **`itemType`/`itemName`/`unitPrice`는 Booking이 아닌 Product 도메인 책임이다** — `Products.name`/`Products.price`가 실제 소유자임을 코드로 확인(PART2).
4. **`businessType`은 시스템 레벨 분류 값이며 Booking에서 직접 유도하지 않는다** — `Bookings`에 그런 컬럼/유도 가능한 필드가 없으므로 이 규칙은 추론이 아니라 사실 확인과 일치한다.

---

## PART 4 — Mapping 규칙 확정

| 항목 | 매핑 방식 |
|---|---|
| `staffId` | `Booking.staffId` → direct |
| `customerId` | `Booking.customerId` → direct |
| `roomId` | 소스 없음 → `null` 고정(Booking에 컬럼 자체가 없으므로 "매핑"이 아니라 "항상 미지정") |
| `refType` | 상수 `'booking'` |
| `refId` | `Booking.id` → `String` 변환 후 direct |
| `itemType` | Product lookup 필요 |
| `itemName` | Product lookup 필요(`Products.name`) |
| `unitPrice` | Product lookup 필요(`Products.price`) |
| `businessType` | External Contract Parameter(PART5) |

---

## PART 5 — 외부 계약(Caller Input Contract) 정의

`BookingCompletionCaller`는 다음 데이터를 **외부에서 받을 수 있다**(A-24의 Caller 구조 자체는 변경하지 않음 — Caller의 메서드가 받는 입력 계약만 정의):

- `businessType`(required) — 호출 시점에 외부에서 명시적으로 전달.
- Product lookup 수단(optional injection 또는 Repository) — **이 단계에서는 "필요성"만 확정하고, 구체적 조회 방식(어떤 Repository를, 어떤 형태로)은 정하지 않는다**(PART6에서 재확인).
- `Booking` entity(required) — `completeBooking()` 호출 이후 또는 호출 전에 `BookingRepository`로부터 조회된 값.

**금지(변경하지 않는 것)**: `Bookings` 테이블 구조 변경, `PaymentSessions`/`PaymentSessionItems` 구조 변경, `Products` 테이블 구조 변경. 본 PART는 기존 3개 테이블 구조를 그대로 둔 채, 그 사이를 잇는 **계약(매개변수)**만 정의한다.

---

## PART 6 — A-25 연결 규칙 확정

A-25에서 구현할 흐름:

1. `BookingCompletionCaller` 호출(외부로부터 `businessType` + Product lookup 수단을 계약대로 전달받음, PART5)
2. `createSession()` 실행 — PART1/PART4 매핑 그대로(`staffId`/`customerId` direct, `roomId`는 항상 `null`, `businessType`은 외부 계약값)
3. Booking 기반 Session 생성(위 2단계의 결과)
4. Product 기반 `addItem()` 생성 — PART2/PART4 매핑 그대로(`itemType`/`itemName`/`unitPrice`는 Product lookup 결과)

**Product 조회 방식(어떤 Repository의 어떤 메서드를 쓸지, 1개 상품만 다룰지 `productIdsCsv`의 여러 상품을 순회할지 등)은 본 문서에서 선택하지 않는다 — "Product 도메인 책임"이라는 소유권과 "lookup이 필요하다"는 사실만 확정한다.** 구체적 조회 방식은 A-25(또는 그 사이의 별도 설계 오더)에서 정한다.

---

## PART 7 — Baseline 영향 확인

| Baseline | 결과 | 근거 |
|---|---|---|
| Session Closing Baseline | **No Impact** | 본 문서는 `createSession()`/`addItem()`의 기존 시그니처를 그대로 사용하는 매핑 규칙만 정의 — `closeSession()`/`SessionClosingWorkflow`/Transaction Boundary와 무관(A-21/A-24에서 이미 확정된 분리 유지). |
| Booking Baseline | **No Impact**(해당 문서 없음) | A-23/A-24에서 이미 확인된 그대로 `docs/baseline/`에 Booking 전용 Baseline 문서가 없음 — `Bookings` 테이블 구조 변경도 없음(PART5 금지 사항). |
| Pricing/Product Baseline | **Review**(단, 별도 Baseline 문서 없음) | `docs/baseline/`에는 `SESSION_CLOSING_BASELINE.md` 1개만 존재하며 "Pricing/Product Baseline"이라는 확정 문서 자체가 없다 — 다만 `itemType`/`itemName`/`unitPrice`의 Product lookup이 향후 `ProductRepository`(또는 `PricingEngine`)와 새로운 호출 관계를 만들 가능성이 있다는 점에서, 영향이 없다고 단정하기보다 "구체적 조회 방식이 정해지는 시점에 재검토 필요"로 표시한다. |

---

## PART 8 — 기준선 검증

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test`(전체) | **369건 전부 통과**(`All tests passed!`) — 코드 변경 없음. |

---

## PART 9 — 최종 결론

| 확인 항목 | 결과 |
|---|---|
| Session 필수 데이터 소유 위치 확정 | 확정됨(PART1) — `staffId`/`customerId`는 Booking 소유, `businessType`은 Booking 외부 계약, `roomId`는 Booking에 컬럼 자체가 없어 항상 `null`. |
| addItem 데이터 소유 위치 확정 | 확정됨(PART2) — `refType`/`refId`는 Booking 기반 고정/매핑, `itemType`/`itemName`/`unitPrice`는 Product 도메인 소유(코드로 확인된 `Products.name`/`Products.price`). |
| businessType 계약 정의 완료 | 완료(PART5) — `BookingCompletionCaller`의 입력 계약(External Contract Parameter)으로 정의. |
| Product mapping 필요성 명확화 | 명확화됨(PART3/PART6) — 필요성만 확정, 구체적 조회 방식은 본 문서 범위 밖으로 명시적으로 남김. |
| A-25 구현 입력 계약 확정 | 확정됨(PART4/PART5 매핑표 그대로 A-25가 따를 계약) |
| 기존 구조 변경 없음 | 변경 없음(PART8, `flutter analyze`/`test` 기준선 무변화로 확인) |

**"Booking Session Data Ownership Contract Established"**
