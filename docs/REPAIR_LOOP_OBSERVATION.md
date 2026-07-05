# Repair Loop Observation

> 이 문서는 실제 프로젝트에서 발생한 Repair 사례를 관찰(Observation) 관점에서 기록한다.
> **제약**: 실제 확인 가능한 내용만 기록. 원인(Causation) 추론 금지. 인과관계 추론 금지. 개선안 제안 금지.
> **기준 문서**: `docs/WORK_LOG.md`, `docs/DECISION_HISTORY.md`, `docs/AI_DEVELOPMENT_NOTEBOOK.md`, `docs/DEVELOPMENT_TRACEABILITY_ARCHITECTURE.md`, `git log --oneline` 실측
> 작성일: 2026-07-03

---

## PART 1 — Repair Event Inventory

실제 발생한 Repair Event: **총 3건**

---

### Repair-1: businessType 출처 부재

| 항목 | 내용 |
|---|---|
| **Repair ID** | Repair-1 (A-25 1차 중단 → A-24.5) |
| **관련 문서** | `docs/WORK_LOG.md` (A-25 1차 항목), `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` |
| **관련 Commit** | `77705c3` (WORK_LOG: A-25 중단 기록), `c77c372` (A-24.5 문서) |
| **관련 코드** | `lib/features/session/data/session_repository.dart` — `createSession(required String businessType)` 시그니처, `lib/db/app_database.dart` — `Bookings` 테이블 컬럼 목록 |
| **Repair 내용** | A-25 구현 착수 중 `createSession()`이 `required String businessType`을 요구하지만 `Bookings` 테이블에 해당 컬럼이 없음을 확인. 구현을 중단하고 A-24.5 오더(Data Ownership & Mapping Contract)를 통해 `businessType=외부주입`으로 계약을 확정함 |
| **Repair 결과** | `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` 작성. `complete({required String businessType})` 시그니처 확정. 코드 작성 없음(설계만) |

---

### Repair-2: itemType 계약 충돌

| 항목 | 내용 |
|---|---|
| **Repair ID** | Repair-2 (A-25 2차 중단 → A-24.7) |
| **관련 문서** | `docs/WORK_LOG.md` (A-25 2차 항목, `ea1884c` 커밋), `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` |
| **관련 Commit** | `ea1884c` (WORK_LOG: 2차 중단 기록), `35217ed` (A-24.7 문서), `a3e64e6` (WORK_LOG: A-24.7 항목) |
| **관련 코드** | `lib/features/session/data/session_repository.dart` — `_validItemTypes = {'service','product','time','staff_fee','discount','surcharge'}` 검증 로직 |
| **Repair 내용** | A-25 2차 시도에서 계약 대조 중 `itemType: Product.id`(정수값)가 `_validItemTypes` 검증을 통과할 수 없음을 발견. PART7 HARD STOP을 적용하고 A-24.7 오더를 통해 `itemType: 'service'`(문자열 상수)로 계약을 정정함 |
| **Repair 결과** | `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` 작성. `itemType='service'`(고정 상수) 확정. `Product.id`는 조회 키로만 사용하고 `addItem()` 파라미터에 미저장으로 확정. 이후 A-24.8 검증 오더 추가 발생 |

---

### Repair-3: Race Condition 발견

| 항목 | 내용 |
|---|---|
| **Repair ID** | Repair-3 (A-13 Concurrency 발견 → A-18.2 → A-18.3) |
| **관련 문서** | `docs/A13_CONCURRENCY_VALIDATION.md`, `docs/A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md`, `docs/A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md` |
| **관련 Commit** | `6cc7bb9` (A-13~A-18.4 통합 커밋) |
| **관련 코드** | `lib/features/session/workflow/session_closing_workflow.dart` — `_db.transaction()` + Conditional UPDATE (`WHERE status='open'`, `updatedRows==0` 체크) |
| **Repair 내용** | `closeSession()`의 status 가드 체크가 `_db.transaction()` 밖에 위치해 두 개의 동시 호출이 모두 가드를 통과할 수 있음을 A-13 분석에서 발견. A-18.1에서 멱등성 재확인 후 A-18.2에서 Minimal Change 방법 선정(Conditional Update). A-18.3에서 구현 |
| **Repair 결과** | `session_closing_workflow.dart`에 Conditional Update 적용 — `WHERE id=sessionId AND status='open'`, `updatedRows==0`이면 `BusinessRuleException` throw. A-18.4에서 `Future.wait()` 동시 호출 테스트로 검증(1건만 성공 확인) |

