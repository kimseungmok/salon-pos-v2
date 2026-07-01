# A-25.11: Documentation Inventory & Asset Analysis

> **목적**: `docs/` 하위 모든 문서를 조사해 문서 자산(Documentation Asset)을 정리한다. 문서 수정/삭제/병합 없음, 조사·분석만 수행.
> **조사 시점**: 2026-07-01, 총 **56개** 마크다운 파일
> 작성일: 2026-07-01

---

## PART 1 — Documentation Inventory

> 범례: **Active** = README 또는 현행 거버넌스 문서에서 직접 참조 / **Passive** = 이력·맥락 문서로 현재 직접 참조는 낮음 / **Archive Candidate** = 보존 가치 있으나 현재 개발 흐름에서 참조 가능성 낮음

### A. 거버넌스/색인 문서 (6개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `README.md` | Other(Index) | A-25.8 | **Active** |
| `WORK_LOG.md` | Log | A-19 정리 시점 | **Active** |
| `ADR_INDEX.md` | Decision | A-25.8 | **Active** |
| `ARCHITECTURE_SUMMARY.md` | Architecture | A-25.5 | **Active** |
| `DECISION_HISTORY.md` | Decision | A-25.6 | **Active** |
| `PROJECT_ROADMAP.md` | Roadmap | A-25.5 | **Active** |

### B. 프로세스/체크리스트 문서 (3개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `AI_DEVELOPMENT_PROCESS.md` | Process | A-25.8 | **Active** |
| `DEVELOPMENT_CHECKLIST.md` | Checklist | A-25.8 | **Active** |
| `AI_DEVELOPMENT_NOTEBOOK.md` | Platform | A-25.10 | **Active** |

### C. Milestone/Future 문서 (2개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` | Milestone | A-25.6 | **Active** |
| `MARK2_IDEAS.md` | Future | A-25 구현 시점 | **Active** |

### D. 기반 아키텍처 문서 (11개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `A8_SESSION_ENGINE.md` | Architecture | A-8 | **Active**(Session Engine 구조 기준 문서) |
| `A9_ID_UNIFICATION.md` | Architecture | A-9 | **Passive**(마이그레이션 이력, 직접 참조 낮음) |
| `ID_CONVENTION.md` | Architecture | A-9 | **Active**(신규 테이블 작성 시 참조 기준) |
| `adr/ADR-001-pricing-engine-domain-isolation.md` | Decision | A-10 | **Active** |
| `adr/ADR-002-discount-representation.md` | Decision | A-11 | **Active** |
| `adr/ADR-003-financial-events.md` | Decision | A-11 | **Active** |
| `adr/ADR-004-promotion-rule-lifecycle.md` | Decision | A-11 | **Active** |
| `adr/ADR-006-staff-earning-policy.md` | Decision | A-12 | **Active** |
| `adr/ADR-007-a13-mvp-transaction-scope.md` | Decision | A-13 | **Active** |
| `architecture/PRICING_ENGINE_ARCHITECTURE.md` | Architecture | A-10 | **Active**(Pricing/Promotion 수정 시 참조) |
| `architecture/PROMOTION_ENGINE_ARCHITECTURE.md` | Architecture | A-11 | **Active** |
| `baseline/SESSION_CLOSING_BASELINE.md` | Verification | A-19 | **Active**(closeSession 수정 시 필수 참조) |

### E. Booking→Session 계약 문서 (5개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `A24_BOOKING_COMPLETION_CALLER_DESIGN.md` | Architecture | A-24 | **Active**(Caller 구조의 설계 근거) |
| `A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` | Contract | A-24.5 | **Active**(데이터 소유권 계약) |
| `A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md` | Contract | A-24.6 | **Active**(Product 조회 전략) |
| `A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` | Contract | A-24.7 | **Active**(itemType='service' 최종 계약) |
| `A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` | Verification | A-24.8 | **Active**(저장 구조 일치 검증 결과) |

