# ADR-007: A-13 MVP Transaction Scope

- **상태**: Accepted
- **시점**: A-12.10 Financial Workflow Decision Review(A-13 착수 직전)
- **관련 문서**: `docs/A13_IMPLEMENTATION_DECISION.md`(상세 근거), `docs/A13_TRANSACTION_BOUNDARY_REVIEW.md`(A-12.5), `docs/A13_FINANCIAL_WORKFLOW_STATE_ANALYSIS.md`(A-12.6), `docs/A13_CONCURRENCY_VALIDATION.md`(A-12.7), `docs/A13_IMPACT_MAPPING.md`(A-12.9)

## 배경(Context)

A-12.5부터 A-12.9까지 네 차례의 설계 리뷰를 거치며, `closeSession()`의 안전성에 관해 두 가지 서로 다른 종류의 문제가 식별됐다:

1. **부분 실패(Partial Failure)**: 결제수단 insert~Ledger insert~상태 변경 사이에 예외/앱 종료/전원 종료가 발생하면, 세션이 `open` 상태로 남은 채 일부 금전 데이터만 저장된 상태가 된다(A-12.6). 이 상태에서 재호출하면 이미 저장된 데이터가 중복 생성된다.
2. **동시 실행(Concurrency)**: 같은 세션에 대해 `closeSession()`이 진짜로 겹쳐서 호출되면(Thread A/B, UI 중복 클릭), 두 호출 모두 "아직 `open`"이라는 같은 판단을 내린 뒤 각자 끝까지 진행해 데이터가 중복된다(A-12.7) — 이는 TOCTOU(Time-Of-Check to Time-Of-Use) 레이스이며, Application Guard나 단순 Transaction만으로는 해결되지 않는다(A-12.7 PART2에서 확인 — DB Constraint류만 진짜 동시성에 면역).

A-12.9(Impact Mapping)에서 실제 코드를 조사한 결과, **`closeSession()`을 호출하는 production 코드(화면)가 현재 0건**이라는 사실이 확인됐다 — Session Engine(A-8~A-12) 전체가 아직 어떤 UI에도 연결되지 않았다. 이는 문제 2(동시 실행)의 **현재 실제 노출도가 0**이라는 뜻이다(겹쳐서 호출할 호출자가 없음). 반면 문제 1(부분 실패)은 단일 호출자만으로도(앱 종료/전원 종료) 발생 가능해, UI가 연결되는 즉시 실현 가능성이 높다.

## 결정(Decision)

**A-13 MVP는 문제 1(부분 실패)만 해결한다.** `closeSession()`의 Settlement insert(결제수단 기록) ~ Session 상태 변경 구간을 단일 Drift Transaction으로 묶는다. 문제 2(동시 실행/TOCTOU)에 대한 대응(조건부 UPDATE, DB Constraint, Idempotency Key)은 **A-13 MVP에서 구현하지 않고 A-14 이후로 명시적으로 이관한다.**

## 결정 근거

- **위험도와 노출도가 다르다.** 문제 1은 노출도가 이미 높다(단일 사용자, 앱 종료만으로 발생). 문제 2는 호출자가 없어 노출도가 0이다 — 지금 막대한 설계/구현 비용을 들여 문제 2를 풀어도 실제로 막아주는 사고가 없다.
- **이미 검증된 선례로 즉시 구현 가능하다.** `lib/features/payment_pos/data/payment_repository.dart:262`의 `cancelOrder()`가 정확히 같은 패턴(조회→분기→복수 쓰기)을 `_db.transaction()`으로 감싸는 선례를 갖고 있다(A-12.9 PART4) — 새로운 패턴을 도입하지 않고 기존 코드베이스 관례를 재사용한다.
- **문제 2의 해법(조건부 UPDATE 등)은 워크플로 순서 재배치를 동반하는 더 큰 변경이다.** 이를 지금 같이 처리하면 A-13의 범위가 불필요하게 커지고, "보통/어려운 작업"(A-12.9 PART6)을 미해결 설계 질문(State Machine 후보, DB Constraint 키 설계)과 함께 한 번에 떠안게 된다.
- **이연이 안전하다 — 단, 조건이 있다.** 문제 2를 미루는 근거(호출자 없음)는 영구적이지 않다. UI가 `closeSession()`을 호출하게 되는 시점 이전에 반드시 재평가해야 한다는 조건을 명시적으로 남긴다.

## 결과(Consequences)

**장점**
- A-13이 가장 시급한 문제(부분 실패)부터 작고 검증된 변경으로 해결 가능하다.
- A-12.6/A-12.9에서 이미 충분히 분석된 경계(Settlement~상태변경)를 그대로 적용하므로 추가 설계 논의가 필요 없다.

**비용/트레이드오프**
- A-13 완료 후에도 동시 실행(TOCTOU) 위험은 **코드상 그대로 남는다** — 이는 알려진 채로 남겨두는 부채이며, "해결됐다"고 오인하지 않도록 주의가 필요하다.
- **재평가 트리거를 반드시 추적해야 한다**: Session Engine을 호출하는 화면이 추가되는 작업(어떤 A-번호든) 착수 시, 본 ADR과 `A13_CONCURRENCY_VALIDATION.md`를 다시 참조해 동시성 대응 여부를 재결정해야 한다. 이 재평가를 누락하면 "노출도 0"이라는 전제가 깨진 채로 위험이 실제 사고로 이어질 수 있다.
