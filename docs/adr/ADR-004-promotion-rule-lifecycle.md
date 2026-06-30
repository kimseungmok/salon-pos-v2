# ADR-004: Promotion Rule Lifecycle

- **상태**: Accepted
- **시점**: A-11 구현 착수 전 최종 아키텍처 정리
- **관련 문서**: `docs/A11_IMPLEMENTATION_PLAN.md` PART 1, `docs/A11_PROMOTION_ENGINE_DESIGN.md`, `ADR-002-discount-representation.md`, `ADR-003-financial-events.md`

## 배경(Context)

`PromotionRule`은 가격 규칙(`PricingRule`)과 달리, 캠페인성 데이터(쿠폰·회원할인 등)라는 특성상 "지금 당장 적용 가능"과 "아직 검수 중" 같은 중간 상태, 그리고 "기간이 끝나서 더 이상 적용되지 않음"이라는 시간 종속적 상태가 필요하다. `PricingRule`의 단순한 `isActive: bool`로는 이를 표현할 수 없었다.

설계 단계에서 `Draft → Active → Expired → Disabled` 4단계 Lifecycle이 요구됐고, 동시에 **"`Applied`라는 5번째 상태를 추가하면 안 된다"**는 제약이 명시됐다 — Rule이 "적용됐다"는 사실은 `PaymentSessionItem(itemType='discount')`라는 **이벤트**로 기록되는 것이며(ADR-002), Rule 자체의 상태가 아니다. 이 구분을 명확히 하지 않으면 "Rule 상태"와 "이벤트 발생 여부"가 같은 컬럼/같은 모델로 뒤섞일 위험이 있었다.

## 결정(Decision)

1. **저장되는 상태는 3개뿐이다**: `promotion_rule.status ∈ {'draft', 'active', 'disabled'}`.
2. **`Expired`는 저장된 상태가 아니라 조회/계산 시점에 평가되는 파생 판정이다**: `status='active' AND now ≥ endAt`이면 "효과적으로 Expired"로 취급한다. 별도의 배치/크론으로 `status`를 `'expired'`로 바꾸는 절차는 두지 않는다.
3. **`Applied`는 Lifecycle에 포함하지 않는다.** Rule이 적용된 사실은 전적으로 `PaymentSessionItem`(이벤트)의 존재로 표현되며, `PromotionRule`은 자신이 몇 번 적용됐는지조차 알 필요가 없다.
4. **상태 전이는 `Draft→Active`(`activate()`)와 `(Active|Expired)→Disabled`(`deactivateRule()`, 멱등) 두 가지뿐이며, `Disabled`가 유일한 종착 상태다.**
5. **`Active` 상태에서는 `discountType`/`value`를 수정할 수 없다** — 이미 effective한 정책의 의미가 운영 중 바뀌는 것을 막는다(이벤트 자체는 스냅샷을 보존하므로 데이터 무결성 문제는 아니지만, 운영 투명성을 위해 금지한다).

## 근거

- **자동 만료에 배치 작업이 필요 없다.** 오프라인 우선 SQLite 단일 인스턴스 앱에서 "만료 시각이 되면 행을 갱신하는" 백그라운드 작업을 만드는 것은 불필요한 인프라다. 조회 시점 판정으로 같은 효과를 얻는다 — 이는 `PricingEngine.isWithinPeakWindow()`가 이미 증명한 "시간 판정은 매칭 시점에 즉석으로 한다"는 패턴과 정확히 같은 원리다.
- **"Rule 상태"와 "이벤트 발생"을 같은 모델에 두지 않는 것이 ADR-003(Financial Events)과 직접 연결된다.** Rule은 "정책"이고 `PaymentSessionItem`은 "사실(무엇이 실제로 일어났는가)"이다. `Applied`라는 상태를 Rule에 추가하면 "정책 객체가 자신이 몇 번 쓰였는지 알아야 하는" 잘못된 책임이 생긴다 — Rule은 정책만 갖고, 사실은 이벤트가 갖는다는 경계가 흐려진다.
- **`Disabled`를 유일한 종착 상태로 고정**한 것은, 과거에 적용된 이벤트가 참조하는 Rule의 데이터가 "다시 살아나서" 의미를 바꾸는 시나리오를 원천적으로 막기 위함이다(`Expired→Active`나 `Disabled→Active` 같은 역행 전이를 만들지 않는다 — 다시 쓰려면 새 `Draft` Rule을 만든다).

## 결과(Consequences)

**장점**
- 배치/스케줄러 없이 정확한 "지금 적용 가능한가" 판정이 가능하다.
- Rule(정책)과 이벤트(사실)의 책임이 명확히 분리되어, ADR-003의 원칙이 Promotion Engine에도 무리 없이 적용된다.

**비용/트레이드오프**
- `Expired`가 컬럼 값으로 직접 보이지 않으므로, 운영자가 Rule 목록 화면에서 "만료된 것"을 구분하려면 화면 단에서 `endAt`을 같이 계산해 보여줘야 한다(저장된 값만 보고는 알 수 없음) — UI 구현 시 유의할 점으로 남긴다.
