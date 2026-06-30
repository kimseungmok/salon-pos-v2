# 작업 로그(Work Log)

> 사용자가 Claude에게 내린 오더(지시)와 그 결과를 시간순으로 기록한다.
> 매 작업이 끝날 때마다 이 문서 맨 아래에 새 항목을 추가하고 커밋한다(작업 규칙 — 아래 "운영 규칙" 참조).

---

## 운영 규칙

- **매 오더(작업 단위)가 끝나면, 그 작업의 코드/문서 변경을 커밋한 직후 본 문서에 항목을 추가하고 별도로 커밋한다.** 코드 커밋과 로그 커밋은 분리한다(로그 자체의 변경 이력을 깔끔하게 추적하기 위함).
- 각 항목은 **오더명 / 날짜 / 요청 요지 / 결과 요약 / 관련 커밋**을 포함한다.
- 순수 분석·검토(코드 변경 없음) 오더도 빠짐없이 기록한다 — 코드 변경 여부와 무관하게 "무엇을 지시받았고 무엇을 했는지"가 기록의 목적이다.
- 결과 요약은 산출물 목록이 아니라 **핵심 결론/판단**을 우선한다(상세는 각 오더가 만든 `docs/A*.md` 문서를 참조).

---

## 2026-06-25 ~ 06-26

### A-9.5: SESSION ENGINE staffId 타입 통일(TEXT → INTEGER)
- **요청**: A-9에서 기존 21개 테이블은 UUID→INTEGER로 통일했으나 A-8 SESSION ENGINE(4개 테이블)은 범위 밖이었던 staffId 컬럼들을 INTEGER로 통일.
- **결과**: `session_tables.dart` 3개 컬럼(`staffIdPrimary`, `PaymentSessionItems.staffId`, `StaffEarningLedgers.staffId`)을 TextColumn→IntColumn 변경, Repository/테스트 동기화. analyze 클린, 278건 테스트 통과.
- **커밋**: `2895cdc`(기존 커밋, 본 정리 작업 이전)

### A-10: Implementation Readiness Review(설계 검토)
- **요청**: 코드 수정 없이 Pricing/Promotion/StaffEarning/Settlement 엔진 경계, amount 필드 구조, A-11~A-13 순서, 누락된 가격 정책을 분석.
- **결과**: 4개 엔진 중 Settlement은 이미 구현됨, Pricing은 백지, Promotion은 구코드(marketing 모듈)에만 존재함을 확인. staffId TEXT/INTEGER 불일치를 HIGH 리스크로 식별(→ A-9.5로 즉시 해결됨).
- **커밋**: `8f08104`(기존 커밋)

### A-10 Pricing Engine MVP 구현
- **요청**: `pricing_rule` 테이블, `PricingRuleRepository`, `PricingEngine`(순수 계산), `SessionRepository` 최소 연동, 테스트.
- **결과**: 시간요금/피크할증 계산 구현. `addItem()` 흐름 무수정, `calcSuggestedTimeFee()` 선택적 헬퍼로 연동. 310건 테스트 통과.

### A-10 구현 리뷰 → 리팩토링(R1) → 문서화
- **요청**: Pricing Engine이 순수 계산 계층인지 검증 → Drift 의존(`PricingRuleRow` 직접 사용) 제거 → 아키텍처 문서/ADR 작성.
- **결과**: `PricingRule` POJO 도입, Drift는 Repository만 알도록 분리(ADR-001 확정). 피크 시간대 하드코딩을 Rule 데이터 기반으로 전환(40개 지점 지원). `docs/architecture/PRICING_ENGINE_ARCHITECTURE.md`, `ADR-001` 작성.

---

## 2026-06-26

### A-10.5: Discount Architecture 검토 → ADR-002 공식화
- **요청**: 할인을 `payment_session.discountAmount`(세션 단일값)로 할지 `PaymentSessionItem(discount)` 이벤트로 할지 결정.
- **결과**: 품목 레벨 이벤트 방식 채택 — A-8 품목 스냅샷 원칙과 일치, `closeSession()` 무수정 유지, 업종별 할인 단위 차이 표현 가능. `ADR-002` 작성.

