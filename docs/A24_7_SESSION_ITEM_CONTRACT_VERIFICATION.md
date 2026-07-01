# A-24.7: Session Item Contract Verification & Mapping Correction Design

> **목적**: A-25 구현 중단의 원인(A-24.5 계약의 `itemType: Product.id` 가 `addItem()`의 실제 검증과 충돌)을 해소하는 최종 계약을 확정한다. 설계만 수행, 코드 수정 없음.
> **근거**: A-24(`docs/A24_*.md`), A-24.5(`docs/A24_5_*.md`), A-24.6(`docs/A24_6_*.md`), A-25 중단 보고, `lib/features/session/data/session_repository.dart`(실제 `addItem()` 구현)
> 작성일: 2026-07-01

---

## PART 0 — 기준 계약

A-24/A-24.5/A-24.6/A-25 중단 보고와 현재 `SessionRepository.addItem()` 구현만 근거로 한다. 추론으로 새 구조를 만들지 않는다. 기존 코드와 기존 계약만 사용한다.

---

## PART 1 — `addItem()` 실제 계약 확인

`lib/features/session/data/session_repository.dart` 168행(`addItem()` 시그니처)과 177~179행(검증 로직) 직접 확인.

| 항목 | 실제 타입 | 실제 의미 | 근거 |
|---|---|---|---|
| `itemType` | `String`(required) | `_validItemTypes`(`'service'`/`'product'`/`'time'`/`'staff_fee'`/`'discount'`/`'surcharge'` 6개 문자열 중 하나) — 이 집합에 없으면 `ValidationException` 발생(`session_repository.dart` 177~179행) | `static const _validItemTypes = {'service','product','time','staff_fee','discount','surcharge'};`(86~93행) |
| `itemName` | `String`(required) | 품목 이름 스냅샷("당시 이름" — 원본이 나중에 바뀌어도 전표는 불변, `session_tables.dart` 61~63행 주석) | `session_tables.dart` 63행 `TextColumn get itemName` |
| `unitPrice` | `int`(required) | 단가(엔/원 단위, 정수) | `session_repository.dart` 169행, `session_tables.dart` 65행 |
| `refType` | `String?`(optional) | 느슨한 도메인 참조 분류(`'booking'`/`'plu'`/`'staff'`/`'manual'`, `session_tables.dart` 57행 주석) | `session_tables.dart` 57~58행 |
| `refId` | `String?`(optional) | 참조 도메인의 식별자(TEXT — 숫자 ID를 문자열로 저장) | `session_tables.dart` 59행 `TextColumn get refId` |

---

## PART 2 — A-24.5 계약과 실제 계약 비교

A-24.5(`docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md`) PART4 매핑 표 기준:

| 항목 | A-24.5 계약 | 실제 계약 | 결과 |
|---|---|---|---|
| `businessType` | External Contract Parameter(외부 주입) | `createSession()` `required String businessType` — A-24.5와 일치 | **Match** |
| `itemType` | `Product.id`(PART2 매핑 표 row: `itemType \| Product.id \| ProductRow`) | `_validItemTypes` 중 하나의 고정 문자열(`String`) — 정수 ID는 이 집합에 포함되지 않음 | **Conflict** |
| `itemName` | `Product.name`(ProductRow) | `String`(required) — 문자열 이름 | **Match** |
| `unitPrice` | `Product.price`(ProductRow) | `int`(required) — 정수 가격 | **Match** |
| `refType` | 상수 `'booking'` | `String?`, `'booking'`이 허용값으로 이미 존재 | **Match** |
| `refId` | `Booking.id` | `String?` — 정수 ID를 문자열로 저장하는 기존 관례(`test/features/session/session_repository_test.dart`의 `refId: '${rule.id}'` 사용 예 등) | **Match** |

**Conflict 1건**: `itemType: Product.id` → `_validItemTypes` 충돌. 이것이 A-25를 중단시킨 정확한 원인이다.

---

## PART 3 — `itemType` 의미 확정

| 후보 | 적합 여부 | 근거 |
|---|---|---|
| `Product.id`(정수, 또는 그 문자열화) | **Invalid** | `_validItemTypes = {'service','product','time','staff_fee','discount','surcharge'}` — 정수나 그 문자열화(`'1'`, `'2'` 등)는 이 집합에 포함되지 않으므로 `addItem()` 호출 시 항상 `ValidationException` 발생. 수정 금지된 `_validItemTypes` 집합을 바꾸지 않는 한 동작 불가. |
| `addItem()` 검증 집합의 기존 문자열(enum) | **Valid** | 코드에 이미 존재하는 6개 문자열 중 하나만 유효. Booking 예약 품목은 "살롱 시술 메뉴(메뉴 기반 서비스)"에 해당하며, `Booking` 도메인의 `computeEndAt()`(`booking_logic.dart` 4행)과 `Booking.productIdsCsv`(`createBooking()` 입력이 `List<int> productIds`)에서 이 Product들이 명백히 "시술 서비스"(서비스 시간이 있는 `durationMin` 컬럼, `product_tables.dart` 34행 주석 "시술시간(분)")라는 것이 코드로 확인된다. 따라서 `_validItemTypes`에서 의미상 가장 부합하는 것은 `'service'`이다. |

