# 03 · 会計(결제수단 선택) 화면 정의서 (v3)

> **파일**: `design/mockups/v2/ja/03_pos_payment_b.html`
> **목적**: 결제 플로우 2단계. 주문 금액 확인 → 고객/포인트/쿠폰 설정 → 결제수단 선택 → 決済実行
> **진입 경로**: `02_pos_order` → 「会計する」버튼
> **다음 화면**: 「を決済する」클릭 → `04_pos_complete`
> **이전 화면**: 「← 注文に戻る」클릭 → `02_pos_order`
> **레이아웃**: 좌(flex:1 결제조작) / 우(320px 주문내역)
> **기준 해상도**: iPad Air 2 — 1024×768px (논리)

---

## 화면 구조 다이어그램

```
┌──────────────────────────────────────────────────────────────────────────┐
│  글로벌 탑바 44px  ☰ · ✂ salon pos          由 Yuki · 06.16 月 10:24 🔒 │
├────────────────────────────────────────────┬─────────────────────────────┤
│ [좌측 결제조작 패널]                        │ [우측 주문내역 320px]        │
│ ← 注文に戻る   会計   [¥17,160 を決済する→] │ ■ 注文内容                  │
│────────────────────────────────────────────│─────────────────────────────│
│  お支払金額                 [⚡ 分割払い]   │ カット 10%割引      ¥3,960  │
│  ¥17,160                                   │ ワンカラー          ¥8,800  │
│  消費税込み ¥1,560                          │ トリートメント M    ¥4,400  │
│                                            │ (스크롤 가능)                │
│  [👤 田中美咲·320pt] [🎟クーポン適用] ⭐    │─────────────────────────────│
│─────────────────────────────────────────── │  小計           ¥17,600     │
│  支払方法                                  │  割引合計         -¥440     │
│  [💴現金] [💳カード] [📱PayPay]            │  お支払金額     ¥17,160     │
│  [💬LINE Pay]       [📋後払い]             │  消費税込み ¥1,560          │
│                                            │  ⭐ +171pt 獲得予定          │
│  ─ 하단 요약 (할인·포인트·메모) ────────   │                             │
│  割引: -¥440                               │                             │
└────────────────────────────────────────────┴─────────────────────────────┘
```

---

## A. 글로벌 탑바

`02_pos_order.md § A`와 동일 구조.

| 항목 | 값 |
|------|----|
| 높이 | 44px |
| 배경 | white, 하단 `.5px solid #E5E5E0` |
| 좌측 | ☰ → 슬라이드 사이드바 |
| 우측 | 아바타 · 스태프명 · 날짜시간 · 🔒 |

> ⚠️ **스텝바 없음** — 이전 버전의 「注文 › 会計 › 完了」스텝바는 삭제됨.

---

## B. 좌측 패널 상단바 (`.pay-left-header`)

| 항목 | 값 |
|------|----|
| 높이 | 52px |
| 배경 | white, 하단 `.5px solid #E5E5E0` |
| 레이아웃 | flex, `align-items:center`, `gap:10px`, `padding:0 16px` |

| 요소 | 위치 | 스타일 | 동작 |
|------|------|--------|------|
| `← 注文に戻る` | 좌측 | 테두리 버튼 `#F4F4F0` 배경, 12px/500 | `goBackToOrder()` → 02 이동 |
| `会計` | 중앙 | 14px/700/`#1A1A1A` | 고정 타이틀 |
| `¥N,NNN を決済する →` | 우측 (`margin-left:auto`) | `#2E86C1` 파란 버튼, 13px/700 | `execPayment()` → 04 이동 |

**決済ボタン 금액 갱신**: `updateTotal()` 호출 시 `#plhExecAmt` 실시간 갱신.

---

## C. 금액 존 (`.amount-zone`)

| 항목 | 값 |
|------|----|
| 패딩 | `18px 24px 14px` |
| 레이블 | `お支払金額`, 11px/`#999`/500 |

