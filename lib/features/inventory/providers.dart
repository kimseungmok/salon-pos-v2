import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import '../product/providers.dart' show appDatabaseProvider;
import 'data/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepository(ref.watch(appDatabaseProvider));
});

final inventoryItemsStreamProvider = StreamProvider<List<InventoryItemRow>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchItems();
});
