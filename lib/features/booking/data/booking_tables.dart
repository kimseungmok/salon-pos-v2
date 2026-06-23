import 'package:drift/drift.dart';

/// design/spec/v3/booking/data_spec.md "엔티티: Booking" 그대로.
///
/// 구현상 단순화 메모(M4, resumable 작업 기록): [productIds]는 본래
/// `string[]`이지만, payment_pos(M5)가 아직 없어 정식 Payment 엔티티도
/// 없는 상태다. 그래서:
/// - 상품 목록은 쉼표구분 텍스트로 저장(다대다 join 테이블은 과설계 —
///   예약은 보통 상품 1~3개뿐이라 텍스트 split이 충분히 단순하고 빠름)
/// - 예약금은 F-PAY의 Payment 엔티티를 참조하지 않고 [depositReceived]/
///   [depositRefunded] 불리언으로 Booking 안에서 직접 추적한다. M5에서
///   진짜 결제(Payment)와 연동할 때 이 필드들을 점진적으로 교체한다.
@DataClassName('BookingRow')
class Bookings extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text()();
  TextColumn get staffId => text().nullable()();

  /// 쉼표구분 Product.id 목록(위 메모 참조).
  TextColumn get productIdsCsv => text().withDefault(const Constant(''))();

  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime()();

  BoolColumn get depositEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get depositMethod => text().nullable()();
  IntColumn get depositAmount => integer().nullable()();
  BoolColumn get depositReceived =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get depositRefunded =>
      boolean().withDefault(const Constant(false))();
  TextColumn get refundNote =>
      text().withDefault(const Constant('返金は24時間以内に可能です。'))();

  TextColumn get repeatRule => text().withDefault(const Constant('none'))();
  TextColumn get memo => text().nullable()();
  BoolColumn get requiresApproval =>
      boolean().withDefault(const Constant(false))();

  /// confirmed/completed/noshow/cancelled.
  TextColumn get status => text().withDefault(const Constant('confirmed'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/booking/data_spec.md "엔티티: WaitingEntry" 그대로.
/// F-BOOK-03 — 토스 근거 없는 살롱 고유 자산.
@DataClassName('WaitingEntryRow')
class WaitingEntries extends Table {
  TextColumn get id => text()();
  TextColumn get customerName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get menuNote => text().nullable()();
  TextColumn get preferredStaffId => text().nullable()();
  DateTimeColumn get checkInAt => dateTime()();
  IntColumn get sortOrder => integer()();

  /// waiting/called/seated/cancelled.
  TextColumn get status => text().withDefault(const Constant('waiting'))();

  @override
  Set<Column> get primaryKey => {id};
}
