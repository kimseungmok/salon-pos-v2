import 'package:drift/drift.dart';

/// design/spec/v3/staff/data_spec.md "엔티티: Staff" 그대로.
/// F-STAFF-00: 권한/PIN은 본 앱에서 절대 쓰기 불가 — [role]은 표시
/// 전용이며, 외부 통근관리시스템에서 동기화되는 값이라고 가정한다.
@DataClassName('StaffRow')
class Staff extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 30)();
  TextColumn get phone => text()();

  /// 표시 전용. 본 앱(POS)에서는 절대 수정 UI를 만들지 않는다.
  TextColumn get role => text().withDefault(const Constant('スタイリスト'))();

  /// F-STAFF-01: 招待 흐름 결과. 초대 안 한 스태프는 null.
  TextColumn get accountStatus => text().nullable()();
  DateTimeColumn get invitedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/staff/data_spec.md "엔티티: Shift" 그대로.
/// booking 모듈(F-BOOK-02)의 staffAvailability()가 이 테이블을 참조한다
/// (M4에서 본격 사용, 화면 UI는 다음 차수).
@DataClassName('ShiftRow')
class Shifts extends Table {
  TextColumn get id => text()();
  TextColumn get staffId =>
      text().references(Staff, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();

  /// null이면 휴무일.
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
