# A-29 Regression Baseline

> **목적**: A-29(Milestone 2 BookingCompletionCaller UI Integration) 구현 완료 이후의 테스트 기준선을 문서화한다. 새 분석/설계 없음 — 실제 Commit과 Verification 결과만 기록한다.
> **대상 Commit**: `98defb3` (feat: A-29 BookingCompletionCaller UI Integration)
> **근거 문서**: `docs/A30_IMPLEMENTATION_VERIFICATION.md`, `docs/WORK_LOG.md` A-29/A-30 항목
> 작성일: 2026-07-08

---

## PART 1 — A-29 변경 범위

| 변경 파일 | 변경 유형 | 내용 |
|---|---|---|
| `lib/features/booking/providers.dart` | 기존 파일 수정 | `bookingCompletionCallerProvider` 추가 |
| `lib/features/booking/screens/booking_list_screen.dart` | 신규 파일 | `BookingListScreen` — 예약 완료 처리 화면 |
| `lib/core/router.dart` | 기존 파일 수정 | `/waiting/bookings` 서브라우트 추가 |
| `lib/features/booking/screens/waiting_list_screen.dart` | 기존 파일 수정 | 予約完了 버튼 → `/waiting/bookings` push |
| `lib/features/booking/data/booking_repository.dart` | 기존 파일 수정 | `getBookingById(int id) → Future<BookingRow?>` 추가 |

---

## PART 2 — Baseline 테스트 결과

| 항목 | 결과 | 근거 |
|---|---|---|
| `flutter analyze` | **Pass — No issues found** | Commit `98defb3` 직후 실측 |
| `flutter test` 전체 | **Pass — 372건 All tests passed** | Commit `98defb3` 직후 실측 |
| 회귀 여부 | **회귀 없음** | A-28.5 이전 기준선(372건)과 동일 |

---

## PART 3 — 테스트 구성 현황

| 범위 | 테스트 수 | 비고 |
|---|---|---|
| A-29 신규 테스트 | 0건 | Design에 명시된 테스트 없음(WORK_LOG A-29 기록) |
| 기존 테스트 전체 | 372건 | A-29 구현 후 회귀 없음 확인 |
| `BookingListScreen` 테스트 | 없음 | A-30 Verification Gap으로 기록됨 |

---

## PART 4 — 미구현 항목 (이번 Baseline 대상 제외)

| 항목 | 상태 | 근거 |
|---|---|---|
| D-8 `Future.wait()` 병렬화 | 미구현 | "Future.wait 전략 변경 금지" 규칙 적용 |
| D-9 silent skip → 명시적 정책 | 미구현 | "Logging 정책 추가 금지" 규칙 적용 |
| `BookingListScreen` 위젯/통합 테스트 | 미구현 | Design에 명시 없음 |
