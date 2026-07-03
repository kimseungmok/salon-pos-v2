# Development Traceability & AI Development Architecture

> 이 문서는 지금까지 구축한 Requirement, Analysis, Design, Contract Verification, Design Repair, Implementation, Verification, Documentation, Decision, Commit, Milestone, MARK2 사이의 관계를 하나의 Development Traceability Architecture로 정리한다.
> **제약**: 실제 프로젝트에서 확인된 내용만 사용한다. 새로운 개발 방법론을 만들지 않는다.
> **See Also**: `docs/AI_DEVELOPMENT_PROCESS.md`, `docs/AI_DEVELOPMENT_NOTEBOOK.md`, `docs/DECISION_HISTORY.md`, `docs/WORK_LOG.md`
> 작성일: 2026-07-03

---

## PART 1 — Development Asset Inventory

프로젝트에서 실제로 사용된 Development Asset 목록:

| Asset | 사용 여부 | 근거 문서 |
|---|---|---|
| **Requirement** | 사용됨 | `docs/proposal/salon_pos_hearing_sheet.md` (2026-07-02 히어링 시트), `docs/proposal/proposal_project_plan.md` (제안서) — 기능 범위와 비즈니스 규칙의 출발점 |
| **Analysis** | 사용됨 | `docs/A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md`, `docs/A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md`, `docs/A22_BOOKING_SESSION_CALL_SITE_ANALYSIS.md`, `docs/A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md` — 코드 기반 실측 분석 |
| **Design** | 사용됨 | `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md`, `docs/A24_5~A24_8` 시리즈 — 계약 설계 및 확정 |
| **Contract Verification** | 사용됨 | `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md`, `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` — 계약과 실제 DB/코드 일치 검증 |
| **Design Repair** | 사용됨 | A-25 1차/2차 중단 → A-24.5(businessType 부재) / A-24.7(itemType 오기) 설계 보완. `docs/AI_DEVELOPMENT_NOTEBOOK.md` PART 3의 5개 Repair Loop 사례 |
| **Implementation** | 사용됨 | `lib/features/booking/data/booking_completion_caller.dart`, `lib/features/pricing/`, `lib/features/promotion/`, `lib/features/staff_earning/`, `lib/features/session/workflow/session_closing_workflow.dart` |
| **Verification** | 사용됨 | `docs/A13_CONCURRENCY_VALIDATION.md`, `docs/A17_OPERATIONAL_STABILITY_CHECK.md`, `docs/A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md`, `test/features/booking/booking_completion_caller_test.dart` (4 tests) |
| **Documentation** | 사용됨 | `docs/README.md`, `docs/ARCHITECTURE_SUMMARY.md`, `docs/ADR_INDEX.md`, `docs/adr/ADR-001~007` 등 60개 문서 |
| **Decision** | 사용됨 | `docs/DECISION_HISTORY.md` — 핵심 설계 결정 9건 시간순 기록 |
| **Commit** | 사용됨 | git log 실측 — 60개 이상 커밋(A-8~A-25.12 시리즈, 코드+문서 분리 커밋 전략) |
| **Milestone** | 사용됨 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` — A-20~A-25.6 공식 완료 기록 |
| **MARK2** | 사용됨 | `docs/MARK2_IDEAS.md` — 3개 아이디어(Repository 단건 조회, addItem 병렬화, 미매칭 상품 정책) |

---

## PART 2 — AI Development Flow

실제 프로젝트에서 확인된 흐름 (`docs/AI_DEVELOPMENT_NOTEBOOK.md` PART 2 참조):

```
Requirement
    ↓  (비즈니스 규칙·기능 범위 정의 — proposal/ 문서)
Analysis
    ↓  (실제 코드 기반 도메인·통합 지점·Call Site 확인)
Design
    ↓  (Caller 패턴 결정, 계약 초안 작성)
Contract Verification
    ↓  (계약과 실제 코드/DB의 일치 확인)
Design Repair               ← [분기] 충돌 발견 시 Design으로 복귀
    ↓  (계약 정정, 재검증)
Implementation
    ↓  (잠긴 계약만 코드화, MARK2 아이디어는 제외)
Verification
    ↓  (flutter analyze 0 issues, flutter test 전체 통과)
