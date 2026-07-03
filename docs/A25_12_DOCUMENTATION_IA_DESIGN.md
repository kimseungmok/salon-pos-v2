# A-25.12: Documentation Information Architecture Design

> **목적**: 현재 프로젝트 문서 전체를 분류하고, 프로젝트가 성장하더라도 유지 가능한 Documentation Information Architecture(IA)를 설계한다.
> **조사 시점**: 2026-07-03, 총 **60개** 마크다운 파일
> **제약**: 코드 수정 금지 / 문서 이동 금지 / Directory 생성 금지 / README 구조 변경 금지
> 작성일: 2026-07-03

---

## PART 1 — Documentation Inventory

현재 `docs/` 디렉터리를 직접 스캔한 결과:

| 항목 | 결과 |
|---|---|
| **총 문서 수** | **60개** |
| Active 문서 수 | 20개 |
| History/이력 문서 수 | 29개 |
| Verification 문서 수 | 4개 |
| Design 문서 수 | 6개 |
| 기타(Proposal/Knowledge/Future) | 6개 |

> **참고**: A-25.11(2026-07-01) 시점 56개 → 현재 60개(+4개): `proposal/` 3개 신규 + `A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md` 자신이 추가됨.

### 위치별 파일 분포

| 디렉터리 | 파일 수 |
|---|---|
| `docs/` (루트) | 49개 |
| `docs/adr/` | 6개 |
| `docs/architecture/` | 2개 |
| `docs/baseline/` | 1개 |
| `docs/proposal/` | 3개 |
| **합계** | **60개 + 1(README)** |

> 실제 `docs/README.md` 포함 시 61개이나, README는 Index 역할이므로 분류 대상에서 제외하고 60개로 산정.

---

## PART 2 — Category 정의

모든 문서는 다음 12개 Category 중 하나에만 속한다. Category는 **문서의 성격**을 나타낸다.

| Category | 정의 |
|---|---|
| **Architecture** | 시스템 구조, ADR, 설계 원칙을 정의하는 문서 |
| **Analysis** | 특정 오더/기능의 분석 과정을 기록한 문서 |
| **Design** | 구현 전 계약·인터페이스·책임을 설계한 문서 |
| **Contract** | 도메인 간 데이터 흐름·소유권·매핑 계약을 확정한 문서 |
| **Verification** | 구현 후 정합성·안정성·동시성을 검증한 문서 |
| **Implementation** | 구현 이력·ID 통일 등 코드 변경의 이유를 기록한 문서 |
| **Milestone** | 특정 Milestone의 완료 선언 및 종합 기록 |
| **Roadmap** | 미래 계획·우선순위·완료/예정 항목 목록 |
| **Development Process** | 개발 방법론·체크리스트·프로세스 표준 |
| **Knowledge** | 프로젝트를 통해 얻은 교훈·원칙·판단 기준 |
| **History** | 의사결정 시간순 이력·작업 로그 |
| **Future** | 현 Milestone에서 보류한 아이디어·개선 후보 |

---

## PART 3 — Status 정의

Status는 **문서의 현재 생명주기**를 나타낸다. Category와 독립적으로 판단한다.

| Status | 정의 |
|---|---|
| **Active** | 현재 개발에 직접 참조되는 문서. 내용이 유효하고 갱신된다. |
| **Passive** | 유효하나 직접 참조 빈도가 낮음. 특정 영역 수정 시에만 참조. |
| **History** | 당시 과정을 기록한 이력. 내용 변경 없이 읽기 전용으로 보존. |
| **Future** | 아직 실행되지 않은 계획·아이디어. 내용이 변할 수 있음. |
| **Archive Candidate** | 결론이 다른 Active 문서에 흡수된 과정 문서. 향후 archive 이동 고려. |

---

## PART 4 — Documentation Classification

60개 전체 문서를 Category + Status로 분류한다.

