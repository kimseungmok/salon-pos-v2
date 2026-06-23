# 顧客管理 (고객관리) — 데이터 정의서

## 엔티티: Customer

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| name | string | |
| phone | string | E.164 또는 일본 휴대폰 포맷(090/080/070-XXXX-XXXX). 표시 시에만 마스킹, 저장은 원본 |
| memo | string \| null | F-CUST-02. 권한: owner만 read/write |
| points | integer | 보유 포인트(P) |
| createdAt | datetime | 최초 등록일 |
| birthday | date \| null | F-CUST-05 통계용 |
| tags | string[] | VIP/ブラック 등 수동 태그(그룹 자동분류와 별개) |

> **주의**: 구 버전(v2 ja_toss100 09)에서 쓰던 정적 `tag` 필드와 `bdayMonth` 필드는 폐기. 그룹은 항상 `groupOf()` 동적 계산 결과를 사용하고, 저장하지 않는다(저장된 그룹 값과 실제 방문이력이 어긋나는 버그를 막기 위함).

## 엔티티: VisitRecord (방문 이력)

| 필드 | 타입 | 설명 |
|---|---|---|
| id | string (PK) | |
| customerId | string (FK → Customer) | |
| visitDate | datetime | 시술 시작 또는 체크인 시각 |
| staffId | string (FK → Staff) | 담당자 |
| menuIds | string[] | 시술 메뉴 |
| amount | integer | 결제 금액(¥) |
| status | enum(`completed`, `noshow`, `cancelled`) | F-CUST-01 그룹 산출 시 `completed`만 카운트 |

## 산출 로직: groupOf(customer)

```ts
type Group = 'first' | 'preRegular' | 'regular' | 'dormant';

function groupOf(customer: Customer, visits: VisitRecord[], today: Date): Group {
  const completedVisits = visits
    .filter(v => v.customerId === customer.id && v.status === 'completed')
    .sort((a, b) => b.visitDate.getTime() - a.visitDate.getTime());

  if (completedVisits.length === 0) return 'first'; // 예약만 있고 방문 전
  if (completedVisits.length === 1) return 'first';

  const lastVisit = completedVisits[0].visitDate;
  const daysSinceLastVisit = diffInDays(today, lastVisit);

  const visits90d = completedVisits.filter(
    v => diffInDays(today, v.visitDate) <= 90
  ).length;

  if (daysSinceLastVisit >= 45) return 'dormant';
  if (visits90d >= 7) return 'regular';
  return 'preRegular';
}
```

- `GROUP_LABEL`: `{first:'初回来店', preRegular:'予備常連', regular:'常連', dormant:'休眠ぎみ'}`
- `GROUP_ICON`: `{first:'🐣', preRegular:'🟡', regular:'🔴', dormant:'⚪'}`
- **재계산 시점**: 화면 렌더링 시점에 항상 즉시 재계산(서버 측에서 캐싱하더라도 방문 완료/취소 트리거 시 invalidate). 별도 배치잡 불필요.

## 화면 간 데이터 의존

| 화면 | 사용 방식 |
|---|---|
| 09 顧客リスト | 전체 고객에 `groupOf()` 적용 후 탭별 필터/카운트 |
| 10 顧客詳細 | 해당 고객 1명에 `groupOf()` 적용 후 헤더에 표시 |
| 06 予約カレンダー | 예약 클릭 팝업에 고객 그룹 표시(향후 연동 시) |
| 17 売上レポート(고객분석 탭, 미정) | 그룹별 매출 집계 시 동일 함수 재사용 |

`groupOf()`는 프론트엔드 공용 유틸(`lib/customerGroup.ts` 등 단일 모듈)로 두고 화면마다 재구현하지 않는다 — v2 단계에서 09/10 두 화면에 각각 구현되어 있던 것을 v3에서는 통합 권장.
