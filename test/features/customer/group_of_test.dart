import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/customer/logic/group_of.dart';

/// design/spec/v3/customer/feature_spec.md F-CUST-01 알고리즘을
/// 표에 명시된 경계값까지 빠짐없이 검증(IMPLEMENTATION_PLAN.md §5
/// 테스트 전략 그대로 — "표에 명시된 경계값 케이스를 그대로 테스트
/// 케이스로 사용").
void main() {
  int visitSeq = 0;
  VisitRecordRow visit({
    required int customerId,
    required DateTime visitDate,
    String status = 'completed',
  }) {
    visitSeq++;
    return VisitRecordRow(
      id: visitSeq,
      customerId: customerId,
      visitDate: visitDate,
      amount: 0,
      status: status,
    );
  }

  final today = DateTime(2026, 6, 23);

  test('방문 0회(예약만 있고 미방문) → 初回来店', () {
    expect(groupOf(1, [], today), CustomerGroup.first);
  });

  test('방문 1회 → 初回来店', () {
    final visits = [visit(customerId: 1, visitDate: today)];
    expect(groupOf(1, visits, today), CustomerGroup.first);
  });

  test('90일 이내 7회 방문, 45일 이내 재방문 → 常連', () {
    final visits = List.generate(
      7,
      (i) => visit(customerId: 1, visitDate: today.subtract(Duration(days: i * 10))),
    );
    expect(groupOf(1, visits, today), CustomerGroup.regular);
  });

  test('90일 이내 6회만 방문 → 常連 미달, 予備常連', () {
    final visits = List.generate(
      6,
      (i) => visit(customerId: 1, visitDate: today.subtract(Duration(days: i * 10))),
    );
    expect(groupOf(1, visits, today), CustomerGroup.preRegular);
  });

  test('마지막 방문 44일 전(임계값 미달) → 休眠ぎみ 아님', () {
    final visits = [
      visit(customerId: 1, visitDate: today.subtract(const Duration(days: 44))),
      visit(customerId: 1, visitDate: today.subtract(const Duration(days: 100))),
    ];
    expect(groupOf(1, visits, today), isNot(CustomerGroup.dormant));
  });

  test('마지막 방문 정확히 45일 전(경계값) → 休眠ぎみ', () {
    final visits = [
      visit(customerId: 1, visitDate: today.subtract(const Duration(days: 45))),
      visit(customerId: 1, visitDate: today.subtract(const Duration(days: 100))),
    ];
    expect(groupOf(1, visits, today), CustomerGroup.dormant);
  });

  test('常連 조건(90일7회)을 만족해도 45일 미방문이면 休眠ぎみ가 우선', () {
    final visits = List.generate(
      7,
      (i) => visit(customerId: 1, visitDate: today.subtract(Duration(days: 50 + i * 10))),
    );
    expect(groupOf(1, visits, today), CustomerGroup.dormant);
  });

  test('노쇼(noshow)는 방문 횟수에서 제외 — completed만 카운트', () {
    final visits = [
      visit(customerId: 1, visitDate: today, status: 'noshow'),
      visit(customerId: 1, visitDate: today.subtract(const Duration(days: 5))),
    ];
    // completed가 1건뿐이므로 初回来店로 판정되어야 함(noshow는 무시).
    expect(groupOf(1, visits, today), CustomerGroup.first);
  });

  test('취소(cancelled)된 방문도 카운트에서 제외', () {
    final visits = [
      visit(customerId: 1, visitDate: today, status: 'cancelled'),
      visit(customerId: 1, visitDate: today.subtract(const Duration(days: 5))),
    ];
    expect(groupOf(1, visits, today), CustomerGroup.first);
  });

  test('다른 고객의 방문 기록은 섞이지 않음', () {
    final visits = [
      ...List.generate(
        7,
        (i) => visit(customerId: 2, visitDate: today.subtract(Duration(days: i * 10))),
      ),
      visit(customerId: 1, visitDate: today.subtract(const Duration(days: 5))),
    ];
    expect(groupOf(1, visits, today), CustomerGroup.first);
    expect(groupOf(2, visits, today), CustomerGroup.regular);
  });
}
