import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/session/data/session_repository.dart';

/// A-8 SESSION ENGINE(docs/A8_SESSION_ENGINE.md) 검증.
void main() {
  late AppDatabase db;
  late SessionRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = SessionRepository(db);
  });

  tearDown(() => db.close());

  group('createSession', () {
    test('1. status == open 확인', () async {
      final s = await repo.createSession(businessType: 'salon');
      expect(s.status, SessionStatus.open.value);
      expect(s.sessionNo, isNotEmpty);
    });

    test('잘못된 businessType → ValidationException', () {
      expect(
        () => repo.createSession(businessType: 'unknown'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('연도별 순번이 0001부터 증가', () async {
      final s1 = await repo.createSession(businessType: 'karaoke');
      final s2 = await repo.createSession(businessType: 'karaoke');
      final year = DateTime.now().year;
      expect(s1.sessionNo, '$year-0001');
      expect(s2.sessionNo, '$year-0002');
    });
  });

  group('addItem', () {
    test('2. totalAmount 정상 계산 확인', () async {
      final s = await repo.createSession(businessType: 'izakaya');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'product',
        itemName: '生ビール',
        qty: 2,
        unitPrice: 600,
      );
      await repo.addItem(
        sessionId: s.id,
        itemType: 'product',
        itemName: '唐揚げ',
        qty: 1,
        unitPrice: 500,
      );
      final updated = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(updated.totalAmount, 1700); // 600*2 + 500
      expect(updated.finalAmount, 1700);
    });

    test('3. staff_fee → earning_ledger 자동 생성 확인', () async {
      final s = await repo.createSession(businessType: 'salon');
      final item = await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 'staff-001',
      );
      final ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, hasLength(1));
      expect(ledgers.single.staffId, 'staff-001');
      expect(ledgers.single.earningType, 'staff_fee');
      expect(ledgers.single.amount, 1000);
      expect(ledgers.single.sessionItemId, item.id);
    });

    test('staff_fee인데 staffId 없으면 ledger 미생성', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
      );
      final ledgers = await (db.select(db.staffEarningLedgers)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(ledgers, isEmpty);
    });

    test('존재하지 않는 세션 → NotFoundException', () async {
      expect(
        () => repo.addItem(
          sessionId: 9999,
          itemType: 'product',
          itemName: 'x',
          unitPrice: 100,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('closeSession', () {
    test('4. status == closed 확인', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      final closed = await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(closed.status, SessionStatus.closed.value);
      expect(closed.endAt, isNotNull);
    });

    test('5. closeSession 후 addItem → BusinessRuleException(guard 동작)', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(
        () => repo.addItem(
          sessionId: s.id,
          itemType: 'product',
          itemName: 'シャンプー',
          unitPrice: 1000,
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('8. 결제수단 합계 != final_amount → closeSession 거부 확인', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      expect(
        () => repo.closeSession(
          sessionId: s.id,
          paymentMethods: const [(method: 'cash', amount: 3000)],
        ),
        throwsA(isA<BusinessRuleException>()),
      );
      // 거부 후에도 세션은 여전히 open으로 남아있어야 한다.
      final stillOpen = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(stillOpen.status, SessionStatus.open.value);
    });

    test('분할결제(여러 결제수단) 합계가 일치하면 정상 마감', () async {
      final s = await repo.createSession(businessType: 'izakaya');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'product',
        itemName: 'コース',
        unitPrice: 8000,
      );
      final closed = await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [
          (method: 'cash', amount: 3000),
          (method: 'card', amount: 5000),
        ],
      );
      expect(closed.status, SessionStatus.closed.value);
      final breakdowns = await (db.select(db.paymentMethodBreakdowns)
            ..where((t) => t.sessionId.equals(s.id)))
          .get();
      expect(breakdowns, hasLength(2));
    });

    test('이미 closed인 세션 재마감 시도 → BusinessRuleException', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(
        () => repo.closeSession(
          sessionId: s.id,
          paymentMethods: const [(method: 'cash', amount: 5000)],
        ),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('cancelSession', () {
    test('6. status == cancelled 확인', () async {
      final s = await repo.createSession(businessType: 'karaoke');
      await repo.cancelSession(s.id);
      final found = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(found.status, SessionStatus.cancelled.value);
    });

    test('7. closed 세션에 cancelSession → BusinessRuleException', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'service',
        itemName: 'カット',
        unitPrice: 5000,
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 5000)],
      );
      expect(
        () => repo.cancelSession(s.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('이미 cancelled인 세션 재취소 → 멱등(예외 없이 유지)', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.cancelSession(s.id);
      await repo.cancelSession(s.id); // 재호출 — 예외 없이 통과해야 함
      final found = await (db.select(db.paymentSessions)
            ..where((t) => t.id.equals(s.id)))
          .getSingle();
      expect(found.status, SessionStatus.cancelled.value);
    });

    test('존재하지 않는 세션 취소 → NotFoundException', () async {
      expect(
        () => repo.cancelSession(9999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getSessionSummary', () {
    test('session + items + earning + payment 전부 조합', () async {
      final s = await repo.createSession(businessType: 'salon');
      await repo.addItem(
        sessionId: s.id,
        itemType: 'staff_fee',
        itemName: '指名料',
        unitPrice: 1000,
        staffId: 'staff-001',
      );
      await repo.closeSession(
        sessionId: s.id,
        paymentMethods: const [(method: 'cash', amount: 1000)],
      );
      final summary = await repo.getSessionSummary(s.id);
      expect(summary.session.status, SessionStatus.closed.value);
      expect(summary.items, hasLength(1));
      expect(summary.earnings, hasLength(1));
      expect(summary.payments, hasLength(1));
    });
  });
}
