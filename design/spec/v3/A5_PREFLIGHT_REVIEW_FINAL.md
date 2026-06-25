# A-5(재고 이력 보존) 최종 프리플라이트 검토

> **기준 문서**: `A5_PREFLIGHT_REVIEW.md`(최초 분석), `A4_A5_INTEGRATED_REVIEW.md`, `A4_A5_PAYMENT_FLOW_VERIFICATION.md`, `A4_PRE_IMPLEMENTATION_IMPACT_CHECK.md`(A-4가 실제 구현된 패턴)
> **시점**: A-4(직원 재직상태)가 이미 구현 완료된 상태(`StaffRepository.assertNotRetired()`/`removeStaff()` 이원화). 본 문서는 A-5 구현 착수 직전, 요청된 6개 항목을 코드 레벨로 재확인하고 A-4와의 충돌 여부까지 포함해 최종 정리한다.
> **범위 제한**: 설계 분석만 수행. 코드/SQL 생성·수정, 테이블 변경 없음.
> 작성일: 2026-06-25

---

## 1. `InventoryItem.quantity` vs `InventoryLog.delta` 정합성

`InventoryRepository.adjustQuantity()` 코드를 재확인한 결과, 이전 분석(`A5_PREFLIGHT_REVIEW.md` §2)과 변동 없음:

- `InventoryItem.quantity`는 **매번 덮어써지는 저장값**이고, `InventoryLog.delta`는 **그 변경을 기록만 하는 이력**이다.
- 코드 어디에도 `SUM(InventoryLog.delta)`를 다시 계산해 `quantity`와 대조하는 검증이 없다.
- **정합성은 "둘이 항상 같을 것"이라는 암묵적 가정에만 의존**하며, 그 가정이 깨지는 경로(§2의 동시성 문제)가 이미 코드 구조상 존재한다.

**결론**: 정합성 구조 자체를 지금 바꿀 필요는 없다(F-INV-00 단일화면 전제에서는 무해). 다만 "정합성이 보장된다"는 표현은 부정확하다 — 정확히는 "정합성이 깨질 계기가 아직 없다"는 것이다.

---

## 2. `adjustQuantity()` 동시성 문제 여부

코드를 다시 줄 단위로 확인:

```
1. item 조회(읽기)
2. newQuantity = item.quantity + delta 계산
3. InventoryItems 갱신(쓰기)
4. InventoryLogs insert(쓰기)
```

**`_db.transaction()`으로 묶여 있지 않다** — `PaymentRepository.cancelOrder()`가 `_db.transaction()`을 쓰는 것과 대조적인 비대칭이 그대로 남아있다. 두 번째 단계(읽은 값으로 새 값을 계산)와 세 번째 단계(쓰기) 사이에 다른 호출이 끼어들 수 있는 **고전적 TOCTOU(read-then-write) 패턴**이다.

**현재 위험도**: 낮음(F-INV-00 — 결제와 미연동, 14번 화면에서 한 번에 한 건씩 순차 입력). **잠재 위험도**: 높음(§5에서 다루는 결제연동이 실제로 만들어지는 순간 활성화).

---

## 3. 삭제 정책(delete vs soft rule) 영향

`InventoryRepository.deleteItem()`은 여전히 `_db.delete()`(하드 삭제)이고, `InventoryLogs.itemId`는 `KeyAction.cascade`로 걸려 있어 **품목을 삭제하면 그 품목의 입출고 이력 전체가 함께 사라진다.**

`A4_PREFLIGHT_REVIEW.md`가 채택한 "기존 컬럼에 새 값 추가"(`Staff.accountStatus`에 `'退職済み'` 추가) 전략을 재검토했지만, **`InventoryItem`에는 그럴 여유 필드가 없다**는 결론이 그대로 유지된다(`name`/`category`/`quantity`/`threshold`/`unit` 중 의미를 훼손하지 않고 "비활성"을 표현할 수 있는 필드가 없음 — 재확인).

**권장(변경 없음, 재확인)**: 컬럼 추가 없이 가능한 유일한 방향은 **"이력이 있으면 삭제 자체를 거부"**다 — `deleteItem()` 호출 시 그 `itemId`를 참조하는 `InventoryLog`가 1건이라도 있으면 차단한다. 이력이 전혀 없는(등록 직후 실수로 만든) 품목만 삭제 가능해진다.

---

## 4. `staffId`가 재고 기록에 미치는 영향

`InventoryLog.staffId`는 nullable이고, `adjustQuantity()`는 받은 값을 그대로 저장할 뿐 **`Staff` 테이블을 전혀 조회하지 않는다**(`accountStatus` 검증 없음). `grep` 재확인 결과 `InventoryRepository`/`InventoryLogs` 어디에도 `StaffRepository`나 `assertNotRetired()`에 대한 참조가 없다.

