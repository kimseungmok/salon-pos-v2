# Project Roadmap

> A-20~A-25 완료 시점(2026-07-01)의 스냅샷.
> 각 단계의 세부 내용은 `docs/WORK_LOG.md`와 개별 설계 문서(`docs/A*.md`)를 참조.

---

## ✅ Completed

### Booking → Session Integration Series (A-20 ~ A-25)

| 단계 | 내용 | 결과 |
|---|---|---|
| A-20 | Booking Engine Domain Analysis | Booking Domain 확인, 기존 구조 파악 |
| A-21 | Booking → Session Integration Point Analysis | `refType='booking'`는 `PaymentSessionItems` 레벨(addItem) 설계임을 확인 |
| A-22 | Booking Session Call Site Analysis | `A1_A2_BOUNDARY.md` 원칙으로 호출 위치 확정(`completeBooking()` 호출자가 책임) |
| A-23 | Booking Completion Orchestrator Analysis | 기존 구조 후보 전부 Rejected → 선정 불가(단, 설계 원칙으로 방향 확정) |
| A-24 | Booking Completion Caller Design | 단일 Caller 클래스 도입 결정, 파일 위치·DI 구조 확정 |
| A-24.5 | Data Ownership & Mapping Contract | businessType=외부주입, roomId=항상 null, Product 매핑 규칙 확정 |
| A-24.6 | Product Retrieval Strategy | `watchProducts().first` + 메모리 매칭 전략 확정 |
| A-24.7 | Session Item Contract Verification | `itemType: Product.id` 오기 발견 → `'service'`로 정정 |
| A-24.8 | Session Item Persistence Contract Verification | 저장 구조와 계약 일치 확인(Conflict 0건), A-25 즉시 구현 가능 선언 |
| A-25 | Booking Completion Caller Implementation | `BookingCompletionCaller` 구현, 테스트 4건, 373건 전체 통과 |

---

### 이전 완료 시리즈

| 시리즈 | 범위 | 주요 결과물 |
|---|---|---|
| A-8 SESSION ENGINE | 공통 전표 엔진 설계·구현 | `PaymentSessions`/`PaymentSessionItems`/`StaffEarningLedgers`/`PaymentMethodBreakdowns` |
| A-9/A-9.5 | ID 통일(UUID→INTEGER) | 전 도메인 21개 테이블 마이그레이션 |
| A-10 | Pricing Engine MVP | `PricingEngine`, `PricingRuleRepository`, ADR-001 |
| A-11 | Promotion Engine MVP | `PromotionEngine`, `PromotionRuleRepository`, ADR-002/003/004 |
| A-12 | Staff Earning Engine MVP | `StaffEarningEngine`, ADR-006 |
| A-13 | Transaction Boundary | `closeSession()` 단일 트랜잭션 적용, ADR-007 |
| A-14 | Workflow Extraction | `SessionClosingWorkflow` 분리 |
| A-15~A-18 | 아키텍처 검증/안정화 | Idempotency, Race Condition(Conditional Update), Baseline 확정 |
| A-19 | Session Closing Baseline | `docs/baseline/SESSION_CLOSING_BASELINE.md` |

---

## 🔜 Next

### 단기 후속 작업

| 단계(가칭) | 목적 |
|---|---|
| **A-26** Booking Integration Test | `BookingCompletionCaller`가 실제 UI 호출 경로에서도 정상 동작하는지 통합 검증 |
| **A-27** Regression Verification | A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정 |
| **A-28** Booking Flow Documentation | Booking 완료 → Session 생성 흐름의 운영자용 문서(예: 어떤 UI 이벤트가 `complete()`를 호출해야 하는지 등) 정리 |

---

## 🔭 Future

### 중·장기 검토 항목

| 분류 | 내용 |
|---|---|
| **MARK2 Review** | `docs/MARK2_IDEAS.md`에 기록된 3개 아이디어(단건 조회 메서드 추가, 병렬 `addItem()`, 미매칭 상품 명시적 정책) 우선순위 검토 |
| **Technical Debt Review** | A-11.5에서 식별한 복수 Promotion 중첩 정책(ADR-005 미작성으로 보류됨), TOCTOU 대응(ADR-007에서 의도적으로 이관된 동시성 대응) 처리 |
| **Architecture Refactoring Candidate** | `BookingRepository`에 단건 조회 메서드 부재로 Caller가 `BookingRow`를 pre-fetch해야 하는 구조 개선(MARK2 항목 1번) |
