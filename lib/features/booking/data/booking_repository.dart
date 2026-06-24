import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../../staff/data/staff_repository.dart';
import '../logic/booking_logic.dart';

const _uuid = Uuid();

/// design/spec/v3/booking/feature_spec.md F-BOOK-01/02/02a/04 그대로.
class BookingRepository {
  BookingRepository(this._db, this._staffRepository);

  final AppDatabase _db;
  final StaffRepository _staffRepository;

  Stream<List<BookingRow>> watchBookings({DateTime? day}) {
    final query = _db.select(_db.bookings);
    if (day != null) {
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      query.where((b) =>
          b.startAt.isBiggerOrEqualValue(start) & b.startAt.isSmallerThanValue(end));
    }
    return query.watch();
  }

  /// F-BOOK-02: 예약 등록. 담당자가 지정된 경우 F-BOOK-02 규칙대로
  /// "같은 시간대 중복 예약"을 사전에 차단한다(담당자 칩의 予約あり
  /// 표시와 동일한 판단 로직을 서버측에서도 강제).
  Future<BookingRow> createBooking({
    required String customerId,
    String? staffId,
    required List<String> productIds,
    required DateTime startAt,
    required DateTime endAt,
    bool depositEnabled = false,
    String? depositMethod,
    int? depositAmount,
    bool depositReceived = false,
    String refundNote = '返金は24時間以内に可能です。',
    String repeatRule = 'none',
    String? memo,
    bool requiresApproval = false,
  }) async {
    if (customerId.isEmpty) {
      throw const ValidationException('お客様を選択してください。');
    }
    if (productIds.isEmpty) {
      throw const ValidationException('メニューを選択してください。');
    }
    if (!endAt.isAfter(startAt)) {
      throw const ValidationException('終了時刻は開始時刻より後にしてください。');
    }
    if (depositEnabled && (depositAmount == null || depositAmount <= 0)) {
      throw const ValidationException('予約金の金額を入力してください。');
    }

    try {
      if (staffId != null) {
        await _assertStaffAvailable(staffId, startAt, endAt);
      }

      final id = _uuid.v4();
      await _db.into(_db.bookings).insert(
            BookingsCompanion.insert(
              id: id,
              customerId: customerId,
              staffId: Value(staffId),
              productIdsCsv: Value(productIds.join(',')),
              startAt: startAt,
              endAt: endAt,
              depositEnabled: Value(depositEnabled),
              depositMethod: Value(depositMethod),
              depositAmount: Value(depositAmount),
              depositReceived: Value(depositReceived),
              refundNote: Value(refundNote),
              repeatRule: Value(repeatRule),
              memo: Value(memo),
              requiresApproval: Value(requiresApproval),
            ),
          );
      return BookingRow(
        id: id,
        customerId: customerId,
        staffId: staffId,
        productIdsCsv: productIds.join(','),
        startAt: startAt,
        endAt: endAt,
        depositEnabled: depositEnabled,
        depositMethod: depositMethod,
        depositAmount: depositAmount,
        depositReceived: depositReceived,
        depositRefunded: false,
        refundNote: refundNote,
        repeatRule: repeatRule,
        memo: memo,
        requiresApproval: requiresApproval,
        status: 'confirmed',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<void> _assertStaffAvailable(
    String staffId,
    DateTime startAt,
    DateTime endAt,
  ) async {
    final onShift = await _staffRepository.isOnShift(staffId, startAt);
    if (!onShift) {
      throw const BusinessRuleException('指定した担当者はこの時間帯休みです。');
    }
    final existing = await (_db.select(_db.bookings)
          ..where((b) =>
              b.staffId.equals(staffId) & b.status.equals('confirmed')))
        .get();
    final conflict = existing.any(
      (b) => overlaps(b.startAt, b.endAt, startAt, endAt),
    );
    if (conflict) {
      throw const BusinessRuleException('指定した担当者は既にこの時間帯に予約があります。');
    }
  }

  /// F-BOOK-04: 취소/노쇼 시 예약금 처리.
  /// 24시간 전 취소·매장사정 취소 = 전액환불, 24시간 이내/노쇼 = 환불불가.
  Future<void> cancelBooking({
    required String bookingId,
    required String reason, // 'customer_early' | 'customer_late_or_noshow' | 'salon_fault'
  }) async {
    const validReasons = {
      'customer_early',
      'customer_late_or_noshow',
      'salon_fault',
    };
    if (!validReasons.contains(reason)) {
      throw const ValidationException('キャンセル理由の値が正しくありません。');
    }

    try {
      final booking = await (_db.select(_db.bookings)
            ..where((b) => b.id.equals(bookingId)))
          .getSingleOrNull();
      if (booking == null) {
        throw const NotFoundException('予約が見つかりませんでした。');
      }
      if (booking.status == 'cancelled' || booking.status == 'noshow') {
        throw const BusinessRuleException('この予約は既にキャンセル処理済みです。');
      }

      final shouldRefund = reason != 'customer_late_or_noshow';
      final newStatus =
          reason == 'customer_late_or_noshow' ? 'noshow' : 'cancelled';

      await (_db.update(_db.bookings)..where((b) => b.id.equals(bookingId)))
          .write(BookingsCompanion(
        status: Value(newStatus),
        depositRefunded: Value(
          booking.depositEnabled && booking.depositReceived && shouldRefund,
        ),
      ));
      // 실제 환불 처리(카드 매입취소 등)는 payment_pos 모듈(M5) 도입 후
      // refundPayment()로 교체 — 지금은 depositRefunded 플래그만 갱신.
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  /// A-2(design/spec/v3/A2_PREFLIGHT_REVIEW.md): 예약 방문완료 상태 전환.
  ///
  /// design/spec/v3/A1_A2_BOUNDARY.md 경계 그대로: 이 메서드는 "예약경로"
  /// 트리거만 처리한다 — 호출 시점(언제 부를지)은 이 레포지토리의 책임이
  /// 아니라 호출자(향후 PaymentRepository, A-1 단계)의 책임이다. 이 메서드
  /// 스스로 CustomerRepository.recordVisit()을 호출하지 않는다(A1_A2_BOUNDARY
  /// §3 "PaymentRepository가 단일 호출 책임 주체" 원칙).
  ///
  /// design/spec/v3/A2_PREFLIGHT_REVIEW.md §7 예외케이스 그대로:
  /// - 이미 completed/cancelled/noshow인 예약은 차단(멱등성, cancelBooking()
  ///   과 동일 패턴)
  /// - depositReceived/depositRefunded는 절대 건드리지 않는다(완료 처리는
  ///   예약금 정산과 무관 — §7 예외케이스 6)
  /// - 시작시각(startAt) 미도래 예약에 대한 차단 여부는 §7 예외케이스 4에서
  ///   "결정 필요"로 남겨진 사안이라, 본 구현에서는 시간 검증을 추가하지
  ///   않는다(현장에서 시술이 예정보다 빨리 끝나 미리 완료처리하는 정당한
  ///   케이스를 막지 않기 위한 의도적 보류).
  Future<void> completeBooking(String bookingId) async {
    try {
      final booking = await (_db.select(_db.bookings)
            ..where((b) => b.id.equals(bookingId)))
          .getSingleOrNull();
      if (booking == null) {
        throw const NotFoundException('予約が見つかりませんでした。');
      }
      if (booking.status == 'completed') {
        throw const BusinessRuleException('この予約は既に来店完了処理済みです。');
      }
      if (booking.status == 'cancelled' || booking.status == 'noshow') {
        throw const BusinessRuleException('キャンセル・ノーショー済みの予約は来店完了にできません。');
      }

      await (_db.update(_db.bookings)..where((b) => b.id.equals(bookingId)))
          .write(const BookingsCompanion(status: Value('completed')));
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  // ── Waiting (F-BOOK-03, 토스 근거 없는 독자기능) ──────────────────────

  Stream<List<WaitingEntryRow>> watchWaiting() {
    return (_db.select(_db.waitingEntries)
          ..orderBy([(w) => OrderingTerm.asc(w.sortOrder)]))
        .watch();
  }

  Future<WaitingEntryRow> addWaiting({
    required String customerName,
    String? phone,
    String? menuNote,
    String? preferredStaffId,
  }) async {
    final trimmed = customerName.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('お客様の名前を入力してください。');
    }
    try {
      final maxOrderQuery = _db.selectOnly(_db.waitingEntries)
        ..addColumns([_db.waitingEntries.sortOrder.max()]);
      final maxRow = await maxOrderQuery.getSingleOrNull();
      final maxOrder =
          maxRow?.read(_db.waitingEntries.sortOrder.max()) ?? 0;

      final id = _uuid.v4();
      final now = DateTime.now();
      await _db.into(_db.waitingEntries).insert(
            WaitingEntriesCompanion.insert(
              id: id,
              customerName: trimmed,
              phone: Value(phone),
              menuNote: Value(menuNote),
              preferredStaffId: Value(preferredStaffId),
              checkInAt: now,
              sortOrder: maxOrder + 1,
            ),
          );
      return WaitingEntryRow(
        id: id,
        customerName: trimmed,
        phone: phone,
        menuNote: menuNote,
        preferredStaffId: preferredStaffId,
        checkInAt: now,
        sortOrder: maxOrder + 1,
        status: 'waiting',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }

  Future<void> callWaiting(String id) => _updateWaitingStatus(id, 'called');

  Future<void> cancelWaiting(String id) =>
      _updateWaitingStatus(id, 'cancelled');

  Future<void> _updateWaitingStatus(String id, String status) async {
    try {
      final rows = await (_db.update(_db.waitingEntries)
            ..where((w) => w.id.equals(id)))
          .write(WaitingEntriesCompanion(status: Value(status)));
      if (rows == 0) {
        throw const NotFoundException('ウェイティングが見つかりませんでした。');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw DatabaseException.writeFailed('$e');
    }
  }
}
