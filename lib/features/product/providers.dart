import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../db/app_database.dart';
import 'data/product_repository.dart';

/// DB 인스턴스는 앱 전체에서 단일 공유(keepAlive).
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(appDatabaseProvider));
});

final categoriesStreamProvider = StreamProvider<List<CategoryRow>>((ref) {
  return ref.watch(productRepositoryProvider).watchCategories();
});

final productsStreamProvider = StreamProvider<List<ProductRow>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});

/// 25번 화면(商品リスト) 카테고리 탭 선택 상태. null = すべて.
final selectedCategoryIdProvider = StateProvider<String?>((ref) => null);
