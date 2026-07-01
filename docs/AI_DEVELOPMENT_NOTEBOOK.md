# AI Development Engineering Notebook

> 이 문서는 A-20~A-25 시리즈를 실제로 진행하면서 확인된 경험과 시행착오를 기록한다. 설계 문서가 아니다 — 향후 MARK2 및 AI Development Platform V2를 만들 때 참고하기 위한 Engineering Notebook이다. 새로운 규칙을 만들지 않는다 — 실제 개발 과정에서 확인된 사실만 기록한다.
> **근거**: `docs/WORK_LOG.md`, `docs/DECISION_HISTORY.md`, `docs/AI_DEVELOPMENT_PROCESS.md`
> **See Also**: `docs/README.md`, `docs/MARK2_IDEAS.md`
> 작성일: 2026-07-01

---

## 1. 처음 생각했던 개발 흐름

```
Requirements
    ↓
Analysis
    ↓
Design
    ↓
Implementation
    ↓
Verification
```

요구사항을 받으면 분석하고, 설계하고, 구현하고, 검증하면 된다고 가정했다.

---

## 2. 실제 개발하면서 확인한 흐름

```
Requirements
    ↓
Analysis
    ↓
Design
    ↓
Contract Verification          ← 이 단계가 필수였다
    ↓
Implementation Attempt
    ↓
Problem Found                  ← 구현 도중 계약 부족 발견
    ↓
Repair Loop                    ← 설계 보완 오더 발생
    ↓  (반복 가능, 1회 이상)
Implementation Resume
    ↓
Verification
    ↓
Documentation
    ↓
Milestone
    ↓
MARK2                          ← 이번에 하지 못한 것을 분리 보관
```

A-25는 세 번의 구현 시도가 있었다:
- 1차 시도(A-25): `businessType` 출처 부재 → 중단
- 2차 시도(A-25 Contract Safe Version): `itemType: Product.id` 계약 충돌 → 중단
- 3차 시도(A-25 Locked Contract): 계약이 완전히 잠긴 뒤 → 성공

---

## 3. Repair Loop가 만들어진 이유

이번 프로젝트에서 Repair Loop가 발생한 실제 사례(A-20~A-25 시리즈):

| # | 발생 오더 | 원인 | 보완 오더 |
|---|---|---|---|
| 1 | A-25 (1차) | `businessType`이 `Bookings` 테이블에 없는데 `createSession()`이 `required String businessType`을 요구 — 계약에 출처가 정의되지 않음 | A-24.5: Data Ownership & Mapping Contract 작성 |
| 2 | A-25 (2차) | `itemType: Product.id`(정수)가 `addItem()`의 `_validItemTypes`{'service','product',...} 검증을 결정적으로 통과 못함 — A-24.5 계약의 오기 | A-24.7: Session Item Contract Verification & Correction |
| 3 | A-24 이전 | `completeBooking()`을 호출하는 기존 구조(화면/Repository)가 존재하지 않아 Orchestrator를 기존 코드에서 선택 불가 — 기존 구조 5개 후보 전부 기존 원칙과 충돌 | A-23 → A-24: Caller 패턴 설계 결정(단일 Caller 클래스 신설) |
| 4 | A-25 (2차) | Product 조회 방식이 계약에 정의되지 않았고, `ProductRepository`에 단건 조회 메서드가 없음을 구현 착수 시점에야 발견 | A-24.6: Product Retrieval Strategy Design |
| 5 | A-25 (3차 직전) | A-24.7 수정 후 저장 구조와 계약이 실제로 일치하는지 검증되지 않은 상태였음 | A-24.8: Session Item Persistence Contract Verification |

### 핵심 관찰

**Repair Loop는 "AI 구현 실패"가 아니라 "설계가 충분하지 않을 때 정상적으로 되돌아가는 과정"이다.** 추가 설계 오더(A-24.5, A-24.6, A-24.7, A-24.8)는 실패의 증거가 아니라, 구현 가능 여부를 검증하는 Contract Verification 단계가 없었을 때 발생하는 자연스러운 절차다.

---

## 4. Repair Loop 수행 조건

다음 상황에서는 구현을 중단하고 Repair Loop를 수행한다:

- **Domain 계약 부족**: 구현에 필요한 데이터의 출처가 어느 테이블/도메인에도 없음
- **Repository 계약 부족**: 필요한 Repository 메서드가 존재하지 않고, 추가는 제약으로 금지됨
- **Contract 충돌**: 잠긴 계약의 값이 기존 코드의 검증 로직을 통과하지 못함
- **Call Site 부족**: 호출자(caller)가 아직 코드에 존재하지 않음
- **Data Ownership 부족**: 필수 데이터의 소유 위치(테이블/도메인)가 정의되지 않음
- **Mapping 부족**: 한 도메인의 데이터를 다른 도메인의 API에 전달하는 변환 규칙이 정의되지 않음
- **DB Schema 변경 필요**: 구현 목적으로 새 컬럼/테이블이 필요해짐
- **Baseline 변경 필요**: 구현이 기존 Baseline(예: `SESSION_CLOSING_BASELINE.md`)을 침범함
- **Architecture 변경 필요**: 구현이 기존 ADR/원칙(Repository 수정 금지 등)과 충돌함

