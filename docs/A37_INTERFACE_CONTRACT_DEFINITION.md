# A-37: Milestone 3 Interface Contract Definition

> **목적**: Milestone 3 Requirement, Analysis, Design을 기반으로 Interface Contract를 정의한다. Implementation은 수행하지 않는다.
> **제약**: Interface Contract Definition만 수행. 코드 수정 금지. Requirement/Design 변경 금지. 새로운 Requirement 생성 금지. 추론 금지.
> **기준 자료**: `docs/A34_MILESTONE3_REQUIREMENT.md`, `docs/A35_REQUIREMENT_ANALYSIS.md`, `docs/A36_DESIGN_DEFINITION.md`, `docs/A36_5_PROJECT_CONSISTENCY_VERIFICATION.md`, `docs/PROJECT_ROADMAP.md`, `docs/MARK2_IDEAS.md`, 실제 코드, Commit, Verification
> 작성일: 2026-07-10

---

## PART 0.5 — Design Baseline Verification

A-36 Design Decision 상태 확인:

| Design Decision | 상태 | 근거 |
|---|---|---|
| **DD-1** `booking_completion_caller.dart:63~72` for loop → `Future.wait()` 병렬화 | **정의됨** | `A36_DESIGN_DEFINITION.md` PART 6: "정의됨". 변경 위치·방향 전부 확인됨. |
| **DD-2** `booking_completion_caller.dart:65~66` silent skip → 명시적 정책 | **일부 정의됨** | `A36_DESIGN_DEFINITION.md` PART 6: "일부 정의됨". 변경 위치 정의됨. 정책 형태(로깅 vs 예외) 미결정. |
| **DD-3** `promotion_engine.dart:52` `candidates.first` 단일 Rule 구조 변경 위치 | **일부 정의됨** | `A36_DESIGN_DEFINITION.md` PART 6: "일부 정의됨". 변경 위치 정의됨. 중첩 정책(ADR-005) 미결정. |
| **DD-4** TOCTOU 기존 구현 상태 확인 | **미확인** | `A36_DESIGN_DEFINITION.md` PART 6: "미확인". Roadmap/코드 불일치 상태. Interface Contract 정의 대상 제외. |

> **적용 규칙**: DD-1 → Contract 정의 대상. DD-2/DD-3 → 확인된 범위만 Contract 대상. DD-4 → 제외.

---

## PART 1 — Interface Contract Inventory

| Contract 대상 Interface | 관련 Design Decision | 근거 | 상태 |
|---|---|---|---|
| **IC-M3-1** `BookingCompletionCaller.complete()` — 병렬화 후 외부 계약 유지 | DD-1 | `A36_DESIGN_DEFINITION.md` DD-1: 변경 방향 `Future.wait()`. 외부 시그니처·반환형은 변경 없음. `booking_completion_caller.dart:31~34`: 현재 시그니처 확인됨. | **정의됨** |
| **IC-M3-2** `BookingCompletionCaller.complete()` — 미매칭 상품 처리 외부 계약 | DD-2 | `A36_DESIGN_DEFINITION.md` DD-2: 변경 위치 정의됨. `MARK2_IDEAS.md`: 로깅 또는 예외. 정책 형태 미결정. | **일부 정의됨** |
| **IC-M3-3** `PromotionEngine.calcDiscount()` — 중첩 정책 변경 후 외부 계약 | DD-3 | `A36_DESIGN_DEFINITION.md` DD-3: 변경 위치 정의됨. `promotion_engine.dart:38~44`: 현재 시그니처 확인됨. ADR-005 미결정. | **일부 정의됨** |

---

## PART 2 — Interface Contract Definition

### IC-M3-1: `BookingCompletionCaller.complete()` — 병렬화 후 외부 계약 (DD-1)

| 항목 | 내용 |
|---|---|
| **입력** | `booking: BookingRow` (required, non-nullable), `businessType: String` (required, non-nullable) |
| **출력** | 없음 |
| **Nullable** | 반환값 없음 |
| **Future** | `Future<void>` |
| **책임** | DD-1(`Future.wait()` 병렬화) 적용 후에도 호출자 관점의 계약은 변경되지 않는다. 병렬화는 내부 구현 변경이며 외부 시그니처·반환형·예외 전파 방식을 변경하지 않는다. |
| **근거** | `lib/features/booking/data/booking_completion_caller.dart:31~34`: 현재 시그니처 `Future<void> complete({required BookingRow booking, required String businessType})` 확인됨. `A36_DESIGN_DEFINITION.md` DD-1: "변경 방향 `Future.wait()`" — 외부 계약 변경 없음 명시. |

