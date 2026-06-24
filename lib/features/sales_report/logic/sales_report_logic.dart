import '../../../db/app_database.dart';

/// design/spec/v3/sales_report/data_spec.md 산출 로직 그대로.
/// **본 모듈은 자체 테이블을 두지 않는다** — Order/Payment를 조회
/// 시점에 집계하는 순수 함수 모음(F-SALES-01 "저장 엔티티가 아니라
/// 조회 시 Order/Payment에서 집계" 그대로).

enum ReportPeriod { day, week, month }

class DateRange {
  const DateRange(this.start, this.end);
  final DateTime start;
  final DateTime end;

  bool includes(DateTime t) => !t.isBefore(start) && t.isBefore(end);
}

DateRange periodRange(ReportPeriod period, DateTime refDate) {
  final day = DateTime(refDate.year, refDate.month, refDate.day);
  switch (period) {
    case ReportPeriod.day:
      return DateRange(day, day.add(const Duration(days: 1)));
    case ReportPeriod.week:
      final weekday = day.weekday; // 1=月 ... 7=日
      final start = day.subtract(Duration(days: weekday - 1));
      return DateRange(start, start.add(const Duration(days: 7)));
    case ReportPeriod.month:
      final start = DateTime(day.year, day.month, 1);
      final end = DateTime(day.year, day.month + 1, 1);
      return DateRange(start, end);
  }
}

class SalesSummary {
  const SalesSummary({
    required this.netSales,
    required this.orderCount,
    required this.refundAmount,
    required this.byPaymentMethod,
  });

  final int netSales;
  final int orderCount;
  final int refundAmount;
  final Map<String, int> byPaymentMethod;
}

/// F-SALES-01: 기간별 売上概況 산출.
SalesSummary salesSummary(
  ReportPeriod period,
  DateTime refDate,
  List<OrderRow> orders,
  List<PaymentRow> payments,
) {
  final range = periodRange(period, refDate);
  final inRange = orders.where((o) => range.includes(o.createdAt)).toList();

  final completed = inRange.where((o) => o.status == 'completed' || o.status == 'partially_paid');
  final cancelled = inRange.where((o) => o.status == 'cancelled');

  final netSales = completed.fold<int>(0, (s, o) => s + o.totalAmount - o.discountAmount);
  final refundAmount = cancelled.fold<int>(0, (s, o) => s + o.totalAmount - o.discountAmount);
  final orderCount = inRange.where((o) => o.status == 'completed').length;

  final orderIdsInRange = inRange.map((o) => o.id).toSet();
  final byPaymentMethod = <String, int>{};
  for (final p in payments) {
    if (!orderIdsInRange.contains(p.orderId)) continue;
    if (p.status != 'completed') continue;
    byPaymentMethod[p.method] = (byPaymentMethod[p.method] ?? 0) + p.amount;
  }

  return SalesSummary(
    netSales: netSales,
    orderCount: orderCount,
    refundAmount: refundAmount,
    byPaymentMethod: byPaymentMethod,
  );
}

/// F-SALES-01: 売上カレンダー 일별 숫자(날짜+매출숫자만 — 날씨 아이콘
/// 등은 결정사항에 따라 표시하지 않음).
int dailySales(DateTime date, List<OrderRow> orders) {
  final day = DateTime(date.year, date.month, date.day);
  return orders
      .where((o) =>
          o.status == 'completed' &&
          o.createdAt.year == day.year &&
          o.createdAt.month == day.month &&
          o.createdAt.day == day.day)
      .fold<int>(0, (s, o) => s + o.totalAmount - o.discountAmount);
}