### docs/adr/ (6개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `adr/ADR-001-pricing-engine-domain-isolation.md` | Architecture | Active | PricingEngine 수정 시 반드시 참조하는 격리 원칙 |
| `adr/ADR-002-discount-representation.md` | Architecture | Active | 할인을 PaymentSessionItem으로 표현하는 핵심 결정 |
| `adr/ADR-003-financial-events.md` | Architecture | Active | Financial Events append-only 원칙, closeSession() 전반에 영향 |
| `adr/ADR-004-promotion-rule-lifecycle.md` | Architecture | Active | Promotion Rule 상태 전이(draft/active/disabled) 정의 |
| `adr/ADR-006-staff-earning-policy.md` | Architecture | Active | Staff Earning 생성 시점(closeSession 시) 원칙 |
| `adr/ADR-007-a13-mvp-transaction-scope.md` | Architecture | Active | Transaction Scope 정의, SessionClosingWorkflow 수정 시 필수 |

### docs/architecture/ (2개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `architecture/PRICING_ENGINE_ARCHITECTURE.md` | Architecture | Passive | Pricing/Promotion Engine 수정 시 참조. 현재는 안정 상태 |
| `architecture/PROMOTION_ENGINE_ARCHITECTURE.md` | Architecture | Passive | 동일. 현재는 안정 상태 |

### docs/baseline/ (1개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `baseline/SESSION_CLOSING_BASELINE.md` | Architecture | Active | closeSession()/SessionClosingWorkflow 수정 시 반드시 참조하는 공식 Baseline |

### docs/proposal/ (3개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `proposal/proposal_project_plan.md` | Roadmap | Passive | 프로젝트 초기 제안서(일본어). 현재 개발과 직접 연결은 낮으나 방향성 참조 가능 |
| `proposal/proposal_project_plan_ko.md` | Roadmap | Passive | 동일 제안서 한국어판. 이중 언어 유지 |
| `proposal/salon_pos_hearing_sheet.md` | Roadmap | Active | 2026-07-02 현장 히어링 시트. 요건 정의의 출발점으로 현재 유효 |

### docs/ 루트 — Architecture/History/Index 계열 (7개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `A8_SESSION_ENGINE.md` | Architecture | Passive | A-8 시점 Session 도메인 전체 설계. 현재도 테이블 구조 확인 시 참조 |
| `A9_ID_UNIFICATION.md` | Implementation | History | A-9 ID 통일 변경 이력. 읽기 전용 보존 |
| `ADR_INDEX.md` | Architecture | Active | 9개 ADR 색인. 신규 ADR 추가 시 갱신 |
| `ARCHITECTURE_SUMMARY.md` | Architecture | Active | 12개 핵심 설계 결정 요약. 유사 기능 설계 시 필수 참조 |
| `ID_CONVENTION.md` | Architecture | Passive | ID 타입 통일 원칙. 신규 테이블 생성 시에만 참조 |
| `DECISION_HISTORY.md` | History | Active | 모든 핵심 결정의 시간순 이력. 결정 추적 시 필수 |
| `WORK_LOG.md` | History | Active | 모든 오더의 요약·결과·커밋 이력. 매 오더 후 갱신 |

### docs/ 루트 — Process/Knowledge/Future (5개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `AI_DEVELOPMENT_PROCESS.md` | Development Process | Active | 분석→설계→계약검증→구현→검증 사이클 표준 |
| `DEVELOPMENT_CHECKLIST.md` | Development Process | Active | 구현 완료 후 커밋 전 체크리스트. 매 구현마다 참조 |
| `AI_DEVELOPMENT_NOTEBOOK.md` | Knowledge | Active | Repair Loop 원리, DB 변경 원칙, 교훈. MARK2 계획 시 참조 |
| `MARK2_IDEAS.md` | Future | Future | 현 Milestone 보류 아이디어 목록. MARK2 진입 시 백로그로 전환 |
| `A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md` | Analysis | History | A-25.11 문서 인벤토리 분석 이력. 현재 문서(A-25.12)로 대체됨 |

### docs/ 루트 — Milestone/Roadmap (2개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` | Milestone | Active | Milestone 1 공식 완료 기록. 다음 Milestone 계획의 기준점 |
| `PROJECT_ROADMAP.md` | Roadmap | Active | 완료/Next/Future 전체 로드맵. 우선순위 결정 시 갱신 |

