# Architecture Summary: Booking → Session Integration

> 이 문서는 A-20~A-25에서 내려진 모든 설계 결정을 하나의 참조 문서로 정리한다. 새로운 설계를 담지 않는다 — 기존 산출물(A-20~A-25, WORK_LOG.md)에서 확인된 내용만 기록한다.
> 작성일: 2026-07-01

---

## 1. BookingCompletionCaller를 도입한 이유

- **결정**: `completeBooking()` 내부가 아니라, 그 호출자 역할을 하는 별도 클래스(`BookingCompletionCaller`)를 `lib/features/booking/data/`에 신설한다.
- **근거**: `completeBooking()` docstring이 인용한 `A1_A2_BOUNDARY.md` 원칙 — "완료 처리 메서드 자신이 다른 도메인을 호출하지 않고, 그 호출자가 책임진다." 기존 코드베이스에 이미 같은 패턴의 선례(`PaymentRepository`가 `CustomerRepository.recordVisit()`을 호출)가 있었다. 기존 구조 4개 후보(Repository 자신/구 PaymentRepository/SessionRepository/SessionClosingWorkflow 확장) 모두 기존 원칙과 충돌했기 때문에 단일 Caller 클래스가 유일한 적합한 선택이었다.
- **참조 문서**: `docs/A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md`, `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md` PART2

---

## 2. Repository를 수정하지 않은 이유

- **결정**: `BookingRepository`/`SessionRepository`/`ProductRepository` 중 어느 것도 수정하지 않는다. 기존 public 메서드만 사용한다.
- **근거**: A-25 계약("Repository 수정 금지")과 Minimal Change 원칙. `completeBooking()`/`createSession()`/`addItem()` 세 메서드의 기존 시그니처가 이미 필요한 모든 기능을 제공하며, `ProductRepository.watchProducts()`(기존 전체 상품 Stream)와 메모리 매칭(`booking_logic.dart`의 `computeEndAt()`이 이미 전제하는 패턴)으로 Product 조회도 새 메서드 없이 구현 가능했다.
- **참조 문서**: `docs/A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md` PART2, `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md` PART2

---

## 3. Caller 패턴을 선택한 이유

- **결정**: Caller는 Repository가 아닌 별도 클래스이며, 두 Repository(`BookingRepository`, `SessionRepository`)와 `ProductRepository`를 생성자 주입으로 받아 순서대로 호출하기만 한다.
- **근거**: A-22에서 확인된 기존 원칙(`completeBooking()` 자신이 Side Effect를 일으키지 않는다)을 따르면서도, 기존 코드베이스에 Orchestrator/UseCase/Service 패턴이 전혀 없고(A-23 확인 결과 0개) 기존 Repository→Repository 호출 패턴(PART1에서 Implemented로 확인)이 이미 확립돼 있어, 이와 구조적으로 동일한 얇은 Caller 클래스가 가장 자연스러운 형태였다.
- **참조 문서**: `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md` PART1~2, `lib/features/booking/data/booking_completion_caller.dart`

---

## 4. `businessType`을 외부 주입으로 결정한 이유

- **결정**: `BookingCompletionCaller.complete()`의 `businessType`은 `required String businessType`으로 선언해 호출자가 외부에서 전달한다. 내부에서 결정하거나 하드코딩하지 않는다.
- **근거**: `Bookings` 테이블에 `businessType` 컬럼이 존재하지 않는다(A-25 2차 시도에서 코드로 확인). `createSession()`의 `businessType`은 `required` 필드라 생략 불가 — 내부에서 "salon" 등으로 하드코딩하면 Business Logic 추론에 해당("추론 기반 필드 생성 금지" 위반). 외부 주입이 유일하게 계약에 맞는 방법이었다.
- **참조 문서**: `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` PART5, `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` PART5

---

## 5. Product 조회 전략

- **결정**: `ProductRepository.watchProducts().first`로 전체 상품 목록을 한 번 가져온 뒤, `productIdsCsv`에서 파싱한 ID 목록과 메모리에서 매칭(`products.where((p) => p.id == id).firstOrNull`)한다. ID별 개별 Repository 호출을 하지 않는다.
- **근거**: `ProductRepository`에 ID 기준 단건/배치 조회 메서드가 현재 존재하지 않는다(A-24.6 확인). `booking_logic.dart`의 `computeEndAt()`이 이미 동일한 패턴을 전제로 설계돼 있어(기존 선례), 새 메서드 추가 없이 코드베이스의 확립된 관례를 그대로 따랐다.
- **참조 문서**: `docs/A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md` PART2~4, `lib/features/booking/logic/booking_logic.dart:4~13`

---

## 6. Snapshot 구조 유지 이유

