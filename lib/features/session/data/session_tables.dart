import 'package:drift/drift.dart';

/// A-8 SESSION ENGINE(docs/A8_SESSION_ENGINE.md). 살롱/카라오케/이자카야
/// 공통으로 동작하는 "전표(세션)" 엔진의 4개 테이블.
///
/// **기존 모듈과의 관계**: A-1~A-7의 Booking/Order/Payment/VisitRecord와
/// 의도적으로 FK를 걸지 않는다(완전 리디자인 단계의 신규 코어이며, 기존
/// 테이블은 수정하지 않는다는 제약 그대로). `refType`/`refId`로 느슨하게
/// 과거 도메인을 참조할 수 있는 자리만 마련해 둔다.
///
/// id는 기존 모듈들(UUID TextColumn)과 다르게 **autoincrement 정수**를
/// 쓴다 — 요청된 스펙 그대로이며, 전표번호(`sessionNo`)가 사람이 보는
/// 식별자 역할을 대신한다.
@DataClassName('PaymentSessionRow')
class PaymentSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 전표번호, 예: "2026-0001". 연도별로 0001부터 다시 시작(연도+4자리).
  TextColumn get sessionNo => text().unique()();
  IntColumn get shopId => integer().withDefault(const Constant(1))();

  /// 'salon' | 'karaoke' | 'izakaya'.
  TextColumn get businessType => text()();

  /// 향후 customer 모듈과의 연결 방식은 별도 결정 필요(design/spec/v3
  /// Customers.id는 UUID 문자열이라 이 정수형 컬럼과 직접 FK를 걸 수
  /// 없음 — 본 1차 구현에서는 비FK 정수 참조로만 둔다).
  IntColumn get customerId => integer().nullable()();

  /// A-9.5(docs/A9_ID_UNIFICATION.md 핫픽스): A-9 이후 실제 Staff.id가
  /// INTEGER로 통일됐으므로 같은 타입으로 맞춘다(향후 실제 Staff
  /// 테이블과 연결할 여지, 현재는 비FK).
  IntColumn get staffIdPrimary => integer().nullable()();
  IntColumn get roomId => integer().nullable()();

  /// 'open' | 'closed' | 'cancelled'.
  TextColumn get status => text().withDefault(const Constant('open'))();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime().nullable()();
  IntColumn get totalAmount => integer().withDefault(const Constant(0))();
  IntColumn get discountAmount => integer().withDefault(const Constant(0))();
  IntColumn get taxAmount => integer().withDefault(const Constant(0))();
  IntColumn get finalAmount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

}

@DataClassName('PaymentSessionItemRow')
class PaymentSessionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(PaymentSessions, #id)();

  /// 'service' | 'product' | 'time' | 'staff_fee' | 'discount' | 'surcharge'.
  TextColumn get itemType => text()();

  /// 'booking' | 'plu' | 'staff' | 'manual'.
  TextColumn get refType => text().nullable()();
  TextColumn get refId => text().nullable()();

  /// 당시 이름 스냅샷 — 원본(상품명 등)이 나중에 바뀌어도 전표에는
  /// 그 시점 이름이 그대로 남아야 한다(영수증 재현성).
  TextColumn get itemName => text()();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  IntColumn get unitPrice => integer()();
  IntColumn get amount => integer()();

  /// 수익 귀속 직원(지정금 핵심) — staff_fee뿐 아니라 service 항목에도
  /// 쓰일 수 있어 모든 item_type에 공통으로 둔다. A-9.5: Staff.id와
  /// 같은 INTEGER 타입으로 통일.
  IntColumn get staffId => integer().nullable()();

  /// 추가 메타(야간할증 등) — JSON 문자열, 구조는 호출자 책임.
  TextColumn get metaJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

}

@DataClassName('StaffEarningLedgerRow')
class StaffEarningLedgers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(PaymentSessions, #id)();
  IntColumn get sessionItemId =>
      integer().nullable().references(PaymentSessionItems, #id)();

  /// A-9.5: Staff.id와 같은 INTEGER 타입으로 통일.
  IntColumn get staffId => integer()();

  /// 'service' | 'commission' | 'staff_fee' | 'bonus'.
  TextColumn get earningType => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime()();

}

@DataClassName('PaymentMethodBreakdownRow')
class PaymentMethodBreakdowns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(PaymentSessions, #id)();

  /// 'cash' | 'card' | 'point' | 'gift' | 'transfer'.
  TextColumn get method => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get receivedAt => dateTime()();

}