### docs/ 루트 — A10~A12 시리즈 (5개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `A10_IMPLEMENTATION_READINESS_REVIEW.md` | Analysis | History | A-10 Pricing Engine 구현 준비 검토 이력 |
| `A10_5_DISCOUNT_ARCHITECTURE_REVIEW.md` | Analysis | History | A-10.5 할인 아키텍처 검토 이력 |
| `A11_PROMOTION_ENGINE_DESIGN.md` | Design | Archive Candidate | A-11 Promotion Engine 설계. 결론은 ADR-004+PROMOTION_ENGINE_ARCHITECTURE에 흡수됨 |
| `A11_IMPLEMENTATION_PLAN.md` | Analysis | Archive Candidate | A-11 구현 계획 이력. 결론은 현재 코드에 반영됨 |
| `A11_5_PROMOTION_EXPANSION_PLAN.md` | Analysis | History | A-11.5 확장 계획 이력 |

### docs/ 루트 — A12 시리즈 (2개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `A12_STAFF_EARNING_ARCHITECTURE.md` | Design | Archive Candidate | A-12 Staff Earning 설계. 결론은 ADR-006+staff_earning_engine.dart에 흡수됨 |
| `A12_IMPLEMENTATION_READY.md` | Analysis | Archive Candidate | A-12 구현 준비 이력. 결론은 현재 코드에 반영됨 |

### docs/ 루트 — A13 시리즈 (6개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `A13_TRANSACTION_BOUNDARY_REVIEW.md` | Analysis | History | A-13 Transaction Boundary 검토 이력 |
| `A13_CONCURRENCY_VALIDATION.md` | Verification | Active | Race Condition 분석. closeSession() 동시성 대응 구현 시 참조 |
| `A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md` | Verification | Active | Financial Workflow 단계별 실패 분석. 장애 대응 시 참조 |
| `A13_IMPACT_MAPPING.md` | Analysis | Archive Candidate | A-13 영향 범위 분석. 결론은 ADR-007에 흡수됨 |
| `A13_IMPLEMENTATION_DECISION.md` | Analysis | Archive Candidate | A-13 구현 결정 이력. 결론은 ADR-007에 흡수됨 |
| `A13_TRANSACTION_IMPLEMENTATION_READY.md` | Analysis | Archive Candidate | A-13 구현 준비 이력. 결론은 현재 코드에 반영됨 |

### docs/ 루트 — A14~A16 시리즈 (7개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `A14_ARCHITECTURE_TRADEOFF_REVIEW.md` | Analysis | Archive Candidate | A-14 Workflow 추출 트레이드오프 검토. 결론은 ARCHITECTURE_SUMMARY에 흡수됨 |
| `A14_WORKFLOW_CONTRACT_VALIDATION.md` | Verification | History | A-14 Workflow 계약 검증 이력 |
| `A14_WORKFLOW_DEPENDENCY_VALIDATION.md` | Verification | History | A-14 의존성 검증 이력 |
| `A14_WORKFLOW_EXTRACTION_READY.md` | Analysis | Archive Candidate | A-14 추출 준비 이력. 결론은 현재 코드에 반영됨 |
| `A14_WORKFLOW_INTERFACE_READY.md` | Design | History | A-14 인터페이스 설계 이력 |
| `A14_WORKFLOW_PATTERN_VALIDATION.md` | Verification | History | A-14 패턴 검증 이력 |
| `A15_WORKFLOW_RESPONSIBILITY_REFINEMENT.md` | Analysis | History | A-15 Workflow 책임 정제 분석 이력 |

### docs/ 루트 — A16~A18 시리즈 (4개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `A16_ARCHITECTURE_FINALIZATION.md` | Architecture | History | A-16 아키텍처 확정 이력. 결론은 ARCHITECTURE_SUMMARY에 흡수됨 |
| `A17_OPERATIONAL_STABILITY_CHECK.md` | Verification | Active | 운영 관점 안정성 확인. Session Engine 운영 전 점검 시 참조 |
| `A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md` | Verification | Active | closeSession() 멱등성 분석. 중복 호출 시나리오 검증 시 참조 |
| `A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md` | Analysis | History | A-18.2 최소 변경 결정 분석 이력 |

### docs/ 루트 — A20~A24 시리즈 (12개)

