# Salon POS v2 — 문서 인덱스

> 이 파일은 `docs/` 디렉터리 내 모든 문서의 분류·목적·참조 시점을 안내한다. 새 문서가 추가되면 이 인덱스도 함께 갱신한다.

---

## Architecture

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [ARCHITECTURE_SUMMARY.md](ARCHITECTURE_SUMMARY.md) | Booking→Session Integration의 12개 핵심 설계 결정 요약 | 기존 결정의 이유를 확인하거나 유사한 새 기능 설계 시 |
| [ADR_INDEX.md](ADR_INDEX.md) | Architecture Decision Record 색인(Caller/Data/Product/Session Item 계약 등) | 특정 설계 결정의 근거와 참조 문서를 찾을 때 |
| [DEVELOPMENT_TRACEABILITY_ARCHITECTURE.md](DEVELOPMENT_TRACEABILITY_ARCHITECTURE.md) | Requirement→Analysis→Design→Contract Verification→Implementation→Verification→Milestone→MARK2 전체 추적 구조 | 특정 코드/결정의 설계 근거를 역추적하거나 새 Milestone 개발 방법론 참조 시 |
| [ENGINEERING_KNOWLEDGE_RELATIONSHIP_ARCHITECTURE.md](ENGINEERING_KNOWLEDGE_RELATIONSHIP_ARCHITECTURE.md) | Engineering Asset 간 관계(Node·Edge·Direction·Traceability) 관찰 기록 | Asset 간 연결 구조를 파악하거나 Navigation 경로를 확인할 때 |
| [adr/ADR-001~ADR-007](adr/) | 개별 ADR(Pricing Engine 격리, 할인 표현, Financial Events, Promotion Lifecycle, Staff Earning, Transaction Scope) | 해당 ADR이 적용되는 코드를 수정하거나 리뷰할 때 |
| [architecture/PRICING_ENGINE_ARCHITECTURE.md](architecture/PRICING_ENGINE_ARCHITECTURE.md) | Pricing Engine 구조·책임·확장 방향 | Pricing/Promotion Engine 수정 시 |
| [architecture/PROMOTION_ENGINE_ARCHITECTURE.md](architecture/PROMOTION_ENGINE_ARCHITECTURE.md) | Promotion Engine 구조·책임 | Promotion Engine 수정 시 |
| [baseline/SESSION_CLOSING_BASELINE.md](baseline/SESSION_CLOSING_BASELINE.md) | Session Closing 구조 공식 Baseline | `closeSession()`/`SessionClosingWorkflow`/Transaction 수정 시 반드시 참조 |
| [A8_SESSION_ENGINE.md](A8_SESSION_ENGINE.md) | SESSION ENGINE 전체 설계 문서(A-8 시점) | Session 도메인 이해 또는 테이블 구조 확인 시 |
| [ID_CONVENTION.md](ID_CONVENTION.md) | ID 타입 통일 원칙(UUID→INTEGER) | 신규 테이블 생성 시 |

---

## Contracts

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md](A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md) | Booking→Session 데이터 소유권·매핑 계약 | `BookingCompletionCaller.complete()` 수정 시 |
| [A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md](A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md) | Product 조회 전략 계약 | `watchProducts()`+메모리 매칭 방식 변경 검토 시 |
| [A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md](A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md) | Session Item 계약 최종본(itemType='service' 포함 정정 이력) | `addItem()` 호출 계약 확인 시 |
| [A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md](A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md) | 저장 구조와 계약 일치 검증 결과 | PaymentSessionItems 스키마 변경 전 확인 시 |
| [DECISION_HISTORY.md](DECISION_HISTORY.md) | 모든 핵심 설계 결정의 시간순 이력 | 특정 결정이 언제, 왜 내려졌는지 추적할 때 |

---

## Implementation

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [A24_BOOKING_COMPLETION_CALLER_DESIGN.md](A24_BOOKING_COMPLETION_CALLER_DESIGN.md) | `BookingCompletionCaller` 설계 결정(Caller 패턴 선택 이유) | Caller 구조 수정 또는 유사 패턴 도입 시 |
| [BOOKING_COMPLETION_OPERATOR_GUIDE.md](BOOKING_COMPLETION_OPERATOR_GUIDE.md) | 予約完了(来店完了) 처리 흐름 운영자 가이드 — UI 진입 경로·5단계 실행 순서·조건·미확인 항목 | `complete()` 실행 흐름 확인 또는 운영 대응 시 |
| [A9_ID_UNIFICATION.md](A9_ID_UNIFICATION.md) | A-9 ID 통일 이력 | ID 관련 버그 조사 또는 마이그레이션 참조 시 |
| [MARK2_IDEAS.md](MARK2_IDEAS.md) | 이번 범위에서 구현하지 않은 개선 아이디어 목록 | 다음 Milestone 계획 시 |

