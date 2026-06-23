import '../../../db/app_database.dart';

/// design/spec/v3/customer/feature_spec.md F-CUST-01,
/// data_spec.md groupOf() 그대로 구현한 순수 함수.
///
/// **반드시 이 함수를 통해서만** 고객 그룹을 계산한다 — 09/10/06 등
/// 여러 화면이 같은 결과를 봐야 하므로(customer/data_spec.md "화면 간
/// 데이터 의존" 참조), 화면마다 따로 구현하지 않는다.
enum CustomerGroup { first, preRegular, regular, dormant }

const Map<CustomerGroup, String> kGroupLabel = {
  CustomerGroup.first: '初回来店',
  CustomerGroup.preRegular: '予備常連',
  CustomerGroup.regular: '常連',
  CustomerGroup.dormant: '休眠ぎみ',
};

const Map<CustomerGroup, String> kGroupIcon = {
  CustomerGroup.first: '🐣',
  CustomerGroup.preRegular: '🟡',
  CustomerGroup.regular: '🔴',
  CustomerGroup.dormant: '⚪',
};

CustomerGroup groupOf(
  String customerId,
  List<VisitRecordRow> allVisits,
  DateTime today,
) {
  final completed = allVisits
      .where((v) => v.customerId == customerId && v.status == 'completed')
      .toList()
    ..sort((a, b) => b.visitDate.compareTo(a.visitDate));

  if (completed.length <= 1) return CustomerGroup.first;

  final lastVisit = completed.first.visitDate;
  final daysSinceLastVisit = today.difference(lastVisit).inDays;

  final visits90d =
      completed.where((v) => today.difference(v.visitDate).inDays <= 90).length;

  if (daysSinceLastVisit >= 45) return CustomerGroup.dormant;
  if (visits90d >= 7) return CustomerGroup.regular;
  return CustomerGroup.preRegular;
}
