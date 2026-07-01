# Architecture Decision Record Index

> 이 파일은 프로젝트 전체의 설계 결정을 주제별로 색인한다. 각 항목은 "결정 / 근거 / 참조 문서" 3개 항목만 포함한다. 새로운 결정을 추가하지 않는다 — 기존 결정을 찾는 색인이다.
> **See Also**: `docs/DECISION_HISTORY.md`(시간순 이력), `docs/ARCHITECTURE_SUMMARY.md`(통합 요약)

---

## Caller Pattern

- **Decision**: `completeBooking()` 내부가 아니라 별도 `BookingCompletionCaller` 클래스(`lib/features/booking/data/`)가 `completeBooking()` 호출 이후 `createSession()`/`addItem()`을 조율한다.
- **Reason**: `A1_A2_BOUNDARY.md` 원칙("완료 처리 메서드 자신이 다른 도메인을 호출하지 않는다"), 기존 구조 5개 후보 전부 기존 원칙과 충돌 확인(A-23).
- **Reference Document**: `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md`, `docs/A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md`

---

## Data Ownership

- **Decision**: `businessType`=외부 주입(`required String`), `staffId`/`customerId`=`Booking` direct mapping, `roomId`=항상 `null`, `itemName`/`unitPrice`=Product 도메인 소유.
- **Reason**: `Bookings` 테이블에 `businessType`/`roomId` 컬럼 없음(코드 확인). 내부 결정이나 하드코딩은 "추론 기반 Business Logic 생성 금지" 위반.
- **Reference Document**: `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md`

---

## Product Retrieval Strategy

- **Decision**: `ProductRepository.watchProducts().first`로 전체 상품을 1회 조회한 뒤, 메모리에서 `products.where((p) => p.id == id).firstOrNull`으로 매칭. ID별 개별 조회 없음.
- **Reason**: `ProductRepository`에 단건/배치 조회 메서드가 없다(코드 확인). `booking_logic.dart`의 `computeEndAt()`이 이미 동일 패턴을 전제로 설계돼 있어 기존 선례를 그대로 따름.
- **Reference Document**: `docs/A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md`

---

## Session Item Contract

- **Decision**: `itemType='service'`(고정), `refType='booking'`(고정), `refId=Booking.id.toString()`, `itemName=Product.name`, `unitPrice=Product.price`.
- **Reason**: `addItem()`의 `_validItemTypes` 검증을 통과하는 기존 집합 중 의미상 가장 부합하는 값이 `'service'`(Booking Product들이 `durationMin` 컬럼을 가진 시술 서비스이므로). A-24.5의 `itemType: Product.id` 오기를 A-24.7에서 정정.
- **Reference Document**: `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md`, `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md`

---

## Session Persistence Contract

- **Decision**: A-24.7 계약 6개 항목 전부 `PaymentSessionItems` 저장 구조와 일치 확인(Conflict 0건).
- **Reason**: A-24.7 정정 후 `itemType`/`itemName`/`unitPrice`/`refType`/`refId` 타입 및 허용값이 모두 기존 `session_tables.dart` 정의와 부합. `Product.id`는 저장 전용 컬럼이 없어 미저장.
- **Reference Document**: `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md`

---

## Snapshot Principle

- **Decision**: `itemName`/`unitPrice`를 해당 시점의 `Product.name`/`Product.price`로 저장한다. 원본이 나중에 바뀌어도 Session Item의 값은 고정된다.
- **Reason**: A-8부터 확립된 스냅샷 원칙(`session_tables.dart` 62~64행 주석 — "당시 이름 스냅샷, 영수증 재현성"). Booking 연동에서 새로 도입한 원칙이 아님.
- **Reference Document**: `docs/A8_SESSION_ENGINE.md`, `docs/ARCHITECTURE_SUMMARY.md` §6

---

## Product.id Ownership

- **Decision**: `Product.id`는 `watchProducts()` 결과에서 Product를 찾는 조회 키로만 사용하며, `addItem()` 파라미터에 별도로 저장하지 않는다.
- **Reason**: `PaymentSessionItems`에 `productId` 전용 컬럼이 없다. `itemName`/`unitPrice` 스냅샷으로 영수증 재현에 필요한 정보가 보존된다(Snapshot Principle). 신규 컬럼 추가는 Minimal Change 원칙에 위배.
- **Reference Document**: `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` PART4, `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` PART3

---

## businessType Ownership

- **Decision**: `businessType`은 `BookingCompletionCaller.complete()`의 `required` 매개변수로 선언해 외부 호출자가 전달한다.
- **Reason**: `Bookings` 테이블에 `businessType` 컬럼이 없다. 내부 결정 또는 하드코딩은 "추론 기반 Business Logic 생성 금지"에 해당.
- **Reference Document**: `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` PART5

---

## addItem Sequential Policy

- **Decision**: 복수 Product에 대한 `addItem()` 호출을 `for` loop `await`로 순차 실행한다. 병렬(`Future.wait()`) 처리를 하지 않는다.
- **Reason**: 구현 시점의 계약("parallel 금지"). 예약 건당 상품 수가 소수라 성능 영향 미미. 병렬화는 `MARK2_IDEAS.md`에 차기 개선 후보로 이관.
- **Reference Document**: `lib/features/booking/data/booking_completion_caller.dart`, `docs/MARK2_IDEAS.md`
