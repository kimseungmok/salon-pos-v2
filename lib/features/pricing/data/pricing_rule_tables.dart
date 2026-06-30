import 'package:drift/drift.dart';

/// A-10 Pricing Engine MVP. 살롱/카라오케/이자카야 공통 가격 규칙 —
/// 1차 구현은 `ruleType`이 `'time_base'`(시간당 요금)/`'peak'`(피크
/// 할증) 2종만 지원한다(Promotion/Staff Earning/Settlement 관련
/// 필드·컬럼은 A-10 범위 밖이라 포함하지 않음).
///
/// A-9.5(docs/ID_CONVENTION.md) 원칙 그대로: PK는 INTEGER AUTOINCREMENT.
@DataClassName('PricingRuleRow')
class PricingRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get shopId => integer().withDefault(const Constant(1))();

  /// 'salon' | 'karaoke' | 'izakaya'.
  TextColumn get businessType => text()();

  /// 'time_base' | 'peak'.
  TextColumn get ruleType => text()();

  /// time_base: 분당 요금(원). peak: 할증율(%, 정수 — 예: 20 = 20%).
  /// 단위 해석은 `ruleType`에 따라 PricingEngine이 결정한다.
  IntColumn get value => integer()();

  /// 같은 businessType+ruleType 규칙이 여러 개 있을 때 우선순위 —
  /// 값이 작을수록 먼저 적용된다.
  IntColumn get priority => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// `ruleType='peak'`일 때만 의미 있는 시간대 범위(0~23시, [peakEndHour]
  /// 미포함) — PricingEngine은 이 값을 그대로 해석만 하고 직접 정책을
  /// 결정하지 않는다(하드코딩 제거, 지점/업종별로 다른 피크 시간대를
  /// Rule 데이터로 표현). 기본값(22~06시)은 기존 A-10 MVP 하드코딩과
  /// 동일하게 유지해 기존 동작을 보존한다. `time_base` 규칙에서는
  /// 미사용(기본값이 남아있어도 무시됨).
  IntColumn get peakStartHour => integer().withDefault(const Constant(22))();
  IntColumn get peakEndHour => integer().withDefault(const Constant(6))();
}
