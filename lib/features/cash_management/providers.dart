import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider;
import 'data/cash_repository.dart';

final cashManagementRepositoryProvider = Provider<CashManagementRepository>((ref) {
  return CashManagementRepository(ref.watch(appDatabaseProvider));
});

final selectedCashDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final checklistStreamProvider = StreamProvider<List<ClosingChecklistItemRow>>((ref) {
  final date = ref.watch(selectedCashDateProvider);
  return ref.watch(cashManagementRepositoryProvider).watchChecklist(date);
});
