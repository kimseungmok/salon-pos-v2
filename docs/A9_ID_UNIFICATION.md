# A-9: 전체 도메인 ID 체계 통일 — 완료 보고

> SESSION ENGINE(A-8) 기준(INTEGER AUTOINCREMENT)으로 기존 9개 모듈 21개 테이블의 UUID TEXT PK를 전부 통일. 브릿지/매핑 레이어 없이 완전 통일.
> 작성일: 2026-06-25

---

## 1. 변경된 테이블 목록 (9개 모듈, 21개 테이블)

| 모듈 | 테이블 | PK 변경 | FK 변경 |
|---|---|---|---|
| staff | `Staff` | `id` TEXT→INTEGER AUTOINCREMENT | — |
| staff | `Shifts` | id 동일 | `staffId` TEXT→INTEGER |
| customer | `Customers` | id 동일 | — |
| customer | `VisitRecords` | id 동일 | `customerId`, `staffId` TEXT→INTEGER |
| booking | `Bookings` | id 동일 | `customerId`, `staffId` TEXT→INTEGER |
| booking | `WaitingEntries` | id 동일 | `preferredStaffId` TEXT→INTEGER |
| payment_pos | `Orders` | id 동일 | `customerId` TEXT→INTEGER |
| payment_pos | `OrderItems` | id 동일 | `orderId`, `productId`, `staffId` TEXT→INTEGER |
| payment_pos | `Payments` | id 동일 | `orderId`, `prepaidBalanceId` TEXT→INTEGER |
| prepaid_pass | `PrepaidPassMenus` | id 동일 | `linkedProductId` TEXT→INTEGER |
| prepaid_pass | `PrepaidPassBalances` | id 동일 | `customerId`, `menuId` TEXT→INTEGER |
| prepaid_pass | `PrepaidPassTransactions` | id 동일 | `balanceId`, `relatedOrderId` TEXT→INTEGER |
| product | `Categories` | id 동일 | — |
| product | `Products` | id 동일 | `categoryId` TEXT→INTEGER |
| marketing | `Coupons` | id 동일 | `giftProductId` TEXT→INTEGER |
| marketing | `Campaigns` | id 동일 | — |
| marketing | `PointPolicies` | id 동일(singleton 고정값 `'singleton'`→`1`) | — |
| cash_management | `CashCounts` | id 동일 | (`confirmedBy`는 자유 텍스트 표시값으로 그대로 유지 — F-STAFF-00) |
| cash_management | `ClosingChecklistItems` | id 동일 | — |
| inventory | `InventoryItems` | id 동일 | — |
| inventory | `InventoryLogs` | id 동일 | `itemId`, `staffId` TEXT→INTEGER |

A-8 SESSION ENGINE의 4개 테이블(`PaymentSessions` 등)은 처음부터 INTEGER였으므로 변경 없음 — 이번 작업으로 **전체 25개 테이블이 동일한 ID 체계**가 됐다.

---

## 2. 변경 전/후 ID 타입

```
변경 전: TextColumn get id => text()();         // 앱코드에서 Uuid().v4()로 생성
변경 후: IntColumn get id => integer().autoIncrement()();  // SQLite가 자동 생성

변경 전: Set<Column> get primaryKey => {id};    // 명시적 PK 선언
변경 후: (삭제)                                  // autoIncrement가 이미 PK를 의미,
                                                  // Drift는 둘을 함께 쓰면 빌드 에러
```

모든 Repository 메서드의 ID 매개변수/필드 타입이 `String`(`String?`) → `int`(`int?`)로 일괄 변경됐다. `Companion.insert()` 호출부에서 `id: _uuid.v4()`를 더 이상 지정하지 않고, `await db.into(table).insert(...)`의 반환값(`Future<int>`)을 그대로 신규 행의 id로 사용한다.

---

## 3. 삭제된 UUID 생성 코드 위치

`grep -rln "_uuid.v4()\|import 'package:uuid'" lib/` 결과 **0건** — 다음 9개 Repository 파일에서 `const _uuid = Uuid();` 선언과 `import 'package:uuid/uuid.dart';`를 전부 제거했다.

- `lib/features/staff/data/staff_repository.dart`
- `lib/features/customer/data/customer_repository.dart`
- `lib/features/booking/data/booking_repository.dart`
- `lib/features/payment_pos/data/payment_repository.dart`
- `lib/features/prepaid_pass/data/prepaid_pass_repository.dart`
- `lib/features/product/data/product_repository.dart`
- `lib/features/marketing/data/marketing_repository.dart`
- `lib/features/cash_management/data/cash_repository.dart`
- `lib/features/inventory/data/inventory_repository.dart`

`pubspec.yaml`의 `uuid` 패키지 의존성 자체는 제거하지 않았다(다른 곳에서 더 이상 import하지 않으므로 dead dependency가 됐지만, 패키지 제거는 본 작업 범위(ID 통일) 밖이라 별도 결정 사항으로 남긴다).

---

## 4. 화면(UI) 레벨 변경

Repository뿐 아니라 화면도 ID 타입을 따라가야 했다 — 다음 위치를 함께 수정했다(요청서에는 명시되지 않았으나, "기존 테스트 케이스 로직은 유지" 원칙을 화면까지 일관되게 지키기 위해 필요했음):