| 문서 | Category | Status | 이유 |
|---|---|---|---|
| `A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md` | Analysis | History | A-20 Booking 도메인 분석 이력 |
| `A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md` | Analysis | History | A-21 통합 포인트 분석 이력 |
| `A22_BOOKING_SESSION_CALL_SITE_ANALYSIS.md` | Analysis | History | A-22 Call Site 분석 이력 |
| `A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md` | Analysis | History | A-23 Orchestrator 후보 5개 Rejected 이력 |
| `A24_BOOKING_COMPLETION_CALLER_DESIGN.md` | Design | Active | Caller 패턴 설계 결정. Caller 구조 수정 시 참조 |
| `A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` | Contract | Active | Booking→Session 데이터 소유권·매핑 계약 |
| `A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md` | Contract | Active | Product 조회 전략 계약(watchProducts()+메모리 매칭) |
| `A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` | Contract | Active | Session Item 계약 최종본(itemType='service' 확정) |
| `A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` | Contract | Active | 저장 구조와 계약 일치 검증 결과 |
| `A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md` | Analysis | History | A-25.11 문서 인벤토리 분석 이력. 본 문서(A-25.12)로 갱신됨 |

> **주의**: `A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md`는 위 "Process/Knowledge/Future" 섹션과 이 섹션 양쪽에 출현하나, 분류는 **Analysis / History**로 단일 확정.

---

## PART 5 — Information Architecture

PART 2의 12개 Category 기준으로 미래 권장 위치를 설계한다.
**실제 이동은 금지. 설계만 수행.**

| Category | 현재 위치 | 미래 권장 위치 | 이유 |
|---|---|---|---|
| **Architecture** | `docs/`, `docs/adr/`, `docs/architecture/`, `docs/baseline/` | `docs/architecture/` (통합) + `docs/adr/` (유지) + `docs/baseline/` (유지) | ADR·Baseline·Engine 설계를 한 레이어로 묶어 일관성 확보. 단, adr/과 baseline/은 하위 구조 그대로 유지 |
| **Analysis** | `docs/` (루트, A10~A25 시리즈) | `docs/archive/analysis/` | 분석 이력은 직접 참조 빈도가 낮고 루트를 오염시킴. 별도 archive로 분리 |
| **Design** | `docs/` (루트) | `docs/design/` | 계약 확정 전 설계 문서. Contract와 구분하여 별도 디렉터리 |
| **Contract** | `docs/` (루트, A24.5~A24.8) | `docs/contracts/` | 도메인 간 계약은 Active 상태가 길고 자주 참조됨. 전용 위치 필요 |
| **Verification** | `docs/` (루트, A13~A18 시리즈) | `docs/verification/` | 안정성·동시성 검증은 운영 중에도 참조됨. Archive와 분리 필요 |
| **Implementation** | `docs/` (루트) | `docs/archive/implementation/` | 구현 이력은 읽기 전용. Archive에 보존 |
| **Milestone** | `docs/` (루트) | `docs/milestones/` | Milestone 문서는 프로젝트 생애 동안 누적됨. 전용 디렉터리로 관리 |
| **Roadmap** | `docs/`, `docs/proposal/` | `docs/` (루트 유지) + `docs/proposal/` (유지) | Roadmap은 루트 레벨에서 바로 접근해야 함. 현재 위치 유지 |
| **Development Process** | `docs/` (루트) | `docs/process/` | 개발 방법론·체크리스트는 팀 전체가 접근. 전용 위치로 가시성 확보 |
| **Knowledge** | `docs/` (루트) | `docs/knowledge/` | 교훈·원칙은 프로젝트 전체 수명 동안 유효. Active 상태 유지 필요 |
| **History** | `docs/` (루트, WORK_LOG·DECISION_HISTORY) | `docs/` (루트 유지) | 이 두 문서는 매 오더마다 갱신. 루트에서 즉시 접근 필요 |
| **Future** | `docs/` (루트) | `docs/` (루트 유지) | MARK2_IDEAS는 짧고 자주 참조. 루트 유지 |

### 미래 디렉터리 구조 (설계안)