| 요소 | ID | 스타일 |
|------|----|--------|
| ¥ 접두 | — | 18px/`#888` |
| 금액 숫자 | `#amountMain` | 32px/700/`#1A1A1A` |
| 소비세 | `#amountTax` | `消費税込み ¥N,NNN`, 11px/`#BBB` |

#### C-01 · ⚡ 分割払い 버튼

| 항목 | 값 |
|------|----|
| 위치 | 금액 행 우측 끝 |
| 기본 | `border: 1.5px dashed #E0A86E`, `color: #E67E22`, `background: #FEF9F0` |
| 완료 후 (`.active`) | `border-style: solid` |
| 클릭 | `openSplitModal()` → [F. 분할결제 모달] 열기 |

---

## D. 칩 행 (`.chips-row`)

| 항목 | 값 |
|------|----|
| 패딩 | `0 24px 12px` |
| 기본 칩 | `border: 1px solid #E0E0DC`, `background: #FAFAF8` |
| 적용됨 (`.applied`) | `border-color: #1E8449`, `color: #1E8449`, `background: #EAFAF1` |

| # | ID | 아이콘 | 기본 레이블 | 적용 후 | 클릭 |
|---|----|--------|------------|---------|------|
| D-01 | `#custChip` | 👤 | `顧客を検索` | `田中 美咲 · 320pt` | `openCpmModal()` |
| D-02 | `#couponChip` | 🎟 | `クーポン適用` | `10%OFF 適用中` | `openCouponModal()` |
| D-03 | — | ⭐ | `+171pt 獲得予定` | 실시간 갱신 | 없음 (정보 표시) |

---

## E. 결제수단 그리드 (`.method-zone`)

| 항목 | 값 |
|------|----|
| 패딩 | `14px 24px 12px` |
| 섹션 레이블 | `支払方法`, 12px/600 |
| 그리드 | `repeat(5, 1fr)`, `gap: 7px` |

#### E-01 · 결제수단 카드 (`.mcard`)

| 상태 | 스타일 |
|------|--------|
| 기본 | `border: 1.5px solid #EAEAE6`, white 배경 |
| hover | `border-color: #2E86C1`, `background: #EBF5FB` |
| 결제 완료 (`.paid`) | `border-color: #1E8449`, `background: #EAFAF1` |

| # | ID | 이름 | 아이콘 | 부제 | 클릭 |
|---|----|------|--------|------|------|
| E-01-1 | `m-cash` | 現金 | 💴 | お釣り計算 | `openMethodPay('cash')` |
| E-01-2 | `m-card` | カード | 💳 | 端末連携 | `openMethodPay('card')` |
| E-01-3 | `m-paypay` | PayPay | 📱 | QR決済 | `openMethodPay('paypay')` |
| E-01-4 | `m-linepay` | LINE Pay | 💬 | QR決済 | `openMethodPay('linepay')` |
| E-01-5 | `m-credit` | 後払い | 📋 | 未収金処理 | `openMethodPay('credit')` |

> 결제수단 카드 클릭 → 인라인 섹션 없음 → **전용 모달(G)** 이 열린다.

---

## F. 좌측 하단 요약 (`.left-summary`)

| 항목 | 값 |
|------|----|
| 위치 | `margin-top:auto` (좌측 패널 최하단) |
| 테두리 | 상단 `.5px solid #F0F0EC` |
| 패딩 | `10px 24px 14px` |

| 행 ID | 표시 조건 | 레이블 | 값 스타일 |
|-------|-----------|--------|----------|
| `#lsDisc` | 항상 (할인 > 0) | 割引 | `#E74C3C` 빨강 |
| `#lsPts` | `ptsUsed > 0` | ポイント使用 | `#2E86C1` |
| `#lsCoupon` | 쿠폰 적용됨 | クーポン | `#8E44AD` |
| `#lsMemo` | 메모 입력됨 | 📝 メモ | `#555`, 30자 말줄임 |

---

