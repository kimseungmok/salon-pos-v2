# 03 · 会計(결제수단 선택) 화면 정의서 (v2)

> **파일**: `design/mockups/v2/ja/03_pos_payment_b.html`
> **목적**: 결제 플로우 2단계. 주문 금액 확인 → 고객/포인트/쿠폰 설정 → 결제수단 선택 → 会計を実行
> **진입 경로**: `02_pos_order` → 「会計する」 버튼
> **다음 화면**: 「会計を実行」 클릭 → `04_pos_complete`
> **이전 화면**: 「← 注文に戻る」 클릭 → `02_pos_order`
> **레이아웃**: 좌(flex:1 결제조작) / 우(320px 주문내역 패널)
> **기준 해상도**: iPad Air 2 — 1024×768px (논리)

---

## 화면 구조 다이어그램

```
┌──────────────────────────────────────────────────────────────────────────┐
│  글로벌 탑바 44px                                                          │
├──────────────────────────────────────────────────────────────────────────┤
│  스텝바 36px: ✓注文 › ②会計 › ③完了                        担当:Yuki 田中美咲│
├────────────────────────────────────────────┬─────────────────────────────┤
│ [좌측 결제조작 패널 flex:1]                │ [우측 주문내역 320px]        │
│                                            │ ■ 注文内容          ← 編集  │
│  お支払金額                   [分割払い]   │─────────────────────────────│
│  ¥ 17,160                                  │ カット 10%割引       ¥3,960 │
│  消費税込み ¥1,560                          │ ワンカラー          ¥8,800  │
│                                            │ トリートメント M    ¥4,400  │
│  [👤 田中 美咲·320pt]  [🎟 クーポン適用]  │ (스크롤 가능)                │
│  ⭐ +171pt 獲得予定                        │─────────────────────────────│
│ ─────────────────────────────────────────  │  小計           ¥17,600     │
│  支払方法                                  │  割引合計        -¥440      │
│  [💴 現金]  [💳 カード]  [📱 PayPay]      │                             │
│  [💬 LINE Pay]   [📋 後払い]              │  お支払金額    ¥17,160      │
│                                            │  消費税込み ¥1,560          │
│  ┌─ 現金 섹션 (현금 선택 시) ────────────┐ │  ⭐ +171pt 獲得予定          │
│  │ 受取金額 ¥ [20,000       ]            │ │                             │
│  │ [ちょうど][¥10,000][¥20,000][¥50,000] │ │                             │
│  │ お釣り               ¥2,840           │ │                             │
│  └───────────────────────────────────────┘ │                             │
│                                            │                             │
│  [  会計を実行  ]     [← 注文に戻る]       │                             │
└────────────────────────────────────────────┴─────────────────────────────┘
```

---

## A. 글로벌 탑바

02_pos_order와 동일 구조. 자세한 정의는 `02_pos_order.md § A` 참조.

| 항목 | 값 |
|------|----|
| 높이 | 44px |
| 배경 | `white`, 하단 `.5px solid #E5E5E0` |
| 좌측 | ☰ 햄버거 → 슬라이드 사이드바 |
| 우측 | 아바타 · 스태프명 · 날짜시간 · 🔒 |

---

## B. 스텝바

| 항목 | 값 |
|------|----|
| 높이 | 36px |
| 배경 | `white`, 하단 `.5px solid #E5E5E0` |

| # | 스텝명 | 상태 | 아이콘 | 색상 |
|---|--------|------|--------|------|
| 1 | 注文 | done | ✓ | `#1E8449` |
| 2 | 会計 | active | 2 | `#2E86C1` |
| 3 | 完了 | pending | 3 | `#bbb` |

**우측 정보**: `担当: Yuki` (11px/`#888`) + `田中 美咲` (11px/`#2E86C1`/500) — 결제 맥락 항상 표시

---

## C. 좌측 결제조작 패널 (`.pay-left`, `flex:1`, `background:white`)

### C-01 · 금액 존 (`.amount-zone`)

| 항목 | 값 |
|------|----|
| 패딩 | `22px 28px 18px` |
| 레이블 | `お支払金額`, 11px / `#999` / `letter-spacing:.05em` |

**금액 표시**:

| 요소 | 스타일 |
|------|--------|
| `¥` 접두 | 20px / `#888` / 500 |
| 금액 숫자 | 34px / 700 / `#1A1A1A`, `letter-spacing:-.02em` |
| 소비세 | `消費税込み ¥N,NNN`, 11px / `#BBB`, 아래 배치 |
| ID | `#amountMain`, `#amountTax` |
| 갱신 | `updateTotal()` 호출 시 실시간 반영 |

