import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../domain/discount_type.dart';
import '../domain/promotion_rule.dart';

/// A-11 Promotion Engine MVP(`docs/A11_IMPLEMENTATION_PLAN.md`).
/// `PromotionRule`(POJO)에 대한 CRUD — 할인 "계산"은 `PromotionEngine`
/// (순수 계산, DB/Drift 미접근)이 담당하고, 이 레포지토리는 규칙 데이터
/// 의 저장/조회/Lifecycle 전이와 **Drift Row ↔ POJO 변환**만 책임진다.
/// **Drift를 직접 아는 계층은 이 파일뿐이다.**
///
/// **기간(`startAt`/`endAt`) 판단은 하지 않는다**(ADR-004) — `Expired`
/// 여부는 `PromotionEngine`이 조회/계산 시점에 판정한다. 이 Repository
/// 는 `shopId`/`businessType`/`status`라는 값싼 컬럼 필터와 명시적
/// `priority ASC, id ASC` 정렬만 책임진다.
class PromotionRuleRepository {
  PromotionRuleRepository(this._db);

  final AppDatabase _db;

  static const validBusinessTypes = {'salon', 'karaoke', 'izakaya'};
  static const validStatuses = {'draft', 'active', 'disabled'};

  Future<PromotionRule> addRule({
    int shopId = 1,
    required String businessType,
    String ruleType = 'discount',
    required String discountType,
    required int amount,
    int priority = 0,
    DateTime? startAt,
    DateTime? endAt,
    String status = 'draft',
  }) async {
    if (!validBusinessTypes.contains(businessType)) {
      throw const ValidationException('業種の値が正しくありません。');
    }
    if (!DiscountType.all.contains(discountType)) {
      throw const ValidationException('割引タイプの値が正しくありません。');
    }
    if (!validStatuses.contains(status)) {
      throw const ValidationException('ステータスの値が正しくありません。');
    }
    if (amount < 0) {
      throw const ValidationException('金額は0以上にしてください。');
    }
    try {
      final now = DateTime.now();
      final id = await _db.into(_db.promotionRules).insert(
            PromotionRulesCompanion.insert(
              shopId: Value(shopId),
              businessType: businessType,
              ruleType: Value(ruleType),
              discountType: discountType,
              amount: amount,
              priority: Value(priority),
              startAt: Value(startAt),
              endAt: Value(endAt),
              status: Value(status),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return PromotionRule(
        id: id,
        shopId: shopId,
        businessType: businessType,
        ruleType: ruleType,
        discountType: discountType,
        priority: priority,
        amount: amount,
        startAt: startAt,
        endAt: endAt,
        status: status,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// 부분 업데이트 — 넘기지 않은 필드는 그대로 유지한다. `status`를
  /// 바꾸는 것이 곧 Lifecycle 전이(`Draft→Active` 등, ADR-004)이며,
  /// 별도의 `activate()` 메서드를 두지 않고 이 메서드로 통일한다.
  Future<PromotionRule> updateRule({
    required int id,
    int? priority,
    int? amount,
    DateTime? startAt,
    DateTime? endAt,
    String? status,
  }) async {
    if (status != null && !validStatuses.contains(status)) {
      throw const ValidationException('ステータスの値が正しくありません。');
    }
    if (amount != null && amount < 0) {
      throw const ValidationException('金額は0以上にしてください。');
    }
    try {
      final existing = await (_db.select(_db.promotionRules)
            ..where((r) => r.id.equals(id)))
          .getSingleOrNull();
      if (existing == null) {
        throw const NotFoundException('プロモーションルールが見つかりませんでした。');
      }
      await (_db.update(_db.promotionRules)..where((r) => r.id.equals(id)))
          .write(PromotionRulesCompanion(
        priority: priority != null ? Value(priority) : const Value.absent(),
        amount: amount != null ? Value(amount) : const Value.absent(),
        startAt: startAt != null ? Value(startAt) : const Value.absent(),
        endAt: endAt != null ? Value(endAt) : const Value.absent(),
        status: status != null ? Value(status) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ));
      final updated = await (_db.select(_db.promotionRules)
            ..where((r) => r.id.equals(id)))
          .getSingle();
      return _toDomain(updated);
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// 하드 삭제 대신 `status='disabled'`로 비활성화(A-4/A-5, A-10과
  /// 동일한 "삭제 대신 상태 전환" 관례). 이미 `disabled`면 멱등하게
  /// 아무 동작 없이 반환(A-7 멱등성 원칙, ADR-004의 종착 상태).
  Future<void> deactivateRule(int id) async {
    try {
      final rule = await (_db.select(_db.promotionRules)
            ..where((r) => r.id.equals(id)))
          .getSingleOrNull();
      if (rule == null) {
        throw const NotFoundException('プロモーションルールが見つかりませんでした。');
      }
      if (rule.status == 'disabled') {
        return; // 이미 비활성화됨 — 멱등, 아무 동작 없음
      }
      await (_db.update(_db.promotionRules)..where((r) => r.id.equals(id)))
          .write(PromotionRulesCompanion(
        status: const Value('disabled'),
        updatedAt: Value(DateTime.now()),
      ));
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// [shopId]/[businessType]/[status] 기준으로만 조회한다. `startAt`/
  /// `endAt` 필터링이나 `Expired` 판정은 하지 않는다(ADR-004 — 이는
  /// `PromotionEngine`의 책임). [status]를 생략하면 기본값 `'active'`
  /// (가장 흔한 호출 형태 — 계산에 쓸 활성 규칙만 조회), 명시적으로
  /// `null`을 넘기면 모든 상태를 포함한다(관리 화면 등에서 활용 가능).
  ///
  /// `priority ASC, id ASC` 명시적 정렬(A-10 M1 재발 방지).
  Future<List<PromotionRule>> getRules({
    required String businessType,
    int shopId = 1,
    String? status = 'active',
  }) async {
    try {
      final query = _db.select(_db.promotionRules)
        ..where((r) => r.shopId.equals(shopId))
        ..where((r) => r.businessType.equals(businessType));
      if (status != null) {
        query.where((r) => r.status.equals(status));
      }
      query.orderBy([
        (r) => OrderingTerm.asc(r.priority),
        (r) => OrderingTerm.asc(r.id),
      ]);
      final rows = await query.get();
      return rows.map(_toDomain).toList();
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  /// Drift Row → POJO 변환(이 변환은 Repository 안에서만 일어난다).
  PromotionRule _toDomain(PromotionRuleRow row) => PromotionRule(
        id: row.id,
        shopId: row.shopId,
        businessType: row.businessType,
        ruleType: row.ruleType,
        discountType: row.discountType,
        priority: row.priority,
        amount: row.amount,
        startAt: row.startAt,
        endAt: row.endAt,
        status: row.status,
      );
}
