import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../logic/sales_report_logic.dart';

/// design/spec/v3/sales_report/feature_spec.md F-SALES-01 그대로.
/// 읽기 전용 — 자체 테이블이 없고 Order/Payment를 직접 조회해 집계.
class SalesReportRepository {
  SalesReportRepository(this._db);

  final AppDatabase _db;

  Future<SalesSummary> summaryFor(ReportPeriod period, DateTime refDate) async {
    try {
      final orders = await _db.select(_db.orders).get();
      final payments = await _db.select(_db.payments).get();
      return salesSummary(period, refDate, orders, payments);
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  Future<int> dailySalesFor(DateTime date) async {
    try {
      final orders = await _db.select(_db.orders).get();
      return dailySales(date, orders);
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }
}
