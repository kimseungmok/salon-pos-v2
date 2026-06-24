import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/cash_management/data/cash_repository.dart';

void main() {
  late AppDatabase db;
  late CashManagementRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = CashManagementRepository(db);
  });

  tearDown(() => db.close());

  group('recordCount (F-CASH-02)', () {
    test('정상 기록 — 총액/차액 계산', () async {
      final c = await repo.recordCount(
        type: 'open',
        date: DateTime(2026, 6, 23),
        denominations: {10000: 2, 500: 3},
        expectedAmount: 50000,
      );
      expect(c.totalAmount, 21500);
      expect(c.diffAmount, 21500 - 50000);
    });

    test('잘못된 type → ValidationException', () async {
      expect(
        () => repo.recordCount(
          type: 'invalid',
          date: DateTime(2026, 6, 23),
          denominations: const {},
          expectedAmount: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('잘못된 권종 키 → ValidationException', () async {
      expect(
        () => repo.recordCount(
          type: 'open',
          date: DateTime(2026, 6, 23),
          denominations: const {99: 1},
          expectedAmount: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('음수 수량 → ValidationException', () async {
      expect(
        () => repo.recordCount(
          type: 'open',
          date: DateTime(2026, 6, 23),
          denominations: const {10000: -1},
          expectedAmount: 0,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('decodeDenominations로 원래 맵 복원', () async {
      final c = await repo.recordCount(
        type: 'open',
        date: DateTime(2026, 6, 23),
        denominations: const {10000: 2, 500: 3},
        expectedAmount: 0,
      );
      final decoded = decodeDenominations(c.denominationsJson);
      expect(decoded[10000], 2);
      expect(decoded[500], 3);
    });
  });

  group('previousCloseTotal (F-CASH-01)', () {
    test('전일 마감 기록이 없으면 null', () async {
      final result = await repo.previousCloseTotal(DateTime(2026, 6, 23));
      expect(result, null);
    });

    test('전일 마감 기록이 있으면 그 총액', () async {
      await repo.recordCount(
        type: 'close',
        date: DateTime(2026, 6, 22),
        denominations: const {10000: 5},
        expectedAmount: 50000,
      );
      final result = await repo.previousCloseTotal(DateTime(2026, 6, 23));
      expect(result, 50000);
    });
  });

  group('checklist (F-CASH-04 독자기능)', () {
    test('ensureChecklist는 기본 4항목 생성', () async {
      await repo.ensureChecklist(DateTime(2026, 6, 23));
      final items =
          await db.select(db.closingChecklistItems).get();
      expect(items.length, 4);
      expect(items.every((i) => !i.checked), true);
    });

    test('재호출해도 중복 생성하지 않음', () async {
      await repo.ensureChecklist(DateTime(2026, 6, 23));
      await repo.ensureChecklist(DateTime(2026, 6, 23));
      final items = await db.select(db.closingChecklistItems).get();
      expect(items.length, 4);
    });

    test('toggleChecklistItem 정상 동작', () async {
      await repo.ensureChecklist(DateTime(2026, 6, 23));
      final items = await db.select(db.closingChecklistItems).get();
      await repo.toggleChecklistItem(items.first.id, true);
      final updated = await (db.select(db.closingChecklistItems)
            ..where((c) => c.id.equals(items.first.id)))
          .getSingle();
      expect(updated.checked, true);
    });

    test('존재하지 않는 항목 토글 → NotFoundException', () async {
      expect(
        () => repo.toggleChecklistItem('no-such-id', true),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