**`itemType`은 `'service'`로 확정한다.** 이 값은 `_validItemTypes` 내에 이미 존재하는 기존 문자열이며, Booking 도메인의 Product가 "시술 서비스"라는 것을 코드(`durationMin` 컬럼, `computeEndAt()`)로 확인한 데 근거한다 — 새 문자열을 추가하지 않는다.

---

## PART 4 — `Product.id`의 실제 매핑 위치 확인

A-24.5 계약의 원래 `itemType: Product.id`가 있던 자리는 오기(誤記)였다고 판단되며, `Product.id`가 실제로 `addItem()` 파라미터 중 어디에 들어가야 하는지를 검토한다.

| 후보 | 적합 여부 | 근거 |
|---|---|---|
| `refId` | **Invalid** | `refId`는 이미 A-24.5 계약에서 `Booking.id`(어떤 예약에서 온 아이템인지를 추적)로 확정됐다. `Product.id`로 덮어쓰면 "이 아이템이 어떤 예약에서 왔는가"라는 추적 정보가 사라진다. |
| `addItem()`의 기존 파라미터 중 `Product.id`와 의미가 일치하는 항목 | **Invalid** | `addItem()`의 기존 파라미터 목록(sessionId/itemType/refType/refId/itemName/qty/unitPrice/staffId/metaJson) 중 Product의 ID를 직접 저장하기에 의미상 맞는 별도 필드가 없다. `itemName`/`unitPrice`로 Product 데이터의 내용(이름/가격)은 이미 스냅샷되므로, ID를 별도로 저장하지 않아도 영수증 재현에 필요한 정보는 보존된다(A-8 스냅샷 원칙, `session_tables.dart` 61~63행). |
| **별도 사용 없음** | **Valid** | `Product.id`는 `ProductRow`를 조회하기 위한 키(`productIdsCsv`에서 파싱한 뒤, `watchProducts()` 결과에서 `where(p.id == id)`로 매칭)로만 사용되며, 매칭 완료 후 `itemName`/`unitPrice`가 추출되면 그 ID 자체를 `addItem()` 파라미터 어디에 저장할 필요가 없다. |
| 기존 코드 외 신설 위치 | **Invalid** | 새 필드/파라미터 추가는 구현 금지 대상. |

**`Product.id`는 조회 키로만 쓰이며, `addItem()` 파라미터에 별도로 저장되지 않는다.**

---

## PART 5 — 최종 계약 확정

A-24.5에서 Conflict였던 `itemType` 행만 수정하고, 나머지는 A-24.5 그대로 유지한다.

| 항목 | 최종 계약 | 출처 |
|---|---|---|
| `businessType` | External Contract Parameter(호출자로부터 `required`로 주입) | A-24.5(변경 없음) |
| `itemType` | `'service'`(상수, `_validItemTypes` 기존 집합 내 문자열) | **본 문서(PART3)에서 정정** |
| `itemName` | `Product.name`(`ProductRow`) | A-24.5(변경 없음) |
| `unitPrice` | `Product.price`(`ProductRow`) | A-24.5(변경 없음) |
| `refType` | `'booking'`(상수) | A-24.5(변경 없음) |
| `refId` | `Booking.id` → `String` 변환 | A-24.5(변경 없음) |

**이 표만 A-25 구현의 기준 계약으로 사용한다.**

---

## PART 6 — 영향 확인

| 대상 | 결과 | 근거 |
|---|---|---|
| Booking Contract | **No Impact** | `Bookings` 테이블 구조 변경 없음, `completeBooking()` 시그니처 변경 없음. |
| Session Contract | **No Impact** | `addItem()`의 기존 파라미터/시그니처/검증 로직 전부 무변경 — 계약이 기존 `_validItemTypes` 집합 안의 값을 사용하도록 정정됐을 뿐이다. |
| Product Contract | **No Impact** | `ProductRepository`/`Products` 테이블 변경 없음, 새 조회 메서드 추가 없음(A-24.6에서 확정된 `watchProducts()` + 메모리 매칭 전략 그대로 유지). |

---

## PART 7 — 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **Pass**(No issues found) |
| `flutter test`(전체) | **Pass** — 369건 전부 통과(`All tests passed!`), 코드 변경 없음. |

---

## 완료 기준 점검

| # | 항목 | 상태 |
|---|---|---|
| 1 | `addItem()` 실제 계약 확인 | ✅ PART1 — 5개 항목, 검증 집합 포함 |
| 2 | A-24.5 계약 비교 | ✅ PART2 — Conflict 1건(`itemType`) 특정 |
| 3 | `itemType` 의미 확정 | ✅ PART3 — `'service'`로 확정 |
| 4 | `Product.id` 실제 매핑 위치 확정 | ✅ PART4 — 별도 사용 없음(조회 키로만 사용) |
| 5 | 최종 계약 표 확정 | ✅ PART5 |
| 6 | `flutter analyze` Pass | ✅ PART7 |
| 7 | `flutter test` Pass | ✅ PART7 |

**"Session Item Mapping Contract Established"**
