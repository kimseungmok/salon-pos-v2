import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product/providers.dart' show appDatabaseProvider;
import 'data/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
});