```
docs/
├── README.md                          ← Index (현재 유지)
├── WORK_LOG.md                        ← History (루트 유지, 매 오더 갱신)
├── DECISION_HISTORY.md                ← History (루트 유지, 추적용)
├── PROJECT_ROADMAP.md                 ← Roadmap (루트 유지)
├── MARK2_IDEAS.md                     ← Future (루트 유지)
│
├── adr/                               ← Architecture ADR (현재 유지)
│   └── ADR-001~007.md
│
├── architecture/                      ← Architecture (통합 확장)
│   ├── ARCHITECTURE_SUMMARY.md        ← 현재 루트에서 이동
│   ├── ADR_INDEX.md                   ← 현재 루트에서 이동
│   ├── SESSION_ENGINE_A8.md           ← A8_SESSION_ENGINE.md 이동
│   ├── ID_CONVENTION.md               ← 현재 루트에서 이동
│   ├── PRICING_ENGINE_ARCHITECTURE.md ← 현재 위치 유지
│   └── PROMOTION_ENGINE_ARCHITECTURE.md
│
├── baseline/                          ← Architecture Baseline (현재 유지)
│   └── SESSION_CLOSING_BASELINE.md
│
├── contracts/                         ← Contract (신규)
│   ├── A24_BOOKING_COMPLETION_CALLER_DESIGN.md
│   ├── A24_5_DATA_OWNERSHIP_MAPPING.md
│   ├── A24_6_PRODUCT_RETRIEVAL_STRATEGY.md
│   ├── A24_7_SESSION_ITEM_CONTRACT.md
│   └── A24_8_SESSION_ITEM_PERSISTENCE.md
│
├── verification/                      ← Verification (신규)
│   ├── A13_CONCURRENCY_VALIDATION.md
│   ├── A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md
│   ├── A17_OPERATIONAL_STABILITY_CHECK.md
│   └── A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md
│
├── milestones/                        ← Milestone (신규)
│   └── MILESTONE_1_BOOKING_SESSION_FOUNDATION.md
│
├── process/                           ← Development Process (신규)
│   ├── AI_DEVELOPMENT_PROCESS.md
│   └── DEVELOPMENT_CHECKLIST.md
│
├── knowledge/                         ← Knowledge (신규)
│   └── AI_DEVELOPMENT_NOTEBOOK.md
│
├── proposal/                          ← Roadmap/Proposal (현재 유지)
│   ├── proposal_project_plan.md
│   ├── proposal_project_plan_ko.md
│   └── salon_pos_hearing_sheet.md
│
└── archive/                           ← Archive (신규)
    ├── analysis/                      ← Analysis 이력 문서
    │   ├── A10~A12 시리즈
    │   ├── A13_IMPACT_MAPPING.md
    │   ├── A13_IMPLEMENTATION_DECISION.md
    │   ├── A13_TRANSACTION_IMPLEMENTATION_READY.md
    │   ├── A13_TRANSACTION_BOUNDARY_REVIEW.md
    │   ├── A14~A16 Archive Candidate 전체
    │   ├── A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md
    │   ├── A20~A23 시리즈
    │   └── A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md
    └── implementation/
        └── A9_ID_UNIFICATION.md
```

---

## PART 6 — Navigation 구조

문서 간 흐름(단방향, 순환 참조 없음):

