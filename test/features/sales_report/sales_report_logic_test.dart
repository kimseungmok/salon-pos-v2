import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/sales_report/logic/sales_report_logic.dart';

void main() {
  OrderRow order({
    required int id,
    required int total,
    int discount = 0,
    required DateTime createdAt,
    String status = 'completed',
  }) {
    return OrderRow(
      id: id,
      totalAmount: total,
      discountAmount: discount,
      pointsUsed: 0,
      prepaidUsedJson: '[]',
      status: status,
      createdAt: createdAt,
    );
  }

  int paymentSeq = 0;
  PaymentRow payment({
    required int orderId,
    required String method,
    required int amount,
    String status = 'completed',
  }) {
    paymentSeq++;
    return PaymentRow(
      id: paymentSeq,
      orderId: orderId,
      method: method,
      amount: amount,
      status: status,
      createdAt: DateTime.now(),
    );
  }

  group('periodRange', () {
    test('day: 해당 날짜 00:00~다음날 00:00', () {
      final r = periodRange(ReportPeriod.day, DateTime(2026, 6, 23, 15, 30));
      expect(r.start, DateTime(2026, 6, 23));
      expect(r.end, DateTime(2026, 6, 24));
    });

    test('week: 월요일 시작', () {
      // 2026-06-23은 화요일(weekday=2) → 월요일은 6/22
      final r = periodRange(ReportPeriod.week, DateTime(2026, 6, 23));
      expect(r.start, DateTime(2026, 6, 22));
      expect(r.end, DateTime(2026, 6, 29));
    });

    test('month: 해당 월 1일~다음달 1일', () {
      final r = periodRange(ReportPeriod.month, DateTime(2026, 6, 23));
      expect(r.start, DateTime(2026, 6, 1));
      expect(r.end, DateTime(2026, 7, 1));
    });
  });

  group('salesSummary (F-SALES-01)', () {
    final refDate = DateTime(2026, 6, 23);

    test('완료 주문만 합산, 할인 차감', () {
      final orders = [
        order(id: 1, total: 10000, discount: 1000, createdAt: refDate),
        order(id: 2, total: 5000, createdAt: refDate),
      ];
      final summary = salesSummary(ReportPeriod.day, refDate, orders, const []);
      expect(summary.netSales, 9000 + 5000);
      expect(summary.orderCount, 2);
    });

    test('취소된 주문은 returnAmount로 집계, netSales에서는 제외', () {
      final orders = [
        order(id: 1, total: 10000, createdAt: refDate),
        order(id: 2, total: 3000, createdAt: refDate, status: 'cancelled'),
      ];
      final summary = salesSummary(ReportPeriod.day, refDate, orders, const []);
      expect(summary.netSales, 10000);
      expect(summary.refundAmount, 3000);
      expect(summary.orderCount, 1);
    });

    test('기간 밖의 주문은 제외', () {
      final orders = [
        order(id: 1, total: 10000, createdAt: refDate),
        order(id: 2, total: 5000, createdAt: refDate.subtract(const Duration(days: 10))),
      ];
      final summary = salesSummary(ReportPeriod.day, refDate, orders, const []);
      expect(summary.netSales, 10000);
    });

    test('결제수단별 집계 — 기간 내 주문의 완료결제만', () {
      final orders = [order(id: 1, total: 10000, createdAt: refDate)];
      final payments = [
        payment(orderId: 1, method: 'cash', amount: 6000),
        payment(orderId: 1, method: 'card', amount: 4000),
      ];
      final summary = salesSummary(ReportPeriod.day, refDate, orders, payments);
      expect(summary.byPaymentMethod['cash'], 6000);
      expect(summary.byPaymentMethod['card'], 4000);
    });

    test('환불(refunded) 상태 결제는 결제수단별 집계에서 제외', () {
      final orders = [order(id: 1, total: 10000, createdAt: refDate)];
      final payments = [
        payment(orderId: 1, method: 'cash', amount: 10000, status: 'refunded'),
      ];
      final summary = salesSummary(ReportPeriod.day, refDate, orders, payments);
      expect(summary.byPaymentMethod.containsKey('cash'), false);
    });
  });

  group('dailySales', () {
    test('해당 날짜의 완료 주문 합계', () {
      final orders = [
        order(id: 1, total: 10000, createdAt: DateTime(2026, 6, 23, 10)),
        order(id: 2, total: 5000, createdAt: DateTime(2026, 6, 23, 15)),
        order(id: 3, total: 3000, createdAt: DateTime(2026, 6, 24)),
      ];
      expect(dailySales(DateTime(2026, 6, 23), orders), 15000);
    });
  });
}
