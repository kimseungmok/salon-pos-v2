import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/customer/data/customer_repository.dart';
import 'package:salon_pos_v2/features/payment_pos/data/payment_repository.dart';
import 'package:salon_pos_v2/features/prepaid_pass/data/prepaid_pass_repository.dart';
import 'package:salon_pos_v2/features/sales_report/data/sales_report_repository.dart';
import 'package:salon_pos_v2/features/sales_report/logic/sales_report_logic.dart';

/// M10 — 전영역 집계 모듈. payment_pos(M5)로 실제 주문/결제를 만들고
/// 이 데이터가 sales_report에서 올바르게 집계되는지 통합 검증.
void main() {
  late AppDatabase db;
  late SalesReportRepository repo;
  late PaymentRepository paymentRepo;

  setUp(() {
    db = AppDatabase.forTesting();
    final customerRepo = CustomerRepository(db);
    final prepaidPassRepo = PrepaidPassRepository(db);
    paymentRepo = PaymentRepository(db, customerRepo, prepaidPassRepo);
    repo = SalesReportRepository(db);
  });

  tearDown(() => db.close());

  const item = (
    productId: 'p1',
    productName: 'カット',
    quantity: 1,
    unitPrice: 5000,
    staffId: null,
  );

  test('payment_pos에서 만든 주문이 売上概況에 정확히 집계됨', () async {
    final order = await paymentRepo.createOrder(items: [item]);
    await paymentRepo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 5000);

    final summary = await repo.summaryFor(ReportPeriod.day, DateTime.now());
    expect(summary.netSales, 5000);
    expect(summary.orderCount, 1);
    expect(summary.byPaymentMethod['cash'], 5000);
  });

  test('취소된 주문은 returnAmount로 반영되고 결제수단별 집계에서 빠짐', () async {
    final order = await paymentRepo.createOrder(items: [item]);
    await paymentRepo.pay(orderId: order.id, method: 'cash', amount: 5000, cashReceived: 5000);
    await paymentRepo.cancelOrder(order.id);

    final summary = await repo.summaryFor(ReportPeriod.day, DateTime.now());
    expect(summary.netSales, 0);
    expect(summary.refundAmount, 5000);
    expect(summary.byPaymentMethod.containsKey('cash'), false);
  });

  test('dailySalesFor — 오늘 매출 합계', () async {
    final order = await paymentRepo.createOrder(items: [item]);
    await paymentRepo.pay(orderId: order.id, method: 'card', amount: 5000);

    final total = await repo.dailySalesFor(DateTime.now());
    expect(total, 5000);
  });
}
