# 02 · POS 주문 화면 정의서 (v2)

> **파일**: `design/mockups/v2/ja/02_pos_order.html`
> **목적**: 결제 플로우의 첫 단계. 카테고리/서브카테고리 탐색 → 상품 그리드에서 카트 담기 → 상품별 할인 적용 → 会計する 클릭
> **진입 경로**: 사이드바 메뉴 → 会計 / 예약 관리 화면에서 예약 연동
> **다음 화면**: 「会計する」클릭 → `03_pos_payment`
> **레이아웃**: 좌 상품 패널 (`flex:1`) / 우 카트 패널 (`width:318px`)
> **기준 해상도**: iPad Air 2 — 1024×768px (논리)

---

## 화면 구조 다이어그램

```
┌─────────────────────────────────────────────────────────────────────────┐
│  글로벌 탑바 44px                                                          │
│  ☰  ✂ salonpos               [由] Yuki  渋谷店  │  06.16 火 10:24  🔒   │
├──────────────────────────────────────────────┬──────────────────────────┤
│  부모 카테고리 탭바 40px (스크롤)  [▾]           │                          │
│  施術 │ カラー▾ │ トリートメント │ パーマ▾ │…│＋│  │  카트 아이템 목록         │
├──────────────────────────────────────────────┤  (overflow-y: auto)      │
│  서브카테고리 탭바 36px (스크롤, 부모 선택 시 표시)  │                          │
│  すべて │ 一般染色 │ プレミアム染色 │ ＋          │                          │
├──────────────────────────────────────────────┤──────────────────────────│
│                                              │  소계 / 할인합계 / 합계     │
│  상품 그리드  4열 × 5행 (고정, 스크롤 없음)       │  消費税                   │
│                                              │                          │
│  [카드][카드][카드][카드]                        │  [회계する] 버튼           │
│  [카드][카드][카드][카드]                        │                          │
│  [카드][카드][카드][카드]                        │                          │
│  [카드][카드][카드][카드]                        │                          │
│  [카드][카드][카드][카드]                        │                          │
├──────────────────────────────────────────────┤                          │
│  그리드바 38px                                 │                          │
│  [✏ グリッド編集] [＋ 商品追加]  ···  [‹ 1/1 ›]  │                          │
└──────────────────────────────────────────────┴──────────────────────────┘
```

---

## A. 글로벌 탑바

| 항목 | 값 |
|------|----|
| 높이 | 44px |
| 배경 | `white` |
| 테두리 | 하단 `.5px solid #E0E0DC` |
| z-index | 10 |

### A-01 · 햄버거 버튼

| 항목 | 값 |
|------|----|
| 타입 | `div.tb-hamburger` |
| 크기 | 32×32px, border-radius 8px |
| 아이콘 | 18px 너비 선 3개, gap 5px, `#1C2833` |
| hover | 배경 `#F4F4F0` |
| 클릭 | `toggleSidebar()` — 왼쪽 슬라이드 사이드바 열기 |

### A-02 · 로고

| 항목 | 값 |
|------|----|
| 텍스트 | `✂ salonpos` |
| 폰트 | 13px / 600 / `#1C2833`, `em` 태그 부분만 `#2E86C1` |

### A-03 · 스태프 정보 (우측)

| 항목 | 값 |
|------|----|
| 아바타 | 26×26px 원형, 보라 배경 `#8E44AD`, 이름 첫 글자 white |
| 스태프명 | 12px / 500 / `#333` |
| 지점명 | 11px / `#AAA` (스태프명 바로 오른쪽) |
| 구분선 | `.5px × 16px / #E0E0DC` |
| 시각 | 11px / `#999`, `MM.DD 요일 HH:MM` 형식 |
| 잠금 | 🔒 14px / `#C0C0BC`, 클릭 시 화면 잠금 (추후 구현) |

---

## B. 좌측 슬라이드 사이드바

| 항목 | 값 |
|------|----|
| 타입 | `div.sidebar` — `position:absolute` inside `.ipad` |
| 너비 | 228px |
| 배경 | `#1C2833` (다크 네이비) |
| 전환 | `translateX(-100%) → translateX(0)`, duration 0.22s, ease |
| z-index | 21 |
| 오버레이 | `.sidebar-overlay`, `rgba(0,0,0,.4)`, z-index 20, 클릭 시 `closeSidebar()` |

### B-01 · 사이드바 메뉴 아이템

