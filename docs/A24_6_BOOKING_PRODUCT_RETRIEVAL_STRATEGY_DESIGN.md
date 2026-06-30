# A-24.6: Booking → Product Retrieval Strategy Design

> **목적**: A-25 구현(`BookingCompletionCaller`)에서 필요한 Product 데이터를 "어떻게" 가져올지 확정한다. "어디서 가져오는가"(소유권)는 A-24.5에서 이미 확정됨 — 변경 대상 아님. 코드 수정 없음, 새 아키텍처 없음.
> **근거**: A-19~A-24.5(`docs/A19~A24_5_*.md`), `lib/features/booking/data/booking_tables.dart`, `lib/features/booking/data/booking_repository.dart`, `lib/features/booking/logic/booking_logic.dart`, `lib/features/product/data/product_repository.dart`
> 작성일: 2026-06-30

---

## PART 0 — 기준 원칙

A-19~A-24.5만 근거로 한다. A-24.5가 확정한 데이터 소유권(`itemType`/`itemName`/`unitPrice`는 Product 도메인 소유, `businessType`은 외부 계약)은 변경하지 않는다. 추론으로 새 구조를 만들지 않고, 기존 코드(`ProductRepository`, `booking_logic.dart`)에 실제로 존재하는 메서드/패턴만 근거로 한다.

---

## PART 1 — Product 데이터 입력 구조 확인

| 항목 | 현재 상태 | 근거 |
|---|---|---|
| `productIdsCsv` | **Present** | `booking_tables.dart` 24행 — `Bookings.productIdsCsv`(`TextColumn`, 기본값 `''`). `createBooking()`이 `productIds.join(',')`로 기록(`booking_repository.dart` 67행). |
| Product 테이블 존재 | **Present** | `product_tables.dart` 22행, `Products`(`id`/`name`/`categoryId`/`price`/`allowCustomPrice`/`durationMin` 등). |
| 단일 Product 조회 가능 여부(Repository 기준) | **Not Present** | `product_repository.dart` 전체 확인 결과, ID 기준 단건 조회 메서드(`findById` 등)가 존재하지 않는다 — 공개 메서드는 `watchCategoriesOnce()`/`watchCategories()`/`createCategory()`/`watchProducts()`(전체 상품 Stream)/`upsertProduct()`/`deleteProduct()`/`tileColorOf()` 뿐. |
| 복수 Product 처리 필요 여부(CSV 구조 기준) | **Present** | `productIdsCsv`는 콤마로 구분된 여러 ID를 담는 구조(`createBooking()`의 `List<int> productIds` 매개변수가 이를 직접 증명, 67행). |

---

## PART 2 — Product 조회 전략 후보 정의

| 후보 | 선택 가능 여부 | 근거 |
|---|---|---|
| `ProductRepository.findById` | **Rejected** | PART1에서 확인한 대로 이 메서드는 현재 존재하지 않는다 — 선택하려면 `ProductRepository`에 새 메서드를 추가해야 하므로 "기존 Repository 기반만 허용"/"Repository 수정 금지"를 동시에 위반한다. |
| `ProductRepository.findByIds (batch)` | **Rejected** | 같은 이유 — 존재하지 않는 메서드이며, 추가하려면 Repository 수정이 필요하다. |
| `productIdsCsv` 직접 파싱 후 loop 조회 | **Selected**(단, "조회"의 의미를 정확히 한정 — PART4) | `booking_logic.dart`의 `computeEndAt(DateTime startAt, List<int> productIds, List<ProductRow> products)`(4~13행)이 이미 정확히 이 패턴을 전제로 설계돼 있다 — **CSV에서 파싱한 ID 목록과, 이미 가져온 `List<ProductRow>` 전체를 받아 메모리에서 `products.where((p) => p.id == id).firstOrNull`로 매칭**한다(11행). 이는 "ID마다 Repository에 개별 조회를 보내는 loop"가 아니라, "기존 `watchProducts()`(유일하게 존재하는 조회 메서드)의 결과 전체를 한 번 받아 메모리에서 반복(loop) 매칭"하는 패턴이며, 코드베이스에 이미 확립돼 있다(테스트로도 검증됨, `test/features/booking/booking_logic_test.dart` 18~36행). |
| `BookingCompletionCaller` 내부 매핑 고정 | **Rejected** | 실제 Product 데이터(이름/가격)를 무시하고 임의의 고정값을 박아 넣는 것은 추론에 기반한 Business Logic 생성에 해당 — A-24.5가 확정한 "Product 도메인이 소유한다"는 원칙과 직접 충돌. |

---

## PART 3 — CSV 처리 방식 정의