> **Milestone 2 계약 연속성**: `A28_5_INTERFACE_CONTRACT_DEFINITION.md` IC-2에서 정의된 `complete()` 시그니처 계약과 동일. DD-1 적용 후에도 이 계약은 유지된다.

### IC-M3-2: `BookingCompletionCaller.complete()` — 미매칭 상품 처리 외부 계약 (DD-2)

| 항목 | 내용 |
|---|---|
| **입력** | IC-M3-1과 동일: `booking: BookingRow`, `businessType: String` |
| **출력** | 없음 |
| **Nullable** | 반환값 없음 |
| **Future** | `Future<void>` |
| **책임(확인된 범위)** | DD-2 적용 후 `productIdsCsv` 내 Product ID가 `watchProducts()` 결과에 없는 경우의 처리 방식이 silent skip에서 변경된다. 변경 방향: 명시적 처리(로깅 또는 예외). 구체적 형태 미결정. |
| **미확인 항목** | 정책 형태(로깅 vs 예외) 미결정 — 로깅인 경우 `Future<void>`로 정상 완료. 예외인 경우 호출자가 추가 예외 처리 필요. 외부 계약 영향 범위 미결정. |
| **근거** | `lib/features/booking/data/booking_completion_caller.dart:65~66`: 현재 `if (product == null) continue;` silent skip. `MARK2_IDEAS.md` Technical Debt 분류: "로깅/예외". `A36_DESIGN_DEFINITION.md` DD-2: 변경 위치 정의됨. 정책 형태 미결정. |

### IC-M3-3: `PromotionEngine.calcDiscount()` — 중첩 정책 변경 후 외부 계약 (DD-3)

| 항목 | 내용 |
|---|---|
| **입력** | `subtotal: int` (required, non-nullable), `at: DateTime` (required, non-nullable), `rules: List<PromotionRule>` (required, non-nullable) |
| **출력** | `PromotionResult` 인스턴스 |
| **Nullable** | 반환값 non-nullable. 미적용 시 `PromotionResult.none` 반환(현재 코드 확인됨) |
| **Future** | 없음(동기 메서드) |
| **책임(확인된 범위)** | 현재: `rules` 목록에서 조건을 만족하는 Rule 중 `priority` 최우선 1개만 선택하여 `PromotionResult` 반환. DD-3 적용 후: 중첩 정책(ADR-005) 확정 후 변경 예정. 변경 내용 미결정. |
| **미확인 항목** | ADR-005 미작성으로 중첩 정책 미결정. 복수 Rule 적용 시 반환형이 `PromotionResult`(단일) 유지 여부 미결정. |
| **근거** | `lib/features/promotion/logic/promotion_engine.dart:38~65`: 현재 시그니처 `PromotionResult calcDiscount({required int subtotal, required DateTime at, required List<PromotionRule> rules})` 확인됨. `A36_DESIGN_DEFINITION.md` DD-3: 변경 위치 정의됨. ADR-005 미결정. |

---

## PART 3 — Existing Component Responsibility Observation

| Component | 책임 | 근거 |
|---|---|---|
| `BookingCompletionCaller` (`lib/features/booking/data/booking_completion_caller.dart`) | Booking 완료 → Session 생성 오케스트레이션. `complete()` 호출 시 `completeBooking()` → `createSession()` → `watchProducts().first` → CSV 파싱 → `addItem()` N회 실행. IC-M3-1/IC-M3-2의 계약 주체. | `lib/features/booking/data/booking_completion_caller.dart:31~79` |
| `PromotionEngine` (`lib/features/promotion/logic/promotion_engine.dart`) | 순수 계산 클래스. Repository/Drift 비의존(ADR-001 원칙 적용). `calcDiscount()`로 할인액 계산. 현재 단일 Rule 반환. IC-M3-3의 계약 주체. | `lib/features/promotion/logic/promotion_engine.dart:21~65` |
| `SessionClosingWorkflow` (`lib/features/session/workflow/session_closing_workflow.dart`) | Session 마감 워크플로. A-18.3에서 Conditional UPDATE 구현 완료. DD-4(미확인)로 Interface Contract 정의 범위 제외됨. | `lib/features/session/workflow/session_closing_workflow.dart:86~103`, `A36_DESIGN_DEFINITION.md` DD-4 |