---

## Verification

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [A13_CONCURRENCY_VALIDATION.md](A13_CONCURRENCY_VALIDATION.md) | Race Condition 분석 결과 | `closeSession()` 동시성 대응 구현 시 |
| [A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md](A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md) | Financial Workflow 단계별 실패 분석 | `closeSession()` 변경 또는 장애 대응 시 |
| [A17_OPERATIONAL_STABILITY_CHECK.md](A17_OPERATIONAL_STABILITY_CHECK.md) | 운영 관점 안정성 확인 결과 | Session Engine 운영 전 점검 시 |
| [A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md](A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md) | `closeSession()` 멱등성 분석 | 중복 호출 시나리오 검증 시 |

---

## Milestones

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [MILESTONE_1_BOOKING_SESSION_FOUNDATION.md](MILESTONE_1_BOOKING_SESSION_FOUNDATION.md) | Milestone 1 공식 완료 기록(A-20~A-25.6 종합) | 다음 Milestone 계획 또는 전체 진행 현황 파악 시 |
| [MILESTONE_2_READINESS_ASSESSMENT.md](MILESTONE_2_READINESS_ASSESSMENT.md) | Milestone 2 착수 준비 상태 관찰(Completion Verification / Candidate / Dependency / Risk / Knowledge Carry-over) | Milestone 2 개발 시작 전 현황 파악 시 |
| [A26_REQUIREMENT_DEFINITION.md](A26_REQUIREMENT_DEFINITION.md) | Milestone 2 Requirement Definition — 6개 Candidate(REQ-A26~28, REQ-M2-1~3) 확인·추적·Gap 관찰 | Milestone 2 개발 착수 시 Requirement 기준 문서로 참조 |
| [A27_REQUIREMENT_ANALYSIS.md](A27_REQUIREMENT_ANALYSIS.md) | Milestone 2 Requirement Analysis — 6개 Requirement Evidence Inventory/Analysis/Traceability/Gap/Status 관찰 | Milestone 2 Requirement 분석 기준 문서로 참조 |
| [A28_DESIGN_DEFINITION.md](A28_DESIGN_DEFINITION.md) | Milestone 2 Design Definition — 9개 Design Decision(D-1~D-9), Design Boundary, Flow Connection Observation | Milestone 2 구현 착수 전 설계 기준 문서로 참조 |
| [A28_5_INTERFACE_CONTRACT_DEFINITION.md](A28_5_INTERFACE_CONTRACT_DEFINITION.md) | Milestone 2 Interface Contract Definition — 5개 Interface Contract(IC-1~IC-5), Responsibility, Traceability | Milestone 2 구현 시 Interface 계약 기준 문서로 참조 |
| [A30_IMPLEMENTATION_VERIFICATION.md](A30_IMPLEMENTATION_VERIFICATION.md) | Milestone 2 Implementation Verification — A-29 구현 결과의 Requirement/Design/Contract 만족 여부 검증 | Milestone 2 구현 완료 후 검증 결과 확인 시 참조 |
| [A31_FOLLOWUP_IMPLEMENTATION.md](A31_FOLLOWUP_IMPLEMENTATION.md) | Milestone 2 Verification Follow-up — A-30 미확인 항목 중 D-5/D-6 문서 구현 결과 | A-30 Follow-up 결과 확인 시 참조 |
| [A32_REMAINING_IMPLEMENTATION.md](A32_REMAINING_IMPLEMENTATION.md) | Milestone 2 Remaining Implementation — 구현 가능 항목 전수 분류, D-8/D-9 구현 불가 확인 | Milestone 2 최종 구현 범위 확인 시 참조 |
| [A33_MILESTONE2_CLOSURE.md](A33_MILESTONE2_CLOSURE.md) | Milestone 2 공식 종료 기록 — Requirement/Design/Contract/CC/Known Limitation/Boundary 종료 상태 | Milestone 2 종료 결과 확인 또는 다음 Milestone 착수 전 참조 |
| [A34_MILESTONE3_REQUIREMENT.md](A34_MILESTONE3_REQUIREMENT.md) | Milestone 3 Requirement Definition — REQ-M3-1~4(병렬화/정책/Promotion/TOCTOU) Inventory/Scope/Traceability/Status | Milestone 3 개발 착수 시 Requirement 기준 문서로 참조 |
| [A35_REQUIREMENT_ANALYSIS.md](A35_REQUIREMENT_ANALYSIS.md) | Milestone 3 Requirement Analysis — REQ-M3-1~4 코드/문서 기반 분석, Structure Observation, Missing Evidence | Milestone 3 Design 착수 전 Requirement 분석 기준으로 참조 |
| [A36_DESIGN_DEFINITION.md](A36_DESIGN_DEFINITION.md) | Milestone 3 Design Definition — DD-1~4(addItem 병렬화/미매칭 정책/Promotion/TOCTOU), TOCTOU A-18.3 기구현 관찰 | Milestone 3 구현 착수 전 Design 기준 문서로 참조 |
| [A36_5_PROJECT_CONSISTENCY_VERIFICATION.md](A36_5_PROJECT_CONSISTENCY_VERIFICATION.md) | Milestone 3 Project Consistency Verification — Roadmap↔코드↔Requirement 정합성 확인, 불일치 3건 관찰(TOCTOU/단건조회/Architecture Refactoring) | Roadmap과 코드 현실 정합성 확인 시 참조(예외적 프로젝트 관리 문서) |
| [A37_INTERFACE_CONTRACT_DEFINITION.md](A37_INTERFACE_CONTRACT_DEFINITION.md) | Milestone 3 Interface Contract Definition — IC-M3-1(complete() 병렬화 후 외부 계약), IC-M3-2(미매칭 처리 일부 정의됨), IC-M3-3(calcDiscount() 중첩 후 일부 정의됨) | Milestone 3 구현 착수 전 Interface 계약 기준 문서로 참조 |
| [A38_IMPLEMENTATION.md](A38_IMPLEMENTATION.md) | Milestone 3 Implementation — IC-M3-1(`complete()` Future.wait() 병렬화) 구현 완료. IC-M3-2/IC-M3-3 미결정으로 구현 불가 기록 | Milestone 3 구현 결과 확인 및 미구현 항목 확인 시 참조 |
| [A39_IMPLEMENTATION_VERIFICATION.md](A39_IMPLEMENTATION_VERIFICATION.md) | Milestone 3 Implementation Verification — REQ-M3-1/DD-1/IC-M3-1 확인됨. REQ-M3-2/3/4 미구현. IC-M3-1 예외 전파 Verification Gap 기록 | Milestone 3 구현 검증 결과 확인 시 참조 |
| [baseline/A29_REGRESSION_BASELINE.md](baseline/A29_REGRESSION_BASELINE.md) | A-29 구현 기준 Regression Baseline — 5개 변경 파일, 372건 Pass | A-29 이후 회귀 판단 기준선 확인 시 참조 |