### ADR-003: Financial Events 원칙 정립
- **요청**(A-11 설계 과정에서 자연 발생): 가격/할인/수익 등 모든 금전 변화는 헤더 컬럼 직접 갱신이 아니라 append-only 이벤트로 표현한다는 원칙을 일반화.
- **결과**: `ADR-003` 작성 — 이후 모든 엔진(Promotion/StaffEarning)이 이 원칙을 따름.

### A-11 Promotion Engine 설계(책임 경계/Lifecycle/조회 인터페이스/구현계획)
- **요청**: Promotion Engine 책임 경계(Pricing/Session/Settlement/StaffEarning과의 관계), Rule Lifecycle, 조회 인터페이스(M1 재발 방지), MVP 범위 확정.
- **결과**: Lifecycle을 `draft/active/disabled` 3상태+`Expired` 파생 판정으로 설계(`ADR-004`), `priority ASC, id ASC` 명시적 정렬 결정. `A11_PROMOTION_ENGINE_DESIGN.md`, `A11_IMPLEMENTATION_PLAN.md` 작성.

### A-11 Promotion Engine MVP 구현
- **요청**: `promotion_rule` 테이블, `PromotionRuleRepository`, `PromotionEngine`(flat/rate 계산), Session 연동, 테스트.
- **결과**: 355건 테스트 통과. `addItem()`/`closeSession()` 등 기존 흐름 무수정.

### A-11.5: Promotion Engine 확장 준비(복수 할인 구조 검토, 미구현)
- **요청**: 복수 할인 동시 적용을 안전하게 추가할 수 있는 구조만 검토(구현 안 함).
- **결과**: `PromotionResult` 확장 방향, 중첩 정책 4가지 비교(RuleType별 최대 1개 권장), Policy 계층 도입 시점 검토. 계산 기준 미결로 `ADR-005`(Stacking Policy)는 **작성 보류**. `A11_5_PROMOTION_EXPANSION_PLAN.md` 작성.

### A-11.9 ~ A-11.95: Staff Earning Architecture Review → Implementation Readiness
- **요청**: A-12 착수 전 계산 정책(할인 전/후 기준), 할인-StaffItem 연결구조, Ledger 갱신 시점 확정.
- **결과**: **할인 전 금액 기준** + **`closeSession()` 시점 1회 확정**(Snapshot) 채택 — 전제 1·2(타이밍/연결부재) 문제를 구조적으로 회피. `ADR-006` 작성. `A12_STAFF_EARNING_ARCHITECTURE.md`, `A12_IMPLEMENTATION_READY.md` 작성.

### A-12 Staff Earning Engine MVP 구현
- **요청**: `StaffEarningLedger`(Snapshot)/`StaffEarningResult`/`StaffEarningEngine` 구현, `closeSession()`에서만 Ledger 생성(`addItem()`에서 제거).
- **결과**: 368건 테스트 통과. 기존 즉시생성 로직 제거 후 `closeSession()`으로 이전.

### A-12.5 ~ A-12.7: Transaction Boundary / Concurrency 분석(미구현)
- **요청**: Financial Workflow의 Transaction 경계, State Machine, Idempotency, 동시성(Race Condition)을 분석만 수행.
- **결과**: `closeSession()`의 위험 구간을 5~8단계(결제수단insert~상태변경)로 특정. **동시 실행 시 Application Guard/Transaction만으로는 막을 수 없고 DB Constraint류만 면역**이라는 핵심 결론 도출(이때는 미해결로 남김). `A13_TRANSACTION_BOUNDARY_REVIEW.md`, `A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md`, `A13_CONCURRENCY_VALIDATION.md` 작성.

