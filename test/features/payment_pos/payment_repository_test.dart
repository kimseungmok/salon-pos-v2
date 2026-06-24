import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/customer/data/customer_repository.dart';
import 'package:salon_pos_v2/features/payment_pos/data/payment_repository.dart';
import 'package:salon_pos_v2/features/prepaid_pass/data/prepaid_pass_repository.dart';

void main() {
  late AppDatabase db;
  late PaymentRepository repo;
  late CustomerRepository customerRepo;
  late PrepaidPassRepository prepaidPassRepo;

  setUp(() {
    db = AppDatabase.forTesting();
    customerRepo = CustomerRepository(db);
    prepaidPassRepo = PrepaidPassRepository(db);
    repo = PaymentRepository(db, customerRepo, prepaidPassRepo);
  });

  tearDown(() => db.close());

  const item = (
    productId: 'p1',
    productName: 'カット',
    quantity: 1,
    unitPrice: 5000,
    staffId: null,
  );

  group('createOrder', () {
    test('정상 생성', () async {
      final order = await repo.createOrder(items: [item]);
      expect(order.totalAmount, 5000);
      expect(order.status, 'pending');
    });

    test('아이템 없음 → ValidationException', () async {
      expect(
        () => repo.createOrder(items: const []),
        throwsA(isA<ValidationException>()),
      );
    });

    test('수량 0 이하 → ValidationException', () async {
      expect(
        () => repo.createOrder(items: [
          (productId: 'p1', productName: 'カット', quantity: 0, unitPrice: 5000, staffId: null)
        ]),
        throwsA(isA<ValidationException>()),
      );
    });

    test('할인액이 합계 초과 → ValidationException', () async {
      expect(
        () => repo.createOrder(items: [item], discountAmount: 99999),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('pay', () {
    test('전액 현금결제 → completed, 거스름돈 계산', () async {
      final order = await repo.createOrder(items: [item]);
      final payment = await repo.pay(
        orderId: order.id,
        method: 'cash',
        amount: 5000,
        cashReceived: 10000,
      );
      expect(payment.cashChange, 5000);
      final updated =
          await (db.select(db.orders)..where((o) => o.id.equals(order.id))).getSingle();
      expect(updated.status, 'completed');
    });

    test('잘못된 결제수단 → ValidationException', () async {
      final order = await repo.createOrder(items: [item]);
      expect(
        () => repo.pay(orderId: order.id, method: 'bitcoin', amount: 5000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('현금인데 받은금액 누락 → ValidationException', () async {
      final order = await repo.createOrder(items: [item]);
      expect(
        () => repo.pay(orderId: order.id, method: 'cash', amount: 5000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('받은금액이 결제금액보다 적음 → ValidationException', () async {
      final order = await repo.createOrder(items: [item]);
      expect(
        () => repo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 3000),
        throwsA(isA<ValidationException>()),
      );
    });

    test('존재하지 않는 주문 → NotFoundException', () async {
      expect(
        () => repo.pay(orderId: 'no-such-id', method: 'card', amount: 5000),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('분할결제: 부분 결제 시 partially_paid 상태', () async {
      final order = await repo.createOrder(items: [
        (productId: 'p1', productName: 'カット', quantity: 1, unitPrice: 10000, staffId: null)
      ]);
      await repo.pay(orderId: order.id, method: 'cash', amount: 4000, cashReceived: 4000);
      final updated =
          await (db.select(db.orders)..where((o) => o.id.equals(order.id))).getSingle();
      expect(updated.status, 'partially_paid');
      expect(await repo.remainingAmount(order.id), 6000);
    });

    test('분할결제: 잔여금액 전부 결제하면 completed', () async {
      final order = await repo.createOrder(items: [
        (productId: 'p1', productName: 'カット', quantity: 1, unitPrice: 10000, staffId: null)
      ]);
      await repo.pay(orderId: order.id, method: 'cash', amount: 4000, cashReceived: 4000);
      await repo.pay(orderId: order.id, method: 'card', amount: 6000);
      final updated =
          await (db.select(db.orders)..where((o) => o.id.equals(order.id))).getSingle();
      expect(updated.status, 'completed');
      expect(await repo.remainingAmount(order.id), 0);
    });

    test('잔여금액을 초과하는 결제 시도 → BusinessRuleException', () async {
      final order = await repo.createOrder(items: [item]); // 5000원
      expect(
        () => repo.pay(orderId: order.id, method: 'card', amount: 6000),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('이미 취소된 주문에 결제 시도 → BusinessRuleException', () async {
      final order = await repo.createOrder(items: [item]);
      await repo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 5000);
      await repo.cancelOrder(order.id);
      expect(
        () => repo.pay(orderId: order.id, method: 'card', amount: 1000),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('pay → recordVisit 연동 (A-1)', () {
    test('주문 완결 시 고객의 방문기록이 1건 적재된다', () async {
      final customer = await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      final order = await repo.createOrder(
        customerId: customer.id,
        items: [item],
      );
      await repo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 5000);

      final visits = await (db.select(db.visitRecords)
            ..where((v) => v.customerId.equals(customer.id)))
          .get();
      expect(visits, hasLength(1));
      expect(visits.single.status, 'completed');
      expect(visits.single.amount, 5000);
    });

    test('분할결제 중간(partially_paid) 단계에서는 적재되지 않는다', () async {
      final customer = await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      final order = await repo.createOrder(
        customerId: customer.id,
        items: [
          (productId: 'p1', productName: 'カット', quantity: 1, unitPrice: 10000, staffId: null)
        ],
      );
      await repo.pay(orderId: order.id, method: 'cash', amount: 4000, cashReceived: 4000);

      final visits = await (db.select(db.visitRecords)
            ..where((v) => v.customerId.equals(customer.id)))
          .get();
      expect(visits, isEmpty);
    });

    test('분할결제가 완결되는 마지막 회차에서만 1건 적재된다', () async {
      final customer = await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      final order = await repo.createOrder(
        customerId: customer.id,
        items: [
          (productId: 'p1', productName: 'カット', quantity: 1, unitPrice: 10000, staffId: null)
        ],
      );
      await repo.pay(orderId: order.id, method: 'cash', amount: 4000, cashReceived: 4000);
      await repo.pay(orderId: order.id, method: 'card', amount: 6000);

      final visits = await (db.select(db.visitRecords)
            ..where((v) => v.customerId.equals(customer.id)))
          .get();
      expect(visits, hasLength(1));
      expect(visits.single.amount, 10000);
    });

    test('customerId가 없는 주문은 방문기록이 적재되지 않는다', () async {
      final order = await repo.createOrder(items: [item]); // customerId 없음
      await repo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 5000);

      final visits = await db.select(db.visitRecords).get();
      expect(visits, isEmpty);
    });

    test('품목 중 첫 번째 non-null staffId가 방문기록에 채택된다', () async {
      final customer = await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      final order = await repo.createOrder(
        customerId: customer.id,
        items: [
          (productId: 'p1', productName: 'カット', quantity: 1, unitPrice: 2000, staffId: null),
          (productId: 'p2', productName: 'カラー', quantity: 1, unitPrice: 3000, staffId: 'staff-001'),
        ],
      );
      await repo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 5000);

      final visits = await (db.select(db.visitRecords)
            ..where((v) => v.customerId.equals(customer.id)))
          .get();
      expect(visits.single.staffId, 'staff-001');
    });
  });

  group('cancelOrder (F-PAY-05 원자적 처리)', () {
    test('정상 취소 → 주문/결제 모두 상태 갱신', () async {
      final order = await repo.createOrder(items: [item]);
      await repo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 5000);
      await repo.cancelOrder(order.id);

      final updatedOrder =
          await (db.select(db.orders)..where((o) => o.id.equals(order.id))).getSingle();
      expect(updatedOrder.status, 'cancelled');

      final payments =
          await (db.select(db.payments)..where((p) => p.orderId.equals(order.id))).get();
      expect(payments.every((p) => p.status == 'refunded'), true);
    });

    test('포인트 사용분이 있으면 고객에게 환원', () async {
      final customer = await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      final order = await repo.createOrder(customerId: customer.id, items: [item]);
      // pointsUsed는 createOrder에 노출되어 있지 않으므로 직접 갱신해 시뮬레이션.
      await db.into(db.orders).insertOnConflictUpdate(
            OrdersCompanion(
              id: drift.Value(order.id),
              customerId: drift.Value(customer.id),
              totalAmount: drift.Value(order.totalAmount),
              pointsUsed: const drift.Value(300),
              createdAt: drift.Value(order.createdAt),
            ),
          );
      await repo.cancelOrder(order.id);
      final updatedCustomer =
          await (db.select(db.customers)..where((c) => c.id.equals(customer.id))).getSingle();
      expect(updatedCustomer.points, 300);
    });

    test('プリペイド券 결제분이 있으면 사용분을 잔액에 복원(M6 연동)', () async {
      final customer = await customerRepo.createCustomer(name: '田中美咲', phone: '090-1234-5678');
      final menu = await prepaidPassRepo.createMenu(type: 'amount', name: '10万円券', price: 100000);
      final balance = await prepaidPassRepo.chargeMenu(customerId: customer.id, menuId: menu.id);

      final order = await repo.createOrder(customerId: customer.id, items: [item]);
      final result = await prepaidPassRepo.useAmountBalance(
        balanceId: balance.id,
        requestedAmount: 5000,
        relatedOrderId: order.id,
      );
      await repo.pay(
        orderId: order.id,
        method: 'prepaid_pass',
        amount: result.usedFromPrepaid,
        prepaidBalanceId: balance.id,
      );

      await repo.cancelOrder(order.id);

      final updatedBalance = await (db.select(db.prepaidPassBalances)
            ..where((b) => b.id.equals(balance.id)))
          .getSingle();
      expect(updatedBalance.remainingAmount, 100000); // 5000 사용 후 취소로 복원
    });

    test('존재하지 않는 주문 취소 → NotFoundException', () async {
      expect(
        () => repo.cancelOrder('no-such-id'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('이미 취소된 주문 재취소 → BusinessRuleException', () async {
      final order = await repo.createOrder(items: [item]);
      await repo.cancelOrder(order.id);
      expect(
        () => repo.cancelOrder(order.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });
}
