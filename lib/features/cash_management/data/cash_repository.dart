import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../logic/cash_logic.dart';

/// design/spec/v3/cash_management/feature_spec.md F-CASH-01~04 그대로.
///
/// A-9(docs/ID_CONVENTION.md): id는 INTEGER AUTOINCREMENT — UUID 생성
/// 코드 없음. `confirmedBy`는 자유 텍스트 표시값으로 유지(Staff.id를
/// 강제 참조하지 않음, F-STAFF-00).
class CashManagementRepository {
  CashManagementRepository(this._db);

  final AppDatabase _db;

  static const _defaultChecklist = [
    '本日の売上精算書を出力・確認',
    '施術スペース・待合スペースを整理',
    '消耗品・在庫の締め確認',
    '出入口施錠・セキュリティON',
  ];

  Stream<List<CashCountRow>> watchCountsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (_db.select(_db.cashCounts)
          ..where((c) =>
              c.date.isBiggerOrEqualValue(start) & c.date.isSmallerThanValue(end)))
        .watch();
  }

  /// F-CASH-02: 권종별 카운트 1건 기록(개점 또는 폐점).
  Future<CashCountRow> recordCount({
    required String type,
    required DateTime date,
    required Map<int, int> denominations,
    required int expectedAmount,
    String? confirmedBy,
  }) async {
    if (!{'open', 'close'}.contains(type)) {
      throw const ValidationException('種類の値が正しくありません。');
    }
    if (denominations.keys.any((k) => !kDenomUnits.containsKey(k))) {
      throw const ValidationException('金種の値が正しくありません。');
    }
    if (denominations.values.any((v) => v < 0)) {
      throw const ValidationException('枚数・個数は0以上にしてください。');
    }

    try {
      final total = computeTotal(denominations);
      final diff = computeDiff(total, expectedAmount);
      final now = DateTime.now();
      final id = await _db.into(_db.cashCounts).insert(
            CashCountsCompanion.insert(
              type: type,
              date: DateTime(date.year, date.month, date.day),
              denominationsJson: jsonEncode(denominations.map((k, v) => MapEntry('$k', v))),
              totalAmount: total,
              expectedAmount: expectedAmount,
              diffAmount: diff,
              confirmedAt: Value(now),
              confirmedBy: Value(confirmedBy),
            ),
          );
      return CashCountRow(
        id: id,
        type: type,
        date: DateTime(date.year, date.month, date.day),
        denominationsJson: jsonEncode(denominations.map((k, v) => MapEntry('$k', v))),
        totalAmount: total,
        expectedAmount: expectedAmount,
        diffAmount: diff,
        confirmedAt: now,
        confirmedBy: confirmedBy,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// 전일 마감액 조회(F-CASH-01: 개점화면의 "前日締め予想額" 산출).
  Future<int?> previousCloseTotal(DateTime date) async {
    try {
      final yesterday = DateTime(date.year, date.month, date.day)
          .subtract(const Duration(days: 1));
      final row = await (_db.select(_db.cashCounts)
            ..where((c) => c.type.equals('close') & c.date.equals(yesterday))
            ..orderBy([(c) => OrderingTerm.desc(c.confirmedAt)])
            ..limit(1))
          .getSingleOrNull();
      return row?.totalAmount;
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  // ── F-CASH-04: 폐점 체크리스트(살롱 고유) ──────────────────────────

  Stream<List<ClosingChecklistItemRow>> watchChecklist(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return (_db.select(_db.closingChecklistItems)
          ..where((c) => c.date.equals(dateOnly)))
        .watch();
  }

  /// 당일 체크리스트가 없으면 기본 4항목으로 생성.
  Future<void> ensureChecklist(DateTime date) async {
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final existing = await (_db.select(_db.closingChecklistItems)
            ..where((c) => c.date.equals(dateOnly)))
          .get();
      if (existing.isNotEmpty) return;
      for (final label in _defaultChecklist) {
        await _db.into(_db.closingChecklistItems).insert(
              ClosingChecklistItemsCompanion.insert(
                date: dateOnly,
                label: label,
              ),
            );
      }
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<void> toggleChecklistItem(int id, bool checked) async {
    try {
      final rows = await (_db.update(_db.closingChecklistItems)
            ..where((c) => c.id.equals(id)))
          .write(ClosingChecklistItemsCompanion(checked: Value(checked)));
      if (rows == 0) {
        throw const NotFoundException('チェックリスト項目が見つかりませんでした。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}

/// CashCountRow.denominationsJson을 `Map<int,int>`로 역직렬화.
Map<int, int> decodeDenominations(String json) {
  final decoded = jsonDecode(json) as Map<String, dynamic>;
  return decoded.map((k, v) => MapEntry(int.parse(k), v as int));
}
