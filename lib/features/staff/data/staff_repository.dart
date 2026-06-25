import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';

const _uuid = Uuid();

/// design/spec/v3/staff/feature_spec.md F-STAFF-00/01 그대로 구현.
///
/// **F-STAFF-00 — 절대 원칙**: 이 레포지토리에는 PIN·권한레벨을 쓰는
/// 메서드를 추가하지 않는다. 토스 전체에 그런 화면이 없고(F-STAFF-00
/// 근거), 본 앱도 그 범위를 넘지 않는다. [Staff.role]은 표시 전용으로만
/// 읽는다.
class StaffRepository {
  StaffRepository(this._db);

  final AppDatabase _db;

  Stream<List<StaffRow>> watchStaff() {
    return (_db.select(_db.staff)
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  /// F-STAFF-01: 이름+휴대폰번호만으로 초대. 로그인ID/PIN/권한레벨
  /// 입력란은 의도적으로 만들지 않는다.
  Future<StaffRow> inviteStaff({
    required String name,
    required String phone,
  }) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException('スタッフ名を入力してください。');
    }
    if (!RegExp(r'^0\d{9,10}$').hasMatch(trimmedPhone.replaceAll('-', ''))) {
      throw const ValidationException('携帯電話番号を正しい形式で入力してください（例：090-1234-5678）。');
    }

    try {
      final duplicate = await (_db.select(_db.staff)
            ..where((s) => s.phone.equals(trimmedPhone)))
          .getSingleOrNull();
      if (duplicate != null) {
        throw BusinessRuleException('この携帯電話番号は既に登録されています。');
      }

      final id = _uuid.v4();
      final now = DateTime.now();
      await _db.into(_db.staff).insert(
            StaffCompanion.insert(
              id: id,
              name: trimmedName,
              phone: trimmedPhone,
              accountStatus: const Value('待機中'),
              invitedAt: Value(now),
            ),
          );
      // 알림톡/SMS 발송은 인프라 영역(외부 연동) — 본 레포지토리 범위 외.
      return StaffRow(
        id: id,
        name: trimmedName,
        phone: trimmedPhone,
        role: 'スタイリスト',
        accountStatus: '待機中',
        invitedAt: now,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// 대기중 상태에서만 재전송 가능.
  Future<void> resendInvite(String staffId) async {
    try {
      final staff = await (_db.select(_db.staff)
            ..where((s) => s.id.equals(staffId)))
          .getSingleOrNull();
      if (staff == null) {
        throw const NotFoundException('スタッフが見つかりませんでした。');
      }
      if (staff.accountStatus != '待機中') {
        throw const BusinessRuleException('連結済みのスタッフには再送信できません。');
      }
      await (_db.update(_db.staff)..where((s) => s.id.equals(staffId)))
          .write(StaffCompanion(invitedAt: Value(DateTime.now())));
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// A-4(design/spec/v3/STAFF_ACCOUNT_STATUS_SPEC.md §3-2): 삭제 대신
  /// 상태 기반으로 처리하되, 보존할 이력이 있는지에 따라 이원화한다.
  /// - `accountStatus == '連結済み'`(정식 연결완료, 재직 중이었던 직원):
  ///   하드 삭제하지 않고 `'退職済み'`로 상태 전환한다. `Shift`/`Booking`/
  ///   `OrderItem`/`VisitRecord` 등이 이 `staffId`를 참조할 수 있어,
  ///   행 자체를 지우면 과거 기록에서 이름이 사라지는 고아참조가 생긴다
  ///   (`DESIGN_REVIEW.md` §5에서 식별된 문제의 해결).
  /// - 그 외(`null`/`'待機中'`, 정식 연결 전): 보존할 이력이 구조적으로
  ///   없으므로 기존 그대로 하드 삭제를 유지한다.
  ///
  /// A-7(design/spec/v3/A6_FLOW_INTEGRATION_DESIGN.md §4/§6에서 식별된
  /// 비멱등성 결함 수정): `'退職済み'`에 대해 다시 호출하면 **아무 동작도
  /// 하지 않고 그대로 반환**한다 — 수정 전에는 이 분기가 빠져있어 `else`
  /// (하드삭제)로 떨어졌고, 이미 보존해야 할 이력이 있는 행을 실수로
  /// 영구 삭제할 위험이 있었다. "같은 요청을 반복해도 상태가 변하지
  /// 않는다"는 멱등성 원칙을 모든 상태전이 메서드에 통일 적용한다.
  Future<void> removeStaff(String staffId) async {
    try {
      final staff = await (_db.select(_db.staff)
            ..where((s) => s.id.equals(staffId)))
          .getSingleOrNull();
      if (staff == null) {
        throw const NotFoundException('スタッフが見つかりませんでした（既に削除されている可能性があります）。');
      }

      if (staff.accountStatus == '退職済み') {
        return; // 이미 퇴직 처리됨 — 멱등, 아무 동작 없음
      }

      if (staff.accountStatus == '連結済み') {
        await (_db.update(_db.staff)..where((s) => s.id.equals(staffId)))
            .write(const StaffCompanion(accountStatus: Value('退職済み')));
      } else {
        await (_db.delete(_db.staff)..where((s) => s.id.equals(staffId)))
            .go();
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// A-4: 신규 배정 시점에만 적용하는 퇴사 검증(design/spec/v3/
  /// STAFF_ACCOUNT_STATUS_SPEC.md §2-1, A4_PRE_IMPLEMENTATION_IMPACT_CHECK.md
  /// §1-2). 호출 시점(언제 이 메서드를 부를지)은 호출자(BookingRepository)
  /// 의 책임이다 — 이 메서드 자체는 단순히 "지금 이 staffId가 퇴사
  /// 상태인가"만 판정한다.
  Future<void> assertNotRetired(String staffId) async {
    try {
      final staff = await (_db.select(_db.staff)
            ..where((s) => s.id.equals(staffId)))
          .getSingleOrNull();
      if (staff == null) {
        throw const NotFoundException('スタッフが見つかりませんでした。');
      }
      if (staff.accountStatus == '退職済み') {
        throw const BusinessRuleException('退職したスタッフを新しい予約に割り当てることはできません。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  // ── Shift (F-STAFF-03, UI는 다음 차수 — booking 모듈 연동용 데이터만 우선 제공) ──

  Stream<List<ShiftRow>> watchShiftsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.shifts)
          ..where((s) => s.date.isBiggerOrEqualValue(start) & s.date.isSmallerThanValue(end)))
        .watch();
  }

  Future<void> setShift({
    required String staffId,
    required DateTime date,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if ((startTime == null) != (endTime == null)) {
      throw const ValidationException('開始時刻と終了時刻は両方入力するか、両方空にしてください（空＝休み）。');
    }
    if (startTime != null && endTime != null && !startTime.isBefore(endTime)) {
      throw const ValidationException('終了時刻は開始時刻より後にしてください。');
    }
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final existing = await (_db.select(_db.shifts)
            ..where((s) =>
                s.staffId.equals(staffId) & s.date.equals(dateOnly)))
          .getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.shifts)..where((s) => s.id.equals(existing.id)))
            .write(ShiftsCompanion(
          startTime: Value(startTime),
          endTime: Value(endTime),
        ));
      } else {
        await _db.into(_db.shifts).insert(
              ShiftsCompanion.insert(
                id: _uuid.v4(),
                staffId: staffId,
                date: dateOnly,
                startTime: Value(startTime),
                endTime: Value(endTime),
              ),
            );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// design/spec/v3/staff/data_spec.md `staffAvailability()` 그대로.
  /// booking 모듈(M4)이 이 메서드를 호출해 담당자 칩의 空き/予約あり/休み
  /// 를 판정한다(예약 중복여부 판단은 booking 쪽 책임이라 이 함수는
  /// 시프트 유무만 본다).
  Future<bool> isOnShift(String staffId, DateTime dateTime) async {
    try {
      final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final shift = await (_db.select(_db.shifts)
            ..where((s) =>
                s.staffId.equals(staffId) & s.date.equals(dateOnly)))
          .getSingleOrNull();
      if (shift == null || shift.startTime == null || shift.endTime == null) {
        return false; // 휴무
      }
      return !dateTime.isBefore(shift.startTime!) &&
          dateTime.isBefore(shift.endTime!);
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }
}
