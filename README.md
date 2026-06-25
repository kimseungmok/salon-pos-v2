# salon-pos-v2

일본 살롱 전용 POS 앱 — 설계 및 구현 프로젝트

## 타겟 기기

| 항목 | 내용 |
|------|------|
| 기기 | iPad Air 2 (2014) |
| 해상도 | 2048 × 1536 (Retina, 264ppi) |
| 화면 | 9.7인치, 비율 4:3 |
| OS | iPadOS 16 |
| 프레임워크 | Flutter (iOS 12+) |
| 모크업 기준 | 1024 × 768 논리 포인트 (4:3)

## 구조

```
design/
  mockups/    화면별 UI 모크업 (HTML)
  spec/       기능 명세 (Markdown)
  assets/     디자인 리소스
lib/          Flutter 소스 코드 (구현 단계에서 추가)
```

## 진행 순서

1. 기능 명세 확정 → `design/spec/`
2. 화면별 모크업 → `design/mockups/`
3. DB 스키마 설계
4. Flutter 구현 → `lib/`

## 화면 목록

| 영역 | 페이지 | 상태 |
|------|--------|------|
| 메인 | 로그인 / 런치패드 | 🔲 |
| 상품 | 商品リスト(카테고리+상품, M1) | ✅ |
| 선불권 | プリペイド券管理(27, M6 완료, 생성/충전/사용/취소/마이그레이션 로직) / 28(충전·사용 모달 UI, 다음 차수) | ✅ |
| 결제 | 注文(02, M5 완료, 현금/카드 등 단일결제) / 분할결제UI·이력화면(다음 차수) | ✅ |
| 예약 | 대기(08, M4 완료) / 캘린더·등록폼(06/07, 다음 차수) | ✅ |
| 고객 | 목록(09, M3 완료) / 상세(10, 다음 차수) | ✅ |
| 직원 | 招待(33, M2 완료) / 목록·상세·시프트UI(다음 차수) | ✅ |
| 선불권 | 관리 / 충전·사용(신규) | 🔲 |
| 재고 | 在庫現況(14, M9 완료, 독자기능) / 在庫変動履歴(15, 로직완료·UI다음차수) | ✅ |
| 매출 | 売上概況(17, M10 완료, 전영역 집계) / 보너스탭(추이·고객분석·스태프실적 등, 다음차수) | ✅ |
| 마케팅 | クーポン発行(19, M7 완료) / 캠페인(20)·포인트정책(21) 로직완료·UI다음차수 | ✅ |
| 매장 | 開店準備(22, M8 완료) / レジ締め(23, 로직완료·UI다음차수) | ✅ |
| 시스템 | 설정 / 권한 | 🔲 |

## 구현 진행 현황 (이어서 작업할 때 확인)

- **정의서**: `design/spec/v3/` 전체 10개 영역 작성+교차검증 완료(IMPLEMENTATION_PLAN.md 포함)
- **구현**: M1(상품/카테고리), M2(직원초대+시프트데이터), M3(고객+그룹자동분류), M4(예약등록로직+취소/노쇼 예약금처리+웨이팅), M5(주문+결제+분할결제로직+취소원자처리), M6(선불권 생성/충전/사용/취소/마이그레이션 + payment_pos 연동), M7(쿠폰발행+캠페인+포인트정책), M8(개점준비 권종카운트+체크리스트), M9(재고관리 — 商品/決済와 의도적으로 미연동), M10(売上概況 전영역 집계) 완료.

**v3 구현 계획(M0~M10) 전체 완료(2026-06-23).** 10개 영역 전부 데이터+로직+예외처리+최소 1개 화면을 갖췄다.

**go_router 정식 내비게이션 도입 완료(2026-06-23)**: `lib/core/router.dart`에 `StatefulShellRoute.indexedStack`으로 10개 화면을 정식 경로(`/pos`, `/products`, `/staff`, `/customers`, `/waiting`, `/prepaid-pass`, `/coupons`, `/store-open`, `/inventory`, `/sales-report`)에 매핑. 기존 `_DevHomeTabs`(수동 IndexedStack+setState) 제거. 이 작업 중 **위젯테스트로 처음 발견한 실버그**: `locale: ja_JP`를 고정해놓고도 `flutter_localizations` 패키지/delegates를 등록하지 않아 MaterialLocalizations 자체가 없던 상태(AppBar 등이 런타임에 깨짐) — `pubspec.yaml`에 `flutter_localizations` 추가하고 `main.dart`에 `localizationsDelegates` 등록해 해결.