#### C-01-1 · 分割払い 버튼

| 항목 | 값 |
|------|----|
| 위치 | 금액 행 우측 끝 |
| 기본 | `border: 1.5px solid #D0D0CC`, `color: #555`, 배경 white |
| 활성 | `border-color: #2E86C1`, `color: #2E86C1`, `background: #EBF5FB` |
| 클릭 | `toggleSplit()` — 분할 모드 ON/OFF |

---

### C-02 · 칩 행 (`.chips-row`)

| 항목 | 값 |
|------|----|
| 패딩 | `0 28px 14px` |
| 스타일 | 가로 배열, `gap:7px` |
| 칩 기본 | `border: 1px solid #E0E0DC`, 배경 `#FAFAF8`, border-radius 20px |
| 칩 적용됨 | `border-color: #1E8449`, `color: #1E8449`, 배경 `#EAFAF1` |
| 칩 hover | `border-color: #2E86C1`, `color: #2E86C1`, 배경 `#EBF5FB` |

| # | ID | 아이콘 | 기본 레이블 | 적용 후 레이블 | 클릭 |
|---|-----|--------|------------|--------------|------|
| C-02-1 | `#custChip` | 👤 | `顧客を検索` | `田中 美咲 · 320pt` | `openCpmModal()` |
| C-02-2 | `#couponChip` | 🎟 | `クーポン適用` | `10%OFF 適用中` 등 | `openCouponModal()` |
| C-02-3 | `#earnChip` | ⭐ | `+171pt 獲得予定` | 실시간 갱신 | 클릭 없음 (정보 표시) |

---

### C-03 · 결제수단 그리드 (`.method-zone`)

| 항목 | 값 |
|------|----|
| 패딩 | `16px 28px 14px` |
| 섹션 레이블 | `支払方法`, 12px / 600 |
| 그리드 | `repeat(3, 1fr)`, `gap:8px` |

#### C-03-1 · 결제수단 버튼 (`.mcard`)

| 항목 | 값 |
|------|----|
| 패딩 | `14px 10px 12px` |
| 보더 레이디어스 | 10px |
| 기본 | `border: 1.5px solid #EAEAE6`, 배경 white |
| hover | `border-color: #C8C8C4`, 배경 `#FAFAF8` |
| 선택 | `border: 2px solid #2E86C1`, 배경 `#EBF5FB` |
| 내부 구성 | 아이콘(22px) + 이름(12px/500) + 부제(10px/`#AAA`) |

| # | ID | 이름 | 아이콘 | 부제 | 선택 시 표시 |
|---|-----|------|--------|------|------------|
| C-03-1 | `m-cash` | 現金 | 💴 | お釣り自動計算 | cashZone |
| C-03-2 | `m-card` | カード | 💳 | 端末連携 | cardZone |
| C-03-3 | `m-paypay` | PayPay | 📱 | QR決済 | qrZone (PayPay) |
| C-03-4 | `m-linepay` | LINE Pay | 💬 | QR決済 | qrZone (LINE Pay) |
| C-03-5 | `m-credit` | 後払い | 📋 | 未収金処理 | creditZone |

> ⚠️ 分割払い 모드 ON 시 그리드 `opacity:0.4`, `pointer-events:none` — 수단 선택 비활성

---

### C-04 · 현금 섹션 (`.cash-zone`, id: `cashZone`)

現金 선택 시에만 표시.

| 요소 | 내용 |
|------|------|
| 컨테이너 | `background:#F9F9F7`, border-radius 10px, 내부 padding 12px 14px |
| 수취금액 행 | 레이블 `受取金額` + `¥` + TextField (`#cashInp`, 18px/600/오른쪽정렬) |
| 빠른 금액 버튼 | `ちょうど` / `¥10,000` / `¥20,000` / `¥50,000` (1:1:1:1 분배) |
| 거스름돈 바 | 레이블 + 금액 (하단 고정) |

**거스름돈 바 상태**:

| 상태 | 조건 | 배경 | 색상 | 레이블 |
|------|------|------|------|--------|
| 정상 | `cashRaw ≥ 합계` | `#EAFAF1` | `#1E8449` | `お釣り ¥N,NNN` |
| 부족 | `cashRaw < 합계` | `#FDEDEC` | `#E74C3C` | `不足 ¥N,NNN` |

