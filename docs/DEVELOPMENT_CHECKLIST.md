# Development Checklist

> 기능 구현 완료 후 커밋 전에 확인하는 체크리스트. 이 프로젝트에서 실제로 따른 원칙을 명문화한 것이다 — 새로운 규칙을 추가하지 않는다.
> **See Also**: `docs/README.md`, `docs/AI_DEVELOPMENT_PROCESS.md`, `docs/DECISION_HISTORY.md`, `docs/ARCHITECTURE_SUMMARY.md`

---

## 구현 완료 체크리스트

### 코드 품질

- [ ] `flutter analyze` — 0 issues (info 레벨 포함 없음)
- [ ] `flutter test` — 전체 기존 테스트 통과, 회귀 없음
- [ ] 신규 기능에 대한 테스트가 존재하고 통과함

### 설계 준수

- [ ] 잠긴 계약(`Locked Contract`)을 변경하지 않았다
- [ ] 기존 Repository/Engine/Workflow를 수정하지 않았다(Minimal Change)
- [ ] 새로운 Architecture/Layer/패턴을 추론으로 도입하지 않았다
- [ ] `docs/baseline/SESSION_CLOSING_BASELINE.md` Baseline에 영향을 주지 않았다

### 문서 갱신

- [ ] `docs/WORK_LOG.md`에 이번 오더 항목을 추가했다
- [ ] 설계 결정이 내려진 경우 `docs/DECISION_HISTORY.md`를 갱신했다
- [ ] Milestone 완료 시 `docs/ARCHITECTURE_SUMMARY.md`와 Milestone 문서를 갱신했다

### MARK2 관리

- [ ] 구현 도중 발견한 개선 아이디어를 `docs/MARK2_IDEAS.md`에 기록했다
- [ ] MARK2 항목을 이번 구현에 포함하지 않았다

### Git

- [ ] 코드 변경 커밋 완료
- [ ] `docs/WORK_LOG.md` 갱신 커밋 완료(별도 커밋)
- [ ] `git push origin main` 완료

---

## 설계 결정 변경 체크리스트

설계를 변경해야 할 경우 추가로 확인한다.

- [ ] 기존 ADR과 충돌하지 않는다
- [ ] `docs/DECISION_HISTORY.md`에 변경 사유를 기록했다
- [ ] 관련 계약 문서(A24.x 시리즈 등)를 갱신했다
- [ ] 해당 변경이 Session Closing Baseline에 영향을 주지 않는다

---

## 모든 신규 기능은 이 체크리스트를 따른다

프로세스 세부: `docs/AI_DEVELOPMENT_PROCESS.md` 참조.