## G. 결제수단 결제 모달 (`.method-pay-modal`)

결제수단 카드 클릭 시 열림. 수단에 따라 본문 HTML 동적 렌더링.

| 항목 | 값 |
|------|----|
| 너비 | 460px |
| 오버레이 ID | `#methodPayOverlay` |
| z-index | 80 |
| 닫기 | ✕ 버튼 또는 오버레이 바깥 클릭 |

#### G-01 · 헤더 (`.mph-icon-header`)

| 요소 | 내용 |
|------|------|
| 아이콘 박스 (`#mphIcon`) | 52×52px, 수단별 배경색, 이모지 |
| 수단명 (`#mphName`) | 16px/700 |
| 부제 (`#mphSub`) | 11px/`#AAA` |
| ✕ | `closeMethodPayModal()` |

#### G-02 · 現金 본문

| 요소 | 내용 |
|------|------|
| 수취금액 행 | `受取金額 ¥` + input (`#cashInp`, 24px/700, 하단 border) |
| 빠른 금액 버튼 | `ちょうど` / `¥10,000` / `¥20,000` / `¥50,000` |
| 거스름돈 바 (`#changeBar`) | 정상: `#EAFAF1` 녹색 / 부족: `#FDEDEC` 빨강 |
| 실행 버튼 | `¥N,NNN を現金で決済する` (파란 전체너비) → `confirmMethodPay('cash')` |

**빠른 금액 동작**:

| 버튼 | 동작 |
|------|------|
| ちょうど | `cashRaw = getTotal()` |
| 금액 버튼 | `cashRaw = 해당 금액` |

#### G-03 · カード 본문

- 단말기 아이콘 (💳, `#EBF5FB`)
- `スタンバイ中 — カードをタッチまたは挿入してください` (녹색 pulse 점)
- `¥N,NNN をカードで決済する` 버튼 → `confirmMethodPay('card')`

#### G-04 · PayPay / LINE Pay 본문

- 4×4 의사 QR 썸네일
- `お客様のスマートフォンでQRコードを読み取ってください` 안내
- PayPay: `background: #E84142`, LINE Pay: `background: #00B900` 버튼

#### G-05 · 後払い 본문

- `#FEF9EC` 경고 박스 (`border: 1.5px solid #F5CBA7`)
- `⚠ 後払い（未収金処理）` + 안내 문구
- `¥N,NNN を後払いで処理する` 오렌지 버튼 → `confirmMethodPay('credit')`

#### G-06 · `confirmMethodPay(m)` 동작

1. 해당 수단 카드에 `.paid` 클래스 추가 (녹색 테두리/배경)
2. `closeMethodPayModal()` 모달 닫기
3. `showToast('¥N,NNN を{수단}で決済しました', 'green')`

---

## H. 분할결제 모달 (`.split-modal`)

「⚡ 分割払い」버튼 클릭 시 표시.

| 항목 | 값 |
|------|----|
| 너비 | 680px |
| 최대 높이 | 700px |
| 레이아웃 | 좌(입력 flex:1) / 우(이력 240px) |
| 오버레이 ID | `#splitOverlay` |

#### H-01 · 헤더

| 요소 | 내용 |
|------|------|
| 타이틀 | ⚡ 分割払い |
| 잔액 배지 (`#splitBadge`) | `残高 ¥N,NNN` — 진행 중: `#FEF3E2` 주황 / 완료: `#EAFAF1` 녹색 |
| ✕ | `closeSplitModal()` |

#### H-02 · 3탭

| 탭 | 콘텐츠 ID | 함수 |
|----|----------|------|
| 💰 金額で分割 | `#tabAmount` | `switchSplitTab('amount')` |
| 👥 人数で分割 | `#tabDutch` | `switchSplitTab('dutch')` |
| 📋 メニュー別 | `#tabMenu` | `switchSplitTab('menu')` |

**활성 탭 스타일**: `background: #E67E22`, `color: white`

---

