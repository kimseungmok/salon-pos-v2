import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider;
import 'data/staff_repository.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepository(ref.watch(appDatabaseProvider));
});

final staffListStreamProvider = StreamProvider<List<StaffRow>>((ref) {
  return ref.watch(staffRepositoryProvider).watchStaff();
});