---

## PART 2 — Repair Flow Observation

실제 프로젝트에서 관찰된 Repair 흐름:

### Repair-1 흐름

```
A-24 Design 완료
    ↓
A-25 Implementation 착수
    ↓
createSession() 시그니처 확인 → businessType 필수 파라미터 확인
    ↓
Bookings 테이블 컬럼 확인 → businessType 컬럼 없음 확인
    ↓
구현 중단 (코드 작성 안 함)
    ↓
WORK_LOG에 중단 기록 (커밋 77705c3)
    ↓
A-24.5 Design 오더 발생 → Data Ownership 계약 작성 (커밋 c77c372)
    ↓
A-25 2차 시도로 이어짐 (→ Repair-2)
```

### Repair-2 흐름

```
A-24.5/A-24.6 Design 완료 후
A-25 2차 시도 — 계약 대조 중
    ↓
itemType: Product.id 값 확인
    ↓
session_repository.dart _validItemTypes 확인 → {'service','product','time','staff_fee','discount','surcharge'}
    ↓
Product.id(정수)가 문자열 집합과 충돌 확인
    ↓
PART7 HARD STOP 적용, 코드 작성 안 함
    ↓
WORK_LOG에 중단 기록 (커밋 ea1884c)
    ↓
A-24.7 Contract Verification 오더 발생 → itemType='service' 확정 (커밋 35217ed)
    ↓
A-24.8 Persistence 검증 오더 추가 발생 → Conflict 0건 확인 (커밋 d0bf64c)
    ↓
A-25 3차 시도 → 성공 (커밋 a12190b)
```

### Repair-3 흐름

```
A-12(Staff Earning) 구현 완료
    ↓
A-13 Concurrency & Transaction Analysis 착수
    ↓
docs/A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md — 9단계 분해, 위험 구간 식별
    ↓
docs/A13_CONCURRENCY_VALIDATION.md — 동시 호출 시 Race Condition 확인
    ↓
A-14 Workflow Extraction (SessionClosingWorkflow 분리)
    ↓
A-17 Operational Stability Check
    ↓
A-18.1 Idempotency Analysis — 순차 재시도 안전, 동시 호출 위험 재확인
    ↓
A-18.2 Minimal Change Resolution Analysis — Conditional Update 선정
    ↓
A-18.3 Implementation — Conditional Update 적용
    ↓
A-18.4 Verification — Future.wait() 동시 호출 테스트 통과
    ↓
docs/baseline/SESSION_CLOSING_BASELINE.md 작성 (A-19)
```

> **관찰**: Repair-1과 Repair-2는 Implementation 착수 단계에서 발견 후 즉시 중단하고 별도 Design 오더로 이어졌다. Repair-3은 Implementation 완료 이전 분석 단계에서 발견되어 Design Repair → Implementation → Verification 순서를 거쳤다.

---

## PART 3 — Repair Evidence Observation

각 Repair에서 실제 확인 가능한 Evidence:

---

### Repair-1 Evidence

| 항목 | 내용 |
|---|---|
| **Repair ID** | Repair-1 |
| **관찰된 Evidence** | `WORK_LOG.md` A-25 1차 항목: "createSession()은 businessType(필수)을 요구하나 Bookings 테이블에 해당 컬럼이 없음", "파일을 작성하지 않은 채 중단", "'Booking Completion Caller Implementation Completed' 미명시" |
| **근거 문서** | `docs/WORK_LOG.md` (A-25 1차 항목, 2026-06-29 기록) |
| **근거 Commit** | `77705c3` — 커밋 메시지: "docs: WORK_LOG에 A-25 항목 추가(구현 중단, 추가 오더 필요)" |
| **근거 코드** | `lib/features/session/data/session_repository.dart` — `createSession({required String businessType, ...})` 시그니처 (코드 직접 확인 가능) |

---

### Repair-2 Evidence

| 항목 | 내용 |
|---|---|
| **Repair ID** | Repair-2 |
| **관찰된 Evidence** | `WORK_LOG.md` A-25 2차 항목: "itemType: Product.id가 SessionRepository.addItem()의 기존 검증 로직과 결정적으로 충돌함", "어떤 실데이터로도 ValidationException을 피할 수 없는 모순", "PART7 HARD STOP 적용, 파일 작성 안 함" |
| **근거 문서** | `docs/WORK_LOG.md` (A-25 2차 항목), `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` |
| **근거 Commit** | `ea1884c` — 커밋 메시지: "docs: WORK_LOG에 A-25 2차 시도 중단 기록(itemType 매핑 모순 발견)" |
| **근거 코드** | `lib/features/session/data/session_repository.dart` — `_validItemTypes = {'service','product','time','staff_fee','discount','surcharge'}` (코드 직접 확인 가능) |