Documentation
    ↓  (WORK_LOG 갱신, 설계 문서 보완)
Decision
    ↓  (DECISION_HISTORY에 결정 이유 기록)
Commit
    ↓  (코드 커밋 + WORK_LOG 별도 커밋 + push)
Milestone
    ↓  (Milestone 문서 작성, ARCHITECTURE_SUMMARY 갱신)
MARK2
       (보류 아이디어를 MARK2_IDEAS.md에 기록, 다음 Milestone 백로그)
```

**핵심 관찰**: Design Repair는 단일 루프가 아니다. A-25에서는 두 번의 중단(1차: businessType, 2차: itemType)이 발생했고, 각각 A-24.5→재검증→A-24.7→재검증(A-24.8)의 두 Repair Loop를 거쳐 3차 시도에서 성공했다.

---

## PART 3 — Traceability Matrix

하나의 거대한 Matrix 대신 Logical Group 단위로 작성한다.

---

### Group A — Session Engine Foundation (A-8~A-9.5)

```
Requirement
  → 살롱/카라오케/이자카야 공통 전표 엔진 필요, INTEGER ID 통일

Analysis
  → 기존 테이블 ID 타입 혼재(UUID/INTEGER) 확인

Design
  → SESSION ENGINE 4개 테이블 설계(PaymentSessions, PaymentSessionItems, PaymentMethodBreakdowns, StaffEarningLedgers)
  → UUID→INTEGER 통일 원칙 확정

Implementation
  → lib/db/app_database.dart (schemaVersion 3→4→5→6)
  → lib/features/session/ 기초 구조

Verification
  → flutter test Pass (기준선 278건)

Commit
  → aa06bff (A-8 SESSION ENGINE)
  → ea76edc (A-9 ID 통일)
  → 2895cdc (A-9.5 staffId TEXT→INTEGER)

문서
  → docs/A8_SESSION_ENGINE.md
  → docs/A9_ID_UNIFICATION.md
  → docs/ID_CONVENTION.md
```

---

### Group B — Engine Layer (A-10~A-12)

```
Requirement
  → 시간·피크 요금 계산, 할인 적용, 직원 수당 계산 기능 필요

Analysis
  → 기존 계산 로직 부재 확인, 도메인 격리 필요성 발견

Design
  → ADR-001: Engine은 Drift 비의존 순수 계산 클래스
  → ADR-002: 할인은 PaymentSessionItem(itemType='discount') 이벤트
  → ADR-006: Staff Earning = 할인 전 기준 + closeSession() 시점 확정

Implementation
  → lib/features/pricing/logic/pricing_engine.dart
  → lib/features/promotion/logic/promotion_engine.dart
  → lib/features/staff_earning/logic/staff_earning_engine.dart
  → lib/features/pricing/data/pricing_rule_repository.dart
  → lib/features/promotion/data/promotion_rule_repository.dart

Verification
  → flutter analyze 0 issues
  → flutter test Pass (278→369건)

Decision (docs/DECISION_HISTORY.md 기록)
  → ADR-001 Pricing Engine 도메인 격리
  → ADR-002 할인 표현 방식
  → ADR-006 Staff Earning 생성 시점

Commit
  → 1fc9d06 (A-10 Pricing Engine)
  → 3c11deb (A-11 Promotion Engine)
  → 128a3b7 (A-12 Staff Earning Engine)

Milestone
  → 해당 없음(Milestone 1 포함 범위이나 별도 중간 Milestone 없음)

MARK2
  → 해당 없음
```

---

### Group C — Transaction Boundary & Race Condition (A-13~A-18.4)

```
Requirement
  → closeSession() 동시 호출 안전성, 결제→상태변경 원자성 필요

Analysis
  → docs/A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md: 단계별 실패 시나리오 분석
  → docs/A13_CONCURRENCY_VALIDATION.md: Race Condition(TOCTOU) 발견
  → docs/A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md: 순차 재시도 안전, 동시 호출 위험

Design
  → ADR-007: Settlement~status-change를 단일 _db.transaction() 콜백으로 래핑
  → Conditional Update: WHERE id=sessionId AND status='open', updatedRows==0 → 예외

