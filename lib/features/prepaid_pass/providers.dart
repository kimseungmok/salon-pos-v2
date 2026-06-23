import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider;
import 'data/prepaid_pass_repository.dart';

final prepaidPassRepositoryProvider = Provider<PrepaidPassRepository>((ref) {
  return PrepaidPassRepository(ref.watch(appDatabaseProvider));
});

final prepaidPassMenusStreamProvider =
    StreamProvider<List<PrepaidPassMenuRow>>((ref) {
  return ref.watch(prepaidPassRepositoryProvider).watchMenus();
});
