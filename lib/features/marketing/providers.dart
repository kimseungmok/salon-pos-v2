import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider;
import 'data/marketing_repository.dart';

final marketingRepositoryProvider = Provider<MarketingRepository>((ref) {
  return MarketingRepository(ref.watch(appDatabaseProvider));
});

final couponsStreamProvider = StreamProvider<List<CouponRow>>((ref) {
  return ref.watch(marketingRepositoryProvider).watchCoupons();
});

final campaignsStreamProvider = StreamProvider<List<CampaignRow>>((ref) {
  return ref.watch(marketingRepositoryProvider).watchCampaigns();
});

final pointPolicyStreamProvider = StreamProvider<PointPolicyRow>((ref) {
  return ref.watch(marketingRepositoryProvider).watchPointPolicy();
});