---

## 5. DB 변경 원칙

이번 A-20~A-25 시리즈에서는 실제 DB 변경이 발생하지 않았다 — `Snapshot 정책`과 `Product.id 미저장` 결정으로 기존 스키마 그대로 구현이 가능했다(`docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md`).

그러나 향후 DB 변경이 필요해지는 경우, 다음 순서를 **반드시** 따른다:

```
구현 중단
    ↓
원인 분석
(왜 기존 스키마로는 불가능한지, 다른 방법은 없는지 확인)
    ↓
Schema Design
(신규 컬럼/테이블 설계, 기존 데이터와의 관계)
    ↓
Migration 설계
(순수 추가형 마이그레이션, 데이터 손실 없는 방식)
    ↓
Contract 확인
(변경된 스키마와 기존 계약의 일치 여부)
    ↓
구현 재개
```

이 순서를 건너뛰고 즉시 구현하지 않는다.

---

## 6. 개발하면서 얻은 교훈

### 설계에 대해

- **구현을 시작해야 부족한 설계가 보인다.** A-25 1차/2차 시도의 중단이 이를 증명했다 — 분석과 설계 단계에서는 보이지 않던 `businessType` 부재와 `itemType` 오기가 구현 착수 직전에야 발견됐다. 이건 설계 과정의 실패가 아니라, "Contract Verification" 단계가 별도로 필요하다는 신호였다.

- **추가 설계 오더는 실패가 아니라 정상적인 개발 과정이다.** A-24.5~A-24.8 오더들은 "구현이 멈췄다"는 것이 아니라 "설계가 구현에 충분히 좁혀지고 있다"는 것이었다. 5개의 설계 보완 오더 끝에 A-25 3차 시도가 첫 번째 시도 만에 373건 테스트를 통과했다는 것이 이를 증명한다.

- **AI가 추론하게 만들기보다 설계를 보완하는 것이 품질이 높다.** A-25 구현 도중 `itemType: Product.id`를 `itemType: 'service'`로 추론해서 고칠 수 있었다. 하지만 그것은 "추론 기반 Business Logic 생성 금지" 위반이었다. PART7 HARD STOP을 발동하고 A-24.7 설계 보완 오더를 받은 결과, 코드에 근거한 `'service'`가 선택됐고 DECISION_HISTORY에 그 이유가 영구히 기록됐다.

### 계약에 대해

- **구현보다 계약이 더 오래 유지된다.** `lib/features/booking/data/booking_completion_caller.dart`는 60행이지만, 그 60행을 만들기 위해 A-24~A-24.8에 걸쳐 5개의 계약 문서가 작성됐다. 코드는 언젠가 바뀔 수 있어도 결정의 이유(`DECISION_HISTORY.md`, `ADR_INDEX.md`)는 계속 남는다.

- **계약이 잠기면(`Locked`) 그 이후 구현에서 임의 변경은 없다.** A-25의 "Absolute Lock" 원칙은 구현 과정에서 계약을 임의로 수정하는 것을 막아, 설계 결정의 신뢰성을 보장했다.

### 문서에 대해

- **문서는 결과뿐 아니라 이유도 남겨야 한다.** `docs/DECISION_HISTORY.md`가 "왜 `'service'`를 선택했는가"를 기록하지 않았다면, 다음 개발자(또는 다음 세션의 AI)가 같은 질문을 다시 반복할 것이다.

- **"선정 불가"도 결과다.** A-23에서 기존 구조 5개 후보를 전부 Rejected하고 "선정 불가"로 끝낸 것은 정직한 결론이었다. 이후 A-24가 그 기반 위에서 Caller 패턴을 결정했고, 그 결정은 더 좋은 근거를 가졌다.

### MARK2에 대해

- **MARK2 아이디어는 반드시 분리해서 관리한다.** `BookingRepository.getBookingById()` 추가, 병렬 `addItem()`, 미매칭 상품 명시적 정책 — 이 세 가지는 구현 도중에 발견했지만 현재 계약("Repository 수정 금지", "parallel 금지", "새로운 로직 추가 금지")에 의해 보류됐다. `docs/MARK2_IDEAS.md`에 분리해 기록함으로써 현재 구현을 단순하게 유지하면서도 아이디어를 잃지 않았다.