### F. Session Engine / Pricing / Promotion / StaffEarning 분석 문서 (12개) — 개발 이력 계열

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `A10_IMPLEMENTATION_READINESS_REVIEW.md` | Analysis | A-10 | **Passive** |
| `A10_5_DISCOUNT_ARCHITECTURE_REVIEW.md` | Analysis | A-10.5 | **Passive** |
| `A11_IMPLEMENTATION_PLAN.md` | Analysis | A-11 | **Passive** |
| `A11_5_PROMOTION_EXPANSION_PLAN.md` | Analysis | A-11.5 | **Passive** |
| `A11_PROMOTION_ENGINE_DESIGN.md` | Analysis | A-11 | **Passive** |
| `A12_IMPLEMENTATION_READY.md` | Analysis | A-12 | **Passive** |
| `A12_STAFF_EARNING_ARCHITECTURE.md` | Architecture | A-12 | **Passive** |
| `A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md` | Verification | A-18.1 | **Active**(README에서 참조, closeSession 멱등성) |
| `A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md` | Analysis | A-18.2 | **Passive**(A-18.4 구현에서 사용된 전략의 이력) |
| `A15_WORKFLOW_RESPONSIBILITY_REFINEMENT.md` | Analysis | A-15 | **Passive** |
| `A16_ARCHITECTURE_FINALIZATION.md` | Verification | A-16 | **Passive** |
| `A17_OPERATIONAL_STABILITY_CHECK.md` | Verification | A-17 | **Active**(README에서 참조, 운영 안정성 확인) |

### G. Transaction Boundary 분석 계열 (7개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `A13_TRANSACTION_BOUNDARY_REVIEW.md` | Analysis | A-12.5 | **Passive** |
| `A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md` | Analysis | A-12.6 | **Active**(README에서 참조) |
| `A13_CONCURRENCY_VALIDATION.md` | Verification | A-12.7 | **Active**(README에서 참조, TOCTOU 분석) |
| `A13_IMPACT_MAPPING.md` | Analysis | A-12.9 | **Passive** |
| `A13_IMPLEMENTATION_DECISION.md` | Decision | A-12.10 | **Passive**(ADR-007에 결정 내용 압축됨) |
| `A13_TRANSACTION_IMPLEMENTATION_READY.md` | Verification | A-12.11 | **Archive Candidate**(ADR-007+A-13 구현으로 목적 완료) |

### H. Workflow Extraction 분석 계열 (6개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `A14_WORKFLOW_EXTRACTION_READY.md` | Analysis | A-13.5 | **Passive** |
| `A14_WORKFLOW_INTERFACE_READY.md` | Analysis | A-13.6 | **Passive** |
| `A14_WORKFLOW_CONTRACT_VALIDATION.md` | Verification | A-13.7 | **Passive** |
| `A14_WORKFLOW_DEPENDENCY_VALIDATION.md` | Verification | A-14 Phase 2 | **Passive** |
| `A14_WORKFLOW_PATTERN_VALIDATION.md` | Verification | A-14 Phase 3 | **Passive** |
| `A14_ARCHITECTURE_TRADEOFF_REVIEW.md` | Analysis | A-14 Phase 4 | **Passive**(결론이 ARCHITECTURE_SUMMARY에 반영됨) |

### I. Booking→Session 분석 계열 (4개)

| 문서 | 종류 | 생성 시점 | 현재 사용 여부 |
|---|---|---|---|
| `A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md` | Analysis | A-20 | **Passive**(결론이 MILESTONE_1에 요약됨) |
| `A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md` | Analysis | A-21 | **Passive** |
| `A22_BOOKING_SESSION_CALL_SITE_ANALYSIS.md` | Analysis | A-22 | **Passive** |
| `A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md` | Analysis | A-23 | **Passive**(선정 불가 결론이 A-24에 근거로 사용됨) |

---

## PART 2 — 역할 분석(주요 문서 중심)

| 문서 | 목적 | 참조하는 문서 | 참조되는 문서 |
|---|---|---|---|
| `README.md` | 전체 문서 색인 | 56개 중 약 20개 직접 링크 | 없음(최상위) |
| `WORK_LOG.md` | 오더 이력 기록 | 없음(독립 기록) | README |
| `ARCHITECTURE_SUMMARY.md` | 12개 설계 결정 통합 요약 | A8, A14, A24 시리즈, adr/x6, A13_CONCURRENCY, A17, MARK2 | README, ADR_INDEX, DECISION_HISTORY |
| `ADR_INDEX.md` | 설계 결정 색인 | A24_5~8, A24_CALLER, adr/ADR 등 | README, ARCHITECTURE_SUMMARY |
| `DECISION_HISTORY.md` | 설계 결정 시간순 이력 | A24_5~8, A23, A24_CALLER | README, ARCHITECTURE_SUMMARY |
| `baseline/SESSION_CLOSING_BASELINE.md` | Session Closing 공식 Baseline | A8, A12, A13, A14 시리즈 | README, AI_DEVELOPMENT_PROCESS |
| `adr/ADR-001~007` | 개별 설계 원칙 | 대응 아키텍처/구현 문서 | ADR_INDEX, ARCHITECTURE_SUMMARY |
| `A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` | itemType 오기 발견·정정 기록 | A24_5, A8, 코드 | A24_8, DECISION_HISTORY, ARCHITECTURE_SUMMARY |
| `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` | Milestone 1 공식 기록 | A20~A25 시리즈 | PROJECT_ROADMAP, README |
| `MARK2_IDEAS.md` | 차기 개선 후보 목록 | ARCHITECTURE_SUMMARY | README, AI_DEVELOPMENT_NOTEBOOK |

