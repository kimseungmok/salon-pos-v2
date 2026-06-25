# ID 컨벤션 — 시스템 전체 공통 규칙

> A-9(`docs/A9_ID_UNIFICATION.md`)로 전체 도메인에 적용 완료.
> 작성일: 2026-06-25

## 원칙

- **모든 PK**: `id INTEGER PRIMARY KEY AUTOINCREMENT` (Drift: `integer().autoIncrement()()`, `primaryKey` 오버라이드 금지 — autoIncrement가 이미 PK를 의미하므로 함께 쓰면 Drift 빌드 에러)
- **모든 FK**: `{domain}_id INTEGER` — 참조 대상 테이블의 PK 타입과 항상 일치
- **UUID 사용 금지** — `package:uuid`의 `Uuid().v4()` 생성 코드는 전체 코드베이스에서 0건이어야 한다
- **비즈니스 코드**(직원번호/상품코드 등): 필요해지면 별도 컬럼 `code TEXT NULL`로 추가 — PK와 절대 혼용하지 않는다(기존 21개 테이블에는 아직 해당 컬럼 없음, 필요 시점에 추가)
- **외부 노출용 식별자**: 필요해지면 `public_id TEXT UNIQUE NULL`로 추가(예: A-8 SESSION ENGINE의 `session_no`가 이미 이 역할 — `"2026-0001"` 같은 사람이 보는 식별자, PK인 정수 `id`와는 별개)

## 적용 범위

A-9 이전: 9개 모듈(Staff/Customer/Booking/Payment_pos/Prepaid_pass/Product/Marketing/Cash_management/Inventory) 21개 테이블이 UUID `TextColumn` PK를 사용 — A-8 SESSION ENGINE(4개 테이블)만 처음부터 INTEGER였음.

A-9 이후: **전체 25개 테이블이 동일한 INTEGER AUTOINCREMENT PK 규칙**을 따른다. 브릿지/매핑 레이어 없이 완전 통일.

## 영향받지 않는 원칙

- **F-INV-00**(재고 독립 — `InventoryRepository`는 `Product`/`Order`/`Payment`를 참조하지 않음): ID 타입 변경과 무관하게 유지
- **F-STAFF-00**(PIN/권한은 본 앱 책임 밖): ID 타입 변경과 무관하게 유지
- 각 Repository의 **검증 로직·예외 종류·비즈니스 규칙은 전혀 변경하지 않음** — 오직 식별자의 타입(`String` → `int`)만 바뀐다
