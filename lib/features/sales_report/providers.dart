import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product/providers.dart' show appDatabaseProvider;
import 'data/sales_report_repository.dart';
import 'logic/sales_report_logic.dart';

final salesReportRepositoryProvider = Provider<SalesReportRepository>((ref) {
  return SalesReportRepository(ref.watch(appDatabaseProvider));
});

final selectedPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.day);
final selectedReportDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final salesSummaryProvider = FutureProvider.autoDispose<SalesSummary>((ref) async {
  final period = ref.watch(selectedPeriodProvider);
  final date = ref.watch(selectedReportDateProvider);
  return ref.watch(salesReportRepositoryProvider).summaryFor(period, date);
});
