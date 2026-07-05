# Milestone 2 Readiness Assessment

> 이 문서는 Milestone 1(A-20~A-25) 결과를 기준으로 현재 프로젝트의 개발 상태를 관찰하고, Milestone 2 개발을 위한 준비 상태를 기록한다.
> **제약**: 관찰·문서화만 수행. 코드 수정 금지. 새로운 기능 제안 금지. 추론 금지. 최종 승인 판단 금지.
> **기준 문서**: `docs/PROJECT_ROADMAP.md`, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/MARK2_IDEAS.md`, `docs/DECISION_HISTORY.md`
> 작성일: 2026-07-03

---

## PART 1 — Milestone 1 Completion Verification

Milestone 1에서 계획된 항목들이 실제 완료되었는지 확인:

| 항목 | 상태 | 근거 문서 | 근거 Commit |
|---|---|---|---|
| A-20 Booking Engine Domain Analysis | 완료 | `docs/A20_BOOKING_ENGINE_DOMAIN_ANALYSIS.md` | `1982bad` |
| A-21 Booking→Session Integration Point Analysis | 완료 | `docs/A21_BOOKING_SESSION_INTEGRATION_POINT_ANALYSIS.md` | `5f847a0` |
| A-22 Booking Session Call Site Analysis | 완료 | `docs/A22_BOOKING_SESSION_CALL_SITE_ANALYSIS.md` | `09e297c` |
| A-23 Booking Completion Orchestrator Analysis | 완료 (선정 불가 확인) | `docs/A23_BOOKING_COMPLETION_ORCHESTRATOR_ANALYSIS.md` | `fbb5d6e` |
| A-24 Booking Completion Caller Design Decision | 완료 | `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md` | `a4158e7` |
| A-24.5 Data Ownership & Mapping Contract | 완료 | `docs/A24_5_BOOKING_SESSION_DATA_OWNERSHIP_MAPPING_DESIGN.md` | `c77c372` |
| A-24.6 Product Retrieval Strategy | 완료 | `docs/A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md` | `0eec1c1` |
| A-24.7 Session Item Contract Verification | 완료 | `docs/A24_7_SESSION_ITEM_CONTRACT_VERIFICATION.md` | `35217ed` |
| A-24.8 Session Item Persistence Contract Verification | 완료 | `docs/A24_8_SESSION_ITEM_PERSISTENCE_CONTRACT_VERIFICATION.md` | `d0bf64c` |
| A-25 BookingCompletionCaller 구현 | 완료 | `lib/features/booking/data/booking_completion_caller.dart` | `a12190b` |
| A-25 신규 테스트 4건 | 완료 | `test/features/booking/booking_completion_caller_test.dart` | `a12190b` |
| A-25 전체 테스트 통과 | 완료 | MILESTONE_1 §6: "373건 Pass" | `a12190b` |
| A-25.5 Architecture Summary / Roadmap 문서화 | 완료 | `docs/ARCHITECTURE_SUMMARY.md`, `docs/PROJECT_ROADMAP.md` | `defa2d4` |
| A-25.6 Milestone 공식화 / Decision History | 완료 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md`, `docs/DECISION_HISTORY.md` | `9d8c661` |
| BookingCompletionCaller UI 연동 | 미완료 | MILESTONE_1 §7: "completeBooking() 호출 UI 없음 — A-26에서 검토" | — |
| Booking 완료 화면/라우트 | 미완료 | MILESTONE_1 §7: "A-23에서 확인된 그대로 라우트 없음" | — |

---

## PART 2 — Remaining Development Inventory

현재 계획되어 있으나 완료되지 않은 개발 항목:

| 기능 | 현재 상태 | 근거 문서 | 비고 |
|---|---|---|---|
| A-26 Booking Integration Test | 미구현 | `docs/PROJECT_ROADMAP.md` §Next | `BookingCompletionCaller`가 실제 UI 호출 경로에서 동작하는지 통합 검증 |
| A-27 Regression Verification | 미구현 | `docs/PROJECT_ROADMAP.md` §Next | A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정 |
| A-28 Booking Flow Documentation | 미구현 | `docs/PROJECT_ROADMAP.md` §Next | 운영자용 흐름 문서(어떤 UI 이벤트가 `complete()`를 호출해야 하는지) |
| BookingCompletionCaller Provider 등록 | 미구현 | `lib/features/booking/providers.dart` 직접 확인 — `BookingCompletionCaller` 관련 Provider 없음 | UI 연동의 선행 조건 |
| Booking 완료 화면 / 라우트 | 미구현 | MILESTONE_1 §7, A-23 분석 | `lib/features/booking/screens/` — 현재 `waiting_list_screen.dart` 1개만 존재 |
| MARK2 아이디어 3건 | 미구현(보류) | `docs/MARK2_IDEAS.md` | Repository 단건 조회 / addItem 병렬화 / 미매칭 상품 정책 |
| ADR-005 Promotion 중첩 정책 | 미구현(보류) | `docs/PROJECT_ROADMAP.md` §Future — "ADR-005 미작성으로 보류됨" | 복수 Promotion 중첩 정책 |
| TOCTOU 동시성 대응(UI 연결 후) | 미구현(보류) | MILESTONE_1 §7 — "UI 연결 전 재평가 필요" | ADR-007에서 의도적 이관 |

---

## PART 3 — Milestone 2 Candidate Inventory

기존 프로젝트 문서에서 확인 가능한 Milestone 2 후보 항목:

| 기능 | 근거 문서 | 현재 상태 |
|---|---|---|
| **A-26** Booking Integration Test | `docs/PROJECT_ROADMAP.md` §Next, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | 미구현 |
| **A-27** Regression Verification | `docs/PROJECT_ROADMAP.md` §Next, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | 미구현 |
| **A-28** Booking Flow Documentation | `docs/PROJECT_ROADMAP.md` §Next, `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §8 | 미구현 |
| **MARK2-1** `BookingRepository.getBookingById()` 단건 조회 메서드 추가 | `docs/MARK2_IDEAS.md` (Repository 분류) | 미구현(보류) |
| **MARK2-2** `addItem()` 병렬 호출 지원 | `docs/MARK2_IDEAS.md` (Performance 분류) | 미구현(보류) |
| **MARK2-3** 미매칭 상품 명시적 정책 | `docs/MARK2_IDEAS.md` (Technical Debt 분류) | 미구현(보류) |

> **주의**: A-26~A-28은 `PROJECT_ROADMAP.md`에서 "단기 후속 작업"으로 명시된 항목. MARK2 3건은 "중·장기 검토 항목"으로 명시됨.

---

## PART 4 — Dependency Observation

Milestone 2 후보 기능이 의존하는 기존 구현:

| 기능 | 의존 대상 | 근거 |
|---|---|---|
| **A-26** Booking Integration Test | `lib/features/booking/data/booking_completion_caller.dart` | A-26의 검증 대상 자체가 `BookingCompletionCaller` — `a12190b` 커밋으로 구현 완료 |
| **A-26** Booking Integration Test | `lib/features/session/data/session_repository.dart` (`createSession()`, `addItem()`) | `BookingCompletionCaller.complete()`가 내부에서 `sessionRepository.createSession()`/`addItem()` 호출 — `booking_completion_caller.dart:36~59` |
| **A-26** Booking Integration Test | `lib/features/booking/data/booking_repository.dart` (`completeBooking()`) | `BookingCompletionCaller.complete()`가 `bookingRepository.completeBooking()` 호출 — `booking_completion_caller.dart:36` |
| **A-26** Booking Integration Test | `lib/features/product/data/product_repository.dart` (`watchProducts()`) | `BookingCompletionCaller.complete()`가 `productRepository.watchProducts().first` 호출 — `booking_completion_caller.dart:39` |
| **A-27** Regression Verification | A-26 통합 테스트 완료 | PROJECT_ROADMAP에서 A-26 이후 항목으로 순서 명시됨 |
| **A-28** Booking Flow Documentation | A-26 통합 테스트 결과 | UI 호출 경로 확인 후 운영 문서 작성이 자연스러운 순서 (MILESTONE_1 §8 명시) |
| **MARK2-1** `getBookingById()` 메서드 추가 | `lib/features/booking/data/booking_repository.dart` | `MARK2_IDEAS.md`: "현재 BookingRepository에 ID 기준 단건 조회 메서드가 없어 … 우회함" |
| **MARK2-2** `addItem()` 병렬화 | `lib/features/session/data/session_repository.dart` (`addItem()`) | `MARK2_IDEAS.md`: "여러 상품에 대해 addItem()을 순차 await로 처리 중" |
| **MARK2-3** 미매칭 상품 정책 | `lib/features/booking/data/booking_completion_caller.dart` (`productIdsCsv` 파싱 로직) | `MARK2_IDEAS.md`: "CSV의 Product ID가 없으면 조용히 건너뛴다" — `booking_completion_caller.dart:47~52` |

---

## PART 5 — Development Risk Observation

Milestone 2 착수 전 확인해야 하는 사항:

| 항목 | 확인 결과 | 근거 |
|---|---|---|
| `BookingCompletionCaller` Provider 등록 여부 | **미등록** — `lib/features/booking/providers.dart`에 `BookingCompletionCaller` 관련 Provider 없음 | `providers.dart` 직접 확인: `bookingRepositoryProvider`, `waitingListStreamProvider` 2개만 존재 |
| Booking 완료 화면/라우트 존재 여부 | **없음** — `lib/features/booking/screens/`에 `waiting_list_screen.dart` 1개만 존재 | 파일시스템 직접 확인, A-23 분석 결과(`completeBooking()` 호출자 0건)와 일치 |
| `completeBooking()` 실제 UI 호출 존재 여부 | **없음** — `lib/` 전체에서 `completeBooking()` 호출이 `booking_completion_caller.dart:36` 외에 없음 | `grep -rn "completeBooking" lib/` 직접 확인 |
| `payment_repository.dart`의 예약 경로 연동 주석 | **명시적 보류** — "예약경로(completeBooking() 연동)는 1차 범위에 포함하지 않음" 주석 존재 | `lib/features/payment_pos/data/payment_repository.dart:184` 직접 확인 |
| flutter analyze 상태 | **Pass** — No issues found (ran in 14.5s) | 이번 작업 시작 시 실행 결과 |
| flutter test 상태 | **Pass** — 372건 All tests passed | PART 9 실행 결과 |
| TOCTOU 동시성 대응 (UI 연결 후 재평가) | **보류 상태** — ADR-007에서 의도적 이관됨 | MILESTONE_1 §7: "UI 연결 전 재평가 필요(`docs/A13_CONCURRENCY_VALIDATION.md`)" |

---

## PART 6 — Knowledge Carry-over Observation

Milestone 1에서 문서화된 Knowledge 중 Milestone 2에서도 사용 가능한 항목:

| Knowledge | 근거 문서 |
|---|---|
| **Repair Loop 수행 조건** — 계약 충돌/부재 발견 시 구현 중단 후 설계 오더 발생 | `docs/AI_DEVELOPMENT_NOTEBOOK.md` PART 4 (9가지 조건 목록) |
| **Contract Verification 필수** — 구현 착수 전 계약과 코드/DB를 1:1 대조 | `docs/AI_DEVELOPMENT_NOTEBOOK.md` PART 2, `docs/AI_DEVELOPMENT_PROCESS.md` |
| **추론 기반 구현 금지** — 계약에 없는 값/로직은 코드에서 추론하지 않음 | `docs/AI_DEVELOPMENT_PROCESS.md` §Implementation, `docs/DECISION_HISTORY.md` A-24.7 항목 |
| **DB 변경 원칙** — 구현 중 스키마 변경이 필요한 경우 즉시 중단 후 Schema Design 오더 | `docs/AI_DEVELOPMENT_NOTEBOOK.md` PART 5 |
| **Minimal Change 원칙** — 기존 Repository/Engine/Workflow 수정 없이 신규 파일만으로 기능 추가 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` §5 ("수정된 기존 파일: 없음") |
| **ADR-001** — Engine은 순수 계산 클래스, Drift 비의존 | `docs/adr/ADR-001-pricing-engine-domain-isolation.md` |
| **ADR-003** — 금전 변화는 이벤트로 기록, 헤더는 파생값 | `docs/adr/ADR-003-financial-events.md` |
| **ADR-007** — Settlement~상태변경은 단일 `_db.transaction()` | `docs/adr/ADR-007-a13-mvp-transaction-scope.md` |
| **SESSION_CLOSING_BASELINE** — `closeSession()` / `SessionClosingWorkflow` 수정 전 반드시 참조 | `docs/baseline/SESSION_CLOSING_BASELINE.md` |
| **A1_A2_BOUNDARY 원칙** — 완료 메서드는 크로스 도메인 사이드 이펙트를 자체 발동하지 않음, Caller가 담당 | `docs/DECISION_HISTORY.md` A-23 항목, `docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md` |
| **watchProducts().first + 메모리 매칭 전략** — ProductRepository 단건 조회 메서드 없을 때의 대안 | `docs/A24_6_BOOKING_PRODUCT_RETRIEVAL_STRATEGY_DESIGN.md` |
| **MARK2_IDEAS.md 즉시 기록 원칙** — 구현 도중 발견한 개선 아이디어는 현재 구현에 포함하지 않고 즉시 MARK2_IDEAS.md에 기록 | `docs/AI_DEVELOPMENT_NOTEBOOK.md` PART 6 §MARK2에 대해 |
| **코드·문서 커밋 분리** — 코드 변경 커밋과 WORK_LOG 갱신 커밋은 항상 별도 커밋 | `docs/DEVELOPMENT_TRACEABILITY_ARCHITECTURE.md` PART 8 |
| **DEVELOPMENT_CHECKLIST** — 구현 완료 후 커밋 전 체크리스트 | `docs/DEVELOPMENT_CHECKLIST.md` |