---

## Roadmap

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [PROJECT_ROADMAP.md](PROJECT_ROADMAP.md) | 완료/예정/장기 계획 전체 로드맵 | 다음 작업 우선순위 결정 시 |
| [WORK_LOG.md](WORK_LOG.md) | 모든 오더의 요청 요지·결과·커밋 이력 | 특정 시점의 결정을 추적하거나 재시작 후 맥락 파악 시 |

---

## Development Process

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [AI_DEVELOPMENT_PROCESS.md](AI_DEVELOPMENT_PROCESS.md) | AI 협업 개발 프로세스 표준(분석→설계→구현→검증 사이클) | 새 기능 개발을 시작할 때 |
| [DEVELOPMENT_CHECKLIST.md](DEVELOPMENT_CHECKLIST.md) | 기능 구현 완료 전 확인 체크리스트 | 구현 완료 후 커밋 전 |
| [AI_DEVELOPMENT_NOTEBOOK.md](AI_DEVELOPMENT_NOTEBOOK.md) | Engineering Notebook — Repair Loop 발생 이유, DB 변경 원칙, 개발 교훈 기록 | MARK2 계획 시, 또는 AI 협업 방식 개선 논의 시 |
| [REPAIR_LOOP_OBSERVATION.md](REPAIR_LOOP_OBSERVATION.md) | 실제 발생한 Repair Event 3건의 관찰 기록 — Trigger, Evidence, Flow, Pattern, Gap | Repair Loop 발생 시 참조 또는 유사 사례 비교 시 |

---

## Future (MARK2)

| 문서 | 목적 | 언제 참고하는가 |
|---|---|---|
| [MARK2_IDEAS.md](MARK2_IDEAS.md) | 현 Milestone에서 보류한 개선 후보 목록(Repository/Performance/Technical Debt) | 다음 Milestone의 백로그 선정 시 |
