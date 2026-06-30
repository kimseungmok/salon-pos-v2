import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/features/pricing/domain/pricing_rule.dart';
import 'package:salon_pos_v2/features/pricing/logic/pricing_engine.dart';

/// A-10 Pricing Engine MVP 검증. 순수 계산 클래스라 DB 없이 테스트한다.
void main() {
  const engine = PricingEngine();

  PricingRule rule({
    required String businessType,
    required String ruleType,
    required int value,
    int priority = 0,
    bool isActive = true,
    int peakStartHour = 22,
    int peakEndHour = 6,
  }) {
    return PricingRule(
      id: 1,
      shopId: 1,
      businessType: businessType,
      ruleType: ruleType,
      value: value,
      priority: priority,
      isActive: isActive,
      peakStartHour: peakStartHour,
      peakEndHour: peakEndHour,
    );
  }

  group('calcTimeFee', () {
    test('시간요금 계산 — 분당 100원 × 30분 = 3000원', () {
      final rules = [rule(businessType: 'karaoke', ruleType: 'time_base', value: 100)];
      final fee = engine.calcTimeFee(minutes: 30, businessType: 'karaoke', rules: rules);
      expect(fee, 3000);
    });

    test('업종 필터 — karaoke 규칙만 있을 때 salon으로 조회하면 0', () {
      final rules = [rule(businessType: 'karaoke', ruleType: 'time_base', value: 100)];
      final fee = engine.calcTimeFee(minutes: 30, businessType: 'salon', rules: rules);
      expect(fee, 0);
    });

    test('매칭 규칙이 없으면 0(예외를 던지지 않음)', () {
      final fee = engine.calcTimeFee(minutes: 30, businessType: 'izakaya', rules: const []);
      expect(fee, 0);
    });

    test('비활성(isActive=false) 규칙은 무시', () {
      final rules = [
        rule(businessType: 'karaoke', ruleType: 'time_base', value: 100, isActive: false),
      ];
      final fee = engine.calcTimeFee(minutes: 30, businessType: 'karaoke', rules: rules);
      expect(fee, 0);
    });

    test('동일 조건 규칙이 여러 개면 priority가 작은(우선순위 높은) 쪽 적용', () {
      final rules = [
        rule(businessType: 'karaoke', ruleType: 'time_base', value: 200, priority: 5),
        rule(businessType: 'karaoke', ruleType: 'time_base', value: 100, priority: 1),
      ];
      final fee = engine.calcTimeFee(minutes: 10, businessType: 'karaoke', rules: rules);
      expect(fee, 1000); // value=100짜리(priority=1)가 채택됨
    });
  });

  group('calcPeakSurcharge — 피크 할증', () {
    test('피크 시간대(23시)에 20% 할증', () {
      final rules = [rule(businessType: 'karaoke', ruleType: 'peak', value: 20)];
      final surcharge = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 25, 23, 0),
        baseFee: 1000,
        businessType: 'karaoke',
        rules: rules,
      );
      expect(surcharge, 200);
    });

    test('비피크 시간대(14시)에는 할증 없음(0)', () {
      final rules = [rule(businessType: 'karaoke', ruleType: 'peak', value: 20)];
      final surcharge = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 25, 14, 0),
        baseFee: 1000,
        businessType: 'karaoke',
        rules: rules,
      );
      expect(surcharge, 0);
    });

    test('자정 넘김 — 새벽 2시도 피크 시간대로 처리(할증 적용)', () {
      final rules = [rule(businessType: 'karaoke', ruleType: 'peak', value: 20)];
      final surcharge = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 26, 2, 0),
        baseFee: 1000,
        businessType: 'karaoke',
        rules: rules,
      );
      expect(surcharge, 200);
    });

    test('자정 넘김 경계값 — 06:00 정각은 피크 종료(할증 없음)', () {
      final rules = [rule(businessType: 'karaoke', ruleType: 'peak', value: 20)];
      final surcharge = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 26, 6, 0),
        baseFee: 1000,
        businessType: 'karaoke',
        rules: rules,
      );
      expect(surcharge, 0);
    });

    test('자정 넘김 경계값 — 22:00 정각부터 피크 시작(할증 적용)', () {
      final rules = [rule(businessType: 'karaoke', ruleType: 'peak', value: 20)];
      final surcharge = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 25, 22, 0),
        baseFee: 1000,
        businessType: 'karaoke',
        rules: rules,
      );
      expect(surcharge, 200);
    });

    test('피크 시간대여도 매칭되는 peak 규칙이 없으면 0', () {
      final surcharge = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 25, 23, 0),
        baseFee: 1000,
        businessType: 'karaoke',
        rules: const [],
      );
      expect(surcharge, 0);
    });

    test('소수점 할증액은 버림(floor) — baseFee=999, 20% → 199.8→199', () {
      final rules = [rule(businessType: 'izakaya', ruleType: 'peak', value: 20)];
      final surcharge = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 25, 23, 0),
        baseFee: 999,
        businessType: 'izakaya',
        rules: rules,
      );
      expect(surcharge, 199);
    });
  });

  group('isWithinPeakWindow — 순수 시간대 판정(정책은 호출자가 결정)', () {
    test('자정 넘는 구간(22~6시) — 22~23시는 포함', () {
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 22, 0), startHour: 22, endHour: 6),
        true,
      );
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 23, 59), startHour: 22, endHour: 6),
        true,
      );
    });
    test('자정 넘는 구간(22~6시) — 0~5시도 포함', () {
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 26, 0, 0), startHour: 22, endHour: 6),
        true,
      );
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 26, 5, 59), startHour: 22, endHour: 6),
        true,
      );
    });
    test('자정 넘는 구간(22~6시) — 6~21시는 제외', () {
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 6, 0), startHour: 22, endHour: 6),
        false,
      );
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 21, 59), startHour: 22, endHour: 6),
        false,
      );
    });

    test('자정을 넘지 않는 구간(점심 12~14시)도 동일 로직으로 판정 — 하드코딩이 아님을 증명', () {
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 12, 0), startHour: 12, endHour: 14),
        true,
      );
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 13, 59), startHour: 12, endHour: 14),
        true,
      );
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 14, 0), startHour: 12, endHour: 14),
        false,
      );
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 11, 59), startHour: 12, endHour: 14),
        false,
      );
    });

    test('startHour == endHour는 길이 0 구간 — 항상 false', () {
      expect(
        engine.isWithinPeakWindow(DateTime(2026, 6, 25, 10, 0), startHour: 10, endHour: 10),
        false,
      );
    });
  });

  group('calcPeakSurcharge — Rule 자신의 시간대를 사용(지점/업종별 다른 피크 시간대 지원)', () {
    test('점심 피크(12~14시)로 설정된 Rule은 22시가 아니라 12시에 할증이 붙는다', () {
      final rules = [
        rule(businessType: 'izakaya', ruleType: 'peak', value: 30, peakStartHour: 12, peakEndHour: 14),
      ];
      final atLunch = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 25, 13, 0),
        baseFee: 1000,
        businessType: 'izakaya',
        rules: rules,
      );
      final atNight = engine.calcPeakSurcharge(
        at: DateTime(2026, 6, 25, 23, 0),
        baseFee: 1000,
        businessType: 'izakaya',
        rules: rules,
      );
      expect(atLunch, 300); // 12~14시 구간 안 — 할증 적용
      expect(atNight, 0); // 이 Rule의 피크 구간 밖 — 할증 없음
    });
  });

  group('calcTotal', () {
    test('시간요금 + 피크할증 합산', () {
      expect(engine.calcTotal(timeFee: 3000, peakSurcharge: 200), 3200);
    });

    test('피크할증이 0이면 시간요금과 동일', () {
      expect(engine.calcTotal(timeFee: 3000, peakSurcharge: 0), 3000);
    });
  });
}
