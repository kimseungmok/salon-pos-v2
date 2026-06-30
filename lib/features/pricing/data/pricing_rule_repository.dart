import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../domain/pricing_rule.dart';
import '../domain/rule_types.dart';

/// A-10 Pricing Engine MVP, A-10 리팩토링(R1): `PricingRule`(POJO)에
/// 대한 단순 CRUD — 가격 "계산"은 `PricingEngine`(순수 계산, DB/Drift
/// 미접근)이 담당하고, 이 레포지토리는 규칙 데이터의 저장/조회/비활성화
/// 와 **Drift Row ↔ POJO 변환**만 책임진다. **Drift를 직접 아는 계층은
/// 이 파일뿐이다** — `PricingEngine`/`SessionRepository`는 `PricingRule`
/// 만 주고받는다.
class PricingRuleRepository {
  PricingRuleRepository(this._db);

  final AppDatabase _db;

  static const validBusinessTypes = {'salon', 'karaoke', 'izakaya'};

  /// A-10 리뷰 후속: `ruleType` 문자열은 `RuleType`(domain/rule_types.dart)
  /// 한 곳에서만 정의 — 여기서는 그 집합을 그대로 재사용한다.
  static const validRuleTypes = RuleType.all;

  Future<PricingRule> addRule({
    int shopId = 1,
    required String businessType,
    required String ruleType,
    required int value,
    int priority = 0,
    bool isActive = true,
    int peakStartHour = 22,
    int peakEndHour = 6,
  }) async {
    if (!validBusinessTypes.contains(businessType)) {
      throw const ValidationException('業種の値が正しくありません。');
    }
    if (!validRuleTypes.contains(ruleType)) {
      throw const ValidationException('価格ルール種別の値が正しくありません。');
    }
    if (value < 0) {
      throw const ValidationException('値は0以上にしてください。');
    }
    if (peakStartHour < 0 || peakStartHour > 23 || peakEndHour < 0 || peakEndHour > 23) {
      throw const ValidationException('時間帯は0〜23の範囲で指定してください。');
    }
    try {
      final id = await _db.into(_db.pricingRules).insert(
            PricingRulesCompanion.insert(
              shopId: Value(shopId),
              businessType: businessType,
              ruleType: ruleType,
              value: value,
              priority: Value(priority),
              isActive: Value(isActive),
              peakStartHour: Value(peakStartHour),
              peakEndHour: Value(peakEndHour),
            ),
          );
      return PricingRule(
        id: id,
        shopId: shopId,
        businessType: businessType,
        ruleType: ruleType,
        value: value,
        priority: priority,
        isActive: isActive,
        peakStartHour: peakStartHour,
        peakEndHour: peakEndHour,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// A-10 리뷰 후속(40개 이상 지점 지원): [shopId]로 먼저 좁힌 뒤
  /// [businessType]로 좁힌다 — 지점마다 서로 다른 가격/피크 규칙을
  /// 독립적으로 둘 수 있다(기본값 1 — 기존 단일 지점 호출부와 동일하게
  /// 동작, 호출부가 명시적으로 다른 shopId를 넘기지 않으면 동작 불변).
  ///
  /// [ruleType]을 생략하면 해당 업종의 모든 규칙(time_base+peak)을
  /// 반환한다. [activeOnly]가 true(기본값)면 `isActive=false`인 규칙은
  /// 제외한다.
  ///
  /// A-10 리뷰 후속(M1): `priority` 동률 시 행 순서가 우연(삽입 순서)에
  /// 의존하지 않도록 `priority ASC, id ASC`로 명시적 정렬한다.
  Future<List<PricingRule>> getRules({
    required String businessType,
    int shopId = 1,
    String? ruleType,
    bool activeOnly = true,
  }) async {
    try {
      final query = _db.select(_db.pricingRules)
        ..where((r) => r.shopId.equals(shopId))
        ..where((r) => r.businessType.equals(businessType));
      if (ruleType != null) {
        query.where((r) => r.ruleType.equals(ruleType));
      }
      if (activeOnly) {
        query.where((r) => r.isActive.equals(true));
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
  PricingRule _toDomain(PricingRuleRow row) => PricingRule(
        id: row.id,
        shopId: row.shopId,
        businessType: row.businessType,
        ruleType: row.ruleType,
        value: row.value,
        priority: row.priority,
        isActive: row.isActive,
        peakStartHour: row.peakStartHour,
        peakEndHour: row.peakEndHour,
      );

  /// 하드 삭제 대신 `isActive=false`로 비활성화(A-4/A-5와 동일한
  /// "삭제 대신 상태 전환" 관례). 이미 비활성화된 규칙에 재호출하면
  /// 멱등하게 아무 동작 없이 반환(A-7 멱등성 원칙).
  Future<void> deactivateRule(int id) async {
    try {
      final rule = await (_db.select(_db.pricingRules)
            ..where((r) => r.id.equals(id)))
          .getSingleOrNull();
      if (rule == null) {
        throw const NotFoundException('価格ルールが見つかりませんでした。');
      }
      if (!rule.isActive) {
        return; // 이미 비활성화됨 — 멱등, 아무 동작 없음
      }
      await (_db.update(_db.pricingRules)..where((r) => r.id.equals(id)))
          .write(const PricingRulesCompanion(isActive: Value(false)));
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}
