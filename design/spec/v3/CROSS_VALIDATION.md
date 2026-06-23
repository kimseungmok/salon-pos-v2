# v3 정의서 교차검증 리포트

> 9개 영역(27개 문서) 전체를 다시 훑으며 용어·엔티티·함수 참조가 영역 간에 서로 맞는지 확인. 발견 즉시 본문에 수정 반영, 이 문서는 **검증 과정과 근거를 남기는 기록**.
> 검증일: 2026-06-23

---

## ✅ 통과 (참조 일치 확인됨)

| 체크 항목 | 확인 내용 |
|---|---|
| F-CUST-01 `groupOf()` 단일 함수 | customer/data_spec에서 정의 → booking(F-BOOK-01 팝업), sales_report(F-SALES-02 顧客分析)에서 동일 명칭·동일 반환타입(`first/preRegular/regular/dormant`)으로 인용. 불일치 없음 |
| F-PP-03 결제수단 연동 | payment_pos/feature_spec(F-PAY-02 표)에 `プリペイド券` 행 추가됨 ↔ prepaid_pass/screen_spec(화면28 모드B)에서 "決済方法に「プリペイド券」を追加（既存グリッドの1枠として）"로 동일 방향 정의. 양방향 일치 |
| F-BOOK-02a 예약금 vs F-PP 선불권 혼동 방지 | booking/feature_spec에 "선불권과는 별개 개념" 주석 명시. prepaid_pass 쪽에서도 역방향 참조 추가(본 리포트 §수정 2) |
| F-STAFF-03 시프트 ↔ F-BOOK-02 담당자 가용여부 | staff/data_spec `staffAvailability()` 함수가 booking/screen_spec의 칩 라벨(空き/予約あり/休み) 3종과 1:1 매칭 |
| F-PROD-02 카테고리 고정색 ↔ F-PAY-01 타일색 | product/data_spec `tileColorOf()`가 카테고리 고정색만 참조하도록 정의되어, payment_pos/feature_spec의 "카테고리ID 고정 매핑 개선 권고"와 일치 |
| F-CASH-02 권종 단위(枚/個) | cash_management feature_spec과 data_spec(`DENOM_UNITS`)이 동일 권종 목록·동일 단위로 일치 |

---

## 🔧 발견 및 수정한 불일치

### 수정 1 — booking이 존재하지 않는 `Menu` 엔티티를 참조하고 있었음

**문제**: `booking/data_spec.md`의 `computeEndAt()` 함수가 `Menu[]` 타입을 사용했으나, 실제 상품 엔티티는 `product/data_spec.md`에서 `Product`로 정의됨. `Menu`라는 엔티티는 어디에도 정의되어 있지 않았다 — 구현 시 타입 미스매치를 일으킬 수 있는 실질적 버그.

**수정**: `booking/data_spec.md`의 시그니처를 `menus: Menu[]` → `products: Product[]`로 변경, `m.durationMin` 참조는 그대로(필드명 일치 확인됨).

> UI 라벨은 미용업 관례상 "メニュー"(메뉴)로 계속 표기하되, **백엔드 엔티티명은 Product로 통일**한다는 원칙을 `01_glossary.md`에 추가.

### 수정 2 — 포인트 적립/환원 함수가 어디에도 정의되어 있지 않았음

**문제**: `payment_pos/data_spec.md`의 `cancelOrder()`가 `restorePoints()`를 호출하지만 이 함수의 정의가 어느 문서에도 없었음. 또한 `marketing/data_spec.md`의 `PointPolicy.earnRate`(F-MKT-03)가 실제로 **결제 완료 시 포인트를 적립하는 트리거**와 연결되어 있지 않았음 — 정책값만 있고 적용 로직이 빠진 상태.

**수정**: `marketing/data_spec.md`에 `computeEarnedPoints()`(F-MKT-03 적용)와 `restorePoints()`(F-PAY-05 취소 시 환원) 두 함수를 추가하고, `payment_pos/data_spec.md`의 `cancelOrder()` 주석에 함수 출처(`marketing/data_spec.md`)를 명시.

### 수정 3 — 결제수단 enum이 기능정의서 목록을 다 담지 않고 있었음

**문제**: `payment_pos/data_spec.md`의 `Payment.method` enum이 `...`로 생략되어 있어, F-PAY-02 표에 명시된 `掛け売り`/`回数券`/`利用券`이 데이터 모델에 빠짐.

**수정**: enum을 전체 8종으로 명시: `cash, card, paypay, linepay, bank_transfer, credit, kakeuri, ticket_count, ticket_voucher, prepaid_pass`.

### 수정 4 — 글로서리에 빠진 용어 보강

**문제**: `予約金`, 서비스업 UI 관례인 `メニュー`(백엔드는 Product, 화면 표기는 メニュー) 두 용어가 `01_glossary.md`에 없었음.

**수정**: 용어집에 두 행 추가.

---

## ✅ 결정 완료 (2026-06-23 2차 검토)

| 이슈 | 결정 | 반영 문서 |
|---|---|---|
| 回数券/利用券(결제수단) vs 선불권 횟수권의 개념적 중복 | **통합 — 선불권 하나로만 관리.** 결제수단 그리드에서 回数券/利用券 제거, 과거 종이 발행분은 F-PP-05(마이그레이션)로 선불권에 일괄 이행 | payment_pos/feature_spec, payment_pos/data_spec, prepaid_pass/feature_spec, prepaid_pass/screen_spec |
| 売上カレンダー 날씨 아이콘 | **제거 확정 — 토스 근거 없음.** 날짜+매출숫자만 표시 | sales_report/feature_spec, sales_report/screen_spec |
| 14/15(재고관리) v3 정의서 미작성 | **작성 완료** — `inventory/` 영역 신설(F-PROD-04와 명확히 분리, 독자기능 배지 유지) | inventory/feature_spec, screen_spec, data_spec |

### 추가 발견 — 재고관리 작성 중 (수정 5)

`inventory/screen_spec.md` 작성 중, 기존 v2 목업의 안내 문구 "在庫が0になると自動的に品切れ表示・**POS側で販売不可になります**"가 F-INV-00 결정(재고관리는 商品/決済와 연결하지 않음)과 **모순**됨을 발견. 실제로는 그런 연결을 만들지 않기로 했으므로, 이 문구는 v3 구현 시 삭제하거나 "향후 검토" 문구로 교체해야 함 — `screen_spec.md`에 경고 주석으로 남김(아직 코드 수정 대상은 없음, 문서 단계의 모순 제거).

---

## ⚠️ 미해결 — 구현 전 의사결정 필요 (수정하지 않고 이슈로만 남김)

| 이슈 | 내용 | 관련 문서 |
|---|---|---|
| 예약 취소/노쇼 시 예약금 처리 | booking F-BOOK-02a에서 "본 정의서 범위 외"로 명시했으나, F-PAY-05(결제취소 원자적 처리)와 사실상 같은 패턴이 필요함 — 다음 차수에서 F-BOOK과 F-PAY를 묶는 교차 기능정의 권장 | booking, payment_pos |