**빠른 금액 동작**:

| 버튼 | `setCash()` 인수 | 결과 |
|------|-----------------|------|
| ちょうど | `'exact'` | `cashRaw = 합계금액` |
| ¥10,000 | `10000` | `cashRaw = 10000` |
| ¥20,000 | `20000` | `cashRaw = 20000` |
| ¥50,000 | `50000` | `cashRaw = 50000` |

> 💡 **Concept B는 숫자 키패드 없음** — iPad OS 소프트 키보드 또는 외부 입력 장치 사용. Concept A(`03_pos_payment.html`)에 풀 키패드 있음.

---

### C-05 · 카드 단말기 섹션 (`.card-zone`, id: `cardZone`)

カード 선택 시에만 표시.

| 요소 | 내용 |
|------|------|
| 컨테이너 | `background:#F9F9F7`, border-radius 10px |
| 아이콘 | 💳, 44×44px, `#EBF5FB` 배경 |
| 단말기명 | `カード端末`, 13px/600 |
| 상태 표시 | 🟢 애니메이션 점 + `スタンバイ中 — カードをタッチまたは挿入してください` |

---

### C-06 · QR 섹션 (`.qr-zone`, id: `qrZone`)

PayPay 또는 LINE Pay 선택 시 표시. `#qrName`으로 브랜드명 전환.

| 요소 | 내용 |
|------|------|
| QR 썸네일 | 70×70px 의사 QR 그리드, 선택 수단 색상 테두리 |
| 안내 | `お客様のスマートフォンでQRコードを読み取ってください` |

---

### C-07 · 後払い 섹션 (`.credit-zone` 또는 inline)

後払い 선택 시 표시.

| 요소 | 내용 |
|------|------|
| 아이콘 | 📋, `#FEF9EC` 배경 |
| 안내 | `お客様の後払い情報を登録します。「会計を実行」で未収金として記録されます。` |
| 경고 배지 | `⚠ 未収金として処理されます`, `#D4AC0D` 텍스트 |

---

### C-08 · 分割払い 섹션 (`.split-zone`, id: `splitZone`)

`toggleSplit()` 로 ON 시 표시. 결제수단 그리드는 비활성화됨.

#### C-08-1 · 분할 행 (`.split-row`, 반복)

| 요소 | 내용 |
|------|------|
| 수단 선택 | `<select>`: 💴 現金 / 💳 カード / 📱 PayPay |
| 구분선 | `.5px solid #E0E0DC` |
| 금액 입력 | `¥` 접두 + TextField (80px, 오른쪽 정렬) |
| 행 삭제 | `✕` 버튼, hover 시 `#E74C3C` |
| 배경 | `#F9F9F7`, border-radius 8px |

#### C-08-2 · 수단 추가 버튼

| 항목 | 값 |
|------|----|
| 내용 | `＋ 支払方法を追加` |
| 스타일 | dashed border `#AED6F1`, `color: #2E86C1`, hover 시 배경 `#EBF5FB` |
| 클릭 | `addSplitRow()` → 새 행 DOM 추가 |

---

### C-09 · 실행 버튼 영역 (`.exec-zone`)

| 항목 | 값 |
|------|----|
| 위치 | 좌측 패널 하단 (`margin-top:auto`) |
| 테두리 | 상단 `.5px solid #F0F0EC` |
| 패딩 | `12px 28px 16px` |

| 버튼 | 스타일 | 동작 |
|------|--------|------|
| 会計を実行 | `flex:1`, 파란 Primary, 15px/600 | `execPayment()` → 04 이동 |
| ← 注文に戻る | Secondary, `#F4F4F0` 배경 | `02_pos_order`로 복귀 |

---

## D. 우측 주문내역 패널 (`.pay-right`, `width:320px`)

### D-01 · 헤더

| 항목 | 값 |
|------|----|
| 배경 | `#1C2833` (네이비 다크) |
| 높이 | `~42px` |
| 좌측 | ✏ `注文内容`, 12px / 600 / white |
| 우측 | `← 編集` (11px / `rgba(255,255,255,.45)`) → `02_pos_order` 이동 |

---

### D-02 · 주문 아이템 목록 (`.right-list`, `flex:1`, `overflow-y:auto`)

스크롤 가능. 항목이 많을수록 세로로 늘어남.