단위테스트 200건(기존 196 + 스모크 4) 전부 통과, `flutter analyze` 클린. 남은 작업은 각 모듈에서 "다음 차수"로 미뤄둔 보조 화면(02 결제수단그리드에 プリペイド券 추가, 06/07 예약캘린더·등록폼UI, 10 顧客詳細, 15 在庫変動履歴, 17 보너스탭, 20/21/23 화면UI 등)이다.

### 라우팅/로케일 회귀 테스트(2026-06-23 추가)

`test/routing_test.dart`(25건) + `test/locale_test.dart`(4건) 추가, 누적 229건 전체 통과.

- **404 처리 갭 발견·수정**: go_router에 `errorBuilder`가 없어 존재하지 않는 경로 접근 시 기본 디버그 에러화면이 그대로 노출되던 문제 → `_NotFoundScreen`(일본어 안내+「注文画面に戻る」버튼) 추가
- **범위 한계 명시**: 현재 라우팅은 `/customer→/customer/detail→/reservation` 같은 중첩 push 구조가 아니라 10개 화면이 모두 평행 브랜치(하단탭)다 — 로그인/고객상세/예약 화면이 아직 없어 "뒤로가기" 테스트는 적용 대상이 없음(탭 반복전환 50회 스트레스 테스트로 대체)
- **로케일 테스트**: `showDatePicker()`/`showTimePicker()`/`AlertDialog`가 일본어로 정상 렌더링됨을 standalone MaterialApp으로 확인(앱 화면 중 아직 picker를 쓰는 화면이 없어, 프레임워크 차원에서 버그 수정이 유효한지만 검증)
- **cold start(`flutter run`) 미검증**: 실제 iOS 시뮬레이터(iPad Air 11" M3)에 빌드는 끝까지 진행됐으나(sqlite3_flutter_libs 컴파일까지 확인) 마지막 앱 설치(`installd`) 단계에서 현재 개발 환경(샌드박스)이 멈춰 끝내 실행 화면을 확인하지 못함 — 로컬 터미널에서 `flutter run -d <시뮬레이터ID>` 직접 실행 권장. hot reload(r)/hot restart(R)도 동일한 이유로 미검증.
- 작업 단위는 Task 도구(M0~M10)로 추적 중 — 새 세션에서도 TaskList로 현재 진행 상태와 다음 작업을 바로 확인 가능
- 모든 화면은 일본어로만 구현(현지화 필수, `design/spec/v3/01_glossary.md` 용어 고정표 준수)

### 설계 리뷰 → MVP 업무규칙 정리 → A-2 구현(2026-06-23)

`SCREENS_ERD_TABLES.md`(27화면×21테이블 ERD/테이블정의/제안엔티티/샘플데이터) → `DESIGN_REVIEW.md`(예약/고객/재고/결제/직원 5영역 운영업무 기준 리뷰, 핵심발견: recordVisit() 호출경로 부재로 고객그룹분류 F-CUST-01 비작동) → `PRIORITIZATION.md`(MVP필수5/베타7/출시후2 분류) → `MVP_IMPACT_MAP.md`(MVP 5건 화면/테이블/Repository/구현순서 매핑) → `A2_PREFLIGHT_REVIEW.md`(A-2 착수전 점검) → `A1_A2_BOUNDARY.md`(A-1×A-2 경계: 방문확정 단일트리거=결제완료) → `BUSINESS_RULES_TO_DECIDE.md`(즉시결정7/구현중3/출시전4 업무규칙) → `BOOKING_OVERLAP_POLICY_ANALYSIS.md`(헤어/네일/마츠게 업종별 예약중복정책 분석, A-3 영향)까지 design/spec/v3/ 에 순차 작성.

**A-2(예약 방문완료 상태전환) 구현 완료**: `BookingRepository.completeBooking()` 추가(신규 테이블/컬럼/Repository 없음). `cancelBooking()`과 동일 패턴으로 멱등성 보장, 예약금 필드(`depositReceived`/`depositRefunded`)는 절대 비침범. `recordVisit()` 자체 호출은 하지 않음(A-1/PaymentRepository 책임으로 명확히 분리 — 호출 순서 결정 전까지 이중적재 위험 회피). 테스트 6건 추가, 전체 235건 통과.

**A-1(recordVisit 연결, 워크인/일반결제 경로) 구현 완료**: `A1_PREFLIGHT_REVIEW.md` §0 추가점검(AuthRepository/AuthService 코드베이스 전체 0건 재확인 — 로그인/세션 개념 자체가 없음, `pay()`엔 staffId 매개변수·컬럼 없음) 결과를 반영해 `PaymentRepository.pay()`의 기존 `newStatus=='completed'` 분기에서 `CustomerRepository.recordVisit()` 호출. `staffId`는 로그인 대신 `OrderItem` 조회로 조달(첫 non-null 채택). 예약경로(`completeBooking()` 연동)는 `Order`에 `bookingId` 저장 컬럼이 없는 구조적 제약으로 이번 범위에서 제외 — 워크인/일반결제 경로만 우선 구현, `PaymentRepository` 생성자 변경 없음. 테스트 5건 추가, 전체 240건 통과.

**A-3(예약 변경 updateBooking) 구현 완료**: `BookingRepository._assertStaffAvailable()`에 `excludeBookingId` 매개변수를 추가해 `createBooking()`/`updateBooking()`이 충돌검사 로직을 공유하도록 구조화(수정 대상 예약 자기 자신과 항상 충돌판정되던 문제 해결). `updateBooking()`은 `status`를 바꾸지 않고 `'confirmed'`인 예약의 `staffId`/`startAt`/`endAt`만 갱신, `cancelBooking()`/`completeBooking()`과 동일한 "현재 confirmed인가" 가드로 통일해 종결된 예약의 수정을 차단. 변경 이력은 보존하지 않음(overwrite — 테이블 추가 금지 조건상 `cancelBooking()`도 이미 같은 한계). 테스트 10건 추가, 전체 250건 통과.

**A-4(직원 재직상태) 구현 완료**: `Staff.accountStatus`에 새 값(`'退職済み'`)만 추가, 마이그레이션 없음. `StaffRepository.removeStaff()`를 이원화(`連結済み`→상태전환, 그 외→하드삭제 유지), `assertNotRetired()` 신설. `BookingRepository.createBooking()`은 항상 신규배정이라 그대로 검증, `updateBooking()`은 **담당자가 실제로 바뀔 때만** 검증(시간만 바꾸는 변경이나 동일 담당자 재지정은 검증 생략) — A-3의 "부분변경도 전체 재검사" 정책과 충돌하지 않도록 별도 조건으로 게이트. Payment/Visit/Inventory는 변경 없음(이미 올바른 상태). 테스트 9건 추가, 전체 259건 통과.

**A-5(재고 이력보존) 구현 완료**: `InventoryRepository.deleteItem()`을 이력보존 삭제정책으로 변경 — soft delete용 상태컬럼 추가 없이, `itemId`를 참조하는 `InventoryLog`가 1건이라도 있으면 삭제를 거부(`BusinessRuleException`, 별도 복구로직 없이 단순 실패 처리). 이력이 없는 품목만 기존과 동일하게 하드 삭제. `adjustQuantity()`(재고수량 변경 로직)는 수정 없음, Payment/Product/Booking/Staff 도메인 무관(F-INV-00 그대로 유지). 테스트 3건 추가, 전체 262건 통과.

**A-4/A-5 모두 구현 완료** — MVP 필수 5건(A-1~A-5) 전부 구현 완료. **다음 권장 순서**: 후속으로 예약경로 recordVisit 연동(06/07 화면 구현 및 bookingId 전달방식 확정 시점에), 그 외 베타/정식출시 단계 항목은 `PRIORITIZATION.md` 참조.
