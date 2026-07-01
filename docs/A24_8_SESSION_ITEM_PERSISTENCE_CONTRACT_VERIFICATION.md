# A-24.8: Session Item Persistence Contract Verification

> **목적**: A-24.7에서 확정한 Session Item Mapping Contract가 실제 `PaymentSessionItems` 저장 구조 및 `addItem()` 파라미터와 완전히 일치하는지 검증한다. 설계 검증만 수행, 코드 수정 없음.
> **근거**: A-24~A-24.7(`docs/A24_*.md`), `lib/features/session/data/session_tables.dart`(49~77행), `lib/features/session/data/session_repository.dart`(168~179행)
> 작성일: 2026-07-01

---

## PART 0 — 기준 계약

A-24~A-24.7과 현재 `PaymentSessionItems` 테이블 정의, `SessionRepository.addItem()` 구현만 근거로 한다. 추론 및 새 구조 제안 없음.

---

## PART 1 — Session Item 저장 구조 확인

`PaymentSessionItems` 테이블(`session_tables.dart` 49~77행) 직접 확인.

| 항목 | 존재 여부 | 타입 | 근거 |
|---|---|---|---|
| `itemType` | **Present** | `TextColumn`(non-null) | `session_tables.dart` 55행, 주석에 `'service'\|'product'\|'time'\|'staff_fee'\|'discount'\|'surcharge'` 명시 |
| `itemName` | **Present** | `TextColumn`(non-null) | 63행, 스냅샷 주석 포함("당시 이름 스냅샷 — 원본이 나중에 바뀌어도 전표에는 그 시점 이름이 그대로 남아야 한다") |
| `unitPrice` | **Present** | `IntColumn`(non-null) | 66행 |
| `refType` | **Present** | `TextColumn`(nullable) | 59행, 주석에 `'booking'\|'plu'\|'staff'\|'manual'` 명시 |
| `refId` | **Present** | `TextColumn`(nullable) | 60행 |
| `Product.id` 저장용 전용 필드 | **Not Present** | — | `PaymentSessionItems`에 `productId` 등 Product ID를 직접 저장하는 별도 컬럼이 없다(테이블 전체 컬럼: `id`/`sessionId`/`itemType`/`refType`/`refId`/`itemName`/`qty`/`unitPrice`/`amount`/`staffId`/`metaJson`/`createdAt`). |

---

## PART 2 — A-24.7 계약과 비교

| 계약 항목 | 저장 구조와 일치 여부 | 근거 |
|---|---|---|
| `businessType` 외부 주입 | **Match** | `businessType`은 `PaymentSessionItems`가 아닌 `PaymentSessions`의 컬럼이며, `createSession()`이 처리한다 — `addItem()`은 이 값을 직접 받지 않아도 되므로 A-24.7 계약("외부에서 `createSession()`에 주입")과 구조가 일치한다. |
| `itemType = 'service'` | **Match** | `PaymentSessionItems.itemType`(TextColumn)에 `'service'`를 저장하는 것은 `session_tables.dart` 55행 주석이 명시한 허용값과 일치하며, `addItem()`의 `_validItemTypes` 집합에도 포함된다(A-24.7 PART3에서 이미 확인). |
| `itemName = Product.name` | **Match** | `PaymentSessionItems.itemName`(TextColumn non-null)에 `String`을 저장 — `Product.name`(`product_tables.dart` 24행, `TextColumn`)과 타입 일치. |
| `unitPrice = Product.price` | **Match** | `PaymentSessionItems.unitPrice`(`IntColumn` non-null)에 `int`를 저장 — `Product.price`(`product_tables.dart` 27행, `IntColumn`)와 타입 일치. |
| `refType = 'booking'` | **Match** | `PaymentSessionItems.refType`(`TextColumn` nullable)에 `'booking'`을 저장 — `session_tables.dart` 58행 주석의 허용값에 `'booking'`이 포함돼 있음. |
| `refId = Booking.id.toString()` | **Match** | `PaymentSessionItems.refId`(`TextColumn` nullable)에 `String`을 저장 — `Booking.id`(`IntColumn` non-null)를 `toString()`으로 변환해 전달. `refId`가 `TEXT`인 것은 "서로 다른 도메인의 정수 ID를 유연하게 참조하기 위한" 기존 설계(`session_tables.dart` 5~9행 주석)와 일치하며, 기존 코드에도 같은 변환 관례가 있음(`test/features/session/session_repository_test.dart`의 `refId: '${rule.id}'`). |

**Conflict 0건** — A-24.7의 6개 계약 항목 전부 실제 저장 구조와 일치한다.

---

## PART 3 — `Product.id` 저장 필요성 검증

| 후보 | 결과 | 근거 |
|---|---|---|
| `Product.id` 저장 필요 | **Not Required** | A-8 스냅샷 원칙(`session_tables.dart` 62~64행 주석 — "당시 이름 스냅샷, 원본이 나중에 바뀌어도 전표에는 그 시점 이름이 그대로 남아야 한다, 영수증 재현성")에 따르면, `itemName`/`unitPrice`가 이미 그 시점의 Product 데이터를 스냅샷하므로 원본 Product의 ID를 별도로 저장하지 않아도 영수증 재현에 필요한 정보는 보존된다. |
| `Product.id` 저장 전용 필드 존재 | **Not Present** | PART1에서 확인된 그대로 — `PaymentSessionItems`에 해당 컬럼 없음. |
| Snapshot(`itemName`/`unitPrice`)만으로 충분 | **Yes** | A-8 스냅샷 원칙 근거(위와 동일). Product 이름이나 가격이 나중에 바뀌어도 그 시점에 저장된 `itemName`/`unitPrice`가 영수증 데이터로 그대로 보존된다. |

---

## PART 4 — A-25 구현 가능 여부

| 항목 | 결과 | 근거 |
|---|---|---|
| 계약 충돌 존재 | **No** | PART2에서 6개 항목 전부 Match 확인. |
| 추가 설계 필요 | **No** | A-24.7에서 이미 최종 계약이 확정됐고, 본 PART에서 저장 구조와의 불일치가 없음을 재확인했다 — A-24.5/A-25 구현 중단 사유(itemType 충돌)는 A-24.7에서 해소됐다. |
| A-25 즉시 구현 가능 | **Yes** | 계약 충돌 없음, 추가 설계 불필요, 저장 구조 완전 일치. |

---

## PART 5 — 기준선 확인

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **Pass**(No issues found) |
| `flutter test`(전체) | **Pass** — 369건 전부 통과(`All tests passed!`), 코드 변경 없음. |

---

## 완료 기준 점검

| # | 항목 | 상태 |
|---|---|---|
| 1 | Session Item 저장 구조 확인 | ✅ PART1 |
| 2 | A-24.7 계약 비교 | ✅ PART2 — Conflict 0건 |
| 3 | `Product.id` 저장 필요성 검증 | ✅ PART3 — Not Required |
| 4 | A-25 구현 가능 여부 확정 | ✅ PART4 — Yes |
| 5 | `flutter analyze` Pass | ✅ PART5 |
| 6 | `flutter test` Pass | ✅ PART5 |

**"Session Item Persistence Contract Verified"**
