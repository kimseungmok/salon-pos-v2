import '../../../db/app_database.dart';

/// design/spec/v3/booking/data_spec.md computeEndAt() 그대로.
DateTime computeEndAt(
  DateTime startAt,
  List<String> productIds,
  List<ProductRow> products,
) {
  final totalMinutes = productIds.fold<int>(0, (sum, id) {
    final p = products.where((p) => p.id == id).firstOrNull;
    return sum + (p?.durationMin ?? 0);
  });
  return startAt.add(Duration(minutes: totalMinutes));
}

/// design/spec/v3/booking/data_spec.md waitColor() 그대로. F-BOOK-03.
enum WaitColor { gray, orange, red }

WaitColor waitColor(DateTime checkInAt, DateTime now) {
  final minutes = now.difference(checkInAt).inMinutes;
  if (minutes < 10) return WaitColor.gray;
  if (minutes < 20) return WaitColor.orange;
  return WaitColor.red;
}

/// 두 시간구간이 겹치는지 — staffAvailability()의 예약중복 체크에 사용.
bool overlaps(DateTime aStart, DateTime aEnd, DateTime bStart, DateTime bEnd) {
  return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
}
