import 'package:drift/drift.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../../customer/data/customer_repository.dart';
import '../../prepaid_pass/data/prepaid_pass_repository.dart';
import '../logic/payment_logic.dart';

/// design/spec/v3/payment_pos/feature_spec.md F-PAY-01~05 그대로 구현.
///
/// A-9(docs/ID_CONVENTION.md): id는 INTEGER AUTOINCREMENT — UUID 생성
/// 코드 없음.
class PaymentRepository {
  PaymentRepository(this._db, this._customerRepository, this._prepaidPassRepository);

  final AppDatabase _db;
  final CustomerRepository _customerRepository;
  final PrepaidPassRepository _prepaidPassRepository;

  static const _validMethods = {
    'cash',
    'card',
    'paypay',
    'linepay',
    'bank_transfer',
    'credit',
    'kakeuri',
    'prepaid_pass',
  };

  Stream<List<OrderRow>> watchOrders() {
    return (_db.select(_db.orders)
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .watch();
  }

  Future<List<OrderItemRow>> itemsOf(int orderId) async {
    try {
      return await (_db.select(_db.orderItems)
            ..where((i) => i.orderId.equals(orderId)))
          .get();
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  /// F-PAY-01: 주문(카트) 생성. 아이템이 1개 이상 있어야 한다.
  Future<OrderRow> createOrder({
    int? customerId,
    required List<({int productId, String productName, int quantity, int unitPrice, int? staffId})>
        items,
    int discountAmount = 0,
  }) async {
    if (items.isEmpty) {
      throw const ValidationException('商品が選択されていません。');
    }
    if (items.any((i) => i.quantity <= 0)) {
      throw const ValidationException('数量は1以上にしてください。');
    }

    try {
      final total = items.fold<int>(0, (sum, i) => sum + i.unitPrice * i.quantity);
      if (discountAmount > total) {
        throw const ValidationException('割引額が合計金額を超えています。');
      }

      final now = DateTime.now();
      final orderId = await _db.into(_db.orders).insert(
            OrdersCompanion.insert(
              customerId: Value(customerId),
              totalAmount: total,
              discountAmount: Value(discountAmount),
              createdAt: now,
            ),
          );
      for (final i in items) {
        await _db.into(_db.orderItems).insert(
              OrderItemsCompanion.insert(
                orderId: orderId,
                productId: i.productId,
                productName: i.productName,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                staffId: Value(i.staffId),
              ),
            );
      }
      return OrderRow(
        id: orderId,
        customerId: customerId,
        totalAmount: total,
        discountAmount: discountAmount,
        pointsUsed: 0,
        prepaidUsedJson: '[]',
        status: 'pending',
        createdAt: now,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// F-PAY-02: 결제 1건 처리(분할결제 시 여러 번 호출). 결제수단이
  /// cash면 거스름돈을 같이 계산해 저장한다(F-PAY-02a).
  ///
  /// **method='prepaid_pass'일 때 호출 순서 주의**: 이 메서드는 결제
  /// "기록"만 남긴다 — 실제 잔액 차감은 호출 전에
  /// `PrepaidPassRepository.useAmountBalance()`/`useCountBalance()`를
  /// 먼저 호출해서 끝내고, 그 결과(usedFromPrepaid)를 [amount]로 넘겨야
  /// 한다(F-PP-03). 두 레포지토리를 강하게 결합하지 않기 위한 설계.
  Future<PaymentRow> pay({
    required int orderId,
    required String method,
    required int amount,
    String? splitType,
    int? cashReceived,
    int? prepaidBalanceId,
  }) async {
    if (!_validMethods.contains(method)) {
      throw const ValidationException('決済方法の値が正しくありません。');
    }
    if (amount <= 0) {
      throw const ValidationException('決済金額は1円以上にしてください。');
    }
    if (method == 'cash') {
      if (cashReceived == null) {
        throw const ValidationException('受取金額を入力してください。');
      }
      if (!canPayWithCash(cashReceived, amount)) {
        throw const ValidationException('受取金額が決済金額より少ないです。');
      }
    }
    if (method == 'prepaid_pass' && prepaidBalanceId == null) {
      throw const ValidationException('使用するプリペイド券を選択してください。');
    }
    if (method == 'prepaid_pass' && splitType != null) {
      // F-PP-02: 선불권은 분할결제(F-PAY-04) 대상에서 제외.
      throw const BusinessRuleException('プリペイド券は分割決済に使用できません。');
    }

    try {
      final order = await (_db.select(_db.orders)
            ..where((o) => o.id.equals(orderId)))
          .getSingleOrNull();
      if (order == null) {
        throw const NotFoundException('注文が見つかりませんでした。');
      }
      if (order.status == 'cancelled') {
        throw const BusinessRuleException('この注文は既にキャンセルされています。');
      }

      final paidSoFar = await _paidAmount(orderId);
      final netTotal = order.totalAmount - order.discountAmount;
      if (paidSoFar + amount > netTotal) {
        throw const BusinessRuleException('決済金額が残りの注文金額を超えています。');
      }

      final now = DateTime.now();
      final change = method == 'cash' ? computeChange(cashReceived!, amount) : null;
      final id = await _db.into(_db.payments).insert(
            PaymentsCompanion.insert(
              orderId: orderId,
              method: method,
              amount: amount,
              splitType: Value(splitType),
              cashReceived: Value(cashReceived),
              cashChange: Value(change),
              prepaidBalanceId: Value(prepaidBalanceId),
              createdAt: now,
            ),
          );

      final newPaidTotal = paidSoFar + amount;
      final newStatus = newPaidTotal >= netTotal ? 'completed' : 'partially_paid';
      await (_db.update(_db.orders)..where((o) => o.id.equals(orderId)))
          .write(OrdersCompanion(status: Value(newStatus)));

      // A-1(design/spec/v3/A1_PREFLIGHT_REVIEW.md): 방문확정 단일 트리거.
      // A1_A2_BOUNDARY.md §3 원칙대로 PaymentRepository만이 호출 책임을
      // 진다. 위의 초과결제 차단 로직이 같은 주문에서 이 분기가 두 번
      // 실행되는 것을 막아준다(중복 적재 방지, §6 점검 결과 그대로).
      // 예약경로(completeBooking() 연동)는 1차 범위에 포함하지 않음
      // (§8 점검 결과 — Order에 bookingId를 저장할 컬럼이 없어 후속작업
      // 으로 분리).
      if (newStatus == 'completed' && order.customerId != null) {
        final staffId = await _staffIdOf(orderId);
        await _customerRepository.recordVisit(
          customerId: order.customerId!,
          visitDate: now,
          staffId: staffId,
          amount: netTotal,
        );
      }

      return PaymentRow(
        id: id,
        orderId: orderId,
        method: method,
        amount: amount,
        splitType: splitType,
        cashReceived: cashReceived,
        cashChange: change,
        prepaidBalanceId: prepaidBalanceId,
        status: 'completed',
        createdAt: now,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// A-1(design/spec/v3/A1_PREFLIGHT_REVIEW.md §0-2): 로그인/세션이
  /// 없어 "결제 처리자"를 알 방법이 없으므로, VisitRecord.staffId는
  /// 시술을 담당한 스태프(OrderItem.staffId)에서 조달한다. 한 주문에
  /// 담당자가 다른 품목이 섞여 있으면 첫 번째 non-null 값을 채택한다
  /// (groupOf() 그룹분류는 이 값을 쓰지 않는 보조정보라 단순화 허용).
  Future<int?> _staffIdOf(int orderId) async {
    final items = await (_db.select(_db.orderItems)
          ..where((i) => i.orderId.equals(orderId)))
        .get();
    for (final item in items) {
      if (item.staffId != null) return item.staffId;
    }
    return null;
  }

  Future<int> _paidAmount(int orderId) async {
    final payments = await (_db.select(_db.payments)
          ..where((p) => p.orderId.equals(orderId) & p.status.equals('completed')))
        .get();
    return payments.fold<int>(0, (sum, p) => sum + p.amount);
  }

  /// 잔여 결제금액(분할결제 진행 중 "총 N원 중 M원 남음" 표시용).
  Future<int> remainingAmount(int orderId) async {
    try {
      final order = await (_db.select(_db.orders)
            ..where((o) => o.id.equals(orderId)))
          .getSingleOrNull();
      if (order == null) {
        throw const NotFoundException('注文が見つかりませんでした。');
      }
      final netTotal = order.totalAmount - order.discountAmount;
      final paid = await _paidAmount(orderId);
      return netTotal - paid;
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.readFailed('$e');
    }
  }

  /// F-PAY-05: 결제 취소(환불) — 원자적 처리.
  /// M6에서 선불권 환원 연동 완료(이전 TODO 해소, CROSS_VALIDATION.md
  /// 수정2 후속) — method='prepaid_pass'인 결제는 해당 잔액에
  /// `restoreUse()`로 사용분을 되돌려준다.
  Future<void> cancelOrder(int orderId) async {
    try {
      await _db.transaction(() async {
        final order = await (_db.select(_db.orders)
              ..where((o) => o.id.equals(orderId)))
            .getSingleOrNull();
        if (order == null) {
          throw const NotFoundException('注文が見つかりませんでした。');
        }
        if (order.status == 'cancelled') {
          throw const BusinessRuleException('この注文は既にキャンセルされています。');
        }

        if (order.pointsUsed > 0 && order.customerId != null) {
          await _customerRepository.restorePoints(order.customerId!, order.pointsUsed);
        }

        final prepaidPayments = await (_db.select(_db.payments)
              ..where((p) =>
                  p.orderId.equals(orderId) &
                  p.method.equals('prepaid_pass') &
                  p.status.equals('completed')))
            .get();
        for (final p in prepaidPayments) {
          if (p.prepaidBalanceId != null) {
            await _prepaidPassRepository.restoreUse(
              balanceId: p.prepaidBalanceId!,
              amount: p.amount,
            );
          }
        }

        await (_db.update(_db.payments)..where((p) => p.orderId.equals(orderId)))
            .write(const PaymentsCompanion(status: Value('refunded')));
        await (_db.update(_db.orders)..where((o) => o.id.equals(orderId)))
            .write(const OrdersCompanion(status: Value('cancelled')));
      });
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}