| 모듈 | 색상 dot | 레이블 |
|------|----------|--------|
| 会計 (활성) | `#2E86C1` | 会計 |
| 予約 | `#8E44AD` | 予約 |
| 顧客 | `#1E8449` | 顧客 |
| スタッフ | `#C0392B` | スタッフ |
| 在庫 | `#7D3C98` | 在庫 |
| 売上 | `#D4AC0D` | 売上 |
| マーケティング | `#D35400` | マーケティング |
| 店舗設定 | `#117A65` | 店舗設定 |
| システム設定 | `#1A5276` | システム設定 |

**아이템 스타일**:
- 비활성: 레이블 `rgba(255,255,255,.65)`, hover `rgba(255,255,255,.07)` 배경
- 활성: 레이블 `white` / 600, 배경 `rgba(255,255,255,.11)`

---

## C. 부모 카테고리 탭바

| 항목 | 값 |
|------|----|
| 높이 | 40px |
| 배경 | `white` |
| 테두리 | 하단 `.5px solid #E0E0DC` |
| z-index | 12 |

### C-01 · 탭 스크롤 영역 (`.cat-scroll`)

| 항목 | 값 |
|------|----|
| 타입 | `div.cat-scroll`, `flex:1` |
| 스크롤 | `overflow-x:auto`, 스크롤바 숨김(`scrollbar-width:none`) |
| 터치 | `-webkit-overflow-scrolling:touch` |
| 스크롤 페이드 마스크 | JS `updateMask()`: 좌끝 도달 전이면 왼쪽 55px 페이드, 우끝 미도달이면 오른쪽 55px 페이드 (`webkitMaskImage` / `maskImage`) |

### C-02 · 개별 카테고리 탭 (`.cat-tab`)

| 항목 | 값 |
|------|----|
| 높이 | 부모와 동일 (align-items:stretch) |
| 패딩 | `0 15px` |
| 비활성 | 12px / `#444`, 오른쪽 구분선 `.5px solid #EBEBEA` |
| 활성 | 배경 `#1C2833`, 글자 `white` / 500, 좌우 border 색 `#1C2833` (pill 없음, 사각형) |
| hover | 글자 `#111`, 배경 `#F6F6F4` |
| 하위 카테고리 보유 | 탭 이름 옆 `▾` (8px, 55% 불투명) |
| 클릭 | `selectParent(id)` |

**카테고리 목록 (11개)**:

| id | 이름(JA) | 자식 수 (すべて 제외) |
|----|----------|--------------------|
| cut | 施術 | 0 |
| color | カラー | 2 (一般染色, プレミアム染色) |
| tr | トリートメント | 0 |
| perm | パーマ | 2 (デジタルパーマ, コールドパーマ) |
| spa | ヘッドスパ | 0 |
| shohin | 商品 | 0 |
| set | セット | 0 |
| organic | オーガニック | 0 |
| bleach | ブリーチ | 0 |
| straight | 縮毛矯正 | 0 |
| other | その他 | 0 |

### C-03 · ＋ 카테고리 추가 버튼 (`.cat-add`)

| 항목 | 값 |
|------|----|
| 표시 조건 | 탭 목록 맨 끝에 항상 표시 |
| 클릭 | `addCategory()` — prompt로 이름 입력 후 CATS에 추가 |

### C-04 · 펼치기 버튼 (`.cat-expand-btn`)

| 항목 | 값 |
|------|----|
| 표시 조건 | `cat-scroll.scrollWidth > clientWidth + 1` (오버플로우 시만) |
| 크기 | 28×28px, border-radius 6px |
| 기본 | 배경 `white`, 테두리 `#E0E0DC`, 글자 `▾` / `#666` |
| 활성(열림) | 배경 `#1C2833`, 글자 `white` |
| 클릭 | `toggleCatDropdown()` |

### C-05 · 카테고리 드롭다운 (`.cat-dropdown`)

| 항목 | 값 |
|------|----|
| 위치 | `position:absolute; top:40px; left:0; right:0` |
| z-index | 15 |
| 표시 | `display:flex; flex-wrap:wrap; gap:6px` |
| 내용 | **모든 카테고리** 칩 + ＋ 카테고리 추가 |
| 항목 스타일 | 비활성 `.cat-dd-item`, 활성 `.on`: 배경 `#1C2833` |
| 닫기 | 드롭다운 외부 클릭 (`document.addEventListener('click',…)`) |

---

## D. 서브카테고리 탭바