---

## PART 3 — 중복성 분석

| 문서 A | 문서 B | 중복 수준 | 근거 |
|---|---|---|---|
| `ARCHITECTURE_SUMMARY.md` | `ADR_INDEX.md` | **Partial** | 동일한 9개 설계 결정을 ARCHITECTURE_SUMMARY는 서술형(12항목), ADR_INDEX는 색인형으로 표현. 내용 중복이지만 형식과 용도가 다름(서술 vs 참조) |
| `ARCHITECTURE_SUMMARY.md` | `DECISION_HISTORY.md` | **Partial** | 동일 결정들을 ARCHITECTURE_SUMMARY는 주제별, DECISION_HISTORY는 시간순으로 기록. 관점이 다름 |
| `A13_IMPLEMENTATION_DECISION.md` | `adr/ADR-007-a13-mvp-transaction-scope.md` | **Partial** | A13_IMPLEMENTATION_DECISION이 Transaction Scope를 최종 결정한 결과가 ADR-007에 압축 기록됨. ADR-007이 공식 결정, A13_IMPLEMENTATION_DECISION은 그 과정 문서 |
| `A14_ARCHITECTURE_TRADEOFF_REVIEW.md` | `ARCHITECTURE_SUMMARY.md` | **Partial** | A14_ARCHITECTURE_TRADEOFF_REVIEW의 최종 결론("현재 구조 유지 권장")이 ARCHITECTURE_SUMMARY §2/§4에 반영됨 |
| A14 시리즈 5개 (`A14_WORKFLOW_EXTRACTION_READY` ~ `A14_ARCHITECTURE_TRADEOFF_REVIEW`) | 서로 간 | **Partial** | 각 문서가 이전 문서를 전제로 점진적 분석 — 마지막 `TRADEOFF_REVIEW`가 사실상 이전 4개의 결론을 대체. 개별 단계 문서들은 과정 이력 |
| `DEVELOPMENT_CHECKLIST.md` | `AI_DEVELOPMENT_PROCESS.md` | **Partial** | PROCESS가 흐름을 기술하고, CHECKLIST가 완료 조건을 나열 — 내용 일부 중복(git 커밋, analyze/test 등)이나 역할이 다름 |

---

## PART 4 — 유지 필요성 평가