#### D-02-1 · 아이템 행 (`.oi`, 반복)

| 요소 | 내용 |
|------|------|
| 상품명 (`.oi-name`) | 12px / 500 / `#1A1A1A` |
| 할인 배지 (`.oi-badge`) | `10%割引` 등, 9px / 빨강 (`#FDEDEC` 배경) |
| 수량 (`.oi-qty`) | `×N`, 10px / `#AAA` |
| 원가 (`.oi-orig`) | 10px / `#CCC`, 취소선, 할인 있을 때만 |
| 가격 (`.oi-price`) | 12px / 600 |
| 할인가 (`.oi-price.disc`) | `color: #E74C3C` |
| 구분선 | `.5px solid #F5F5F3`, 마지막 항목 제외 |

**파라미터**: `orderItems: [{name, qty, price, discount: {type, value}|null}]`

---

### D-03 · 합계 푸터 (`.right-footer`)

| 행 | 표시 조건 | 색상 |
|----|-----------|------|
| 小計 | 항상 | `#1A1A1A` |
| 割引合計 | 항상 | `#E74C3C` |
| ポイント使用 | `ptsUsed > 0` | `#2E86C1` |
| チップ | `tip > 0` | `#1A1A1A` |
| — 구분선 — | — | — |
| お支払金額 (최종) | 항상 | 24px / 700 / `#1A1A1A` |
| 消費税込み | 항상 | 10px / `#BBB` |
| ⭐ ポイント獲得予定 | 항상 | 11px / `#2E86C1` |

---

## E. 고객·포인트·메모 모달 (`.cpm-modal`)

👤 칩 클릭 시 표시.

| 항목 | 값 |
|------|----|
| 너비 | 520px |
| 최대 높이 | 640px (`overflow-y:auto`) |
| 오버레이 | `position:absolute;inset:0`, `rgba(0,0,0,.5)`, z-index 80 |
| 닫기 | ✕ 버튼 또는 오버레이 바깥 클릭 |

### E-01 · 고객 섹션

| 요소 | 내용 |
|------|------|
| 검색 입력 | placeholder `名前・電話番号で検索...` |
| 검색 버튼 | `検索`, `#2E86C1` 배경 |
| 고객 카드 | 아바타 36px + 이름/전화/태그/방문횟수 + 보유 pt + `削除` 버튼 |
| 고객 삭제 | `removeCustomer()` → 카드 숨김, 칩 초기화 |

### E-02 · 포인트 사용 섹션

| 요소 | 내용 |
|------|------|
| 보유 pt 표시 | `保有ポイント: 320pt`, `#2E86C1` 강조 |
| 입력 | TextField 80px + `pt` 단위 + `全額使用` 버튼 |
| 연동 | `oninput="updateTotal()"` → 합계·우측 패널 실시간 갱신 |
| 파라미터 | `ptsUsed: number (0 ~ 320)` |

### E-03 · 회계 메모 섹션

| 요소 | 내용 |
|------|------|
| textarea | 72px 높이, `font-size:12px`, focus 시 파란 테두리 |
| ID | `#memoTa` |
| 파라미터 | `memo: string` |

### E-04 · 옵션 섹션

| 옵션 | 타입 | 파라미터 |
|------|------|---------|
| チップ | TextField 70px + `円` | `tipAmount: number` |
| 領収書 | 토글 스위치 (기본 ON) | `issueReceipt: boolean` |

### E-05 · 하단 버튼

| 버튼 | 스타일 | 동작 |
|------|--------|------|
| キャンセル | `#F4F4F0` / `#666` | `closeCpmModal()` |
| 適用する | `#2E86C1` / white | `applyCpmModal()` → 합계 갱신 + 칩 상태 반영 + green toast |

---

## F. 쿠폰 모달 (`.coupon-modal`)

🎟 칩 클릭 시 표시.

| 항목 | 값 |
|------|----|
| 너비 | 460px |
| 최대 높이 | 540px |

### F-01 · 코드 입력 행

| 요소 | 내용 |
|------|------|
| 입력 | `クーポンコードを入力...`, focus 시 `#8E44AD` 테두리 |
| 버튼 | `適用`, `#8E44AD` 배경 → `applyCouponCode()` |

### F-02 · 쿠폰 리스트 (`.coupon-list`, 스크롤)

실시간 검색 필터링 (코드 입력값 포함 여부).

#### F-02-1 · 쿠폰 아이템 (`.coupon-item`)