- **결정**: `addItem()`에 `itemName`/`unitPrice`를 그 시점의 `Product.name`/`Product.price`로 전달한다. 원본 Product 데이터가 나중에 바뀌어도 Session Item의 이름·가격은 고정된다.
- **근거**: A-8 스냅샷 원칙(`session_tables.dart` 62~64행 주석 — "당시 이름 스냅샷, 원본이 나중에 바뀌어도 전표에는 그 시점 이름이 그대로 남아야 한다, 영수증 재현성"). 이 원칙은 기존 서비스/상품 품목 추가 시에도 동일하게 적용되고 있으며, Booking 연동에서 새로 도입한 원칙이 아니다.
- **참조 문서**: `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` PART3, `lib/features/session/data/session_tables.dart:62~64`

---

## 7. `itemType` 계약

- **결정**: `itemType: 'service'` — `_validItemTypes` 내의 기존 고정 문자열 상수.
- **근거**: `addItem()`은 `itemType`이 `_validItemTypes = {'service','product','time','staff_fee','discount','surcharge'}` 중 하나임을 검증한다. Booking의 Product들은 `durationMin`(시술시간 분) 컬럼을 가진 시술 서비스이며, `computeEndAt()`이 이를 전제로 설계돼 있다 — 따라서 `'service'`가 의미상 가장 부합하는 기존 값이다.
- **참조 문서**: `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` PART3, `lib/features/product/data/product_tables.dart:34`

---

## 8. `refType` 계약

- **결정**: `refType: 'booking'` — 상수.
- **근거**: A-8 설계 시점(`docs/A8_SESSION_ENGINE.md` 14행)부터 `PaymentSessionItems.refType`이 `'booking'`을 허용값으로 포함해 왔다(`session_tables.dart` 57행 주석 `'booking' | 'plu' | 'staff' | 'manual'`). 이 자리는 A-8 설계 당시부터 이미 예약돼 있었다.
- **참조 문서**: `docs/A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md`, `lib/features/session/data/session_tables.dart:57`

---

## 9. `refId` 계약

- **결정**: `refId: booking.id.toString()` — `Booking.id`(int)를 String으로 변환해 전달.
- **근거**: `PaymentSessionItems.refId`는 `TextColumn nullable`이다. 기존 코드베이스에 이미 `refId: '${rule.id}'`처럼 정수 ID를 문자열화해 전달하는 관례가 존재한다(`test/features/session/session_repository_test.dart`). `refType='booking'`이면 `refId`는 어느 예약에서 온 아이템인지를 추적하는 값이므로 `Booking.id`가 의미상 정확하다.
- **참조 문서**: `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` PART5, `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` PART2

---

## 10. `Product.id`를 저장하지 않는 이유

- **결정**: `Product.id`는 `watchProducts()` 결과에서 Product를 찾는 조회 키로만 사용하며, `addItem()` 파라미터 어디에도 저장하지 않는다.
- **근거**: `PaymentSessionItems`에 `Product.id`를 저장하는 전용 컬럼이 없다(A-24.8 PART1 확인). `itemName`/`unitPrice`가 이미 그 시점의 Product 데이터를 스냅샷하므로(PART6), 원본 Product의 ID를 별도로 저장하지 않아도 영수증 재현에 필요한 정보가 보존된다(A-8 스냅샷 원칙). 새 컬럼을 추가하면 DB 변경이 필요해 Minimal Change 원칙에 위배된다.
- **참조 문서**: `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` PART3, `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` PART4

---

## 11. `addItem()` 순차 호출 이유

- **결정**: 복수 Product에 대한 `addItem()` 호출을 `for` loop로 순차(`await`) 실행한다. 병렬(`Future.wait()`) 처리를 하지 않는다.
- **근거**: A-25 계약("parallel 금지"). 현재 예약 건당 상품 수가 소수이므로 성능 영향이 미미하다. 병렬화는 `docs/MARK2_IDEAS.md`에 차기 개선 후보로 기록됐다.
- **참조 문서**: `lib/features/booking/data/booking_completion_caller.dart:51~59`, `docs/MARK2_IDEAS.md`

---

## 12. Minimal Change 원칙

- **결정**: 기존 코드(Repository/Engine/Workflow/테이블)를 일절 수정하지 않고, `booking_completion_caller.dart` 신규 파일 1개 추가만으로 Booking → Session 연결을 구현한다.
- **근거**: A-23에서 기존 구조 5개 후보를 전부 검토했으나 전부 Rejected — 이 중 어떤 기존 구조를 수정해도 기존 원칙(A1_A2_BOUNDARY.md/A-15 Baseline/ADR-001/구‒신 결제 파이프라인 분리)과 충돌했다. 기존 코드를 건드리지 않는 단일 Caller 클래스가 Minimal Change의 유일한 경로였다.
- **참조 문서**: `docs/A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md` PART4, `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md` PART2~4
