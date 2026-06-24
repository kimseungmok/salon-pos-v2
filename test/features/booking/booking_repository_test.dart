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

  Future<String> aCustomer() async =>
      (await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678')).id;

  Future<String> aStaffOnShift(DateTime date) async {
    final s = await staffRepo.inviteStaff(name: 'Yuki', phone: '090-2222-3333');
    await staffRepo.setShift(
      staffId: s.id,
      date: date,
      startTime: DateTime(date.year, date.month, date.day, 9),
      endTime: DateTime(date.year, date.month, date.day, 18),
    );
    return s.id;
  }

  group('createBooking', () {
    test('정상 생성(담당자 없음)', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const ['p1'],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      expect(b.status, 'confirmed');
    });

    test('고객 미지정 → ValidationException', () async {
      expect(
        () => repo.createBooking(
          customerId: '',
          productIds: const ['p1'],
          startAt: DateTime(2026, 6, 23, 14),
          endAt: DateTime(2026, 6, 23, 15),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('메뉴 미선택 → ValidationException', () async {
      final cid = await aCustomer();
      expect(
        () => repo.createBooking(
          customerId: cid,
          productIds: const [],
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
          productIds: const ['p1'],
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
          productIds: const ['p1'],
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
          productIds: const ['p1'],
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
        productIds: const ['p1'],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      expect(
        () => repo.createBooking(
          customerId: cid,
          staffId: staffId,
          productIds: const ['p2'],
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
        productIds: const ['p1'],
        startAt: DateTime(2026, 6, 23, 14),
        endAt: DateTime(2026, 6, 23, 15),
      );
      final b2 = await repo.createBooking(
        customerId: cid,
        staffId: staffId,
        productIds: const ['p2'],
        startAt: DateTime(2026, 6, 23, 15),
        endAt: DateTime(2026, 6, 23, 16),
      );
      expect(b2.status, 'confirmed');
    });
  });

  group('cancelBooking (F-BOOK-04)', () {
    test('24시간 전 취소 → 예약금 환불', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const ['p1'],
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
        productIds: const ['p1'],
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
        productIds: const ['p1'],
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
        productIds: const ['p1'],
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
        () => repo.cancelBooking(bookingId: 'no-such-id', reason: 'customer_early'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('이미 취소된 예약 재취소 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const ['p1'],
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
        productIds: const ['p1'],
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
        productIds: const ['p1'],
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
        () => repo.completeBooking('no-such-id'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('이미 완료된 예약 재완료 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final b = await repo.createBooking(
        customerId: cid,
        productIds: const ['p1'],
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
        productIds: const ['p1'],
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
        productIds: const ['p1'],
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
        () => repo.callWaiting('no-such-id'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