| 문서 | 평가 | 근거 |
|---|---|---|
| `README.md`, `WORK_LOG.md`, `ADR_INDEX.md`, `ARCHITECTURE_SUMMARY.md`, `DECISION_HISTORY.md`, `PROJECT_ROADMAP.md` | **Keep** | 핵심 거버넌스 문서, 활발히 참조됨 |
| `AI_DEVELOPMENT_PROCESS.md`, `DEVELOPMENT_CHECKLIST.md`, `AI_DEVELOPMENT_NOTEBOOK.md` | **Keep** | 개발 표준 문서, 신규 기능 착수 시 참조 |
| `MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `MARK2_IDEAS.md` | **Keep** | Milestone 기록 및 차기 계획 관리용 |
| `A8_SESSION_ENGINE.md`, `ID_CONVENTION.md`, `baseline/SESSION_CLOSING_BASELINE.md` | **Keep** | 기반 아키텍처 및 Baseline — 수정 시 필수 참조 |
| `adr/ADR-001~007`, `architecture/PRICING_ENGINE_ARCHITECTURE.md`, `architecture/PROMOTION_ENGINE_ARCHITECTURE.md` | **Keep** | ADR은 확정된 설계 결정의 공식 기록 |
| `A24_BOOKING_COMPLETION_CALLER_DESIGN.md`, `A24_5~8` | **Keep** | 현행 Booking→Session 계약의 직접 근거 |
| `A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md`, `A13_CONCURRENCY_VALIDATION.md`, `A17_OPERATIONAL_STABILITY_CHECK.md`, `A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md` | **Keep** | README에서 직접 참조, Verification 기준 문서 |
| `A9_ID_UNIFICATION.md`, `A10_IMPLEMENTATION_READINESS_REVIEW.md`, `A10_5_DISCOUNT_ARCHITECTURE_REVIEW.md`, `A11_IMPLEMENTATION_PLAN.md`, `A11_5_PROMOTION_EXPANSION_PLAN.md`, `A11_PROMOTION_ENGINE_DESIGN.md`, `A12_IMPLEMENTATION_READY.md`, `A12_STAFF_EARNING_ARCHITECTURE.md`, `A14_WORKFLOW_EXTRACTION_READY.md`, `A14_WORKFLOW_INTERFACE_READY.md`, `A14_WORKFLOW_CONTRACT_VALIDATION.md`, `A14_WORKFLOW_DEPENDENCY_VALIDATION.md`, `A14_WORKFLOW_PATTERN_VALIDATION.md`, `A15_WORKFLOW_RESPONSIBILITY_REFINEMENT.md`, `A16_ARCHITECTURE_FINALIZATION.md`, `A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md`, `A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md`, `A21~A23` | **Keep** (이력) | 개발 과정의 분석 이력 — 직접 참조는 낮으나 보존 가치 있음(WORK_LOG에 연결, 추후 유사 작업 참조 가능) |
| `A13_TRANSACTION_IMPLEMENTATION_READY.md` | **Merge Candidate** | A13 구현 직전 최종 확인 문서 — `ARCHITECTURE_SUMMARY.md`나 `MILESTONE_1`에 내용이 충분히 요약됨. 단독 참조 필요성이 낮음 |
| `A13_IMPACT_MAPPING.md`, `A13_TRANSACTION_BOUNDARY_REVIEW.md`, `A13_IMPLEMENTATION_DECISION.md` | **Merge Candidate** | 세 문서의 최종 결론이 `ADR-007`과 `ARCHITECTURE_SUMMARY`에 반영됨. 단독으로는 과정 이력 역할만 수행 |
| `A14_ARCHITECTURE_TRADEOFF_REVIEW.md` | **Merge Candidate** | 결론("현재 구조 유지 권장")이 `ARCHITECTURE_SUMMARY §1~§2`에 통합됨. 단독 참조 필요성 낮음 |

---

## PART 5 — Documentation Dependency

```
docs/README.md (최상위 색인)
    │
    ├── [Architecture]
    │       A8_SESSION_ENGINE.md
    │       ID_CONVENTION.md
    │       ARCHITECTURE_SUMMARY.md ←─── ADR_INDEX.md
    │           └── adr/ADR-001~007
    │           └── architecture/PRICING_ENGINE_ARCHITECTURE.md
    │           └── architecture/PROMOTION_ENGINE_ARCHITECTURE.md
    │           └── baseline/SESSION_CLOSING_BASELINE.md
    │
    ├── [Contracts]
    │       A24_BOOKING_COMPLETION_CALLER_DESIGN.md
    │       A24_5 ~ A24_8 (계약 시리즈)
    │       DECISION_HISTORY.md ─────────┐
    │                                     │
    ├── [Milestones & Roadmap]            │
    │       MILESTONE_1 ─────────────────┘ (A20~A25 오더 시리즈 요약)
    │       PROJECT_ROADMAP.md
    │
    ├── [Verification]
    │       A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md
    │       A13_CONCURRENCY_VALIDATION.md
    │       A17_OPERATIONAL_STABILITY_CHECK.md
    │       A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md
    │
    ├── [Development Process]
    │       AI_DEVELOPMENT_PROCESS.md
    │           └── DEVELOPMENT_CHECKLIST.md
    │       AI_DEVELOPMENT_NOTEBOOK.md
    │
    ├── [Future]
    │       MARK2_IDEAS.md ←──────────── AI_DEVELOPMENT_NOTEBOOK.md
    │
    └── [Log]
            WORK_LOG.md (모든 오더 이력)
