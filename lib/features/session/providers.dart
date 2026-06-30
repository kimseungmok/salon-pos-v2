import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pricing/providers.dart'
    show pricingEngineProvider, pricingRuleRepositoryProvider;
import '../product/providers.dart' show appDatabaseProvider;
import '../promotion/providers.dart'
    show promotionEngineProvider, promotionRuleRepositoryProvider;
import '../staff_earning/providers.dart' show staffEarningEngineProvider;
import 'data/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    ref.watch(appDatabaseProvider),
    pricingRuleRepository: ref.watch(pricingRuleRepositoryProvider),
    pricingEngine: ref.watch(pricingEngineProvider),
    promotionRuleRepository: ref.watch(promotionRuleRepositoryProvider),
    promotionEngine: ref.watch(promotionEngineProvider),
    staffEarningEngine: ref.watch(staffEarningEngineProvider),
  );
});