| 항목 | 값 |
|------|----|
| 높이 | 0px(닫힘) → 36px(열림), `transition: height .18s` |
| 열림 조건 | 선택된 부모 카테고리가 children 배열을 가질 때 (모든 부모가 최소 `すべて` 1개 보유) |
| 배경 | `#F4F4F2` |
| 테두리 | 하단 `.5px solid #E0E0DC` (열림 시) |

### D-01 · すべて (공통 첫 자식)

| 항목 | 값 |
|------|----|
| 규칙 | **모든 부모 카테고리는 반드시 `すべて` 자식을 첫 번째로 보유** |
| id 규칙 | `{parentId}_all` |
| 동작 | 부모 슬롯(`SLOTS[parentId]`) 그대로 표시 (별도 슬롯 없음, alias) |
| 선택 시 기본 | 부모 탭 클릭 시 자동으로 `すべて` 선택 상태 |

### D-02 · 서브카테고리 탭 (`.subcat-tab`)

- 비활성: 11px / `#444`
- 활성: 배경 `#444`, 글자 `white` / 500, 사각형 스타일
- 스크롤/페이드 로직: 부모 탭바와 동일

---

## E. 상품 그리드

### E-01 · 그리드 컨테이너 (`.product-grid`)

| 항목 | 값 |
|------|----|
| 레이아웃 | `display:grid; grid-template-columns:repeat(4,1fr); grid-template-rows:repeat(5,1fr)` |
| 페이지당 슬롯 수 | 20 (4열 × 5행) — `PAGE = 20` |
| 스크롤 | `overflow:hidden` (항상 딱 5행, 스크롤 없음) |
| 패딩 | `9px 12px` |
| gap | `8px` |
| 편집 모드 | class `.edit-mode` 추가 → 배경 `#F0EEE8`, padding `8px` |

### E-02 · 상품 카드 (`.prod-card`) — 일반 모드

| 항목 | 값 |
|------|----|
| 배경 | `white` |
| 테두리 | `.5px solid #E5E5E0`, border-radius 10px |
| hover | `border-color:#2E86C1`, `box-shadow:0 2px 10px rgba(46,134,193,.13)` |
| active | `transform:scale(.97)` |
| 카트 담김 상태 | class `.in-cart`: 배경 `#F0F8FF`, 테두리 `#2E86C1` |
| 클릭 | `addToCart(product)` |

**내부 구조 (위→아래)**:

| # | 요소 | 값 |
|---|------|-----|
| E-02-1 | 인기 배지 (선택) | 빨강 배경 `#E74C3C`, 9px white, `badge` 값 있을 때만 |
| E-02-2 | 상품명 | 12px / 500 / `#1A1A1A`, 2줄 클램프 |
| E-02-3 | 가격 | 13px / 600 / `#2E86C1`, `¥N,NNN` |
| E-02-4 | 소요시간 | 10px / `#C0C0BC`, `time` 값 있을 때만 |

### E-03 · 빈 슬롯 (`.prod-empty`)

| 항목 | 값 |
|------|----|
| 배경 | `#F9F9F7`, 테두리 `1px dashed #DDDDD8` |
| 일반 모드 | 내용 없음 (표시만) |
| 편집 모드 | `.edit-empty` → ＋아이콘 + 「商品を追加」, 클릭 시 `addProductAtSlot(i)` |

### E-04 · 편집 카드 (`.edit-card`) — 편집 모드

| 항목 | 값 |
|------|----|
| 배경 | `white` (비표시 항목: `#F6F6F4`, 테두리 dashed, opacity 0.5) |
| 테두리 | `1.5px solid #D0D0CC`, border-radius 10px |
| cursor | grab (드래그 가능, 추후 구현) |

**내부 구조 (위→아래)**:

| # | 요소 | 설명 |
|---|------|------|
| E-04-1 | 드래그 핸들 | `· · ·`, 9px, 회색, 상단 |
| E-04-2 | 상품명 | 11px / 500 / `#333`, 2줄 클램프 |
| E-04-3 | 가격 | 11px / 600 / `#2E86C1` |
| E-04-4 | 표시/비표시 버튼 | `👁 表示中` / `🚫 非表示`. 파란 테두리 ↔ 회색 테두리 토글. 클릭 → `toggleVisible(i)` |
| E-04-5 | 취소 버튼 | `✕ 取り外す`. 빨간 계열. 클릭 → `deleteSlot(i)` (상품 데이터 삭제 아님, 그리드 슬롯만 null 처리) |

