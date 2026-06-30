import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../product/providers.dart' show appDatabaseProvider;
import 'data/promotion_rule_repository.dart';
import 'logic/promotion_engine.dart';

final promotionRuleRepositoryProvider = Provider<PromotionRuleRepository>((ref) {
  return PromotionRuleRepository(ref.watch(appDatabaseProvider));
});

final promotionEngineProvider = Provider<PromotionEngine>((ref) {
  return const PromotionEngine();
});