- `lib/features/customer/screens/customer_list_screen.dart` — `Map<String,CustomerGroup>` → `Map<int,CustomerGroup>`
- `lib/features/inventory/screens/inventory_list_screen.dart` — `_adjust()` 매개변수
- `lib/features/marketing/screens/coupon_screen.dart` — `giftProductId` placeholder 값
- `lib/features/payment_pos/providers.dart`/`screens/pos_order_screen.dart` — 카트 상태(`cartProvider`)와 관련 `Map`/`MapEntry` 타입
- `lib/features/prepaid_pass/screens/prepaid_pass_menu_screen.dart` — `_linkedProductId` 필드, 기존에 있던 `as String` 강제캐스트(타입 불일치를 가리던 코드) 제거
- `lib/features/product/providers.dart`/`screens/product_list_screen.dart` — `selectedCategoryIdProvider`, `_categoryId` 필드
- `lib/features/booking/logic/booking_logic.dart` — `computeEndAt()`의 `productIds` 매개변수
- `lib/features/payment_pos/logic/payment_logic.dart` — `payByItems()`의 `selectedItemIds` 매개변수

---

## 5. 테스트 변경 요약

22개 테스트 파일 중 ID 리터럴을 포함하던 모든 파일을 수정했다. 패턴은 두 종류:

1. **단순 타입 치환**: `'p1'`/`'c1'`/`'no-such-id'` 같은 문자열 리터럴을 `1`/`2`/`999999`(존재하지 않는 정수)로 교체. 검증하는 비즈니스 로직(예외 종류, 상태값, 금액)은 전혀 바꾸지 않았다.
2. **헬퍼 함수 반환형 변경**: `Future<String> aCustomer()` 등 테스트 헬퍼의 반환형을 `Future<int>`로 변경.

**제거된 테스트 2건**(타입 변경으로 의미가 없어진 경우 — "테스트 수는 줄어도 되지만 로직 커버리지는 유지" 조건에 따라 제거, 대체 불필요로 판단):
- `booking_repository_test.dart` "고객 미지정 → ValidationException"(`customerId: ''`로 빈 문자열을 검증하던 테스트 — `int`는 "비어있음"이라는 상태가 없어 동등한 테스트를 만들 수 없음. `createBooking()`의 해당 검증 코드 자체도 함께 제거됨)
- `prepaid_pass_repository_test.dart` "고객 미지정 → ValidationException"(동일한 이유)

**결과**: 전체 278건 통과(기존 280건 - 위 2건 제거), `flutter analyze` 클린.

---

## 6. 완료 조건 체크

| 조건 | 결과 |
|---|---|
| `flutter analyze` 클린 | ✅ |
| 전체 테스트 통과 | ✅ 278건(로직 커버리지 유지, 의미 없어진 2건만 제거) |
| UUID 생성 코드 0개 | ✅ `grep` 재확인 |
| `docs/ID_CONVENTION.md` 존재 | ✅ |
| `docs/A9_ID_UNIFICATION.md` 존재 | ✅ (본 문서) |

## 7. 마이그레이션에 대한 중요한 한계

`lib/db/app_database.dart`의 `schemaVersion`을 3으로 올렸으나, **v1/v2→v3 데이터 보존 마이그레이션은 작성하지 않았다** — UUID 문자열을 정수로 치환하면서 모든 테이블의 FK 참조까지 일관되게 재매핑하는 것은 단순 `ALTER TABLE`로 표현할 수 없는 작업이다. 본 앱이 아직 정식 출시 전(라이브 사용자 데이터 없음)이라는 전제로, v3은 `onCreate`(신규 설치) 경로만 지원한다. **출시 이후 동일한 종류의 PK 타입 변경이 필요해지면, 이번처럼 마이그레이션을 생략하는 방식은 쓸 수 없다** — 이 한계는 `app_database.dart`의 코드 주석에도 명시해 두었다.

## A-9.5 핫픽스

SESSION ENGINE staffId 컬럼 TEXT → INTEGER 통일.
변경 컬럼: payment_session.staffIdPrimary,
payment_session_item.staffId,
staff_earning_ledger.staffId

**배경**: A-9가 기존 9개 모듈 21개 테이블만 통일했고, A-8 SESSION ENGINE(4개 테이블)은 작업 범위 밖이었다. 당시 SESSION ENGINE의 `staffId` 계열 컬럼은 "기존 Staff.id(UUID)와 같은 타입"이라는 이유로 TEXT로 설계됐는데, A-9가 그 전제(Staff.id=UUID)를 뒤집어버려 SESSION ENGINE만 뒤늦게 불일치 상태로 남았다(`A10_IMPLEMENTATION_READINESS_REVIEW.md` §6 HIGH-1에서 식별).

**변경 내용**: `lib/features/session/data/session_tables.dart`의 3개 컬럼을 `TextColumn` → `IntColumn`으로 변경(nullable 여부는 그대로 유지 — `staffIdPrimary`/`PaymentSessionItems.staffId`는 nullable, `StaffEarningLedgers.staffId`는 non-null). `session_repository.dart`의 `createSession()`/`addItem()` 매개변수 타입을 `String?` → `int?`로 변경. `test/features/session/session_repository_test.dart`의 문자열 리터럴(`'staff-001'`)을 정수(`1`)로 교체.

**결과**: `grep -rn "TextColumn get staffId\|TextColumn get staffIdPrimary" lib/` 0건. 전체 278건 통과(테스트 개수 변동 없음, 리터럴만 교체), `flutter analyze` 클린.
