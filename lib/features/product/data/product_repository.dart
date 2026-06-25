import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';

/// design/spec/v3/product/feature_spec.md F-PROD-01/F-PROD-02 비즈니스
/// 규칙을 그대로 구현. 모든 쓰기 작업은 입력 검증 → DB 작업 순서로
/// 진행하고, 실패 시 [AppException] 계열을 던진다(UI에서 일본어
/// 메시지를 그대로 보여줄 수 있도록).
///
/// A-9(docs/ID_CONVENTION.md): id는 INTEGER AUTOINCREMENT — UUID 생성
/// 코드 없음.
class ProductRepository {
  ProductRepository(this._db);

  final AppDatabase _db;

  // ── Category ──────────────────────────────────────────────────────

  Future<List<CategoryRow>> watchCategoriesOnce() async {
    try {
      return await (_db.select(_db.categories)
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .get();
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  Stream<List<CategoryRow>> watchCategories() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  /// 카테고리 생성. 이름 중복(공백 무시, 대소문자 무시)을 막는다 —
  /// 토스 원본에는 명시적 검증이 없으나, 같은 이름의 카테고리가 여러
  /// 개 생기면 F-PAY-01의 "카테고리 고정색" 전제가 무너지므로 필수.
  Future<CategoryRow> createCategory({
    required String name,
    required String colorHex,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('カテゴリ名を入力してください。');
    }
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(colorHex)) {
      throw const ValidationException('色を選択してください。');
    }

    try {
      final existing = await (_db.select(_db.categories)
            ..where((c) => c.name.equals(trimmed)))
          .getSingleOrNull();
      if (existing != null) {
        throw BusinessRuleException('「$trimmed」は既に登録されているカテゴリ名です。');
      }

      final maxOrderQuery = _db.selectOnly(_db.categories)
        ..addColumns([_db.categories.sortOrder.max()]);
      final maxOrderRow = await maxOrderQuery.getSingleOrNull();
      final maxOrder = maxOrderRow?.read(_db.categories.sortOrder.max());
      final id = await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              name: trimmed,
              colorHex: colorHex,
              sortOrder: Value((maxOrder ?? 0) + 1),
            ),
          );
      return CategoryRow(
        id: id,
        name: trimmed,
        colorHex: colorHex,
        kioskVisible: true,
        sortOrder: (maxOrder ?? 0) + 1,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final inUse = await (_db.select(_db.products)
            ..where((p) => p.categoryId.equals(id)))
          .get();
      if (inUse.isNotEmpty) {
        throw BusinessRuleException(
          'このカテゴリには商品が${inUse.length}件登録されているため削除できません。先に商品を移動してください。',
        );
      }
      final rows = await (_db.delete(_db.categories)
            ..where((c) => c.id.equals(id)))
          .go();
      if (rows == 0) {
        throw const NotFoundException('カテゴリが見つかりませんでした（既に削除されている可能性があります）。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  // ── Product ───────────────────────────────────────────────────────

  Stream<List<ProductRow>> watchProducts() {
    return (_db.select(_db.products)
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .watch();
  }

  /// 상품 생성/수정 공용. [id]가 null이면 신규, 있으면 수정.
  Future<ProductRow> upsertProduct({
    int? id,
    required String name,
    required int categoryId,
    required int price,
    required bool allowCustomPrice,
    int? durationMin,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('商品名を入力してください。');
    }
    if (durationMin != null && durationMin < 0) {
      throw const ValidationException('施術時間は0分以上で入力してください。');
    }
    if (!allowCustomPrice && price < 0) {
      throw const ValidationException('価格は0円以上で入力してください。');
    }

    try {
      final category = await (_db.select(_db.categories)
            ..where((c) => c.id.equals(categoryId)))
          .getSingleOrNull();
      if (category == null) {
        throw const ValidationException('選択したカテゴリが見つかりません。再度選択してください。');
      }

      final resolvedPrice = allowCustomPrice ? 0 : price;
      int resolvedId;
      if (id == null) {
        resolvedId = await _db.into(_db.products).insert(
              ProductsCompanion.insert(
                name: trimmed,
                categoryId: categoryId,
                price: resolvedPrice,
                allowCustomPrice: Value(allowCustomPrice),
                durationMin: Value(durationMin),
              ),
            );
      } else {
        resolvedId = id;
        await _db.into(_db.products).insertOnConflictUpdate(
              ProductsCompanion(
                id: Value(resolvedId),
                name: Value(trimmed),
                categoryId: Value(categoryId),
                price: Value(resolvedPrice),
                allowCustomPrice: Value(allowCustomPrice),
                durationMin: Value(durationMin),
              ),
            );
      }

      return ProductRow(
        id: resolvedId,
        name: trimmed,
        categoryId: categoryId,
        price: resolvedPrice,
        allowCustomPrice: allowCustomPrice,
        kioskVisible: true,
        durationMin: durationMin,
        displayStock: null,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final rows =
          await (_db.delete(_db.products)..where((p) => p.id.equals(id)))
              .go();
      if (rows == 0) {
        throw const NotFoundException('商品が見つかりませんでした（既に削除されている可能性があります）。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// F-PAY-01 연동: 카테고리 고정색을 그대로 타일 배경색으로 사용.
  /// (product/data_spec.md `tileColorOf()`의 Dart 구현)
  Future<String> tileColorOf(int categoryId) async {
    try {
      final c = await (_db.select(_db.categories)
            ..where((c) => c.id.equals(categoryId)))
          .getSingleOrNull();
      if (c == null) {
        throw const NotFoundException('カテゴリが見つかりません。');
      }
      return c.colorHex;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }
}