#### H-03 · 金額で分割 탭

| 요소 | 내용 |
|------|------|
| 금액 입력 (`#splitAmtInp`) | 28px/700, `border-bottom: 2px solid #E67E22` |
| 빠른 버튼 | 残額全額 / ¥5,000 / ¥10,000 / ¥3,000 / ¥8,000 / ¥15,000 (3열) |

**`setSplitAmt(val)`**: `'remaining'` → 잔액 전액 / 숫자 → `min(val, splitRemaining)`

---

#### H-04 · 人数で分割 탭 (더치페이)

| 요소 | 내용 |
|------|------|
| 인원 조절 | `−` / 숫자 (`#dutchNum`) / `＋` 버튼, 범위: 2 ~ 10 |
| 1인당 금액 | `Math.ceil(splitRemaining / dutchCount)` → `#dutchPerVal`, 오렌지 강조 |

---

#### H-05 · メニュー別 탭

| 요소 | 내용 |
|------|------|
| 체크리스트 (`#menuCheckList`) | `ORDER_ITEMS` 배열 기반 렌더링 |
| 선택 스타일 | `border-color: #E67E22`, `background: #FEF9F0`, 체크박스 오렌지 |
| 선택 합계 (`#menuTotal`) | Σ 선택 아이템 가격 |

**`toggleMenuCheck(i)`**: `menuChecked` Set에 index 토글 → 리렌더링 → `updateSplitPayBtn()`

---

#### H-06 · 결제수단 선택 (분할 모달 내)

| 상태 | 스타일 |
|------|--------|
| 기본 (`.smc`) | `border: 1px solid #E0E0DC` |
| hover | `border-color: #E67E22`, `background: #FEF9F0` |
| 선택 (`.smc.selected`) | `border: 1.5px solid #E67E22`, `background: #FEF3E2` |

**`selectSplitMethod(m)`**: 카드 `.selected` 토글 → 現金 선택 시 `#splitCashInline` 표시

#### H-07 · 현금 인라인 (`#splitCashInline`, 現金 선택 시만 표시)

| 요소 | 내용 |
|------|------|
| 수취금액 입력 | `#sciCashInp` |
| 빠른 버튼 | ちょうど / ¥10,000 / ¥20,000 / ¥50,000 |
| 거스름돈 | `#sciChangeBar` — 정상 녹색 / 부족 빨강 |

#### H-08 · 결제 실행 버튼 (`#splitPayBtn`)

| 상태 | 조건 | 텍스트 |
|------|------|--------|
| disabled | 수단 미선택 | `支払方法を選択してください` |
| disabled | 금액 = 0 | `金額を入力してください` |
| 활성 | 수단 + 금액 유효 | `¥N,NNN を{수단}で決済する` |

**`execSplitPay()` 동작 순서**:

1. `splitHistory.push({method, icon, amount, tab})` 이력 추가
2. `splitRemaining = max(0, splitRemaining - amt)` 잔액 차감
3. UI 리셋 (수단/현금 인라인/메뉴 체크 초기화)
4. `splitAmtInp` → 잔액으로 갱신
5. `renderSplitHistory()`, `updateSplitRemaining()` 호출
6. `showToast('¥N,NNN を{수단}で決済しました', 'orange')`
7. 잔액 = 0 시 → `#splitDoneBtn` 활성, 배지 녹색 `残高 ¥0 — 完了！`

---

#### H-09 · 우측 이력 패널 (`.split-right`, 240px, `background: #FAFAF8`)

| 요소 | 내용 |
|------|------|
| 빈 상태 | `まだ決済がありません` |
| 이력 아이템 (`.split-hist-item`) | `{icon} {method}` 이름 + 금액 (녹색) + 「決済N · {탭명}」 부제 |
| 프로그레스 바 (`#spBarFill`) | 결제 진행률 % (녹색, 트랜지션 `.3s`) |
| 잔액 (`#spRemVal`) | 현재 잔액 중앙 표시 |