Contract Verification
  → docs/A14_WORKFLOW_CONTRACT_VALIDATION.md, A14_WORKFLOW_DEPENDENCY_VALIDATION.md, A14_WORKFLOW_PATTERN_VALIDATION.md

Design Repair
  → A-18.2: 최소 변경 분석(Guard check 위치 변경 vs Conditional Update 중 Conditional Update 선택)

Implementation
  → lib/features/session/workflow/session_closing_workflow.dart (_db.transaction() 내 Conditional Update)

Verification
  → Future.wait() 동시 호출 테스트: 1건만 성공, 나머지 BusinessRuleException 확인
  → docs/A17_OPERATIONAL_STABILITY_CHECK.md: 운영 관점 안정성 확인

Documentation
  → docs/baseline/SESSION_CLOSING_BASELINE.md (A-19 공식 Baseline 확정)

Decision (docs/DECISION_HISTORY.md 기록)
  → ADR-007 Transaction Scope

Commit
  → 6cc7bb9 (A-13~A-18.4: Transaction + Workflow + Race Condition)
  → 15296f1 (A-19: Session Closing Baseline)

MARK2
  → 해당 없음
```

---

### Group D — Booking Session Integration Foundation (A-20~A-25)

```
Requirement
  → 예약 완료 시 자동으로 Session 생성 + Session Item 추가 필요

Analysis (4단계)
  → A-20(docs/A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md): BookingRepository 8개 메서드, createSession() 호출자 0건
  → A-21(docs/A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md): refType='booking'은 addItem 레벨
  → A-22(docs/A22_BOOKING_SESSION_CALL_SITE_ANALYSIS.md): Call Site = completeBooking() 호출 위치
  → A-23(docs/A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md): 기존 5개 후보 전부 Rejected — "선정 불가"

Design (1+4단계)
  → A-24(docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md): 단일 Caller 클래스 신설 결정
  → A-24.5(docs/A24_5_...): businessType=외부주입, staffId/customerId=직접 매핑, roomId=null
  → A-24.6(docs/A24_6_...): watchProducts().first + 메모리 매칭 전략
  → A-24.7(docs/A24_7_...): itemType='service'(A-24.5 오기 정정), Product.id=조회 키만
  → A-24.8(docs/A24_8_...): 저장 구조와 계약 일치 검증 — Conflict 0건

Design Repair (2회)
  → 1차 중단(A-25): businessType 출처 부재 → A-24.5 오더 발생
  → 2차 중단(A-25): itemType:Product.id 검증 실패 → A-24.7 오더 발생

Contract Verification
  → A-24.7: _validItemTypes{'service','product','time','staff_fee','discount','surcharge'} 확인
  → A-24.8: PaymentSessionItems 6개 컬럼 1:1 대조, 전부 일치

Implementation (3차 시도에서 성공)
  → lib/features/booking/data/booking_completion_caller.dart (60행)
  → test/features/booking/booking_completion_caller_test.dart (4 tests)

Verification
  → flutter analyze 0 issues
  → flutter test 373건 Pass (278→373: +95건)

Documentation (A-25.5~A-25.12)
  → docs/ARCHITECTURE_SUMMARY.md, docs/ADR_INDEX.md
  → docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md
  → docs/DECISION_HISTORY.md (9건)
  → docs/AI_DEVELOPMENT_PROCESS.md, docs/DEVELOPMENT_CHECKLIST.md
  → docs/AI_DEVELOPMENT_NOTEBOOK.md
  → docs/A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md
  → docs/A25_12_DOCUMENTATION_IA_DESIGN.md (60개 문서 IA 설계)

Decision (docs/DECISION_HISTORY.md 기록)
  → Caller 패턴 도입, businessType 외부 주입, watchProducts() 전략, itemType='service' 확정, Snapshot 정책 유지, Product.id 미저장, addItem() 순차 호출

Commit
  → a4158e7 (A-24), c77c372 (A-24.5), 0eec1c1 (A-24.6), 35217ed (A-24.7), d0bf64c (A-24.8)
  → a12190b (A-25 구현), defa2d4 (A-25.5), 9d8c661 (A-25.6)
  → c7c5121 (A-25.8), 3572338 (A-25.10), 66bf5bb (A-25.11), 5df5d77 (A-25.12)
  → (각 문서 커밋에 대응하는 WORK_LOG 별도 커밋 12건)

