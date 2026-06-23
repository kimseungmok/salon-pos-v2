import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../customer/providers.dart' show customerRepositoryProvider;
import '../product/providers.dart' show appDatabaseProvider;
import 'data/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(customerRepositoryProvider),
  );
});

/// 02번 화면(注文)의 카트 상태 — productId별 수량.
final cartProvider =
    StateProvider<Map<String, int>>((ref) => {});