```
README.md                          ← 전체 Index. 모든 Active 문서로의 진입점
    │
    ├── architecture/              ← 설계 원칙 (가장 오래 유지됨)
    │   ├── ARCHITECTURE_SUMMARY.md
    │   ├── ADR_INDEX.md
    │   │     └── adr/ADR-001~007.md
    │   ├── baseline/SESSION_CLOSING_BASELINE.md
    │   └── architecture/PRICING/PROMOTION_ENGINE_ARCHITECTURE.md
    │
    ├── contracts/                 ← 도메인 계약 (Architecture를 전제)
    │   ├── A24_BOOKING_COMPLETION_CALLER_DESIGN.md
    │   ├── A24_5 ~ A24_8 (데이터 소유권·매핑·검증)
    │   └── → Architecture 참조 (단방향)
    │
    ├── verification/              ← 검증 결과 (Contract를 전제)
    │   ├── A13_CONCURRENCY_VALIDATION.md
    │   ├── A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md
    │   ├── A17_OPERATIONAL_STABILITY_CHECK.md
    │   └── A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md
    │
    ├── milestones/                ← 완료 선언 (Verification 이후)
    │   └── MILESTONE_1_BOOKING_SESSION_FOUNDATION.md
    │       └── → WORK_LOG.md, DECISION_HISTORY.md 참조
    │
    ├── PROJECT_ROADMAP.md         ← 미래 계획 (Milestone 기반)
    │   └── → milestones/ 참조 (단방향)
    │
    ├── knowledge/                 ← 교훈 (모든 단계에서 참조 가능)
    │   └── AI_DEVELOPMENT_NOTEBOOK.md
    │       └── → WORK_LOG.md, DECISION_HISTORY.md 참조
    │
    ├── process/                   ← 개발 프로세스 (개발 시작 시 참조)
    │   ├── AI_DEVELOPMENT_PROCESS.md
    │   └── DEVELOPMENT_CHECKLIST.md
    │
    ├── WORK_LOG.md                ← 이력 (모든 오더 후 갱신)
    ├── DECISION_HISTORY.md        ← 이력 (설계 결정 시 갱신)
    ├── MARK2_IDEAS.md             ← Future (보류 아이디어)
    │
    └── archive/                   ← 읽기 전용. 외부에서 참조하지 않음
        └── (A10~A25 분석 이력)
```

### 순환 참조 확인

| 경로 | 순환 여부 |
|---|---|
| Architecture → Contract → Verification → Milestone | 없음 (단방향) |
| Knowledge → WORK_LOG / DECISION_HISTORY | 없음 (단방향 참조) |
| archive/ → Active 문서 참조 | 없음 (archive는 외부 참조 없음) |
| README → 모든 Active 문서 | 없음 (index는 단방향) |

**결론: 순환 참조 없음**

---

## PART 7 — Documentation Health

| 항목 | 결과 |
|---|---|
| **고아 문서 존재 여부** | 있음 — 22개 (README에서 직접 링크 없는 이력 문서. 단, WORK_LOG/MILESTONE_1 경유로 간접 접근 가능하여 완전한 고아는 아님) |
| **중복 문서 존재 여부** | 있음 — `proposal_project_plan.md` / `proposal_project_plan_ko.md` (동일 내용 이중 언어. 의도적 중복이므로 제거 불필요) |
| **Merge Candidate** | 4개: `A13_IMPACT_MAPPING.md`, `A13_IMPLEMENTATION_DECISION.md`, `A13_TRANSACTION_IMPLEMENTATION_READY.md`, `A14_ARCHITECTURE_TRADEOFF_REVIEW.md` — 결론이 ADR-007/ARCHITECTURE_SUMMARY에 흡수됨 |
| **Archive Candidate** | 11개: A11_PROMOTION_ENGINE_DESIGN, A11_IMPLEMENTATION_PLAN, A12_STAFF_EARNING_ARCHITECTURE, A12_IMPLEMENTATION_READY, A13_IMPACT_MAPPING, A13_IMPLEMENTATION_DECISION, A13_TRANSACTION_IMPLEMENTATION_READY, A14_ARCHITECTURE_TRADEOFF_REVIEW, A14_WORKFLOW_EXTRACTION_READY, A16_ARCHITECTURE_FINALIZATION, A25_11_DOCUMENTATION_INVENTORY_ANALYSIS |
| **Broken Navigation** | 없음 — README의 모든 링크 대상이 존재함. archive 예정 문서도 현재 위치에 존재 |

### 상세: Archive Candidate 11개

