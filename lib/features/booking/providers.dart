import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider, productRepositoryProvider;
import '../session/providers.dart' show sessionRepositoryProvider;
import '../staff/providers.dart' show staffRepositoryProvider;
import 'data/booking_completion_caller.dart';
import 'data/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(staffRepositoryProvider),
  );
});

final waitingListStreamProvider = StreamProvider<List<WaitingEntryRow>>((ref) {
  return ref.watch(bookingRepositoryProvider).watchWaiting();
});

/// A-29: IC-1 — BookingCompletionCaller DI.
/// 의존: bookingRepositoryProvider / sessionRepositoryProvider / productRepositoryProvider.
final bookingCompletionCallerProvider = Provider<BookingCompletionCaller>((ref) {
  return BookingCompletionCaller(
    bookingRepository: ref.watch(bookingRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
  );
});
