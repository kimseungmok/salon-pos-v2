import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider;
import 'data/customer_repository.dart';
import 'logic/group_of.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(appDatabaseProvider));
});

final customersStreamProvider = StreamProvider<List<CustomerRow>>((ref) {
  return ref.watch(customerRepositoryProvider).watchCustomers();
});

final visitsStreamProvider = StreamProvider<List<VisitRecordRow>>((ref) {
  return ref.watch(customerRepositoryProvider).watchAllVisits();
});

/// 09번 화면 그룹 탭 선택 상태. null = すべて.
final selectedGroupProvider = StateProvider<CustomerGroup?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');
