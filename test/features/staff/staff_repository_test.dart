import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/staff/data/staff_repository.dart';

/// design/spec/v3/staff/feature_spec.md F-STAFF-01 규칙 검증.
/// 정상 케이스 + 예외 케이스(F-STAFF-00 위반 방지 포함) 전수 테스트.
void main() {
  late AppDatabase db;
  late StaffRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = StaffRepository(db);
  });

  tearDown(() => db.close());

  group('inviteStaff', () {
    test('정상 초대 → 待機中 상태로 생성', () async {
      final s = await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      expect(s.accountStatus, '待機中');
      expect(s.name, 'Yuki');
    });

    test('이름 공백 → ValidationException', () async {
      expect(
        () => repo.inviteStaff(name: '  ', phone: '090-1234-5678'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('전화번호 형식 오류 → ValidationException', () async {
      expect(
        () => repo.inviteStaff(name: 'Yuki', phone: '1234'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('중복 전화번호 → BusinessRuleException', () async {
      await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      expect(
        () => repo.inviteStaff(name: 'Mika', phone: '090-1234-5678'),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('resendInvite', () {
    test('대기중 상태에서는 재전송 성공', () async {
      final s = await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      await repo.resendInvite(s.id); // 예외 없이 통과해야 함
    });

    test('연결완료 상태에서는 재전송 불가 → BusinessRuleException', () async {
      final s = await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      // 연결완료로 전환(실제로는 외부 동의 흐름, 테스트에서는 직접 갱신)
      await db.into(db.staff).insertOnConflictUpdate(
            StaffCompanion(
              id: Value(s.id),
              name: Value(s.name),
              phone: Value(s.phone),
              accountStatus: const Value('連結済み'),
            ),
          );
      expect(
        () => repo.resendInvite(s.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('존재하지 않는 스태프 → NotFoundException', () async {
      expect(
        () => repo.resendInvite('no-such-id'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('removeStaff', () {
    test('존재하지 않는 스태프 삭제 → NotFoundException', () async {
      expect(
        () => repo.removeStaff('no-such-id'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('isOnShift (F-BOOK-02 연동 — staffAvailability 기반)', () {
    test('시프트가 없으면 휴무로 판정(false)', () async {
      final s = await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      final result = await repo.isOnShift(s.id, DateTime(2026, 6, 23, 14, 0));
      expect(result, false);
    });

    test('시프트 시간 내면 true, 밖이면 false', () async {
      final s = await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      await repo.setShift(
        staffId: s.id,
        date: DateTime(2026, 6, 23),
        startTime: DateTime(2026, 6, 23, 9, 0),
        endTime: DateTime(2026, 6, 23, 18, 0),
      );
      expect(
        await repo.isOnShift(s.id, DateTime(2026, 6, 23, 14, 0)),
        true,
      );
      expect(
        await repo.isOnShift(s.id, DateTime(2026, 6, 23, 20, 0)),
        false,
      );
    });

    test('시작/종료 중 하나만 입력 → ValidationException', () async {
      final s = await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      expect(
        () => repo.setShift(
          staffId: s.id,
          date: DateTime(2026, 6, 23),
          startTime: DateTime(2026, 6, 23, 9, 0),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('종료시각이 시작시각보다 빠름 → ValidationException', () async {
      final s = await repo.inviteStaff(name: 'Yuki', phone: '090-1234-5678');
      expect(
        () => repo.setShift(
          staffId: s.id,
          date: DateTime(2026, 6, 23),
          startTime: DateTime(2026, 6, 23, 18, 0),
          endTime: DateTime(2026, 6, 23, 9, 0),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