Milestone
  → docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md (A-25.6 작성, 커밋 9d8c661)

MARK2
  → docs/MARK2_IDEAS.md: 3개 아이디어(Repository.getById, 병렬 addItem, 미매칭 정책)
```

---

## PART 4 — Decision Traceability

Decision이 어디에 영향을 주는지 실제 확인 가능한 관계만 기록한다.

| Decision | 영향을 받은 문서 | 영향을 받은 코드 | Verification |
|---|---|---|---|
| **ADR-001** Pricing Engine 도메인 격리(Repository만 Drift를 앎) | `docs/adr/ADR-001-pricing-engine-domain-isolation.md`, `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md`, `docs/ARCHITECTURE_SUMMARY.md` | `lib/features/pricing/logic/pricing_engine.dart` (import drift 없음), `lib/features/pricing/data/pricing_rule_repository.dart` | flutter analyze 0 issues (Engine에 Drift import 없음 확인됨) |
| **ADR-002** 할인 = PaymentSessionItem(itemType='discount') | `docs/adr/ADR-002-discount-representation.md`, `docs/ARCHITECTURE_SUMMARY.md` | `lib/features/session/data/session_repository.dart` (`_validItemTypes`에 'discount' 포함) | flutter test Pass (세션 아이템 유효성 테스트) |
| **ADR-003** Financial Events append-only | `docs/adr/ADR-003-financial-events.md`, `docs/baseline/SESSION_CLOSING_BASELINE.md` | `lib/features/session/workflow/session_closing_workflow.dart` (이벤트 삽입만 수행, 갱신 없음) | flutter test Pass |
| **ADR-004** Promotion Rule Lifecycle | `docs/adr/ADR-004-promotion-rule-lifecycle.md`, `docs/architecture/PROMOTION_ENGINE_ARCHITECTURE.md` | `lib/features/promotion/data/promotion_rule_repository.dart` (status 전이 검증) | flutter test Pass |
| **ADR-006** Staff Earning = closeSession() 시점 확정 | `docs/adr/ADR-006-staff-earning-policy.md`, `docs/ARCHITECTURE_SUMMARY.md`, `docs/baseline/SESSION_CLOSING_BASELINE.md` | `lib/features/session/workflow/session_closing_workflow.dart` (run() 내 staff_earning_ledgers 삽입) | flutter test Pass (A-12 이후 addItem() 즉시 생성 로직 제거 확인) |
| **ADR-007** Transaction Scope | `docs/adr/ADR-007-a13-mvp-transaction-scope.md`, `docs/baseline/SESSION_CLOSING_BASELINE.md`, `docs/A13_CONCURRENCY_VALIDATION.md` | `lib/features/session/workflow/session_closing_workflow.dart` (`_db.transaction()` + Conditional Update) | Future.wait() 동시 호출 테스트 (1건만 성공 확인) |
| **Caller 패턴** (A-23/A-24) | `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md`, `docs/ARCHITECTURE_SUMMARY.md`, `docs/DECISION_HISTORY.md` | `lib/features/booking/data/booking_completion_caller.dart` (신규 파일) | `test/features/booking/booking_completion_caller_test.dart` 4 tests Pass |
| **businessType 외부 주입** (A-24.5) | `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md`, `docs/DECISION_HISTORY.md` | `booking_completion_caller.dart:complete({required String businessType})` 메서드 시그니처 | test: `complete(businessType: 'salon')` 호출 패턴 확인 |
| **watchProducts() 전략** (A-24.6) | `docs/A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md`, `docs/DECISION_HISTORY.md` | `booking_completion_caller.dart:39` — `_productRepository.watchProducts().first` | test: mock products 전달 후 매칭 확인 |
| **itemType='service'** (A-24.7) | `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md`, `docs/DECISION_HISTORY.md` | `booking_completion_caller.dart:49` — `itemType: 'service'` (고정 상수) | `test/features/booking/booking_completion_caller_test.dart` — addItem 호출 검증 |
| **addItem() 순차 호출** (A-25) | `docs/MARK2_IDEAS.md` (Performance 항목), `docs/DECISION_HISTORY.md` | `booking_completion_caller.dart:51~59` — `for` loop `await` | test: 순차 호출로 4 tests Pass |

---

## PART 5 — Code Traceability

핵심 구현 파일별로 어떤 설계 단계를 거쳐 생성되었는지 기록한다.

---

### BookingCompletionCaller

```
Requirement
  → 예약 완료 시 Session 자동 생성 + Session Item 추가