---

## PART 7 — Milestone Transition Status

Milestone 2 준비 상태 관찰:

| 항목 | 상태 | 근거 |
|---|---|---|
| Milestone 1 공식 완료 선언 | 준비 완료 | `docs/MILESTONE_1_BOOKING_SESSION_FOUNDATION.md` 존재 및 "✅ Completed" 명시 |
| Next 항목(A-26~A-28) 정의 | 준비 완료 | `docs/PROJECT_ROADMAP.md` §Next에 3개 항목과 목적이 명시됨 |
| MARK2 후보 목록 | 준비 완료 | `docs/MARK2_IDEAS.md`에 3개 항목과 보류 이유가 명시됨 |
| ADR 기준선(ADR-001~007) | 준비 완료 | 7개 ADR 파일 존재, `docs/ADR_INDEX.md`에 색인됨 |
| Session Closing Baseline | 준비 완료 | `docs/baseline/SESSION_CLOSING_BASELINE.md` 존재 |
| Traceability 구조 | 준비 완료 | `docs/DEVELOPMENT_TRACEABILITY_ARCHITECTURE.md` 존재 (A-25.13) |
| Repair Loop 지식 | 준비 완료 | `docs/REPAIR_LOOP_OBSERVATION.md`(A-25.14), `docs/AI_DEVELOPMENT_NOTEBOOK.md`(A-25.10) 존재 |
| Knowledge Relationship 구조 | 준비 완료 | `docs/ENGINEERING_KNOWLEDGE_RELATIONSHIP_ARCHITECTURE.md` 존재 (A-25.15) |
| BookingCompletionCaller UI 연동 | 미확인 | Provider 미등록, UI 화면 없음 — A-26 이전 단계에서 확인 필요 |
| `completeBooking()` UI 호출 경로 | 미확인 | `grep` 결과 실제 UI 호출 0건 — A-28 문서화 전 확인 필요 |
| TOCTOU 재평가 시점 | 일부 준비 | MILESTONE_1 §7에 "UI 연결 전 재평가 필요"로 명시됨. 재평가 기준·시점은 미정 |
| flutter analyze | 준비 완료 | Pass — No issues found |
| flutter test | 준비 완료 | Pass — 372건 All tests passed |

---

## PART 9 — Baseline Verification

### flutter analyze

```
Analyzing salon-pos-v2...
No issues found! (ran in 14.5s)
```

결과: **Pass**

### flutter test

```
+372: All tests passed!
```

결과: **Pass (372건)**

### git status

```
On branch main
Your branch is up to date with 'origin/main'.

Changes not staged for commit:
  deleted: design/mockups/v2/ja/03_pos_payment_b.html

Untracked files:
  .claude/
  design/spec/pages/02_pos_order 복사본.md
  design/spec/pages/1 1.txt
  design/spec/pages/1.txt
  design/결제하기_files.zip
  design/결제하기_files/
  design/분할결제하기_files.zip
  design/분할결제하기_files/
```

**코드 변경 없음** — 이번 작업은 순수 관찰·문서화만 수행함. git status의 변경사항은 이번 작업과 무관하게 사전 존재하던 상태.

---

**"Milestone 2 Readiness Assessment Established"**