이는 `A4_A5_PAYMENT_FLOW_VERIFICATION.md` §1-2가 이미 정한 분류와 정확히 일치한다 — `InventoryLog`는 "과거 기록"(누가 이 변동을 처리했는지 사후 기록)이라, `Payment`/`VisitRecord`와 같은 범주로 분류되고 **상태 검증 대상이 아니다.**

**참고(1차 범위 밖)**: `OrderItem.staffId`(시술 수행자)와 `InventoryLog.staffId`(재고 처리자)는 이름은 같지만 역할이 다르다는 점은 `A4_A5_PAYMENT_FLOW_VERIFICATION.md` §2-2에서 이미 식별된 위험이며, 본 검토에서도 변동 없이 그대로 유효하다(자동연동이 생길 때 재검토 대상).

---

## 5. Payment 연동 시점에서 재고 차감 위치

`A4_A5_PAYMENT_FLOW_VERIFICATION.md` §2-2의 결론을 재확인: **"언제/어디서"는 이미 답이 정해져 있다** — `PaymentRepository.pay()`의 `newStatus == 'completed'` 분기, `recordVisit()` 호출과 같은 자리. `visit 기준`과 `payment 기준`은 별개 질문이 아니라 이미 같은 지점이다.

**그러나 "무엇을 얼마나"는 여전히 답할 수 없다** — `OrderItem.productId`에서 `InventoryItem.id`로 가는 매핑이 데이터에 전혀 없다. 이번 재검토에서도 그런 매핑의 흔적(예: `Product`/`InventoryItem`을 동시에 참조하는 코드, 이름 매칭 로직 등)이 전혀 발견되지 않았다 — **위치는 정해졌지만 실행할 재료가 없는 상태가 그대로 유지된다.**

---

## 6. 음수 재고 허용 여부

`adjustQuantity()`는 `newQuantity < 0`이면 `BusinessRuleException`으로 차단한다 — **애플리케이션 레벨 검증**이며, §2에서 확인한 비원자성 때문에 동시 요청 상황에서는 이 차단이 보장되지 않을 수 있다(TOCTOU). `BUSINESS_RULES_TO_DECIDE.md` §1-6이 이미 "즉시결정 필요" 항목으로 분류했고 **아직 결정되지 않은 채로 남아있다.**

**본 검토 결론**: 음수 재고 허용 여부 결정은 A-5(이력 보존)의 1차 범위와 독립적이다 — 삭제정책(§3)을 먼저 정리하고, 음수 허용 여부는 별도로 결정해도 무방하다.

---

## 종합 — 출력 형식

### 즉시 구현 가능한 영역
- **`deleteItem()` 정책 변경** — "참조하는 `InventoryLog`가 있으면 삭제 거부"로 전환. 컬럼/테이블 변경 없음, 기존 `deleteItem()` 테스트가 정상삭제 케이스를 검증하지 않아(`A5_PREFLIGHT_REVIEW.md` §7에서 이미 확인) 회귀 위험 없음.

### 구조적으로 위험한 영역
- **`adjustQuantity()`의 비원자성(TOCTOU)** — 지금은 잠재 위험이지만, §5의 연동이 만들어지는 순간 동시 결제 시 실제 데이터 손상(lost update, 음수 재고 차단 무력화)으로 즉시 전환된다.
- **음수 재고 차단이 "보장"이 아니라 "대개 맞음" 수준이라는 사실** — §6에서 확인했듯 비원자성과 결합돼 있어, 차단 로직이 있다는 사실만으로 안전하다고 간주하면 안 된다.

### 반드시 설계 분리해야 하는 영역
- **`Product`↔`InventoryItem` 매핑(결제-재고 자동연동)** — 신규 엔티티/컬럼이 필요해 현재 제약(테이블/컬럼 변경 금지) 밖. A-6+로 명시적으로 분리.
- **재고조사(棚卸) 구조화** — `CashCount`급 구조화는 신규 엔티티 필요, A-5 1차 범위(삭제정책) 밖.
- **`quantity`/이력 합산값 정합성 검증 로직** — 삭제정책과 별개의 독립 과제. 이력을 보존하는 것(§3)과 그 이력이 정확한지 확인하는 것(§1)은 서로 다른 문제이므로 같이 묶지 않는다.

### A-4 Staff 정책과 충돌 여부
**충돌 없음.** `A4_A5_PAYMENT_FLOW_VERIFICATION.md`가 이미 결론낸 대로, `InventoryLog.staffId`는 검증 대상이 아닌 "과거 기록" 범주에 속해 A-4(`assertNotRetired()`/`removeStaff()` 이원화)가 도입돼도 `InventoryRepository` 코드는 **한 줄도 영향받지 않는다**(`grep` 재확인 — 참조 0건). 향후 "재고 처리 권한자 검증"이 추가되더라도, `BookingRepository.createBooking()`/`updateBooking()`이 채택한 **같은 단일 조건(`accountStatus != '退職済み'`) + "신규 발생 시점에만 적용"** 원칙을 그대로 재사용하면 된다 — 새로운 규칙을 고안할 필요가 없다.
