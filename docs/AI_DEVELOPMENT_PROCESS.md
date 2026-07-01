# AI Collaboration Development Process

> 이 문서는 이 프로젝트에서 실제로 따른 AI 협업 개발 프로세스를 기록한다. 새로운 규칙을 만들지 않는다 — A-20~A-25 시리즈에서 실제로 수행한 절차를 명문화한 것이다.
> **See Also**: `docs/README.md`, `docs/DEVELOPMENT_CHECKLIST.md`, `docs/WORK_LOG.md`

---

## 개발 사이클 개요

```
Analysis
  ↓
Design Decision
  ↓
Implementation
  ↓
Verification
  ↓
Documentation
```

각 단계를 순서대로 진행하며, 한 단계에서 막히면 다음 단계로 넘어가지 않고 "추가 오더 필요"로 기록한 뒤 설계 단계로 돌아간다.

---

## Analysis 단계

> **A-25.8 추가 설명**: Analysis 단계는 두 단계를 하나의 상위 단계로 표현한 것이다.
>
> - **Domain Analysis**: 현재 코드베이스에서 관련 도메인의 모든 구조(테이블, Repository, 화면, 라우트)를 실제 코드 기준으로 확인한다.
> - **Integration Analysis**: 도메인 간 연결 지점, 데이터 소유권, 호출 경로를 현재 코드와 기존 문서를 기준으로 분석한다.

규칙:
- 추론이 아니라 실제 코드(`grep`/파일 읽기)로 근거를 확인한다.
- 결과가 "선정 불가"/"Not Implemented"일 경우 그대로 기록한다 — 패턴 맞추기 위해 억지로 "완료"로 표시하지 않는다(A-23, A-25 1차 시도의 선례).

---

## Design Decision 단계

규칙:
- 새로운 구조를 발명하지 않는다 — 기존 코드베이스에 이미 있는 패턴과 원칙을 우선 참조한다.
- 설계 결정은 `docs/DECISION_HISTORY.md`에 기록한다.
- 계약이 잠기면(`Locked`) 구현 단계에서 임의로 변경하지 않는다.
- 기존 문서(ADR, Baseline)와 충돌하면 구현 착수 전에 충돌을 먼저 해소한다.

---

## Implementation 단계

규칙:
- 잠긴 계약(`A24~A24.8`)만 구현한다. 계약에 없는 내용은 추론으로 채우지 않는다.
- 구현 도중 새로운 계약 충돌을 발견하면 즉시 중단하고 "추가 오더 필요"를 기록한다(PART7 규칙).
- 기존 Repository/Engine/Workflow를 수정하지 않는 것을 원칙으로 한다(Minimal Change).
- "더 좋은 구조" 아이디어는 현재 구현에 포함하지 않고 `docs/MARK2_IDEAS.md`에만 기록한다.

---

## Verification 단계

규칙:
- `flutter analyze` — 0 issues 필수.
- `flutter test` — 전체 기존 테스트 Pass + 신규 테스트 Pass 필수.
- 회귀가 발생하면 Business Logic을 바꾸지 않고 구조 변경 범위만 수정한다.

---

## Documentation 단계

규칙:
- 작업 완료 후 반드시 커밋 + push(기존 메모리 규칙: "작업 완료 후 항상 git commit + push").
- `docs/WORK_LOG.md`에 오더 항목을 추가하고 별도 커밋한다(A-26 운영 규칙).
- Milestone 완료 시 `docs/ARCHITECTURE_SUMMARY.md`와 `docs/DECISION_HISTORY.md`를 갱신한다.