Analysis
  → A-20: BookingRepository.completeBooking() 존재 확인
  → A-21: refType='booking'은 addItem() 레벨 파라미터 확인
  → A-22: Call Site = completeBooking() 호출 위치
  → A-23: 기존 5개 후보 전부 Rejected

Design
  → A-24: 단일 Caller 클래스 신설(lib/features/booking/data/)

Contract Verification
  → A-24.5: Data Ownership (businessType=외부주입, staffId/customerId=직접 매핑)
  → A-24.6: Product 조회 전략 (watchProducts().first + 메모리 매칭)
  → A-24.7: itemType='service' 확정 (Product.id 오기 정정)
  → A-24.8: PaymentSessionItems 컬럼 대조 — Conflict 0건

Design Repair
  → 1차 중단 → A-24.5
  → 2차 중단 → A-24.7

Implementation (3차 시도, 성공)
  → lib/features/booking/data/booking_completion_caller.dart (60행)
  → test/features/booking/booking_completion_caller_test.dart (4 tests)

Commit: a12190b (A-25 구현)
```

---

### SessionClosingWorkflow

```
Requirement
  → closeSession() 원자성 + Race Condition 방지

Analysis
  → A-13: Financial Workflow 단계별 실패 분석
  → A-18.1: 멱등성 분석 (순차 재시도 안전, 동시 호출 위험)
  → A-18.2: Conditional Update가 최소 변경 방법

Design
  → A-14: Workflow 추출 결정 (SessionRepository → Workflow 분리)
  → ADR-007: _db.transaction() + Conditional Update

Contract Verification
  → A-14 시리즈(Contract, Dependency, Pattern, Interface Validation)

Implementation
  → lib/features/session/workflow/session_closing_workflow.dart
  → Conditional Update: WHERE id=sessionId AND status='open', updatedRows==0 → throw

Verification
  → A-17: 운영 안정성 확인
  → A-18.4: Future.wait() 동시 호출 테스트

Documentation
  → docs/baseline/SESSION_CLOSING_BASELINE.md (A-19)

Commit: 6cc7bb9 (A-13~A-18.4 통합)
```

---

### PricingEngine / PromotionEngine / StaffEarningEngine

```
Requirement
  → 시간·피크 요금, 할인, 직원 수당 계산 필요

Design
  → ADR-001: Engine = 순수 계산, Drift 비의존
  → ADR-002: 할인 = 이벤트 기록
  → ADR-006: Staff Earning = closeSession() 시점

Implementation
  → lib/features/pricing/logic/pricing_engine.dart
  → lib/features/promotion/logic/promotion_engine.dart
  → lib/features/staff_earning/logic/staff_earning_engine.dart

Commit
  → 1fc9d06 (A-10: PricingEngine)
  → 3c11deb (A-11: PromotionEngine)
  → 128a3b7 (A-12: StaffEarningEngine)
