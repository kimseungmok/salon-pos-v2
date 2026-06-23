import 'package:intl/intl.dart';

/// design/spec/v3/01_glossary.md "숫자·단위 표기 규칙" 그대로 구현.
/// 앱 전체에서 화폐/날짜 표시는 항상 이 함수들을 거친다 — 화면마다
/// 포맷을 따로 만들지 않는다(일관성 보장).

final _yenFormat = NumberFormat('#,###');

/// ¥12,000 형식. 円 텍스트는 절대 붙이지 않는다(글로서리 규칙).
String formatYen(int amount) => '¥${_yenFormat.format(amount)}';

/// 2026年6月23日（火） 형식.
String formatDateJp(DateTime date) {
  const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  final w = weekdays[date.weekday - 1];
  return '${date.year}年${date.month}月${date.day}日（$w）';
}

/// 14:30 형식(24시간).
String formatTimeJp(DateTime time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

/// 来店3回 / 注文5件처럼 단위가 다른 두 카운트 표기 헬퍼.
String formatCount(int n, {required String unit}) => '$n$unit';