> ⚠️ **개념 주의**: 取り外す는 그리드 슬롯을 null로 만드는 것. 상품 마스터 데이터(`SLOTS` 외부의 상품 DB)는 영향 없음. Flutter 구현 시 product_master 테이블과 grid_slot 테이블을 분리해야 함.

---

## F. 그리드바

| 항목 | 값 |
|------|----|
| 높이 | 38px |
| 배경 | `white` |
| 테두리 | 상단 `.5px solid #E0E0DC` |

### F-01 · 모드별 버튼 구성

**일반 모드**:
```
[✏ グリッド編集]  [＋ 商品追加]  ───flex:1───  [‹  1/1  ›]
```

**편집 모드**:
```
[✏ グリッド編集·활성]  [💾 保存する]  ───flex:1───  [＋ページ追加]  [ページ削除]  [‹  1/2  ›]
```

### F-02 · 편집 모드 진입/종료 (`toggleEditMode()`)

| 상황 | 동작 |
|------|------|
| 진입 | `editMode = true`, `isDirty = false`, 버튼 구성 전환, toast 표시 |
| 종료 (변경 없음) | `editMode = false`, 정상 종료, toast 표시 |
| 종료 (변경 있음, `isDirty = true`) | 미저장 확인 모달 표시 |

### F-03 · 페이지 관리

| 함수 | 동작 |
|------|------|
| `addPage()` | `SLOTS[key]`에 20개 null 추가, 마지막 페이지로 이동, `isDirty = true` |
| `deletePage()` | 현재 페이지 20슬롯 splice, 페이지 수 조정, `isDirty = true` (1페이지뿐이면 거부) |

### F-04 · 저장 (`saveGrid()`)

| 항목 | 값 |
|------|----|
| 동작 | `isDirty = false`, green toast, 버튼 텍스트 `✓ 保存済み` → 1.8초 후 원복 |
| 실제 앱 | Flutter 구현 시 Hive/SQLite에 grid_slot 데이터 persist |

---

## G. 카트 패널

| 항목 | 값 |
|------|----|
| 너비 | 318px (고정) |
| 배경 | `white` |

### G-01 · 카트 아이템 (`.ci`)

**상단 행**:

| # | 요소 | 값 |
|---|------|-----|
| G-01-1 | 상품명 | `flex:1`, 12px / 500 / `#1A1A1A` |
| G-01-2 | 가격 표시 | 할인 시 취소선 원가(10px/회색) + 할인 후가(13px/600/빨강) 표시. 정가 시 13px/600/`#1A1A1A` |

**하단 행** (`justify-content: space-between`):

| 위치 | 요소 | 값 |
|------|------|-----|
| 좌측 그룹 | `[－]` `qty` `[＋]` | 각 28×28px, border-radius 6px |
| 중앙 | `[割引]` 버튼 | 28px 높이, min-width 28px, padding `0 7px` |
| 우측 | `[✕]` 삭제 버튼 | 28×28px, border-radius 6px |

**할인 버튼 상태**:
- 기본: 배경 `#F4F4F0`, 글자 `割引` |
- 할인 적용됨 (`.on`): 배경 `#F5EEF8`, 테두리/글자 `#8E44AD`, 텍스트 `-10%` 또는 `-¥500` 형식 |

**파라미터 (cart 배열 항목)**:

```js
{
  id: number,           // 자동 증가 고유 ID
  name: string,         // 상품명
  price: number,        // 정가 (JPY)
  qty: number,          // 수량 (최소 1)
  discount: null | {
    type: 'percent' | 'fixed',
    value: number       // % 또는 JPY
  }
}
```

**실효 가격 계산**:
```js
// percent: price × (1 - value/100), 소수점 반올림
// fixed:   max(0, price - value)
effectivePrice(item) → number
```

### G-02 · 합계 요약 (`#cartSummary`)

| 행 | 조건 | 스타일 |
|----|------|--------|
| 小計 (N点) | 항상 | 레이블 `小計 (N点)` — 점수는 `#888`/500, 금액 `#1A1A1A` |
| 割引合計 (N点) | `totalDiscount > 0` 시만 | 레이블의 `(N点)` 부분은 `#E74C3C`/600, 금액도 `#E74C3C`/600 |
| 구분선 | 항상 | `.5px solid #E5E5E0` |
| 合計 | 항상 | 레이블 12px/600, 금액 22px/700 |
| 消費税 | 항상 | 10px/`#BBB`, `税込み · 消費税 ¥N,NNN` |