```

---

## PART 6 — Commit Traceability

`git log --oneline` 실측 결과를 기반으로 작성. A-8 이후 주요 커밋만 기록.

| Commit | 관련 문서 | 관련 구현 | 관련 Milestone |
|---|---|---|---|
| `2f15616` | `docs/WORK_LOG.md` (A-25.12 항목) | 없음 | — |
| `5df5d77` | `docs/A25_12_DOCUMENTATION_IA_DESIGN.md` | 없음 | — |
| `b65dea1` | `docs/proposal/proposal_project_plan.md` (완전판) | 없음 | — |
| `e1a4033` | `docs/proposal/proposal_project_plan_ko.md` | 없음 | — |
| `a16f7e3` | `docs/proposal/proposal_project_plan.md` (초판) | 없음 | — |
| `9c88168` | `docs/proposal/salon_pos_hearing_sheet.md` (v2) | 없음 | — |
| `1fefca3` | `docs/proposal/salon_pos_hearing_sheet.md` (초판) | 없음 | — |
| `cbbb4bd` | `docs/WORK_LOG.md` (A-25.11 항목) | 없음 | — |
| `66bf5bb` | `docs/A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md` | 없음 | — |
| `bc1314e` | `docs/WORK_LOG.md` (A-25.10 항목) | 없음 | — |
| `3572338` | `docs/AI_DEVELOPMENT_NOTEBOOK.md` | 없음 | — |
| `22c0fad` | `docs/WORK_LOG.md` (A-25.8 항목) | 없음 | — |
| `c7c5121` | `docs/README.md`, `docs/ADR_INDEX.md`, `docs/AI_DEVELOPMENT_PROCESS.md`, `docs/DEVELOPMENT_CHECKLIST.md` | 없음 | — |
| `de50ddb` | `docs/WORK_LOG.md` (A-25.6 항목) | 없음 | — |
| `9d8c661` | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/DECISION_HISTORY.md`, `docs/PROJECT_ROADMAP.md` | 없음 | **Milestone 1** |
| `549f779` | `docs/WORK_LOG.md` (A-25.5 항목) | 없음 | — |
| `defa2d4` | `docs/ARCHITECTURE_SUMMARY.md`, `docs/PROJECT_ROADMAP.md`, `docs/MARK2_IDEAS.md` | 없음 | — |
| `facf64c` | `docs/WORK_LOG.md` (A-25 항목) | 없음 | — |
| `a12190b` | `docs/A25_*.md` | `lib/features/booking/data/booking_completion_caller.dart`, `test/features/booking/booking_completion_caller_test.dart` | Milestone 1 포함 |
| `d0bf64c` | `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` | 없음 | — |
| `35217ed` | `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` | 없음 | — |
| `0eec1c1` | `docs/A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md` | 없음 | — |
| `c77c372` | `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` | 없음 | — |
| `a4158e7` | `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md` | 없음 | — |
| `fbb5d6e` | `docs/A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md` | 없음 | — |
| `09e297c` | `docs/A22_BOOKING_SESSION_CALL_SITE_ANALYSIS.md` | 없음 | — |
| `5f847a0` | `docs/A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md` | 없음 | — |
| `1982bad` | `docs/A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md` | 없음 | — |
| `8658f89` | `docs/WORK_LOG.md` (초판 + A-19 항목) | 없음 | — |
| `15296f1` | `docs/baseline/SESSION_CLOSING_BASELINE.md` | 없음 | — |
| `6cc7bb9` | `docs/A13~A18 시리즈`, `docs/adr/ADR-007`, `docs/architecture/` | `lib/features/session/workflow/session_closing_workflow.dart` | Milestone 1 포함 |
| `128a3b7` | `docs/A12_*.md`, `docs/adr/ADR-006` | `lib/features/staff_earning/` | Milestone 1 포함 |
| `3c11deb` | `docs/A11_*.md`, `docs/adr/ADR-002`, `docs/adr/ADR-004` | `lib/features/promotion/` | Milestone 1 포함 |
| `1fc9d06` | `docs/A10_*.md`, `docs/adr/ADR-001`, `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md` | `lib/features/pricing/` | Milestone 1 포함 |
| `8f08104` | `docs/A10_IMPLEMENTATION_READINESS_REVIEW.md` | 없음 | — |
| `2895cdc` | `docs/A9_ID_UNIFICATION.md` | `lib/db/app_database.dart` (staffId INTEGER 통일) | — |
| `ea76edc` | `docs/ID_CONVENTION.md` | `lib/db/app_database.dart` (21개 테이블 ID 통일) | — |
| `aa06bff` | `docs/A8_SESSION_ENGINE.md` | `lib/features/session/` (4개 테이블 초기 구조) | — |
| 이전 커밋들 (`843acd6`~`7c5a317`) | `design/mockups/`, `design/spec/` | HTML mockup 파일들 | — (설계 시각화 목적) |

---

## PART 7 — Gap Analysis

현재 Traceability에서 부족한 부분:

