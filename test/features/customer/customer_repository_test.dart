import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/customer/data/customer_repository.dart';

void main() {
  late AppDatabase db;
  late CustomerRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = CustomerRepository(db);
  });

  tearDown(() => db.close());

  group('createCustomer', () {
    test('정상 생성', () async {
      final c = await repo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      expect(c.name, '田中美咲');
      expect(c.points, 0);
    });

    test('이름 공백 → ValidationException', () async {
      expect(
        () => repo.createCustomer(name: '  ', phone: '090-1234-5678'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('전화번호 공백 → ValidationException', () async {
      expect(
        () => repo.createCustomer(name: '田中美咲', phone: '  '),
        throwsA(isA<ValidationException>()),
      );
    });

    test('전화번호 중복 → BusinessRuleException', () async {
      await repo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      expect(
        () => repo.createCustomer(name: '別の名前', phone: '090-1234-5678'),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('updateMemo (F-CUST-02)', () {
    test('정상 저장', () async {
      final c = await repo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      await repo.updateMemo(c.id, '首の後ろのくせ毛注意');
    });

    test('존재하지 않는 고객 → NotFoundException', () async {
      expect(
        () => repo.updateMemo(999999, 'メモ'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('recordVisit', () {
    test('정상 기록', () async {
      final c = await repo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      await repo.recordVisit(customerId: c.id, visitDate: DateTime.now());
    });

    test('잘못된 status 값 → ValidationException', () async {
      final c = await repo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      expect(
        () => repo.recordVisit(
          customerId: c.id,
          visitDate: DateTime.now(),
          status: 'invalid_status',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('존재하지 않는 고객 → NotFoundException', () async {
      expect(
        () => repo.recordVisit(customerId: 999999, visitDate: DateTime.now()),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}