### A-12.9 ~ A-12.10: Impact Mapping → MVP Transaction Scope 확정
- **요청**: A-13 실제 변경 범위 식별, 최종 결정 확정.
- **결과**: **결정적 발견 — `closeSession()`을 호출하는 production 화면이 0건**(노출도 0). 이를 근거로 "A-13 MVP는 부분 실패 방지(Transaction 적용)만, 동시성 대응은 A-14 이후로 이관"이라는 범위 확정. `ADR-007` 작성. `A13_IMPACT_MAPPING.md`, `A13_IMPLEMENTATION_DECISION.md` 작성.

### A-12.11: Transaction Implementation Readiness(구현 직전 최종 검증)
- **요청**: ADR-007 적용 시 실제 수정 범위/Business Logic 무변경 여부 최종 확인.
- **결과**: "코드 이동 없이 래퍼 1개만 추가" 결론 — A-13 구현 착수 가능 확정. `A13_TRANSACTION_IMPLEMENTATION_READY.md` 작성.

### A-13: Transaction Boundary Implementation
- **요청**: ADR-007 범위(Settlement→Ledger→상태변경)를 `_db.transaction()`으로 감싼다.
- **결과**: `closeSession()` 내부 270~320행을 트랜잭션 콜백으로 래핑. 로직 무변경, 368건 테스트 통과(회귀 없음).

### A-13.5 ~ A-13.7: Workflow Extraction 사전 검토(미구현)
- **요청**: `closeSession()`의 Workflow Coordination 책임을 별도 클래스로 분리할 수 있는지 단계적으로 검증(의존성/인터페이스/계약 정합성).
- **결과**: Engine/Repository 책임 충돌 없음 확인, 단 "트랜잭션 경계를 보존하는 Workflow 인터페이스 형태"가 미결로 남음 — 이는 A-14 자체의 설계 작업 범위로 판단해 "착수 가능" 결론. `A14_WORKFLOW_EXTRACTION_READY.md`, `A14_WORKFLOW_INTERFACE_READY.md`, `A14_WORKFLOW_CONTRACT_VALIDATION.md` 작성.

### A-14 Phase 1: Workflow Extraction 구현
- **요청**: `closeSession()`의 트랜잭션 본문(Settlement→Ledger→상태변경)을 `SessionClosingWorkflow` 클래스로 추출, 호출 형태로 변경.
- **결과**: `lib/features/session/workflow/session_closing_workflow.dart` 신규. `closeSession()`은 검증→Workflow 호출→재조회만 수행. 368건 테스트 통과(회귀 없음).

### A-14 Phase 2~4: Dependency / Pattern / Trade-off Review(미구현)
- **요청**: 분리된 Workflow의 실제 의존성, 다른 Session 업무 재사용 가능성, Phase2/3에서 식별된 Review 항목이 수정 필요한 결함인지 Trade-off인지 최종 판정.
- **결과**: `SessionClosingWorkflow`가 `AppDatabase`를 직접 다루는 점(ADR-001과 표현상 어긋남)을 일관되게 식별 → 최종적으로 **"ADR-007 보존을 위한 의도된 Trade-off, Accepted"로 명시적 종결**. "현재 구조 유지 권장" 반복 확인. `A14_WORKFLOW_DEPENDENCY_VALIDATION.md`, `A14_WORKFLOW_PATTERN_VALIDATION.md`, `A14_ARCHITECTURE_TRADEOFF_REVIEW.md` 작성.

### A-15: Workflow Responsibility Refinement Analysis(미구현)
- **요청**: A-14 이후 구조를 기준으로 책임 경계 재정리, "이전과 동일" 항목은 반복분석 금지 원칙 적용.
- **결과**: 새로 평가한 것은 "테스트 영향 가능성" 1개 항목뿐(Unknown으로 정직하게 기록). "Workflow Responsibility Refinement 확인 완료". `A15_WORKFLOW_RESPONSIBILITY_REFINEMENT.md` 작성.

### A-16: Architecture Finalization Analysis(미구현)
- **요청**: 구조가 최종 고정 가능한 상태인지 종합 판단.
- **결과**: 추가 Workflow/DI 변경/Repository 재설계 전부 불필요 확인. **"Architecture Finalization Completed"**. `A16_ARCHITECTURE_FINALIZATION.md` 작성.