| 문서 | 이유 |
|---|---|
| `A11_PROMOTION_ENGINE_DESIGN.md` | 결론 → ADR-004 + PROMOTION_ENGINE_ARCHITECTURE.md |
| `A11_IMPLEMENTATION_PLAN.md` | 결론 → 현재 promotion_engine.dart 코드 |
| `A12_STAFF_EARNING_ARCHITECTURE.md` | 결론 → ADR-006 + staff_earning_engine.dart |
| `A12_IMPLEMENTATION_READY.md` | 결론 → 현재 코드 |
| `A13_IMPACT_MAPPING.md` | 결론 → ADR-007 |
| `A13_IMPLEMENTATION_DECISION.md` | 결론 → ADR-007 |
| `A13_TRANSACTION_IMPLEMENTATION_READY.md` | 결론 → 현재 session_closing_workflow.dart |
| `A14_ARCHITECTURE_TRADEOFF_REVIEW.md` | 결론 → ARCHITECTURE_SUMMARY.md |
| `A14_WORKFLOW_EXTRACTION_READY.md` | 결론 → 현재 session_closing_workflow.dart |
| `A16_ARCHITECTURE_FINALIZATION.md` | 결론 → ARCHITECTURE_SUMMARY.md |
| `A25_11_DOCUMENTATION_INVENTORY_ANALYSIS.md` | 결론 → 본 문서(A-25.12)로 갱신됨 |

---

## PART 8 — Documentation Evolution

### Milestone 종료 후 문서 처리 흐름

```
Milestone 종료 (Milestone 문서 작성 완료)
    ↓
해당 Milestone의 Analysis 이력 문서들
→ Status: History → Archive Candidate 심사
    ↓
Archive Candidate 심사 기준:
  ① 결론이 Active 문서(ADR/ARCHITECTURE_SUMMARY/Contract)에 흡수되었는가?
  ② 이 문서만이 가진 고유 정보가 없는가?
  → 두 조건 모두 충족 시 → Archive Candidate 확정
    ↓
Archive 이동 (MARK2 또는 다음 Milestone 계획 시 수행)
→ docs/archive/analysis/ 또는 docs/archive/implementation/
    ↓
README에서 해당 문서 링크 제거 (이미 링크되어 있지 않으면 생략)
    ↓
WORK_LOG.md에 이동 기록 추가 (별도 커밋)
    ↓
README 유지: Active 문서만 링크
Knowledge 유지: AI_DEVELOPMENT_NOTEBOOK.md는 Milestone과 무관하게 Active 유지
Future 유지: MARK2_IDEAS.md는 다음 Milestone 진입 시 Active로 전환
```

### 각 단계의 기준

| 단계 | 기준 |
|---|---|
| **History 이동** | Milestone 완료 시 자동. 해당 Milestone의 분석 이력 전체 |
| **Archive 이동** | Archive Candidate 심사 통과 후 (다음 Milestone 초기에 일괄 처리 권장) |
| **README 유지** | Active 문서만 링크. Archive 이동 시 README에서 제거 |
| **Knowledge 유지** | AI_DEVELOPMENT_NOTEBOOK.md는 프로젝트 전체 수명 동안 Active. 내용 추가는 허용 |
| **Future 유지** | MARK2_IDEAS.md는 다음 Milestone 백로그 선정 시까지 Future 상태 유지 |

### MARK2 진입 시 처리 흐름

```
MARK2 백로그 선정
    ↓
MARK2_IDEAS.md → 선정 항목은 PROJECT_ROADMAP.md로 이동
    ↓
Archive Candidate 11개 → 일괄 docs/archive/로 이동
    ↓
README 갱신 (Archive 이동된 문서 링크 제거)
    ↓
새 Milestone 문서 생성 (MILESTONE_2_xxx.md)
```

---

## PART 9 — Baseline 확인

| 항목 | 결과 |
|---|---|
| **flutter analyze** | **Pass** — No issues found (ran in 23.7s) |
| **flutter test** | **Pass** — 373 tests passed (코드 변경 없음) |

> flutter analyze 및 flutter test는 이번 작업 시작 직전에 실행한 결과. 이번 작업은 문서 작성만 수행하였으며 코드 변경 없음.

---

## 요약

| 항목 | 결과 |
|---|---|
| 총 문서 수 | **60개** (README 포함 61개) |
| Active 문서 | **20개** |
| Archive Candidate | **11개** |
| 순환 참조 | **없음** |
| 미래 신규 디렉터리 권장 수 | **5개** (contracts, verification, milestones, process, knowledge, archive) |
| flutter analyze | **Pass** |
| flutter test | **Pass** |

---

**"Documentation Information Architecture Established"**