| 항목 | 결과 |
|---|---|
| **추적 불가능한 Requirement** | `proposal/salon_pos_hearing_sheet.md`의 개별 요건 항목이 어떤 코드/오더로 구현되었는지 1:1 매핑 없음. Requirement → Analysis 연결은 있으나 세분화 매핑 부재. |
| **추적 불가능한 Design** | A-11~A-12 설계(Promotion/Staff Earning Architecture)의 일부 결정이 Archive Candidate 상태여서 직접 참조 경로가 README에 없음. ADR로 흡수된 결론만 추적 가능. |
| **추적 불가능한 Contract** | A-24.5 계약 중 `roomId=null`의 미래 변경 가능성에 대한 추적 경로 없음. 현재는 MARK2에도 기록되지 않음. |
| **추적 불가능한 Code** | `lib/features/session/data/session_repository.dart`의 `calcSuggestedTimeFee()`, `calcSuggestedDiscount()` 메서드가 어떤 오더/설계 결정에서 도입되었는지 문서 추적 불가능(A-10/A-11 커밋에 포함되었으나 별도 계약 문서 없음). |
| **추적 불가능한 Commit** | 초기 mockup 커밋들(`843acd6`~`0e93032`, 약 15건)은 설계 문서 없이 HTML 파일만 존재. Requirement와의 연결 불명확. |
| **개선 후보** | (1) Requirement ↔ 오더 매핑 테이블 작성(proposal 문서의 각 요건이 어떤 A-x 오더로 구현됐는지). (2) `session_repository.dart` 선택적 헬퍼 메서드에 대한 Design 문서 보완. (3) mockup 커밋들에 대응하는 UX 설계 결정 기록. |

---

## PART 8 — Future Development Architecture

향후 모든 Milestone에서 사용할 Development Architecture:

```
Requirement
    ↓  [출력물: proposal/ 또는 오더 요청 텍스트]
    ↓  [기준: 비즈니스 규칙, 기능 범위, 제약 조건]
Analysis
    ↓  [출력물: docs/A{n}_*.md (Domain Analysis + Integration Analysis)]
    ↓  [규칙: 실제 코드 grep/Read 기반. "선정 불가"도 유효한 결과]
Design
    ↓  [출력물: docs/A{n}_*.md (Caller 설계, 계약 초안)]
    ↓  [규칙: 기존 ADR/Baseline과 충돌하지 않는 범위. 기존 패턴 우선]
Contract Verification
    ↓  [출력물: docs/A{n}.x_*.md (계약 vs 코드/DB 1:1 대조)]
    ↓  [규칙: Conflict > 0 → 즉시 Design Repair 오더 발생]
    ↓
  [Conflict 발견 시] ──→ Design Repair
    ↓                        ↓  [출력물: 정정된 계약 문서]
    ↓                        ↓  [재검증 오더 발생]
    ↓  ←──────────────────────
Implementation
    ↓  [출력물: lib/features/{domain}/...]
    ↓  [규칙: 잠긴 계약만 코드화. 새로운 아이디어 → MARK2 즉시 기록]
    ↓  [규칙: 계약 충돌 발견 시 PART7 HARD STOP]
Verification
    ↓  [출력물: flutter analyze 0 issues + flutter test 전체 Pass]
    ↓  [규칙: 회귀 발생 시 Business Logic 변경 없이 구조만 수정]
Documentation
    ↓  [출력물: docs/WORK_LOG.md, docs/DECISION_HISTORY.md, 관련 설계 문서]
    ↓  [규칙: 코드 커밋 + WORK_LOG 별도 커밋. 두 커밋은 분리]
Decision
    ↓  [출력물: docs/DECISION_HISTORY.md 신규 행]
    ↓  [규칙: 이유(Why)를 반드시 기록. 결과(What)만 기록하지 않음]
Commit
    ↓  [출력물: git commit + push]
    ↓  [규칙: 코드 커밋 → WORK_LOG 커밋 → push (순서 고정)]
Milestone
    ↓  [출력물: docs/MILESTONE_{n}_{name}.md, docs/ARCHITECTURE_SUMMARY.md 갱신]
    ↓  [기준: 로드맵에서 정의한 범위 전체 구현 + Verification 통과]
MARK2
       [출력물: docs/MARK2_IDEAS.md 항목 추가]
       [규칙: 현 구현에서 보류한 모든 아이디어를 기록. 다음 Milestone 백로그 후보]
```

