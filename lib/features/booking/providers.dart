import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider;
import '../staff/providers.dart' show staffRepositoryProvider;
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