#### H-10 · 모달 하단

| 버튼 | 스타일 | 동작 |
|------|--------|------|
| キャンセル | `#F4F4F0`, 100px 고정 | `closeSplitModal()` |
| 分割払いを完了する (`#splitDoneBtn`) | `#1E8449` 녹색, 잔액 > 0 시 disabled | `execSplitDone()` |

**`execSplitDone()`**: 모달 닫기 → `splitToggleBtn.classList.add('active')` → `showToast('分割払いが完了しました → 04_pos_complete', 'green')`

---

## I. 고객·포인트·메모 모달 (`.cpm-modal`)

👤 칩 클릭 시 표시.

| 항목 | 값 |
|------|----|
| 너비 | 520px, 최대 높이 640px |

| 섹션 | 주요 요소 |
|------|-----------|
| 顧客 | 검색 input + `検索` 버튼 + 고객 카드 (아바타/이름/전화/태그/내방횟수/포인트) + `削除` |
| ポイント使用 | 보유 pt 표시 + 수량 input + `pt` 단위 + `全額使用` 버튼 |
| 会計メモ | `#memoTa` textarea, 72px |
| オプション | チップ (숫자 input + 円) / 領収書発行 (토글, 기본 ON) |

**`applyCpmModal()`**: 모달 닫기 → `updateTotal()` → 메모 있으면 `#lsMemo` 표시 → `showToast(..., 'green')`

---

## J. 쿠폰 모달 (`.coupon-modal`)

🎟 칩 클릭 시 표시.

| 항목 | 값 |
|------|----|
| 너비 | 460px, 최대 높이 540px |
| 강조색 | `#8E44AD` (보라) |

| 섹션 | 내용 |
|------|------|
| 코드 입력 | input (focus: 보라 테두리) + `適用` 버튼 → `applyCouponCode()` |
| 쿠폰 리스트 | 스크롤, 실시간 검색 필터, 라디오 선택 |

**쿠폰 아이템**: 44px 배지 + 이름/설명 + 할인 표시 + 라디오  
**`confirmCoupon()`**: 쿠폰 칩 `.applied` 갱신 → `#lsCoupon` 요약 표시 → `showToast(..., 'purple')`

---

## K. 우측 주문내역 패널 (`.pay-right`, 320px)

| 항목 | 값 |
|------|----|
| 헤더 (`right-header`) | `background: #1C2833` 네이비, `✏ 注文内容` 흰색 12px/600 |
| ← 編集 | **없음** (v3에서 삭제) |
| 아이템 목록 (`right-list`) | 스크롤, 할인 배지 + 취소선 원가 + 현재가 |

**합계 푸터 (`right-footer`) 행**:

| 행 | 표시 조건 |
|----|-----------|
| 小計 | 항상 |
| 割引合計 | 항상 |
| ポイント使用 | `ptsUsed > 0` |
| チップ | `tip > 0` |
| — 구분선 — | — |
| お支払金額 (24px/700) | 항상 |
| 消費税込み | 항상 |
| ⭐ ポイント獲得予定 | 항상 |

---

## L. JS 상태 관리

### L-01 · 전역 변수

| 변수 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `subtotalRaw` | number | 17600 | 할인 전 소계 |
| `discountTotal` | number | 440 | 상품별 할인 합계 |
| `subtotal` | number | 17160 | `subtotalRaw - discountTotal` |
| `ptsUsed` | number | 0 | 사용 포인트 |
| `cashRaw` | number | — | 수취 현금 (단독 결제 모달) |
| `selectedCoupon` | object\|null | null | 선택된 쿠폰 |
| `ORDER_ITEMS` | Array | — | 주문 아이템 (분할 메뉴 탭용) |
| `METHOD_META` | Object | — | 수단별 메타 (icon/name/sub/bg) |

### L-02 · 분할결제 전용 변수

