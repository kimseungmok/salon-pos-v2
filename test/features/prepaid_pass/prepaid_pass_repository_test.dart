import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/customer/data/customer_repository.dart';
import 'package:salon_pos_v2/features/prepaid_pass/data/prepaid_pass_repository.dart';

void main() {
  late AppDatabase db;
  late PrepaidPassRepository repo;
  late CustomerRepository customerRepo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = PrepaidPassRepository(db);
    customerRepo = CustomerRepository(db);
  });

  tearDown(() => db.close());

  Future<String> aCustomer() async =>
      (await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678')).id;

  group('createMenu (F-PP-01)', () {
    test('금액권 정상 생성', () async {
      final m = await repo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      expect(m.type, 'amount');
    });

    test('횟수권 정상 생성', () async {
      final m = await repo.createMenu(
        type: 'count',
        name: 'カット10回券',
        linkedProductId: 'p1',
        price: 80000,
        countPerPurchase: 10,
      );
      expect(m.countPerPurchase, 10);
    });

    test('잘못된 유형 → ValidationException', () async {
      expect(
        () => repo.createMenu(type: 'invalid', name: 'テスト', price: 1000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('이름 공백 → ValidationException', () async {
      expect(
        () => repo.createMenu(type: 'amount', name: '  ', price: 1000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('횟수권인데 적용상품 누락 → ValidationException', () async {
      expect(
        () => repo.createMenu(type: 'count', name: 'テスト', price: 1000, countPerPurchase: 10),
        throwsA(isA<ValidationException>()),
      );
    });

    test('횟수권인데 횟수 누락 → ValidationException', () async {
      expect(
        () => repo.createMenu(type: 'count', name: 'テスト', linkedProductId: 'p1', price: 1000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('고정가인데 가격 0 → ValidationException', () async {
      expect(
        () => repo.createMenu(type: 'amount', name: 'テスト', price: 0),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('chargeMenu (F-PP-02)', () {
    test('보너스 없는 충전', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      expect(balance.remainingAmount, 100000);
    });

    test('보너스 충전 — 추가금액 반영', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(
        type: 'amount',
        name: '10万円券',
        price: 100000,
        bonusType: 'bonus',
        bonusAmount: 10000,
      );
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      expect(balance.remainingAmount, 110000);
    });

    test('횟수권 보너스 충전 — 추가횟수 반영', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(
        type: 'count',
        name: 'カット10回券',
        linkedProductId: 'p1',
        price: 80000,
        countPerPurchase: 10,
        bonusType: 'bonus',
        bonusCount: 2,
      );
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      expect(balance.remainingCount, 12);
    });

    test('존재하지 않는 메뉴 → NotFoundException', () async {
      final cid = await aCustomer();
      expect(
        () => repo.chargeMenu(customerId: cid, menuId: 'no-such-id'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('고객 미지정 → ValidationException', () async {
      final menu = await repo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      expect(
        () => repo.chargeMenu(customerId: '', menuId: menu.id),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('useAmountBalance (F-PP-03)', () {
    test('잔액 충분 → 전액 차감', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      final result = await repo.useAmountBalance(balanceId: balance.id, requestedAmount: 5500);
      expect(result.usedFromPrepaid, 5500);
      expect(result.remainingToPayOtherwise, 0);
    });

    test('잔액 부족 → 혼합결제(한도까지+나머지)', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(type: 'amount', name: '5千円券', price: 5000);
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      final result = await repo.useAmountBalance(balanceId: balance.id, requestedAmount: 8000);
      expect(result.usedFromPrepaid, 5000);
      expect(result.remainingToPayOtherwise, 3000);
    });

    test('횟수권 잔액에 금액사용 시도 → BusinessRuleException', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(
        type: 'count',
        name: 'カット10回券',
        linkedProductId: 'p1',
        price: 80000,
        countPerPurchase: 10,
      );
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      expect(
        () => repo.useAmountBalance(balanceId: balance.id, requestedAmount: 1000),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('만료된 선불권 사용 시도 → BusinessRuleException(자동 expired 처리)', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(
        type: 'amount',
        name: '만료테스트권',
        price: 10000,
        expiryType: 'custom',
        expiryCustomDays: 1,
      );
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      // 충전일을 과거로 되돌려 만료 상태를 시뮬레이션.
      await db.into(db.prepaidPassBalances).insertOnConflictUpdate(
            PrepaidPassBalancesCompanion(
              id: drift.Value(balance.id),
              customerId: drift.Value(cid),
              menuId: drift.Value(menu.id),
              remainingAmount: drift.Value(balance.remainingAmount),
              purchasedAt: drift.Value(DateTime.now().subtract(const Duration(days: 10))),
              expiresAt: drift.Value(DateTime.now().subtract(const Duration(days: 9))),
            ),
          );
      expect(
        () => repo.useAmountBalance(balanceId: balance.id, requestedAmount: 1000),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('존재하지 않는 선불권 → NotFoundException', () async {
      expect(
        () => repo.useAmountBalance(balanceId: 'no-such-id', requestedAmount: 1000),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('useCountBalance (F-PP-03)', () {
    test('잔여횟수 있으면 1회 차감', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(
        type: 'count',
        name: 'カット10回券',
        linkedProductId: 'p1',
        price: 80000,
        countPerPurchase: 10,
      );
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      await repo.useCountBalance(balanceId: balance.id);
      final updated = await (db.select(db.prepaidPassBalances)
            ..where((b) => b.id.equals(balance.id)))
          .getSingle();
      expect(updated.remainingCount, 9);
    });

    test('잔여횟수 0이면 BusinessRuleException', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(
        type: 'count',
        name: 'カット1回券',
        linkedProductId: 'p1',
        price: 8000,
        countPerPurchase: 1,
      );
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      await repo.useCountBalance(balanceId: balance.id);
      expect(
        () => repo.useCountBalance(balanceId: balance.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('voidCharge (F-PP-02 충전취소)', () {
    test('잔액 전부 소멸, voided 상태', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      await repo.voidCharge(balance.id);
      final updated = await (db.select(db.prepaidPassBalances)
            ..where((b) => b.id.equals(balance.id)))
          .getSingle();
      expect(updated.status, 'voided');
      expect(updated.remainingAmount, 0);
    });
  });

  group('restoreUse (F-PAY-05 연동 — 정규주문 취소시 사용분 복원)', () {
    test('금액 복원', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      final balance = await repo.chargeMenu(customerId: cid, menuId: menu.id);
      await repo.useAmountBalance(balanceId: balance.id, requestedAmount: 5000);
      await repo.restoreUse(balanceId: balance.id, amount: 5000);
      final updated = await (db.select(db.prepaidPassBalances)
            ..where((b) => b.id.equals(balance.id)))
          .getSingle();
      expect(updated.remainingAmount, 100000);
    });
  });

  group('migratePaperTicket (F-PP-05)', () {
    test('정상 이행', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(
        type: 'count',
        name: 'カット10回券',
        linkedProductId: 'p1',
        price: 80000,
        countPerPurchase: 10,
      );
      final balance = await repo.migratePaperTicket(
        customerId: cid,
        menuId: menu.id,
        remainingCount: 6,
        originalPurchaseDate: DateTime(2026, 1, 1),
      );
      expect(balance.remainingCount, 6);
      expect(balance.purchasedAt, DateTime(2026, 1, 1));
    });

    test('잔여 정보 둘 다 누락 → ValidationException', () async {
      final cid = await aCustomer();
      final menu = await repo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      expect(
        () => repo.migratePaperTicket(
          customerId: cid,
          menuId: menu.id,
          originalPurchaseDate: DateTime(2026, 1, 1),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