**계산 로직**:
```
小計     = Σ(item.price × item.qty)
割引合計  = Σ((item.price - effectivePrice(item)) × item.qty)
合計     = Σ(effectivePrice(item) × item.qty)
消費税    = round(合計 × 10 / 110)   // 세금 포함 기준 내세 계산

// 카운팅
小計 옆 점수  = Σ(item.qty)                                   // 전체 수량 합
割引合計 점수 = Σ(item.qty where item.discount !== null)       // 할인 적용 아이템의 수량 합
```

### G-03 · 会計する 버튼

| 항목 | 값 |
|------|----|
| 배경 | `#2E86C1` |
| 비활성 (카트 비어있음) | 배경 `#D0D0CC`, `cursor:not-allowed` |
| 클릭 | `goPayment()` → `03_pos_payment` 이동 |
| 전달 데이터 | `cart[]` (할인 정보 포함) |

---

## H. 상품별 할인 모달 (`.disc-modal`)

| 항목 | 값 |
|------|----|
| 오버레이 | `position:absolute; inset:0`, `rgba(0,0,0,.45)`, z-index 50 |
| 모달 크기 | 380px 너비, border-radius 14px |
| 진입 | 카트 아이템의 `[割引]` 버튼 클릭 → `openDiscModal(itemId)` |

### H-01 · 헤더

| 항목 | 값 |
|------|----|
| 레이블 | `商品割引` (10px / `#AAA`) |
| 상품명 | 15px / 600 / `#1A1A1A` |
| 정가 | 13px / `#888`, `定価 ¥N,NNN` (수량 > 1이면 `× N` 표기) |

### H-02 · 할인 타입 탭

| 탭 | id | 활성 시 |
|----|-----|---------|
| % 割引 | `tabPct` | 하단 보더 `#8E44AD` |
| 固定額割引 (円) | `tabFix` | 하단 보더 `#8E44AD` |

### H-03 · % 프리셋 버튼

`5%, 10%, 15%, 20%, 30%, 50%` — 클릭 시 `setDiscPreset(value)`, 입력창에 반영

### H-04 · 固定額 프리셋 버튼

`¥500, ¥1,000, ¥1,500, ¥2,000, ¥3,000`

### H-05 · 커스텀 입력

| 항목 | 값 |
|------|----|
| 타입 | `input[type=number]`, 오른쪽 정렬 |
| 단위 표시 | `%` 또는 `円` (타입에 따라) |
| 입력 이벤트 | `onDiscInput()` → 프리셋 선택 해제, 미리보기 갱신 |

### H-06 · 미리보기 (`#discPreview`)

| 행 | 값 |
|----|-----|
| 通常価格 | 정가 |
| 割引額 | `-¥N,NNN` (빨강 / 700) |
| 割引後 | 최종가 (보라 `#8E44AD` / 700) |

### H-07 · 하단 버튼

| 버튼 | 동작 |
|------|------|
| 割引解除 | `clearDiscount()` — `item.discount = null`, 모달 닫기 |
| キャンセル | `closeDiscModal()` — 변경 없이 닫기 |
| 適用する | `applyDiscount()` — `item.discount` 설정, 카트 재렌더, toast |

---

## I. 미저장 변경 확인 모달 (`.confirm-modal`)

| 항목 | 값 |
|------|----|
| 표시 조건 | 편집 모드 중 `isDirty === true` 상태에서 グリッド編集 버튼 재클릭 |
| 오버레이 | z-index 60 (할인 모달보다 위) |
| 제목 | `変更が保存されていません` |
| 메시지 | `グリッドの編集内容が保存されていません。保存せずに終了しますか？` |

| 버튼 | 동작 |
|------|------|
| 保存せずに終了 | `confirmDiscardEdit()` — isDirty 리셋 후 편집 모드 종료 |
| 編集を続ける | `closeConfirmModal()` — 모달만 닫기, 편집 모드 유지 |

> **모크업 한계**: 현재 구현에서는 SLOTS 객체가 이미 변경된 상태이므로 "보존 없이 종료" 시 실제 롤백이 되지 않음. Flutter 구현 시 편집 진입 시점에 딥카피 스냅샷을 저장하고 버리기 시 복원해야 함.

---

## J. 토스트 알림 (`.toast`)

