import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/booking/data/booking_repository.dart';
import 'package:salon_pos_v2/features/customer/data/customer_repository.dart';
import 'package:salon_pos_v2/features/staff/data/staff_repository.dart';

/// design/spec/v3/booking/feature_spec.md F-BOOK-02/02a/04 검증.
void main() {
  late AppDatabase db;
  late BookingRepository repo;
  late StaffRepository staffRepo;
  late CustomerRepository customerRepo;

  setUp(() {
    db = AppDatabase.forTesting();
    staffRepo = StaffRepository(db);
    customerRepo = CustomerRepository(db);
    repo = BookingRepository(db, staffRepo);
  });

  tearDown(() => db.close());

  Future<int> aCustomer() async =>
      (await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678')).id;

  int staffPhoneSeq = 0;
  Future<int> aStaffOnShift(DateTime date) async {
    staffPhoneSeq++;
    final phone = '090-2222-${staffPhoneSeq.toString().padLeft(4, '0')}';
    final s = await staffRepo.inviteStaff(name: 'Yuki', phone: phone);
    await staffRepo.setShift(
      staffId: s.id,
      date: date,
      startTime: DateTime(date.year, date.month, date.day, 9),
      endTime: DateTime(date.year, date.month, date.day, 18),
    );
    return s.id;
  }

  /// A-4 검증용: 재직중(連結済み) 상태를 거쳐 退職済み로 전환된 직원.
  Future<int> aRetiredStaffOnShift(DateTime date) async {
    final id = await aStaffOnShift(date);
    final staff = await (db.select(db.staff)..where((t) => t.id.equals(id))).getSingle();
    await db.into(db.staff).insertOnConflictUpdate(
          StaffCompanion(
            id: Value(staff.id),
            name: Value(staff.name),
            phone: Value(staff.phone),
            accountStatus: const Value('連結済み'),
          ),
        );
    await staffRepo.removeStaff(id); // 連結済み → 退職済み 전환
    return id;
  }

  group('createBooking', () {
    test('정상 생성(담당자 없음)', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      expect(b.status, 'confirmed');
    });

    test('메뉴 미선택 → ValidationException', () async {
      final cid = await aCustomer();
      expect(
        () => repo.createBooking(
          customerId: cid,
          productIds: const <int>[],
          startAt: DateTime(2026, 6, 23, 14),
          endAt: DateTime(2026, 6, 23, 15),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('종료시각이 시작시각보다 빠름 → ValidationException', () async {
      final cid = await aCustomer();
      expect(
        () => repo.createBooking(
          customerId: cid,
          productIds: const [1],
          startAt: DateTime(2026, 6, 23, 15),
          endAt: DateTime(2026, 6, 23, 14),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('예약금 ON인데 금액 누락 → ValidationException', () async {
      final cid = await aCustomer();
      expect(
        () => repo.createBooking(
          customerId: cid,
          productIds: const [1],
          startAt: DateTime(2026, 6, 23, 14),
          endAt: DateTime(2026, 6, 23, 15),
          depositEnabled: true,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('담당자가 휴무일 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final staff = await staffRepo.inviteStaff(name: 'Kenji', phone: '090-9999-0000');
      expect(
        () => repo.createBooking(
          customerId: cid,
          staffId: staff.id,
          productIds: const [1],
          startAt: DateTime(2026, 6, 23, 14),
          endAt: DateTime(2026, 6, 23, 15),
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('담당자 시간대 중복 예약 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final staffId = await aStaffOnShift(DateTime(2026, 6, 23));
      await repo.createBooking(
        customerId: cid,
        staffId: staffId,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      expect(
        () => repo.createBooking(
          customerId: cid,
          staffId: staffId,
          productIds: const [2],
          startAt: DateTime(2026, 6, 23, 14, 30),
          endAt: DateTime(2026, 6, 23, 15, 30),
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('담당자 시간대 겹치지 않으면 정상 생성', () async {
      final cid = await aCustomer();
      final staffId = await aStaffOnShift(DateTime(2026, 6, 23));
      await repo.createBooking(
        customerId: cid,
        staffId: staffId,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      final b2 = await repo.createBooking(
        customerId: cid,
        staffId: staffId,
        productIds: const [2],
        startAt: DateTime(2026, 6, 23, 15),
        endAt: DateTime(2026, 6, 23, 16),
      );
      expect(b2.status, 'confirmed');
    });

    test('퇴직 처리된 담당자에게 신규 예약 배정 시도 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final retiredStaffId = await aRetiredStaffOnShift(DateTime(2026, 6, 23));
      expect(
        () => repo.createBooking(
          customerId: cid,
          staffId: retiredStaffId,
          productIds: const [1],
          startAt: DateTime(2026, 6, 23, 14),
          endAt: DateTime(2026, 6, 23, 15),
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('cancelBooking (F-BOOK-04)', () {
    test('24시간 전 취소 → 예약금 환불', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
        depositEnabled: true,
        depositAmount: 20000,
        depositReceived: true,
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'customer_early');
      final updated = await (db.select(db.bookings)..where((t) => t.id.equals(b.id)))
          .getSingle();
      expect(updated.status, 'cancelled');
      expect(updated.depositRefunded, true);
    });

    test('노쇼 → 예약금 환불 불가', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
        depositEnabled: true,
        depositAmount: 20000,
        depositReceived: true,
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'customer_late_or_noshow');
      final updated = await (db.select(db.bookings)..where((t) => t.id.equals(b.id)))
          .getSingle();
      expect(updated.status, 'noshow');
      expect(updated.depositRefunded, false);
    });

    test('매장사정 취소 → 예약금 환불', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
        depositEnabled: true,
        depositAmount: 20000,
        depositReceived: true,
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'salon_fault');
      final updated = await (db.select(db.bookings)..where((t) => t.id.equals(b.id)))
          .getSingle();
      expect(updated.depositRefunded, true);
    });

    test('잘못된 reason 값 → ValidationException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      expect(
        () => repo.cancelBooking(bookingId: b.id, reason: 'invalid'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('존재하지 않는 예약 → NotFoundException', () async {
      expect(
        () => repo.cancelBooking(bookingId: 999999, reason: 'customer_early'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('이미 취소된 예약 재취소 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'customer_early');
      expect(
        () => repo.cancelBooking(bookingId: b.id, reason: 'customer_early'),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('completeBooking (A-2)', () {
    test('정상 완료 처리', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.completeBooking(b.id);
      final updated = await (db.select(db.bookings)..where((t) => t.id.equals(b.id)))
          .getSingle();
      expect(updated.status, 'completed');
    });

    test('예약금이 있어도 depositReceived/depositRefunded는 건드리지 않음', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
        depositEnabled: true,
        depositAmount: 20000,
        depositReceived: true,
      );
      await repo.completeBooking(b.id);
      final updated = await (db.select(db.bookings)..where((t) => t.id.equals(b.id)))
          .getSingle();
      expect(updated.status, 'completed');
      expect(updated.depositReceived, true);
      expect(updated.depositRefunded, false);
    });

    test('존재하지 않는 예약 → NotFoundException', () async {
      expect(
        () => repo.completeBooking(999999),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('이미 완료된 예약 재완료 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.completeBooking(b.id);
      expect(
        () => repo.completeBooking(b.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('취소된 예약을 완료 처리 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'customer_early');
      expect(
        () => repo.completeBooking(b.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('노쇼 처리된 예약을 완료 처리 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'customer_late_or_noshow');
      expect(
        () => repo.completeBooking(b.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('updateBooking (A-3)', () {
    test('시간만 변경', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      final updated = await repo.updateBooking(
        bookingId: b.id,
        startAt: DateTime(2026, 6, 23, 16),
        endAt: DateTime(2026, 6, 23, 17),
      );
      expect(updated.startAt, DateTime(2026, 6, 23, 16));
      expect(updated.endAt, DateTime(2026, 6, 23, 17));
      expect(updated.status, 'confirmed');
    });

    test('담당자만 변경 — 새 담당자 가용성 검증', () async {
      final cid = await aCustomer();
      final staffA = await aStaffOnShift(DateTime(2026, 6, 23));
      final staffB = await aStaffOnShift(DateTime(2026, 6, 23));
      final b = await repo.createBooking(
        customerId: cid,
        staffId: staffA,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      final updated = await repo.updateBooking(bookingId: b.id, staffId: staffB);
      expect(updated.staffId, staffB);
    });

    test('동일 예약의 시간 변경 시 자기 자신과 충돌판정되지 않음(자기 제외)', () async {
      final cid = await aCustomer();
      final staffId = await aStaffOnShift(DateTime(2026, 6, 23));
      final b = await repo.createBooking(
        customerId: cid,
        staffId: staffId,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      // 같은 담당자, 거의 같은 시간대로 "변경"해도 자기 자신은 제외되어
      // BusinessRuleException이 발생하지 않아야 한다.
      final updated = await repo.updateBooking(
        bookingId: b.id,
        startAt: DateTime(2026, 6, 23, 14, 30),
        endAt: DateTime(2026, 6, 23, 15, 30),
      );
      expect(updated.startAt, DateTime(2026, 6, 23, 14, 30));
    });

    test('변경 후 시간이 다른 기존 예약과 충돌 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final staffId = await aStaffOnShift(DateTime(2026, 6, 23));
      await repo.createBooking(
        customerId: cid,
        staffId: staffId,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 16),
        endAt: DateTime(2026, 6, 23, 17),
      );
      final b2 = await repo.createBooking(
        customerId: cid,
        staffId: staffId,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 10),
        endAt: DateTime(2026, 6, 23, 11),
      );
      expect(
        () => repo.updateBooking(
          bookingId: b2.id,
          startAt: DateTime(2026, 6, 23, 16, 30),
          endAt: DateTime(2026, 6, 23, 17, 30),
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('종료시각이 시작시각보다 빠르게 변경 시도 → ValidationException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      expect(
        () => repo.updateBooking(
          bookingId: b.id,
          startAt: DateTime(2026, 6, 23, 16),
          endAt: DateTime(2026, 6, 23, 15),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('존재하지 않는 예약 → NotFoundException', () async {
      expect(
        () => repo.updateBooking(bookingId: 999999, startAt: DateTime(2026, 6, 23, 16)),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('완료된 예약 변경 시도 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.completeBooking(b.id);
      expect(
        () => repo.updateBooking(bookingId: b.id, startAt: DateTime(2026, 6, 23, 16)),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('취소된 예약 변경 시도 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'customer_early');
      expect(
        () => repo.updateBooking(bookingId: b.id, startAt: DateTime(2026, 6, 23, 16)),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('노쇼 처리된 예약 변경 시도 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      await repo.cancelBooking(bookingId: b.id, reason: 'customer_late_or_noshow');
      expect(
        () => repo.updateBooking(bookingId: b.id, startAt: DateTime(2026, 6, 23, 16)),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('예약금 필드는 변경되지 않음', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
        depositEnabled: true,
        depositAmount: 20000,
        depositReceived: true,
      );
      final updated = await repo.updateBooking(
        bookingId: b.id,
        startAt: DateTime(2026, 6, 23, 16),
        endAt: DateTime(2026, 6, 23, 17),
      );
      expect(updated.depositReceived, true);
      expect(updated.depositAmount, 20000);
    });

    test('A-4: 담당자가 그 사이 퇴직해도, 시간만 바꾸는 변경은 차단되지 않음', () async {
      final cid = await aCustomer();
      final retiredStaffId = await aRetiredStaffOnShift(DateTime(2026, 6, 23));
      // 예약은 담당자가 재직중일 때 생성됐다고 가정 — 직접 DB에 confirmed
      // 예약을 넣어 "이미 배정된 뒤 담당자가 퇴직한" 상황을 재현한다.
      final bookingId = await db.into(db.bookings).insert(
            BookingsCompanion.insert(
              customerId: cid,
              staffId: Value(retiredStaffId),
              startAt: DateTime(2026, 6, 23, 14),
              endAt: DateTime(2026, 6, 23, 15),
            ),
          );
      final updated = await repo.updateBooking(
        bookingId: bookingId,
        startAt: DateTime(2026, 6, 23, 16),
        endAt: DateTime(2026, 6, 23, 17),
      );
      expect(updated.startAt, DateTime(2026, 6, 23, 16));
      expect(updated.staffId, retiredStaffId);
    });

    test('A-4: 같은(퇴직한) 담당자를 명시적으로 다시 지정해도 검증 생략', () async {
      final cid = await aCustomer();
      final retiredStaffId = await aRetiredStaffOnShift(DateTime(2026, 6, 23));
      final bookingId = await db.into(db.bookings).insert(
            BookingsCompanion.insert(
              customerId: cid,
              staffId: Value(retiredStaffId),
              startAt: DateTime(2026, 6, 23, 14),
              endAt: DateTime(2026, 6, 23, 15),
            ),
          );
      final updated = await repo.updateBooking(
        bookingId: bookingId,
        staffId: retiredStaffId, // 동일 담당자 — "변경"이 아님
        startAt: DateTime(2026, 6, 23, 16),
        endAt: DateTime(2026, 6, 23, 17),
      );
      expect(updated.staffId, retiredStaffId);
    });

    test('A-4: 퇴직한 담당자로 실제로 변경 시도 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const [1],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      final retiredStaffId = await aRetiredStaffOnShift(DateTime(2026, 6, 23));
      expect(
        () => repo.updateBooking(bookingId: b.id, staffId: retiredStaffId),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('waiting (F-BOOK-03)', () {
    test('정상 추가', () async {
      final w = await repo.addWaiting(customerName: '森かれん');
      expect(w.status, 'waiting');
    });

    test('이름 공백 → ValidationException', () async {
      expect(
        () => repo.addWaiting(customerName: '  '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('호출 처리', () async {
      final w = await repo.addWaiting(customerName: '森かれん');
      await repo.callWaiting(w.id);
      final updated =
          await (db.select(db.waitingEntries)..where((t) => t.id.equals(w.id)))
              .getSingle();
      expect(updated.status, 'called');
    });

    test('존재하지 않는 항목 호출 → NotFoundException', () async {
      expect(
        () => repo.callWaiting(999999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