---

### Repair-3 Evidence

| 항목 | 내용 |
|---|---|
| **Repair ID** | Repair-3 |
| **관찰된 Evidence** | `docs/A13_CONCURRENCY_VALIDATION.md` PART1: "호출 A가 await 지점에서 제어를 양보한 틈에 호출 B도 같은 가드를 통과한다 — 결과: payment_method_breakdowns에 결제수단 기록이 2배, staff_earning_ledgers에 수당 기록이 2배" |
| **근거 문서** | `docs/A13_CONCURRENCY_VALIDATION.md`, `docs/A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md` |
| **근거 Commit** | `6cc7bb9` — 커밋 메시지: "A-13~A-18.4: Transaction Boundary + Workflow Extraction + Race Condition 해소" |
| **근거 코드** | `lib/features/session/workflow/session_closing_workflow.dart` — `WHERE id=sessionId AND status='open'` Conditional Update, `if (updatedRows == 0) throw BusinessRuleException(...)` (코드 직접 확인 가능) |

---

## PART 4 — Repair Pattern Observation

실제 Repair Event 기준으로 반복 관찰된 패턴:

---

### 관찰 1: 구현 착수 후 코드 작성 전 중단

| 항목 | 내용 |
|---|---|
| **관찰 내용** | Repair가 발생한 시점에 실제 코드 파일이 작성되지 않은 채 중단됨 |
| **동일 패턴이 확인된 Event 수** | **2건** (Repair-1, Repair-2) |
| **근거** | WORK_LOG.md Repair-1 항목: "파일을 작성하지 않은 채 중단". WORK_LOG.md Repair-2 항목: "파일 작성 안 함". 두 중단 커밋(`77705c3`, `ea1884c`) 모두 코드 변경 없음(docs 디렉터리만 변경) |

---

### 관찰 2: Repair 발생 후 별도 문서 오더 생성

| 항목 | 내용 |
|---|---|
| **관찰 내용** | Repair마다 해당 충돌을 해소하기 위한 별도 설계/검증 문서가 생성됨 |
| **동일 패턴이 확인된 Event 수** | **3건** (Repair-1 → A-24.5, Repair-2 → A-24.7+A-24.8, Repair-3 → A-18.2+docs) |
| **근거** | Repair-1: 커밋 `c77c372` (A-24.5 신규). Repair-2: 커밋 `35217ed` (A-24.7 신규), `d0bf64c` (A-24.8 신규). Repair-3: 커밋 `6cc7bb9` (A-18.2 포함 다수 문서 신규) |

---

### 관찰 3: WORK_LOG에 중단 사실 기록

| 항목 | 내용 |
|---|---|
| **관찰 내용** | 구현 중단 시 WORK_LOG에 중단 사실과 이유가 별도 커밋으로 기록됨 |
| **동일 패턴이 확인된 Event 수** | **2건** (Repair-1, Repair-2) |
| **근거** | 커밋 `77705c3` 메시지: "WORK_LOG에 A-25 항목 추가(구현 중단, 추가 오더 필요)". 커밋 `ea1884c` 메시지: "WORK_LOG에 A-25 2차 시도 중단 기록(itemType 매핑 모순 발견)" |

> **주의**: Repair-3은 Implementation 착수 이전 분석 단계에서 발견되어 위 3개 패턴과 발생 형태가 다름.

---

## PART 5 — Discovery Observation

Repair가 최초로 확인된 위치:

| Repair ID | 최초 확인 문서 | 최초 확인 Commit | 최초 확인 개발 단계 | 근거 |
|---|---|---|---|---|
| **Repair-1** | `docs/WORK_LOG.md` (A-25 1차 중단 항목) | `77705c3` | Implementation | WORK_LOG: "구현 착수 중 A-24가 다루지 않은 필수 정보 누락을 발견하고 … 중단". 커밋 `77705c3`이 최초 기록. A-24.5 오더(`c77c372`)는 그 이후 생성 |
| **Repair-2** | `docs/WORK_LOG.md` (A-25 2차 중단 항목) | `ea1884c` | Implementation | WORK_LOG: "구현 착수 전 계약을 기존 코드와 대조 검증하던 중 … 충돌함을 발견". 커밋 `ea1884c`이 최초 기록. A-24.7 오더(`35217ed`)는 그 이후 생성 |
| **Repair-3** | `docs/A13_CONCURRENCY_VALIDATION.md` | `6cc7bb9` (통합 커밋) | Analysis | `A13_CONCURRENCY_VALIDATION.md`에서 "현재 코드는 안전하지 않다"로 Race Condition 최초 명시. 이 문서는 Implementation 이전 Analysis 단계에서 작성됨 |

