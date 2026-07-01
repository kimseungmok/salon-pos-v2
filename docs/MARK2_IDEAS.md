# Mark 2 개선 아이디어

> A-25 이후 구현 과정에서 발견된 "이번 범위에서는 구현하지 않지만 차기 개선으로 검토할 것"들을 기록한다. 현재 구현에는 영향을 주지 않는다.
> A-25.5 분류 추가됨(내용 변경 없음).

| 분류 | 제목 | 이유 | 현재 반영하지 않은 이유 |
|---|---|---|---|
| **Repository** | `BookingRepository.getBookingById(int id)` 단건 조회 메서드 추가 | 현재 `BookingRepository`에 ID 기준 단건 조회 메서드가 없어 `BookingCompletionCaller`의 호출자가 Booking 엔티티를 직접 pre-fetch해서 전달해야 한다 — Caller 자체가 내부에서 Booking을 조회할 수 없어 추상화가 완전하지 않다. | A-25 계약("BookingRepository 수정 금지")을 준수하기 위해 보류. Caller 시그니처에 `BookingRow`를 외부에서 받도록 설계해 우회함(A-24.5 PART5의 "Booking entity(required) — 호출 전에 조회된 값"과 일치). |
| **Performance** | `addItem()` 병렬 호출 지원 | 여러 상품에 대해 `addItem()`을 순차 `await`로 처리 중 — `Future.wait()`로 병렬화하면 다중 상품 시 성능을 개선할 수 있다. | A-25 계약("순서 변경 금지", "parallel 금지")을 준수하기 위해 보류. 현재 예약 건당 상품 수가 일반적으로 소수라 성능 영향이 미미함. |
| **Technical Debt** | `productIdsCsv` 파싱 미매칭 상품의 명시적 정책 정의 | 현재 CSV의 Product ID가 `watchProducts()` 결과에 없으면 조용히 건너뛴다 — "예약 메뉴가 Session Item 없이 통과됐다"는 것을 감지할 로깅/예외가 없어 운영 시 추적이 어렵다. | A-25 계약("새로운 로직 추가 금지")을 준수하기 위해 보류. 기존 코드(`computeEndAt()`의 `firstOrNull`)도 동일하게 조용히 무시하는 패턴이라 일관성은 유지됨. |