```

**분석 이력 문서(이 트리에 미연결된 문서들)**:
A9_ID_UNIFICATION, A10_IMPL_READINESS, A10_5_DISCOUNT, A11 시리즈(3개), A12 시리즈(2개), A13_TRANSACTION_BOUNDARY/IMPACT/IMPL_DECISION/TRANSACTION_IMPL_READY, A14 시리즈(5개), A15~A16, A18_2, A20~A23 — 이들은 **WORK_LOG**를 통해 간접 참조되며, 직접 트리에서는 고아처럼 보이지만 MILESTONE_1이 "포함된 오더" 목록으로 이들을 포함한다.

**순환 참조**: 없음. A-시리즈 문서들은 일방향으로 이전 시리즈를 참조하며, 역방향 참조가 없다.

---

## PART 6 — Missing Documentation

실제 개발 과정에서 부족했던 문서만 기록한다.

| 필요한 문서 | 필요한 이유 |
|---|---|
| **Booking Completion UI Flow Spec** | A-23 분석 결과 Booking 완료를 위한 화면/라우트가 존재하지 않음을 확인했으나, "어떤 UI 이벤트가 `BookingCompletionCaller.complete()`를 호출해야 하는지"를 명시한 문서가 없다. MILESTONE_1 §7에서 A-28로 이관됨. |
| **Repository Method Reference** | 모든 모듈의 Repository public 메서드를 한 곳에서 확인할 수 없다 — A-24.6에서 `ProductRepository.watchProducts()`의 존재를 확인하기 위해 코드를 직접 grep해야 했다. 새 기능 설계 시마다 동일한 조사 반복 발생. |
| **Schema ↔ Domain Map** | 현재 어떤 도메인이 어떤 테이블을 소유하는지 한눈에 볼 수 있는 지도가 없다 — A-24.5에서 `Bookings` 테이블에 `businessType` 컬럼이 없다는 사실을 확인하기 위해 `booking_tables.dart`를 직접 읽어야 했다. |

---

## PART 7 — Documentation Health

| 항목 | 결과 |
|---|---|
| README로 모든 문서 접근 가능 | **No** — A-시리즈 분석 이력 문서(약 22개)가 README에 미링크. 단, MILESTONE_1/WORK_LOG을 통해 간접 접근 가능. |
| 고아 문서 존재 | **Yes** (협의의 의미로) — README에서 직접 링크되지 않는 분석 이력 문서가 22개 존재. 완전한 고아는 아니며 WORK_LOG/MILESTONE_1 경유로 접근 가능. |
| 순환 참조 존재 | **No** |
| 문서 분류 일관성 | **Good** — README의 8개 카테고리 체계가 현재 56개 문서를 포괄. 일부 분석 이력 문서는 "Analysis" 단일 종류로 묶여 있어 세분화 여지 있음. |
| 중복 문서 존재 | **Yes** (Partial) — PART3에서 확인된 6건의 Partial 중복. 어느 것도 High 수준의 완전 중복은 없음. |

---

## PART 8 — 최종 결론

### 수치 요약

| 항목 | 개수 |
|---|---|
| 전체 문서 | **56개** |
| Active 문서 | **30개** (직접 참조 또는 Baseline/ADR 역할) |
| Passive 문서(이력) | **23개** (개발 과정 분석 이력, 보존 가치 있음) |
| Archive Candidate | **0개** (삭제 불필요, 판단 자체 미수행) |
| Merge Candidate | **4개** (A13_TRANSACTION_IMPLEMENTATION_READY, A13_IMPACT_MAPPING, A13_IMPLEMENTATION_DECISION, A14_ARCHITECTURE_TRADEOFF_REVIEW) |

### Documentation 구조의 장점

1. **계층이 명확하다** — README(색인) → 거버넌스 문서 → ADR → 세부 계약 → 이력 분석 순서로 접근 가능하다.
2. **이력이 풍부하다** — "왜 그 결정을 내렸는가"를 DECISION_HISTORY, ADR, A-시리즈 문서를 통해 추적할 수 있다.
3. **Baseline이 명확하다** — `baseline/SESSION_CLOSING_BASELINE.md`가 `closeSession()` 관련 변경의 기준점 역할을 한다.
4. **MARK2가 분리 관리된다** — 구현 중 발견된 개선 아이디어가 현재 코드에 섞이지 않고 별도로 관리된다.

### Documentation 구조의 개선 후보

1. **README에서 분석 이력 문서 접근성 개선** — 22개 분석 이력 문서가 README에 링크되지 않아 직접 탐색이 어렵다. `Archive/` 섹션 또는 "Analysis Trail" 색인 추가를 검토할 수 있다(MARK2 후보).
2. **Merge Candidate 4개 처리** — A13_TRANSACTION_IMPLEMENTATION_READY, A13_IMPACT_MAPPING, A13_IMPLEMENTATION_DECISION, A14_ARCHITECTURE_TRADEOFF_REVIEW의 핵심 내용이 이미 다른 Active 문서에 반영돼 있어, 향후 아카이브 디렉터리로 이동을 검토할 수 있다.
3. **Repository Method Reference 부재** — PART6에서 확인된 대로, 새 기능 설계 시마다 코드를 직접 grep해야 하는 반복 작업이 발생한다.

---

**"Documentation Inventory Completed"**