| 요소 | 내용 |
|------|------|
| 아이콘 배지 | 44×44px, `#F4ECF7` 배경, 이모지 |
| 쿠폰명 | 12px / 600 |
| 설명 | 11px / `#888` (대상 · 기한) |
| 할인 표시 | 13px / 700 / `#8E44AD` |
| 라디오 버튼 | 선택 시 `#8E44AD` 채움 |
| 클릭 | `selectCoupon(id)` → 선택/해제 토글 |

**데이터**: `COUPONS: [{id, icon, name, desc, disc}]`

### F-03 · 하단 버튼

| 버튼 | 동작 |
|------|------|
| キャンセル | `closeCouponModal()` |
| 適用する | `confirmCoupon()` → 쿠폰 적용, 칩 상태 갱신, purple toast |

---

## G. JS 상태 관리

### 변수

| 변수 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `subtotalRaw` | number | 17600 | 할인 전 소계 (02에서 전달) |
| `discountTotal` | number | 440 | 상품별 할인 합계 (02에서 전달) |
| `subtotal` | number | 17160 | `subtotalRaw - discountTotal` |
| `ptsUsed` | number | 0 | 사용 포인트 수 |
| `cashRaw` | number | 20000 | 수취 현금 |
| `currentMethod` | string | `'cash'` | 현재 선택된 결제수단 |
| `isSplit` | boolean | false | 分割払い 모드 여부 |
| `selectedCoupon` | object\|null | null | 선택된 쿠폰 객체 |
| `COUPONS` | Array | — | 쿠폰 마스터 목록 |

### 주요 함수

| 함수 | 역할 |
|------|------|
| `getTotal()` | `subtotal - ptsUsed + tip` 계산 반환 |
| `updateTotal()` | 금액존·우측 패널 합계·포인트획득 전체 갱신 |
| `calcChange()` | 현금 거스름돈 계산 및 거스름돈 바 색상 갱신 |
| `setCash(val)` | 빠른 금액 버튼 처리 (`'exact'` 또는 숫자) |
| `onCashInput()` | 수취금액 직접 입력 처리 |
| `useAllPts()` | 전액 포인트 입력 후 `updateTotal()` |
| `selectMethod(m)` | 결제수단 선택, 관련 섹션 표시/숨김 |
| `toggleSplit()` | 分割払い 모드 ON/OFF, 그리드 비활성화 |
| `addSplitRow()` | 분할 행 DOM 추가 |
| `openCpmModal()` / `closeCpmModal()` | 고객·포인트·메모 모달 열기/닫기 |
| `applyCpmModal()` | 포인트·팁 반영, 칩 상태 갱신, 모달 닫기 |
| `removeCustomer()` | 고객 정보 초기화 |
| `openCouponModal()` / `closeCouponModal()` | 쿠폰 모달 열기/닫기 |
| `renderCouponList(query)` | 검색어 기준 쿠폰 리스트 렌더링 |
| `selectCoupon(id)` | 쿠폰 선택/해제 토글 |
| `confirmCoupon()` | 쿠폰 적용, 칩 상태 갱신 |
| `execPayment()` | 결제 실행 (→ 04_pos_complete) |
| `showToast(msg, type)` | 토스트 알림 (blue/purple/green) |

---

## H. 데이터 흐름 (02 → 03)

```
02_pos_order (cart) ──전달──▶ 03_pos_payment
  cart: [{id, name, price, qty, discount}]
  ──계산──▶
  subtotalRaw  = Σ(price × qty)
  discountTotal = Σ(effectiveDiscount per item)
  subtotal     = subtotalRaw - discountTotal
```

> Flutter 구현 시 `Navigator.push(arguments: cartData)`로 전달. 03 화면은 cartData를 읽기 전용으로 사용.

---

## I. DB 스키마 예고 (Flutter 구현 시)

```
payment_session (
  id, order_session_id, method,    -- 결제수단: cash|card|paypay|linepay|credit|split
  amount_paid, cash_received, change_given,
  points_used, points_earned,
  coupon_id, tip_amount,
  issue_receipt, memo,
  created_at
)

split_payment (
  id, payment_session_id, method, amount
)

coupon (
  id, name, discount_type, discount_value,
  target, expires_at, is_active
)
```

---

*최종 수정: 2026-06-16 (v2 전면 재작성 — Concept B 기준) | 기준 모크업: `design/mockups/v2/ja/03_pos_payment_b.html`*