### A-17: Architecture Operational Stability Check(미구현)
- **요청**: 설계가 아닌 **운영(런타임) 관점**에서 구조 안정성 확인.
- **결과**: rollback 보장이 "실제 장애 주입 실증이 아니라 Drift/SQLite의 문서화된 보장에 근거한 판단"임을 명확히 구분해 기록. **"Architecture Operational Stability Confirmed"**(단서 포함). `A17_OPERATIONAL_STABILITY_CHECK.md` 작성.

---

## 2026-06-29 ~ 06-30

### A-18.1: Idempotency Stability Analysis(미구현)
- **요청**: `closeSession()` 중복 호출 시 데이터 중복 생성 여부 확인.
- **결과**: **"순차 재시도는 안전, 진짜 동시 호출은 안전하지 않음"(Partial)** — 패턴을 맞추기 위해 "Confirmed"로 왜곡하지 않고 정직하게 조건부 결론을 냄. 가드(`session.status` 체크)가 Transaction 밖에 있다는 TOCTOU 레이스가 A-12.7 이후 해소되지 않은 채 남아 있음을 재확인. `A18_1_IDEMPOTENCY_STABILITY_ANALYSIS.md` 작성.

### A-18.2: Minimal Change Resolution Analysis(미구현)
- **요청**: A-18.1에서 확인된 Race Condition을 가장 작은 변경으로 해결할 방법 1개 선정(설계만, 구현 안 함).
- **결과**: **Conditional Update**(`UPDATE ... WHERE status='open'` + 영향 행 수 확인) 선정 — "Transaction 내부 재확인" 대비 더 적은 가정(SQLite 단일 문장 원자성만 의존)으로 같은 목적 달성. `A18_2_MINIMAL_CHANGE_RESOLUTION_ANALYSIS.md` 작성.

### A-18.3: Conditional Update Implementation
- **요청**: A-18.2에서 선정된 방법만 실제 구현.
- **결과**: `SessionClosingWorkflow`의 상태 변경 `UPDATE` 문에 `status='open'` 조건 추가, 영향 행 0이면 기존 `BusinessRuleException` 재사용. 1개 파일, 1개 문장만 변경. 368건 테스트 통과.

### A-18.4: Race Condition Verification Test
- **요청**: `Future.wait()`로 `closeSession()` 동시 호출 테스트 작성, Conditional Update가 실제로 동작하는지 검증.
- **결과**: 동시 호출 시 1건 성공+1건 `BusinessRuleException`, Settlement/Ledger 중복 없음, 상태 1회만 갱신됨을 실제로 확인. **"Race Condition Verification Completed"**(단, Dart 단일 isolate 협력적 동시성 범위 안에서의 검증이며 멀티프로세스 경쟁은 범위 밖임을 명시). 369건 테스트 통과.

---

## 2026-06-30

### (작업 로그/커밋 정리) 6월 작업 전체 정리 + 작업 로그 운영 규칙 도입
- **요청**: A-9.5~A-18.4까지 쌓인 미커밋 변경사항과 오더 내역을 정리해서 커밋. 앞으로도 매 작업 종료 시 오더/결과를 별도로 기록.
- **결과**: 누적 변경(80개+ 파일)을 의미 단위 5개 커밋(A-10/A-11/A-12/A-13~18.4/작업로그)으로 정리해 push. 본 `WORK_LOG.md` 신규 작성, "매 오더 완료 시 항목 추가+별도 커밋" 규칙을 메모리에 저장.
- **커밋**: `1fc9d06`, `3c11deb`, `128a3b7`, `6cc7bb9`, `0b06b6f`

### A-19: Session Closing Baseline Documentation
- **요청**: A-14~A-18에서 확정된 Session Closing 구조(Repository/Workflow/Engine/Transaction Boundary)를 `docs/baseline/SESSION_CLOSING_BASELINE.md`로 공식 문서화(새 분석/설계 없음, 기존 문서·코드 확인만).
- **결과**: 구조/설계 결정/검증 결과(5개 항목 전부 Completed)/향후 개발 기준 정리. **"Session Closing Baseline Established"**. 369건 테스트 통과.
- **커밋**: `15296f1`

