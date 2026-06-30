import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product/providers.dart' show appDatabaseProvider;
import 'data/pricing_rule_repository.dart';
import 'logic/pricing_engine.dart';

final pricingRuleRepositoryProvider = Provider<PricingRuleRepository>((ref) {
  return PricingRuleRepository(ref.watch(appDatabaseProvider));
});

final pricingEngineProvider = Provider<PricingEngine>((ref) {
  return const PricingEngine();
});
