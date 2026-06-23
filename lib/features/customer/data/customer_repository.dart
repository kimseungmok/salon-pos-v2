import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';

const _uuid = Uuid();

/// design/spec/v3/customer/feature_spec.md F-CUST-02/04 그대로 구현.
class CustomerRepository {
  CustomerRepository(this._db);

  final AppDatabase _db;

  Stream<List<CustomerRow>> watchCustomers() {
    return (_db.select(_db.customers)
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .watch();
  }

  Stream<List<VisitRecordRow>> watchAllVisits() {
    return _db.select(_db.visitRecords).watch();
  }

  /// F-CUST-04: 전화번호 뒷자리 또는 이름 부분일치 검색.
  Future<List<CustomerRow>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return watchCustomersOnce();
    try {
      return await (_db.select(_db.customers)
            ..where((c) => c.name.contains(trimmed) | c.phone.contains(trimmed)))
          .get();
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  Future<List<CustomerRow>> watchCustomersOnce() async {
    try {
      return await _db.select(_db.customers).get();
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  Future<CustomerRow> createCustomer({
    required String name,
    required String phone,
  }) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException('お客様の名前を入力してください。');
    }
    if (trimmedPhone.isEmpty) {
      throw const ValidationException('電話番号を入力してください。');
    }

    try {
      final duplicate = await (_db.select(_db.customers)
            ..where((c) => c.phone.equals(trimmedPhone)))
          .getSingleOrNull();
      if (duplicate != null) {
        throw BusinessRuleException('この電話番号は既に登録されているお客様です（${duplicate.name}様）。');
      }

      final id = _uuid.v4();
      final now = DateTime.now();
      await _db.into(_db.customers).insert(
            CustomersCompanion.insert(
              id: id,
              name: trimmedName,
              phone: trimmedPhone,
              createdAt: now,
            ),
          );
      return CustomerRow(
        id: id,
        name: trimmedName,
        phone: trimmedPhone,
        points: 0,
        createdAt: now,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// F-CUST-02: 메모 저장. 권한 체크(오너만)는 화면단(호출 측)에서
  /// 로그인 정보로 판단 — 레포지토리는 저장만 책임진다.
  Future<void> updateMemo(String customerId, String memo) async {
    try {
      final rows = await (_db.update(_db.customers)
            ..where((c) => c.id.equals(customerId)))
          .write(CustomersCompanion(memo: Value(memo)));
      if (rows == 0) {
        throw const NotFoundException('お客様情報が見つかりませんでした。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// 방문 완료 기록 — F-CUST-01 그룹 재계산은 다음 조회 시 자동 반영
  /// (저장값이 아니라 항상 즉시 계산이므로 별도 트리거 불필요).
  Future<void> recordVisit({
    required String customerId,
    required DateTime visitDate,
    String? staffId,
    int amount = 0,
    String status = 'completed',
  }) async {
    if (!['completed', 'noshow', 'cancelled'].contains(status)) {
      throw const ValidationException('来店ステータスの値が正しくありません。');
    }
    try {
      final customer = await (_db.select(_db.customers)
            ..where((c) => c.id.equals(customerId)))
          .getSingleOrNull();
      if (customer == null) {
        throw const NotFoundException('お客様情報が見つかりませんでした。');
      }
      await _db.into(_db.visitRecords).insert(
            VisitRecordsCompanion.insert(
              id: _uuid.v4(),
              customerId: customerId,
              visitDate: visitDate,
              staffId: Value(staffId),
              amount: Value(amount),
              status: Value(status),
            ),
          );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}
