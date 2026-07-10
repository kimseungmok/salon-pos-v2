# A-38: Milestone 3 Implementation

> **목적**: A-37 Interface Contract에서 정의된 Contract를 만족하도록 Milestone 3 기능을 구현한다. Implementation만 수행한다.
> **제약**: Requirement/Analysis/Design/Interface Contract 변경 금지. PROJECT_ROADMAP 수정 금지. 새로운 Requirement/Design/Interface Contract 생성 금지. 새 파일 생성 금지. 추론 금지.
> **기준 자료**: `docs/A34_MILESTONE3_REQUIREMENT.md`, `docs/A35_REQUIREMENT_ANALYSIS.md`, `docs/A36_DESIGN_DEFINITION.md`, `docs/A37_INTERFACE_CONTRACT_DEFINITION.md`, 실제 프로젝트 코드, 실제 Commit
> 작성일: 2026-07-10

---

## PART 0.5 — Implementation Target Verification

A-37 Interface Contract 상태 확인 및 구현 대상 결정:

| Interface Contract | 상태 | 구현 대상 여부 | 근거 |
|---|---|---|---|
| **IC-M3-1** `complete()` 병렬화 후 외부 계약 | **정의됨** | **구현 가능** | `A37_INTERFACE_CONTRACT_DEFINITION.md` PART 6: "정의됨". 입력·출력·반환형·Nullable·Future 전항 확인됨. DD-1 변경 방향 `Future.wait()` 확인됨. 외부 계약 변경 없음 명시됨. |
| **IC-M3-2** `complete()` 미매칭 처리 외부 계약 | **일부 정의됨** | **구현 불가(확인된 범위 없음)** | `A37_INTERFACE_CONTRACT_DEFINITION.md` PART 6: "일부 정의됨". 정책 형태(로깅 vs 예외) 미결정 — 구현 가능한 확인된 범위 없음. 예외 선택 시 외부 계약 변경 가능성 존재. |
| **IC-M3-3** `calcDiscount()` 중첩 후 외부 계약 | **일부 정의됨** | **구현 불가(확인된 범위 없음)** | `A37_INTERFACE_CONTRACT_DEFINITION.md` PART 6: "일부 정의됨". ADR-005 미결정 — 중첩 정책 구현 불가. 반환 구조 변경 가능성 미확인. |

> **규칙 적용**: 정의됨 → 구현 가능. 일부 정의됨 → 확인된 범위만 구현. IC-M3-2/IC-M3-3은 확인된 구현 범위가 없으므로 구현 불가.

---

## PART 1 — Implementation Scope

A-37에서 구현 대상으로 확인된 IC-M3-1만 구현한다.

| Interface Contract | 구현 위치 | 근거 |
|---|---|---|
| **IC-M3-1** `complete()` 병렬화 후 외부 계약 | `lib/features/booking/data/booking_completion_caller.dart:62~74` | `A36_DESIGN_DEFINITION.md` DD-1: "변경 위치 `booking_completion_caller.dart:63~72`". `A37_INTERFACE_CONTRACT_DEFINITION.md` IC-M3-1: "정의됨". `MARK2_IDEAS.md` Performance 분류: "`Future.wait()`로 병렬화". |

**구현 제외 항목**: IC-M3-2, IC-M3-3 — 확인된 구현 범위 없음(위 PART 0.5 참조).

---

## PART 2 — Contract Preservation

IC-M3-1 구현 결과가 A-37에서 정의된 계약과 일치하는지 확인:

| 항목 | A-37 정의 | 구현 결과 | 일치 여부 |
|---|---|---|---|
| **입력(Parameter)** | `booking: BookingRow` (required, non-nullable), `businessType: String` (required, non-nullable) | 변경 없음 — 기존 시그니처 유지 | **일치** |
| **출력(Return)** | 없음 | 변경 없음 | **일치** |
| **반환형** | `Future<void>` | 변경 없음 | **일치** |
| **Nullable 여부** | 반환값 없음 | 변경 없음 | **일치** |
| **Future 여부** | `Future<void>` | 변경 없음 | **일치** |
| **Component 책임** | Booking 완료 → Session 생성 오케스트레이션. 병렬화는 내부 구현. | for loop → `Future.wait()` — 내부 구현만 변경. 호출자 관점 계약 변경 없음. | **일치** |

---

## PART 3 — Existing Structure Preservation

기존 구조 확인:

