# Milestone 1: Booking → Session Integration Foundation

> **공식 완료 확인일**: 2026-07-01
> **상태**: ✅ Completed

---

## 1. Milestone 이름

**Booking → Session Integration Foundation**

---

## 2. 목표

살롱 POS의 예약(Booking) 완료 이후 전표(Session) 생성 흐름을 연결하는 기반 구조를 확립한다. 기존 `BookingRepository`/`SessionRepository`/`ProductRepository`를 수정하지 않고, 최소한의 신규 파일(단일 Caller 클래스)만으로 도메인 간 연결을 달성하는 것이 핵심 목표다.

---

## 3. 완료 범위

| 범위 | 설명 |
|---|---|
| 도메인 분석 | Booking 도메인 현황, Session Engine과의 연계 포인트 식별 |
| 설계 결정 | 호출 위치, Caller 클래스 도입, 데이터 소유권, Product 조회 전략, Session Item 계약 전체 확정 |
| 구현 | `BookingCompletionCaller` 신규 파일 1개 구현 |
| 검증 | 신규 테스트 4건 + 기존 전체 테스트 373건 통과 확인 |
| 문서화 | 아키텍처 요약, 프로젝트 로드맵, 결정 이력, MARK2 아이디어 |

---

## 4. 포함된 오더

| 오더 | 유형 | 핵심 결과 |
|---|---|---|
| A-20 | 분석 | Booking Domain 확인 — 기존 `BookingRepository` 7개 메서드, `createSession()` 호출 0건 |
| A-21 | 분석 | `refType='booking'`은 `PaymentSessionItems`(addItem 레벨) 설계 |
| A-22 | 분석 | 호출 위치 = `completeBooking()` 호출자(`A1_A2_BOUNDARY.md` 원칙), `completeBooking()` 호출도 0건 |
| A-23 | 분석(선정 불가) | 기존 구조 5개 후보 전부 Rejected — 기존 코드에 적합한 Orchestrator 없음 |
| A-24 | 설계 결정 | 단일 Caller 클래스(`lib/features/booking/data/`) 도입 확정 |
| A-24.5 | 설계 결정 | Data Ownership 계약: `businessType`=외부주입, `staffId`/`customerId`=direct, `roomId`=null |
| A-24.6 | 설계 결정 | Product 조회 전략: `watchProducts().first` + 메모리 매칭(기존 `computeEndAt()` 패턴) |
| A-24.7 | 설계 검증 | `itemType: Product.id` 오기 발견·수정 → `'service'`로 확정 |
| A-24.8 | 설계 검증 | 저장 구조 일치 확인(Conflict 0건), A-25 즉시 구현 가능 선언 |
| A-25 | 구현 | `BookingCompletionCaller` 구현 완료, 테스트 4건, 373건 전부 통과 |
| A-25.5 | 문서화 | `ARCHITECTURE_SUMMARY.md`, `PROJECT_ROADMAP.md`, MARK2 분류 추가 |
| A-25.6 | 문서화(본 문서) | Milestone 공식화, Decision History, Roadmap 갱신 |

---

## 5. 최종 구현 결과

### 신규 파일

| 파일 | 설명 |
|---|---|
| `lib/features/booking/data/booking_completion_caller.dart` | `BookingCompletionCaller` 클래스 — 60행, DI 3개(BookingRepository/SessionRepository/ProductRepository), `complete({required BookingRow booking, required String businessType})` 메서드 1개 |
| `test/features/booking/booking_completion_caller_test.dart` | 단일 상품 / 복수 상품 / 빈 CSV / 미매칭 ID 4개 테스트 케이스 |
| `docs/MARK2_IDEAS.md` | 3개 차기 개선 아이디어(Repository/Performance/Technical Debt) |
| `docs/ARCHITECTURE_SUMMARY.md` | 12개 설계 결정 요약 |
| `docs/PROJECT_ROADMAP.md` | 3단계 로드맵 |

### 수정된 기존 파일

**없음** — `BookingRepository`/`SessionRepository`/`ProductRepository`/`SessionClosingWorkflow` 등 기존 코드는 어느 것도 수정하지 않았다. Minimal Change 원칙이 완전히 지켜졌다.

### 구현 흐름 요약(계약 순서)

```
BookingCompletionCaller.complete({booking, businessType})
  ↓
completeBooking(booking.id)                   ← 예약 상태 'completed'
  ↓
createSession(businessType, staffId, customerId, roomId=null)  ← 전표 생성
  ↓
watchProducts().first                          ← 전체 상품 1회 조회
  ↓
productIdsCsv split+매칭                       ← 메모리 필터
  ↓
addItem(itemType='service', refType='booking',  ← 상품당 1회 순차
        refId=booking.id.toString(),
        itemName=product.name,
        unitPrice=product.price) × N
```

---

## 6. 테스트 결과

| 항목 | 결과 |
|---|---|
| `flutter analyze` | **Pass** — No issues found |
| 신규 테스트(4건) | **Pass** — 단일 상품 / 복수 상품 / 빈 CSV / 미매칭 ID 전부 통과 |
| 전체 테스트(373건) | **Pass** — All tests passed (기존 369건 + 신규 4건, 회귀 없음) |

---

## 7. 남아있는 범위

| 항목 | 상태 | 비고 |
|---|---|---|
| `BookingCompletionCaller` UI 연동 | 미구현 | `completeBooking()` 호출 UI 없음 — A-26에서 검토 |
| Booking 완료 화면/라우트 | 미구현 | A-23에서 확인된 그대로 라우트 없음 |
| MARK2 아이디어 3건 | 보류 | `docs/MARK2_IDEAS.md` 참조 |
| TOCTOU 동시성 대응 | ADR-007에서 의도적 이관 | UI 연결 전 재평가 필요(`docs/A13_CONCURRENCY_VALIDATION.md`) |

---

## 8. 다음 Milestone

| 단계 | 예상 내용 |
|---|---|
| **A-26** Booking Integration Test | `BookingCompletionCaller`가 실제 UI/화면 호출 경로에서도 정상 동작하는지 통합 검증 |
| **A-27** Regression Verification | A-25 이후 전체 회귀 테스트 재실행 및 기준선 재확정 |
| **A-28** Booking Flow Documentation | 운영자용 흐름 문서(어떤 UI 이벤트가 `complete()`를 호출해야 하는지) |
