import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../logic/prepaid_pass_logic.dart';

const _uuid = Uuid();

/// design/spec/v3/prepaid_pass/feature_spec.md F-PP-01~05 그대로 구현.
class PrepaidPassRepository {
  PrepaidPassRepository(this._db);

  final AppDatabase _db;

  static const _validTypes = {'amount', 'count'};
  static const _validExpiryTypes = {
    'none', '90d', '180d', '1y', '2y', '3y', 'fixedDate', 'custom',
  };

  Stream<List<PrepaidPassMenuRow>> watchMenus() {
    return (_db.select(_db.prepaidPassMenus)
          ..where((m) => m.status.equals('active')))
        .watch();
  }

  Stream<List<PrepaidPassBalanceRow>> watchBalancesOf(String customerId) {
    return (_db.select(_db.prepaidPassBalances)
          ..where((b) => b.customerId.equals(customerId) & b.status.equals('active')))
        .watch();
  }

  // ── F-PP-01: 메뉴 생성 ──────────────────────────────────────────────

  Future<PrepaidPassMenuRow> createMenu({
    required String type,
    required String name,
    String? linkedProductId,
    required int price,
    bool allowCustomPrice = false,
    int? countPerPurchase,
    String bonusType = 'none',
    int? bonusAmount,
    int? bonusCount,
    String expiryType = 'none',
    int? expiryCustomDays,
  }) async {
    if (!_validTypes.contains(type)) {
      throw const ValidationException('プリペイド券の種類が正しくありません。');
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException('メニュー名を入力してください。');
    }
    if (type == 'count') {
      if (linkedProductId == null || linkedProductId.isEmpty) {
        throw const ValidationException('回数券は適用商品を1つ選択してください。');
      }
      if (countPerPurchase == null || countPerPurchase <= 0) {
        throw const ValidationException('回数を1以上で入力してください。');
      }
    }
    if (!allowCustomPrice && price <= 0) {
      throw const ValidationException('決済価格を入力してください。');
    }
    if (!_validExpiryTypes.contains(expiryType)) {
      throw const ValidationException('有効期限の値が正しくありません。');
    }

    try {
      final id = _uuid.v4();
      await _db.into(_db.prepaidPassMenus).insert(
            PrepaidPassMenusCompanion.insert(
              id: id,
              type: type,
              name: trimmedName,
              linkedProductId: Value(linkedProductId),
              price: price,
              allowCustomPrice: Value(allowCustomPrice),
              countPerPurchase: Value(countPerPurchase),
              bonusType: Value(bonusType),
              bonusAmount: Value(bonusAmount),
              bonusCount: Value(bonusCount),
              expiryType: Value(expiryType),
              expiryCustomDays: Value(expiryCustomDays),
            ),
          );
      return PrepaidPassMenuRow(
        id: id,
        type: type,
        name: trimmedName,
        linkedProductId: linkedProductId,
        price: price,
        allowCustomPrice: allowCustomPrice,
        countPerPurchase: countPerPurchase,
        bonusType: bonusType,
        bonusAmount: bonusAmount,
        bonusCount: bonusCount,
        expiryType: expiryType,
        expiryCustomDays: expiryCustomDays,
        status: 'active',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  // ── F-PP-02: 충전(판매) ────────────────────────────────────────────

  /// 선불권 충전 — 일반상품과 별도 결제(F-PP-02 규칙, payment_pos의
  /// Order를 거치지 않고 독립적으로 처리). 보너스 충전(F-PP-01a)을
  /// 자동 적용한다.
  Future<PrepaidPassBalanceRow> chargeMenu({
    required String customerId,
    required String menuId,
  }) async {
    if (customerId.isEmpty) {
      throw const ValidationException('お客様を選択してください。');
    }
    try {
      final menu = await (_db.select(_db.prepaidPassMenus)
            ..where((m) => m.id.equals(menuId)))
          .getSingleOrNull();
      if (menu == null) {
        throw const NotFoundException('プリペイド券メニューが見つかりませんでした。');
      }
      if (menu.status != 'active') {
        throw const BusinessRuleException('このメニューは現在販売停止中です。');
      }

      final now = DateTime.now();
      final expiresAt = computeExpiry(menu, now);

      int? remainingAmount;
      int? remainingCount;
      if (menu.type == 'amount') {
        remainingAmount = menu.price;
        if (menu.bonusType == 'bonus' && menu.bonusAmount != null) {
          remainingAmount += menu.bonusAmount!;
        }
      } else {
        remainingCount = menu.countPerPurchase ?? 0;
        if (menu.bonusType == 'bonus' && menu.bonusCount != null) {
          remainingCount += menu.bonusCount!;
        }
      }

      final balanceId = _uuid.v4();
      await _db.into(_db.prepaidPassBalances).insert(
            PrepaidPassBalancesCompanion.insert(
              id: balanceId,
              customerId: customerId,
              menuId: menuId,
              remainingAmount: Value(remainingAmount),
              remainingCount: Value(remainingCount),
              purchasedAt: now,
              expiresAt: Value(expiresAt),
            ),
          );
      await _db.into(_db.prepaidPassTransactions).insert(
            PrepaidPassTransactionsCompanion.insert(
              id: _uuid.v4(),
              balanceId: balanceId,
              type: 'charge',
              amount: Value(remainingAmount),
              count: Value(remainingCount),
              createdAt: now,
            ),
          );

      return PrepaidPassBalanceRow(
        id: balanceId,
        customerId: customerId,
        menuId: menuId,
        remainingAmount: remainingAmount,
        remainingCount: remainingCount,
        purchasedAt: now,
        expiresAt: expiresAt,
        status: 'active',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  // ── F-PP-03: 사용(결제 차감) ────────────────────────────────────────

  Future<PrepaidPaymentResult> useAmountBalance({
    required String balanceId,
    required int requestedAmount,
    String? relatedOrderId,
  }) async {
    if (requestedAmount <= 0) {
      throw const ValidationException('使用金額は1円以上にしてください。');
    }
    try {
      final balance = await _activeBalanceOrThrow(balanceId);
      if (balance.remainingAmount == null) {
        throw const BusinessRuleException('この券は金額チャージ券ではありません。');
      }
      final result = applyPrepaidAmountPayment(balance.remainingAmount!, requestedAmount);
      await (_db.update(_db.prepaidPassBalances)..where((b) => b.id.equals(balanceId)))
          .write(PrepaidPassBalancesCompanion(
        remainingAmount: Value(balance.remainingAmount! - result.usedFromPrepaid),
      ));
      await _db.into(_db.prepaidPassTransactions).insert(
            PrepaidPassTransactionsCompanion.insert(
              id: _uuid.v4(),
              balanceId: balanceId,
              type: 'use',
              amount: Value(-result.usedFromPrepaid),
              relatedOrderId: Value(relatedOrderId),
              createdAt: DateTime.now(),
            ),
          );
      return result;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// 횟수권 사용 — 1회 시술 = 1회 차감(부분차감 없음, F-PP-03).
  Future<void> useCountBalance({
    required String balanceId,
    String? relatedOrderId,
  }) async {
    try {
      final balance = await _activeBalanceOrThrow(balanceId);
      if (balance.remainingCount == null) {
        throw const BusinessRuleException('この券は回数券ではありません。');
      }
      if (!canUseCountPass(balance.remainingCount!)) {
        throw const BusinessRuleException('残り回数がありません。');
      }
      await (_db.update(_db.prepaidPassBalances)..where((b) => b.id.equals(balanceId)))
          .write(PrepaidPassBalancesCompanion(
        remainingCount: Value(balance.remainingCount! - 1),
      ));
      await _db.into(_db.prepaidPassTransactions).insert(
            PrepaidPassTransactionsCompanion.insert(
              id: _uuid.v4(),
              balanceId: balanceId,
              type: 'use',
              count: const Value(-1),
              relatedOrderId: Value(relatedOrderId),
              createdAt: DateTime.now(),
            ),
          );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<PrepaidPassBalanceRow> _activeBalanceOrThrow(String balanceId) async {
    final balance = await (_db.select(_db.prepaidPassBalances)
          ..where((b) => b.id.equals(balanceId)))
        .getSingleOrNull();
    if (balance == null) {
      throw const NotFoundException('プリペイド券が見つかりませんでした。');
    }
    if (balance.status != 'active') {
      throw const BusinessRuleException('この券は使用できません（失効または無効化済み）。');
    }
    if (balance.expiresAt != null && DateTime.now().isAfter(balance.expiresAt!)) {
      await (_db.update(_db.prepaidPassBalances)..where((b) => b.id.equals(balanceId)))
          .write(const PrepaidPassBalancesCompanion(status: Value('expired')));
      throw const BusinessRuleException('この券は有効期限が切れています。');
    }
    return balance;
  }

  /// payment_pos의 결제취소(F-PAY-05)가 호출 — 정규주문에서 선불권을
  /// 사용했다가 주문이 취소되면 사용분을 되돌려준다(F-PP-02의 "충전
  /// 취소시 재사용 불가"와는 다른 케이스 — 이건 사용 취소의 복원).
  Future<void> restoreUse({
    required String balanceId,
    int? amount,
    int? count,
  }) async {
    try {
      final balance = await (_db.select(_db.prepaidPassBalances)
            ..where((b) => b.id.equals(balanceId)))
          .getSingleOrNull();
      if (balance == null) {
        throw const NotFoundException('プリペイド券が見つかりませんでした。');
      }
      if (amount != null) {
        await (_db.update(_db.prepaidPassBalances)..where((b) => b.id.equals(balanceId)))
            .write(PrepaidPassBalancesCompanion(
          remainingAmount: Value((balance.remainingAmount ?? 0) + amount),
        ));
      }
      if (count != null) {
        await (_db.update(_db.prepaidPassBalances)..where((b) => b.id.equals(balanceId)))
            .write(PrepaidPassBalancesCompanion(
          remainingCount: Value((balance.remainingCount ?? 0) + count),
        ));
      }
      await _db.into(_db.prepaidPassTransactions).insert(
            PrepaidPassTransactionsCompanion.insert(
              id: _uuid.v4(),
              balanceId: balanceId,
              type: 'refund',
              amount: Value(amount),
              count: Value(count),
              createdAt: DateTime.now(),
            ),
          );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// F-PP-02: 충전(구매) 자체를 취소 — 잔액 전부 소멸, 재사용 불가.
  Future<void> voidCharge(String balanceId) async {
    try {
      final rows = await (_db.update(_db.prepaidPassBalances)
            ..where((b) => b.id.equals(balanceId)))
          .write(const PrepaidPassBalancesCompanion(
        status: Value('voided'),
        remainingAmount: Value(0),
        remainingCount: Value(0),
      ));
      if (rows == 0) {
        throw const NotFoundException('プリペイド券が見つかりませんでした。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  // ── F-PP-05: 과거 종이 티켓 마이그레이션 ───────────────────────────

  Future<PrepaidPassBalanceRow> migratePaperTicket({
    required String customerId,
    required String menuId,
    int? remainingAmount,
    int? remainingCount,
    required DateTime originalPurchaseDate,
  }) async {
    if (remainingAmount == null && remainingCount == null) {
      throw const ValidationException('残り回数または残額を入力してください。');
    }
    try {
      final menu = await (_db.select(_db.prepaidPassMenus)
            ..where((m) => m.id.equals(menuId)))
          .getSingleOrNull();
      if (menu == null) {
        throw const NotFoundException('プリペイド券メニューが見つかりませんでした。');
      }
      final expiresAt = computeExpiry(menu, originalPurchaseDate);
      final id = _uuid.v4();
      await _db.into(_db.prepaidPassBalances).insert(
            PrepaidPassBalancesCompanion.insert(
              id: id,
              customerId: customerId,
              menuId: menuId,
              remainingAmount: Value(remainingAmount),
              remainingCount: Value(remainingCount),
              purchasedAt: originalPurchaseDate,
              expiresAt: Value(expiresAt),
            ),
          );
      return PrepaidPassBalanceRow(
        id: id,
        customerId: customerId,
        menuId: menuId,
        remainingAmount: remainingAmount,
        remainingCount: remainingCount,
        purchasedAt: originalPurchaseDate,
        expiresAt: expiresAt,
        status: 'active',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}