| 항목 | 구현 전 | 구현 후 | 변경 여부 |
|---|---|---|---|
| 클래스 | `BookingCompletionCaller` | 동일 | **변경 없음** |
| 파일 | `lib/features/booking/data/booking_completion_caller.dart` | 동일 | **변경 없음** |
| Layer | 기존 data layer | 동일 | **변경 없음** |
| Provider | 기존 provider 변경 없음 | 동일 | **변경 없음** |
| 새 파일 | 없음 | 없음 | **생성 없음** |

---

## PART 4 — Change Control

이번 구현에서 Requirement, Design, Interface Contract와의 충돌 발견 없음.

| 충돌 대상 | 충돌 내용 | 근거 |
|---|---|---|
| — | 없음 | IC-M3-1은 정의됨 상태이며 외부 계약 변경 없음. 기존 구조 안에서만 수정. |

---

## PART 5 — Verification Result Observation

Baseline: flutter analyze Pass (0 issues), flutter test 372건 All passed (`docs/baseline/A29_REGRESSION_BASELINE.md`).

| 확인 항목 | 결과 | 근거 |
|---|---|---|
| flutter analyze | **Pass** (No issues found, ran in 9.3s) | `flutter analyze` 실행 결과 |
| flutter test | **Pass (+372: All tests passed!)** | `flutter test` 실행 결과 |

새로운 실패 없음. Baseline 대비 동일.

---

## PART 6 — Remaining Item Observation

| 항목 | 구현 제외 이유 | 근거 |
|---|---|---|
| **IC-M3-2** `complete()` 미매칭 처리 외부 계약 | 정책 형태(로깅 vs 예외) 미결정 — 구현 가능한 확인된 범위 없음 | `A37_INTERFACE_CONTRACT_DEFINITION.md` PART 6: "일부 정의됨". PART 5 Missing Evidence: "정책 형태 결정 문서 없음" |
| **IC-M3-3** `calcDiscount()` 중첩 후 외부 계약 | ADR-005 미결정 — 중첩 정책 구현 불가. 반환 구조 변경 가능성 미확인 | `A37_INTERFACE_CONTRACT_DEFINITION.md` PART 6: "일부 정의됨". PART 5 Missing Evidence: "ADR-005 파일 없음" |
| **IC-M3-1** `Future.wait()` 예외 전파 방식 | A-37 PART 5 Missing Evidence로 기록됨. 외부 계약 유지 범위에서 구현하였으므로 별도 처리 불가 | `A37_INTERFACE_CONTRACT_DEFINITION.md` PART 5: IC-M3-1 미확인 항목 |

---

## PART 7 — 산출물

### 구현 내용

**파일**: `lib/features/booking/data/booking_completion_caller.dart`

**변경 전** (lines 62~74):
```dart
for (final id in productIds) {
  final product = products.where((p) => p.id == id).firstOrNull;
  if (product == null) continue;

  await _sessionRepository.addItem(
    sessionId: session.id,
    itemType: 'service',
    refType: 'booking',
    refId: booking.id.toString(),
    itemName: product.name,
    unitPrice: product.price,
  );
}
```

**변경 후**:
```dart
final futures = <Future<void>>[];
for (final id in productIds) {
  final product = products.where((p) => p.id == id).firstOrNull;
  if (product == null) continue;
  futures.add(_sessionRepository.addItem(
    sessionId: session.id,
    itemType: 'service',
    refType: 'booking',
    refId: booking.id.toString(),
    itemName: product.name,
    unitPrice: product.price,
  ));
}
await Future.wait(futures);
```

**클래스 주석 변경**: 실행 순서 5번 "순차" → "병렬 — DD-1 Future.wait()"

| Interface Contract | 구현 위치 | 변경 내용 | 근거 |
|---|---|---|---|
| **IC-M3-1** `complete()` 병렬화 후 외부 계약 | `lib/features/booking/data/booking_completion_caller.dart:62~79` | 순차 for loop `await` → `futures` 리스트 수집 후 `Future.wait()` 병렬 실행. 시그니처·반환형·외부 계약 변경 없음. | DD-1: `A36_DESIGN_DEFINITION.md`, `MARK2_IDEAS.md` Performance 분류, `A37_INTERFACE_CONTRACT_DEFINITION.md` IC-M3-1 |

### Verification 결과

| 항목 | 결과 |
|---|---|
| flutter analyze | **Pass** (No issues found) |
| flutter test | **Pass (+372: All tests passed!)** |

---

**"Milestone 3 Implementation Completed"**