| 변수 | 타입 | 초기값 | 설명 |
|------|------|--------|------|
| `splitTab` | string | `'amount'` | 현재 탭 |
| `splitHistory` | Array | `[]` | 결제 이력 |
| `splitRemaining` | number | `getTotal()` | 잔여 결제액 |
| `splitCurMethod` | string\|null | null | 현재 선택 수단 |
| `dutchCount` | number | 2 | 더치페이 인원 수 |
| `menuChecked` | Set\<number\> | empty | 선택된 메뉴 index |
| `sciCashRaw` | number | 20000 | 분할 현금 수취액 |

### L-03 · 주요 함수

| 함수 | 역할 |
|------|------|
| `getTotal()` | `subtotal - ptsUsed + tip` 반환 |
| `updateTotal()` | 금액·탑바버튼·우측패널·좌측요약 전체 갱신 |
| `openMethodPay(m)` | 수단별 모달 열기 + 본문 HTML 동적 렌더링 |
| `confirmMethodPay(m)` | 카드 `.paid` 처리 + 모달 닫기 + 토스트 |
| `setCash(val)` / `calcChange()` | 현금 거스름돈 계산 |
| `openSplitModal()` | 분할 모달 열기 + 상태 전체 초기화 |
| `switchSplitTab(tab)` | 탭 전환 + 콘텐츠 표시/숨김 |
| `getSplitCurrentAmt()` | 현재 탭 기준 결제액 계산 |
| `setSplitAmt(val)` | 금액 탭 빠른 금액 설정 |
| `changeDutch(d)` | 더치페이 인원 증감 |
| `toggleMenuCheck(i)` | 메뉴 체크 토글 |
| `selectSplitMethod(m)` | 분할 수단 선택 + 현금 인라인 토글 |
| `execSplitPay()` | 분할 1건 결제 처리 |
| `renderSplitHistory()` | 이력 패널 재렌더링 |
| `updateSplitRemaining()` | 배지·프로그레스바·잔액 갱신 |
| `updateSplitPayBtn()` | 결제 버튼 활성화 여부 판단 |
| `execSplitDone()` | 분할결제 완료 처리 |
| `openCpmModal()` / `applyCpmModal()` | 고객·포인트·메모 모달 |
| `openCouponModal()` / `confirmCoupon()` | 쿠폰 모달 |
| `showToast(msg, type)` | 토스트 (`blue`/`green`/`orange`/`purple`) |
| `execPayment()` | 단독 결제 실행 → 04 이동 |
| `goBackToOrder()` | 02 이동 |

---

## M. 데이터 흐름 (02 → 03)

```
02_pos_order (cart)
  cart: [{id, name, price, origPrice, disc, qty}]
  ──계산──▶
  subtotalRaw   = Σ(origPrice × qty)
  discountTotal = Σ(origPrice - price per item)
  subtotal      = subtotalRaw - discountTotal
  ORDER_ITEMS   = cart   ← 분할 메뉴 탭에서 직접 참조
```

> Flutter 구현 시 `Navigator.push(arguments: cartData)` 로 전달.

---

## N. DB 스키마 예고 (Flutter 구현 시)

```sql
payment_session (
  id, order_session_id,
  total_amount, discount_total,
  points_used, points_earned,
  coupon_id, tip_amount, memo, issue_receipt,
  is_split, created_at
)

payment_item (
  id, payment_session_id,
  method,       -- cash|card|paypay|linepay|credit
  amount,
  split_type,   -- null|amount|dutch|menu
  dutch_count,  -- 人数分割 시 인원수
  seq           -- 분할 결제 순서
)

split_menu_item (
  id, payment_item_id, order_item_id
)
```

---

*최종 수정: 2026-06-16 (v3 전면 재작성)*
*변경 내용: 스텝바 삭제, 좌측 상단바 신설, 결제수단 모달화, 分割払い 3탭 모달 (金額/人数/メニュー別), 하단 실행버튼 삭제, 우측 ← 編集 삭제*
*기준 모크업: `design/mockups/v2/ja/03_pos_payment_b.html`*