| 항목 | 결과 | 근거 |
|---|---|---|
| CSV split 처리 | **Required** | `productIdsCsv`는 `String`(콤마 구분)이고 `addItem()`/Product 매칭은 `int` ID가 필요하므로, `split(',')` 후 `int.parse`로의 변환이 반드시 필요하다(`createBooking()`이 기록할 때 쓴 `.join(',')`의 역연산). |
| 순서 유지 | **Required** | `split(',')`는 원본 순서를 그대로 보존한다 — 별도 정렬/재배치 로직을 추가하지 않는 한(추가 로직은 금지) 순서는 자연히 유지된다. |
| null/empty 처리 | **Required** | `productIdsCsv`의 기본값은 빈 문자열(`''`, `booking_tables.dart` 24행)이다. 다만 `createBooking()`이 이미 `productIds.isEmpty`를 `ValidationException`으로 차단하고 있어(47~49행) 정상적으로 생성된 `Booking`은 빈 CSV를 가질 수 없다 — 그럼에도 방어적으로 빈 문자열 입력 시 빈 리스트를 반환하는 처리(추가 로직이 아니라 `split(',')`가 빈 문자열에 대해 `['']`를 반환하는 엣지케이스를 피하는 최소한의 가드)가 필요하다. |

---

## PART 4 — A-25 호출 방식 확정

| 선정 전략 | 설명 | 근거 |
|---|---|---|
| `productIdsCsv` split 후, 기존 `ProductRepository.watchProducts()` 결과에서 메모리 매칭 | `Booking.productIdsCsv`를 `split(',')`+`int.parse`로 `List<int>`로 변환한 뒤, **새 조회 메서드를 추가하지 않고** 기존 `watchProducts()`가 반환하는 전체 `List<ProductRow>`에서 ID로 필터링한다(`computeEndAt()`이 이미 보여주는 정확히 같은 패턴 — `products.where((p) => p.id == id)`). | PART2에서 유일하게 `Selected`된 후보. 새 Repository 메서드 추가 없이(Repository 수정 금지 준수) 코드베이스에 이미 확립된 선례(`booking_logic.dart`)를 그대로 따른다 — "fallback 전략" 없이 이 하나만 사용한다. |

---

## PART 5 — A-25 실행 경계 정의

**허용**:
- PART4에서 선정된 Product 조회 방식 1개만 사용.
- `BookingCompletionCaller` 내부에서 호출(A-24 Caller 구조 그대로).
- `createSession()` → `addItem()` 흐름 연결(A-22/A-24.5에서 이미 확정된 순서/매핑 그대로).

**금지**:
- 새로운 아키텍처 추가.
- `Products`/`Bookings`/`PaymentSessions`/`PaymentSessionItems` 구조 변경.
- `productIdsCsv` 구조(콤마 구분 TEXT) 변경.

---

## PART 6 — Baseline 영향 확인

| Baseline | 결과 | 근거 |
|---|---|---|
| Session Closing Baseline | **No Impact** | `createSession()`/`addItem()` 기존 시그니처만 사용 — `closeSession()`/`SessionClosingWorkflow`/Transaction Boundary와 무관(A-21/A-24/A-24.5에서 반복 확인된 분리 유지). |
| Booking Baseline | **No Impact** | `Bookings`/`productIdsCsv` 구조 변경 없음(PART5 금지 사항), 별도 Booking Baseline 문서도 존재하지 않음(A-23/A-24에서 이미 확인). |
| Pricing/Product Baseline | **Review**(A-24.5와 동일한 근거 재확인) | 별도 확정 Baseline 문서가 없다는 사실은 동일하게 유지되며, 본 문서에서 `ProductRepository.watchProducts()`를 호출하는 새로운 관계가 추가될 것이라는 점이 구체화됐다 — 다만 이는 기존 공개 메서드를 그대로 사용하는 것이라 `ProductRepository` 자체의 구조 변경은 아니다. |

---

## PART 7 — 기준선 검증

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **Pass**(No issues found) |
| `flutter test`(전체) | **Pass** — 369건 전부 통과(`All tests passed!`), 코드 변경 없음. |

---

## PART 8 — 최종 결론

| 확인 항목 | 결과 |
|---|---|
| Product 조회 전략이 단일로 결정되었는가 | 결정됨(PART4) — `watchProducts()` + 메모리 매칭, fallback 없음. |
| CSV 처리 방식이 정의되었는가 | 정의됨(PART3) — split/순서유지/empty 가드 3개 전부 `Required`로 확정. |
| A-25 구현 방식이 더 이상 추론 없이 수행 가능한가 | 가능함 — `businessType`(A-24.5, 외부 계약)과 Product 조회 방식(본 문서) 둘 다 확정되어, A-25를 중단시켰던 두 미정 항목이 모두 해소됨. |
| 기존 구조와 충돌이 없는가 | 충돌 없음(PART2/PART5 — 새 Repository 메서드 없이 기존 `watchProducts()`/`computeEndAt()` 선례만 사용). |
| Baseline 영향이 통제되는가 | 통제됨(PART6 — Session/Booking은 무영향, Pricing/Product는 기존과 동일하게 Review로 표시되되 구조 변경은 없음). |

**"Booking Product Retrieval Strategy Established"**