### 이 Architecture의 핵심 원칙

1. **단계 건너뜀 금지**: Contract Verification 없이 Implementation 착수 금지. 발견된 충돌은 Design Repair로 해소 후 재시도.
2. **추론 기반 구현 금지**: 계약에 없는 값/로직은 코드에서 추론하지 않고 설계 오더로 확정.
3. **MARK2 즉시 기록**: 구현 도중 발견한 아이디어는 현재 구현에 포함하지 않고 즉시 MARK2_IDEAS.md에만 기록.
4. **이유 기록 의무**: DECISION_HISTORY는 "무엇을 결정했는가"가 아니라 "왜 그렇게 결정했는가"를 기록.
5. **코드·문서 커밋 분리**: 코드 변경 커밋과 WORK_LOG 갱신 커밋은 항상 별도 커밋.

---

## PART 9 — Traceability Coverage

실제 확인 가능한 범위만 평가:

| Coverage | 상태 | 근거 |
|---|---|---|
| **Requirement → Analysis** | Partial | Proposal 문서 존재, A-20~A-23에서 코드 기반 분석 수행. 단, proposal 개별 항목과 분석 문서의 1:1 매핑 없음 |
| **Analysis → Design** | Complete | A-20~A-23 분석 결과가 A-24 Caller 설계 결정의 직접 근거. A-23 "선정 불가" → A-24 신규 패턴으로 이어진 흐름이 DECISION_HISTORY에 기록됨 |
| **Design → Contract Verification** | Complete | A-24.5~A-24.8: 설계 초안 → 계약 문서 → 코드/DB 대조 검증의 완전한 체인 존재 |
| **Contract Verification → Design Repair** | Complete | 2회의 충돌(businessType 부재, itemType 오기)이 발견되고 각각 A-24.5, A-24.7 오더로 즉시 이어짐. WORK_LOG에 중단 기록 존재 |
| **Design Repair → Implementation** | Complete | 2회 Repair 후 A-24.8 최종 검증 통과, A-25 3차 시도에서 성공. 인과 관계가 커밋 이력으로 추적 가능 |
| **Implementation → Verification** | Complete | 모든 구현 커밋 이후 flutter analyze + flutter test 결과가 WORK_LOG에 기록됨. 373건 Pass |
| **Verification → Documentation** | Complete | Verification 통과 후 설계 문서(A-25.5~A-25.12), Milestone 문서, WORK_LOG가 작성됨. 순서가 커밋 이력으로 확인됨 |
| **Documentation → Decision** | Complete | DECISION_HISTORY.md가 각 설계 문서(A-24~A-24.8)를 참조하며 결정 이유를 기록. 양방향 참조 확인 가능 |
| **Decision → Commit** | Partial | 주요 결정(ADR-001~007, A-24 시리즈)은 대응 커밋이 존재. 단, `session_repository.dart` 헬퍼 메서드 등 일부 코드는 결정 문서 없이 커밋에 포함됨 |
| **Commit → Milestone** | Complete | Milestone 1에 포함된 모든 커밋이 `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`의 "포함된 오더" 목록에 명시됨 |
| **Milestone → MARK2** | Complete | A-25.5에서 구현 도중 발견한 3개 아이디어가 즉시 MARK2_IDEAS.md에 기록됨. Milestone 1 완료 후 MARK2 항목이 다음 Milestone 백로그 후보로 명시됨 |

**전체 Coverage 평가**: **10/11 Complete, 1/11 Partial** (Requirement → Analysis 매핑 세분화 부족)

---

## PART 10 — 산출물 확인

이 문서: `docs/DEVELOPMENT_TRACEABILITY_ARCHITECTURE.md` ✓

README 링크 추가: PART 10 완료 시 `docs/README.md` Architecture 섹션에 추가.

---

## PART 11 — Baseline 확인

| 항목 | 결과 |
|---|---|
| **flutter analyze** | **Pass** — No issues found |
| **flutter test** | **Pass** — 373 tests passed |

코드 변경 없음. 이 문서는 순수 분석·설계 문서이다.

---

**"Development Traceability & AI Development Architecture Established"**