### A-20: Booking Engine Domain Analysis
- **요청**: Booking Engine 구현 전 도메인 구조 분석 + Session Closing Baseline과의 연계 방식 확인(분석만, 구현 없음).
- **결과**: 기존 `BookingRepository`/`Bookings`/`WaitingEntries`는 이미 구현돼 있으나, A-8 설계 시점부터 자리만 마련된 `refType='booking'` 연결은 실제 호출 코드가 0건임을 확인. Booking은 Session 생성 이전 단계라 **No Baseline Impact**. Phase 1 최소 범위를 "기존 설계된 연결 지점을 실제로 호출하는 것" 하나로 좁힘. **"Booking Engine Domain Analysis Completed"**. 369건 테스트 통과(코드 변경 없음).
- **커밋**: `1982bad`

### A-21: Booking → Session Integration Point Analysis
- **요청**: A-20 결과를 바탕으로 Booking Domain과 Session Engine을 연결해야 하는 정확한 Integration Point 확정(분석만, 구현 없음).
- **결과**: Booking 7개 이벤트 전부 Session 생성을 트리거하지 않음을 재확인. **A-8 설계의 `refType='booking'` 연결은 `PaymentSessions`가 아니라 `PaymentSessionItems` 컬럼**이라는 정밀한 사실을 확인 — Integration Point는 `createSession()` 단독이 아니라 `createSession()`+`addItem()`의 조합. Baseline 영향 없음(No Baseline Impact), 새 Repository/Workflow/Engine/Table 전부 불필요. **"Booking Session Integration Point Analysis Completed"**. 369건 테스트 통과(코드 변경 없음).
- **커밋**: `5f847a0`

### A-22: Booking Session Call Site Analysis
- **요청**: Booking 완료 이후 `createSession()`→`addItem(refType='booking', refId=...)`를 실제로 어느 위치에서 호출해야 하는지 호출 지점 1개 확정(분석만, 구현 없음).
- **결과**: `completeBooking()` 자체를 호출하는 곳이 `createSession()`처럼 0건임을 확인. `completeBooking()` docstring이 인용한 기존 원칙(`A1_A2_BOUNDARY.md`) — "완료 처리 메서드 자신이 아니라 그 호출자가 도메인 간 연결 책임을 진다" — 을 발견하고, `payment_repository.dart`의 `PaymentRepository→CustomerRepository.recordVisit()` 호출을 실제 선례로 확인. 이에 따라 Session 생성 호출 위치를 **"`completeBooking()`을 호출하는 지점"**(아직 코드에 없음 — A-23에서 신설 대상)으로 확정. **"Booking Session Call Site Established"**. 369건 테스트 통과(코드 변경 없음).
- **커밋**: `09e297c`

---

## 누적 산출물 요약(2026-06-25 ~ 06-30)

- **ADR**: `ADR-001`(Pricing Engine Domain Isolation) ~ `ADR-007`(A-13 MVP Transaction Scope), 총 7개(`ADR-005`는 보류로 미작성)
- **신규 모듈**: `lib/features/pricing/`, `lib/features/promotion/`, `lib/features/staff_earning/`, `lib/features/session/workflow/`
- **DB 스키마**: `schemaVersion` 3 → 6(`pricing_rule`, `promotion_rule` 테이블 추가, 모두 순수 추가형 마이그레이션)
- **테스트**: 278건(A-9.5 시점) → 369건(A-18.4 시점)
- **핵심 아키텍처 결정**: Engine은 항상 순수 계산(Drift 비의존), Repository만 Drift를 안다(ADR-001) / 금전 변화는 이벤트로 기록, 헤더는 파생값(ADR-003) / 할인은 품목 이벤트(ADR-002) / 직원 수당은 할인 전 기준+마감 시점 확정(ADR-006) / Settlement~상태변경은 단일 Transaction(ADR-007)