---

## PART 6 — Repair Trigger Observation

Repair를 시작하게 만든 실제 관찰 사실:

| Repair ID | Trigger | 근거 |
|---|---|---|
| **Repair-1** | `createSession()` 메서드 시그니처에서 `required String businessType` 파라미터 확인, `Bookings` 테이블 컬럼 목록에서 `businessType` 컬럼 부재 확인 | WORK_LOG: "createSession()은 businessType(필수)을 요구하나 Bookings 테이블에 해당 컬럼이 없음". 코드: `lib/features/session/data/session_repository.dart` 시그니처 직접 확인 가능 |
| **Repair-2** | `_validItemTypes = {'service','product','time','staff_fee','discount','surcharge'}` 집합에 정수형 `Product.id`가 포함 불가함을 코드에서 직접 확인 | WORK_LOG: "itemType: Product.id가 … 결정적으로 충돌함". `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md`: "어떤 실데이터로도 ValidationException을 피할 수 없는 모순". 코드: `session_repository.dart` `_validItemTypes` 선언 직접 확인 가능 |
| **Repair-3** | `closeSession()` 내 status 가드 체크가 `_db.transaction()` 호출 이전에 위치함을 코드에서 확인, 두 개의 async 호출이 동일 가드를 통과 가능한 인터리빙 시나리오를 `A13_CONCURRENCY_VALIDATION.md`에서 기록 | `docs/A13_CONCURRENCY_VALIDATION.md` PART1: "호출 A가 await 지점에서 이벤트 루프에 제어를 양보한다 … 호출 B도 가드를 통과한다". `docs/A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md`: 가드 위치 확인 재확인 |

---

## PART 7 — Gap Analysis

| 항목 | 결과 |
|---|---|
| **Repair 추적 불가 사례** | A-10~A-12 Engine 개발 시리즈의 중간 설계 조정이 있었는지 `6cc7bb9` 이전 개별 커밋이 없어 추적 불가. 세 Engine(`PricingEngine`, `PromotionEngine`, `StaffEarningEngine`)은 각각 단일 커밋(`1fc9d06`, `3c11deb`, `128a3b7`)으로 통합 기록됨. 중간 Repair 발생 여부 미확인 |
| **최초 발견 위치 확인 불가 사례** | Repair-3의 최초 발견이 `A13_CONCURRENCY_VALIDATION.md`에 기록된 것은 확인되나, 이 문서와 `6cc7bb9` 커밋이 동일 커밋으로 묶여 있어 개별 단계별 발견 순서 추적 불가 |
| **Evidence 부족 사례** | Repair-1에서 `Bookings` 테이블 컬럼 목록을 어느 시점에 확인했는지 코드 이외의 문서 근거가 없음. WORK_LOG에 텍스트로만 기록되어 있고 해당 확인 행위의 커밋이 별도 존재하지 않음 |
| **Trigger 확인 불가 사례** | Repair-2의 Trigger가 "계약 대조 중 발견"으로 기록되어 있으나, 대조 행위 자체의 문서(별도 분석 파일)가 없음. WORK_LOG 텍스트와 A-24.7 문서만 존재 |
| **추가 증거 확보가 필요한 항목** | (1) A-10~A-12 각 Engine 개발 중 중간 Repair 발생 여부 — 개별 커밋이 없어 현재 확인 불가. (2) Repair-1 발생 직전 `createSession()` 시그니처 확인 행위의 타임라인 — WORK_LOG 텍스트만 존재 |

---

## PART 8 — 산출물 확인

이 문서: `docs/REPAIR_LOOP_OBSERVATION.md` ✓

README 링크 추가: PART 8 완료 시 `docs/README.md` Development Process 섹션에 추가.

---

## Baseline 확인

| 항목 | 결과 |
|---|---|
| **flutter analyze** | **Pass** — No issues found |
| **flutter test** | **Pass** — 373 tests passed |

코드 변경 없음. 이 문서는 순수 관찰 기록이다.

---

**"Repair Loop Observation Established"**