| 항목 | 값 |
|------|----|
| 위치 | `position:fixed; top:18px; left:50%` (iPad 탑바 위쪽) |
| 전환 | `translateY(-16px) opacity:0` → `translateY(0) opacity:1`, 0.22s |
| 스타일 | 흰 배경, 좌측 3px 컬러 라인, 그림자 |
| 자동 소멸 | 기본 2.4초, 일부 3초 |

| 컬러 클래스 | 라인 색 | 사용 시점 |
|------------|---------|----------|
| (default) | `#2E86C1` | 일반 안내 |
| `.purple` | `#8E44AD` | 편집 모드 진입, 할인 적용 |
| `.green` | `#1E8449` | 저장 완료, 편집 종료, 페이지 추가 |

---

## K. JS 상태 관리

### 변수

| 변수 | 타입 | 설명 |
|------|------|------|
| `CATS` | Array | 카테고리 목록 (id, name, children) |
| `SLOTS` | Object | `{catId: [slot|null, …20]}` — 그리드 슬롯 데이터 |
| `PAGE` | number | 20 (페이지당 슬롯, 4열×5행) |
| `currentParentId` | string | 선택된 부모 카테고리 id |
| `currentChildId` | string | 선택된 서브카테고리 id (`xxx_all` = すべて) |
| `currentPage` | number | 현재 그리드 페이지 (0-indexed) |
| `editMode` | boolean | 그리드 편집 모드 여부 |
| `isDirty` | boolean | 편집 모드 중 미저장 변경 여부 |
| `cart` | Array | 카트 아이템 배열 |
| `nextId` | number | 카트 아이템 자동 증가 ID |
| `discItemId` | number\|null | 현재 할인 모달이 열려있는 카트 아이템 ID |
| `discType` | string | `'percent'` \| `'fixed'` |
| `discValue` | number | 현재 입력된 할인 값 |

### 주요 함수

| 함수 | 역할 |
|------|------|
| `renderCatBar()` | 부모 카테고리 탭바 렌더링 + 오버플로우 감지 |
| `renderSubcatBar()` | 서브카테고리 탭바 렌더링 (열기/닫기 포함) |
| `renderProducts()` | 현재 카테고리/페이지 기준 그리드 렌더링 |
| `renderCartPanel()` | 카트 아이템 목록 + 합계 요약 렌더링 |
| `selectParent(id)` | 부모 카테고리 선택, 서브 초기화 (`xxx_all`) |
| `selectChild(id)` | 서브카테고리 선택 |
| `activeKey()` | `currentChildId`가 `_all`이면 `currentParentId` 반환, 아니면 `currentChildId` |
| `addToCart(p)` | 카트에 추가 또는 qty++ |
| `removeItem(id)` | 카트에서 제거 |
| `changeQty(id, d)` | 수량 변경 (min 1) |
| `effectivePrice(item)` | 할인 적용 후 단가 계산 |
| `openDiscModal(id)` | 할인 모달 열기 (기존 할인 복원) |
| `applyDiscount()` | 할인 적용 후 카트 재렌더 |
| `clearDiscount()` | 할인 해제 |
| `toggleEditMode()` | 편집 모드 전환 (isDirty 체크 포함) |
| `saveGrid()` | isDirty 리셋, 저장 토스트 |
| `addPage()` / `deletePage()` | 슬롯 배열 확장/축소 |
| `toggleVisible(i)` | 슬롯 visible 토글, isDirty = true |
| `deleteSlot(i)` | 슬롯 null 처리, isDirty = true |
| `updateMask(el)` | 스크롤 위치에 따라 페이드 마스크 동적 적용 |
| `checkOverflow(sc, exp)` | 오버플로우 여부로 ▾ 버튼 표시/숨김 |
| `showToast(msg, type, dur)` | 토스트 표시 (type: blue/purple/green) |

---

## L. DB 스키마 예고 (Flutter 구현 시)

```
product_master (id, name, price, time, badge, category_id, created_at)
grid_slot      (id, category_id, page, position, product_master_id, visible)
cart_item      (id, session_id, product_master_id, qty, discount_type, discount_value)
order_session  (id, staff_id, created_at, status)
```

> `grid_slot.product_master_id` = null → 빈 슬롯
> `grid_slot.visible = false` → 그리드에서 비표시 (상품 자체는 존재)

---

*최종 수정: 2026-06-16 (v2 완성) | 기준 모크업: `design/mockups/v2/ja/02_pos_order.html`*