---

## PART 4 — Interface Contract Traceability

| Interface Contract | 근거 1 | 근거 2 | 추가 근거 |
|---|---|---|---|
| **IC-M3-1** `complete()` 병렬화 후 외부 계약 | **Requirement**: `MARK2_IDEAS.md` Performance 분류 — 병렬화 목적 확인됨 | **코드**: `booking_completion_caller.dart:31~34` — 현재 시그니처 `Future<void> complete(...)` 확인됨 | **Design**: `A36_DESIGN_DEFINITION.md` DD-1 — "외부 계약 변경 없음" 방향 확인됨 |
| **IC-M3-2** `complete()` 미매칭 처리 외부 계약 | **Requirement**: `MARK2_IDEAS.md` Technical Debt 분류 — 로깅/예외 방향 확인됨 | **코드**: `booking_completion_caller.dart:65~66` — 현재 silent skip 구현 확인됨 | **Design**: `A36_DESIGN_DEFINITION.md` DD-2 — 변경 위치 정의됨, 정책 형태 미결정 |
| **IC-M3-3** `calcDiscount()` 중첩 후 외부 계약 | **Requirement**: `PROJECT_ROADMAP.md` §Future — ADR-005 미작성 보류 확인됨 | **코드**: `promotion_engine.dart:38~44` — 현재 시그니처 `PromotionResult calcDiscount(...)` 확인됨 | **Design**: `A36_DESIGN_DEFINITION.md` DD-3 — 변경 위치 정의됨, ADR-005 미결정 |

---

## PART 5 — Missing Contract Evidence Observation

| Interface Contract | 미확인 항목 | 근거 |
|---|---|---|
| **IC-M3-1** | `Future.wait()` 내 하나 실패 시 외부 예외 전파 방식 관련 문서 없음. 현재 순차 loop에서의 예외 전파와 `Future.wait()` 예외 전파 차이 관련 계약 없음. | `MARK2_IDEAS.md`: "Future.wait()로 병렬화" 이상의 상세 없음. `A36_DESIGN_DEFINITION.md` PART 5 Missing Evidence |
| **IC-M3-2** | 정책 형태(로깅 vs 예외) 결정 문서 없음. 예외 선택 시 외부 계약 변경 여부(호출자 추가 처리 필요 여부) 미결정. 로깅 선택 시 로깅 API/대상 미결정. `MARK2_IDEAS.md`: "로깅/예외" 두 가지 기재, 결정 없음. | `MARK2_IDEAS.md`, `A36_DESIGN_DEFINITION.md` PART 5 |
| **IC-M3-3** | ADR-005 파일 없음(`docs/adr/`에 ADR-004까지만). 중첩 정책 결정 후 반환형이 `PromotionResult`(단일 Rule 기준) 유지 여부 미결정. 복수 적용 시 반환 구조 변경 가능성 미확인. | `docs/adr/` 파일 목록, `A36_DESIGN_DEFINITION.md` PART 5 |

---

## PART 6 — Interface Contract Status

| Interface Contract | 상태 | 근거 |
|---|---|---|
| **IC-M3-1** `complete()` 병렬화 후 외부 계약 | **정의됨** | 입력·출력·반환형·Nullable·Future 전항 확인됨. 외부 계약 변경 없음이 DD-1에서 확인됨. |
| **IC-M3-2** `complete()` 미매칭 처리 외부 계약 | **일부 정의됨** | 입력·출력·반환형 확인됨. 정책 형태(로깅 vs 예외) 미결정으로 예외 선택 시 외부 계약 변경 가능성 존재. |
| **IC-M3-3** `calcDiscount()` 중첩 후 외부 계약 | **일부 정의됨** | 입력·출력·Nullable 현재 상태 확인됨. ADR-005 미결정으로 중첩 정책 적용 후 반환 구조 변경 가능성 미확인. |

---

## Baseline 확인

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 13.8s)
```

| 항목 | 결과 |
|---|---|
| flutter analyze | **Pass** |

### flutter test

```
+372: All tests passed!
```

| 항목 | 결과 |
|---|---|
| flutter test | **Pass (372건)** |

코드 변경 없음. 이 문서는 순수 Interface Contract Definition 작업이다.

---

**"Milestone 3 Interface Contract Established"**
