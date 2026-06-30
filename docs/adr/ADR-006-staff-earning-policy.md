# ADR-006: Staff Earning Policy

- **상태**: Accepted
- **시점**: A-11.9 Staff Earning Architecture Review(A-12 착수 전)
- **관련 문서**: `docs/A12_STAFF_EARNING_ARCHITECTURE.md`(상세 비교 분석), `ADR-001`(Domain Isolation), `ADR-003`(Financial Events)

## 배경(Context)

A-11.5에서 식별된 3가지 전제 — (1) `staff_earning_ledger` 갱신 타이밍 문제, (2) 할인 Item과 `staff_fee` Item 사이의 `refId` 연결 부재, (3) Promotion MVP는 단일 Rule만 적용 — 가 A-12 착수를 막고 있었다. `docs/A12_STAFF_EARNING_ARCHITECTURE.md`에서 이 3가지를 모두 고려해 계산 정책(할인 전/후 기준 × 품목/세션 단위 귀속)과 Ledger 갱신 시점(즉시/마감/Settlement)을 비교했고, 둘 다 하위 미결 질문 없이 자기완결적인 권장안으로 귀결됐다.

## 결정(Decision)

1. **Staff Earning 계산은 할인 전(原) 금액을 기준으로 한다.** 할인이 적용된 세션이라도, 직원 수익 산정은 `staff_fee`/`service` 품목의 원래 `amount`를 그대로 사용한다 — 할인은 Staff Earning 계산에 영향을 주지 않는다.
2. **Ledger는 `closeSession()` 시점에 1회 계산·확정된다.** 현재의 `addItem()` 즉시 생성 방식을 폐기하고, 세션이 마감될 때 그 시점의 `PaymentSessionItem` 전체 목록으로부터 결정적으로 계산해 기록한다.
3. **할인-Staff Item 연결 구조(`refType='session_item'`)는 설계만 확정하고 A-12 MVP에서는 구현하지 않는다** — 결정 1을 따르면 할인이 Staff Earning에 영향을 주지 않으므로 이 연결이 당장 불필요하다. 향후 "할인 후 기준"으로 전환할 때를 위한 사전 합의로만 남긴다.

## 결정 근거

- **전제 1·2를 동시에, 구조적으로 회피한다.** "할인 전 기준"을 택하면 타이밍 문제(언제 재계산할지)와 연결 부재 문제(어떤 할인이 어떤 품목을 타겟팅하는지)가 둘 다 발생하지 않는 조건이 된다 — 둘을 "해결"하는 게 아니라 "해당 안 되게 만드는" 선택이다.
- **확장성이 가장 높다.** A-11.5에서 식별된 복수 Promotion 중첩 문제(여러 할인이 동시에 한 직원의 매출에 영향을 줄 때의 배분 알고리즘)가 이 정책 하에서는 발생하지 않는다 — Promotion Engine이 단일 Rule에서 다중 Rule으로 확장돼도 Staff Earning Engine은 영향을 받지 않는다.
- **`closeSession()` 시점 확정은 ADR-003(Financial Events)을 코드 레벨에서 완전히 만족시킨다.** 현재 `addItem()` 즉시 생성 방식은 "그 순간의 잠정값"을 확정된 사건처럼 저장한다는 점에서 ADR-003의 "이벤트는 사실이고 불변"이라는 원칙과 미묘하게 어긋나 있었다(실행 격차, `A12_STAFF_EARNING_ARCHITECTURE.md` §5). 마감 시점 1회 확정으로 전환하면 이 격차가 사라진다.
- **오프라인 우선 아키텍처와 맞다.** 이 앱은 단일 SQLite 인스턴스이므로 "마감"이라는 명확한 단일 트리거 지점이 이미 존재한다(`closeSession()`) — 별도의 배치/크론 없이 그 지점 하나만 재사용하면 충분하다(ADR-004의 "자동 만료를 조회 시점에 즉석 판정"과 동일한 사고방식 — 별도 인프라를 만들지 않는다).

## 결과(Consequences)

**장점**
- A-12 구현이 가장 낮은 리스크로 시작 가능하다 — 계산 로직 자체는 현재 `addItem()`이 하던 것과 결과적으로 동일한 값을 만들어내므로, 새로운 계산 알고리즘을 발명할 필요가 없다.
- Ledger Rebuild/Event Replay가 가능해진다(`A12_STAFF_EARNING_ARCHITECTURE.md` §5).

**비용/트레이드오프**
- **이것은 사업 정책 결정이다.** "할인이 인건비에 영향을 주지 않는다"는 선택은 기술적으로만 내릴 수 있는 결정이 아니며, 점주/운영 정책 결정자가 이 트레이드오프(직원 동기부여 우선 vs 회사 마진 보호)를 인지하고 동의해야 한다. 본 ADR은 기술 아키텍처 관점의 권장안이지, 경영 판단을 대신하지 않는다.
- Ledger가 마감 전까지 비어있다 — 마감 전 세션을 조회하는 화면(예: 영업 중 실시간 매출/수당 현황)이 있다면, "아직 확정 안 됨"을 구분해 보여줘야 한다.
- 향후 "할인 후 기준"으로 전환하려면 `refType='session_item'` 연결 구조(`A12_STAFF_EARNING_ARCHITECTURE.md` PART 3 방식 1)를 그때 가서 구현해야 한다 — 본 ADR은 그 가능성을 막지 않지만, 지금 미리 만들어두지 않는다(YAGNI).
