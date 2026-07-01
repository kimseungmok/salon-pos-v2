// ignore_for_file: prefer_initializing_formals
import '../../../db/app_database.dart';
import '../../product/data/product_repository.dart';
import '../../session/data/session_repository.dart';
import 'booking_repository.dart';

/// A-24 Booking Completion Caller(docs/A24_BOOKING_COMPLETION_CALLER_DESIGN.md).
///
/// Booking 완료 후 Session 생성 → Item 추가 흐름을 조율한다.
/// **Booking 엔티티는 호출자가 사전에 조회해 전달한다**(A-24.5 PART5).
///
/// 실행 순서(A-25 계약, 변경 불가):
/// 1. completeBooking()
/// 2. createSession()
/// 3. watchProducts().first
/// 4. productIdsCsv 파싱 + 메모리 매칭(A-24.6)
/// 5. addItem() × N (순차, 상품당 1회)
class BookingCompletionCaller {
  BookingCompletionCaller({
    required BookingRepository bookingRepository,
    required SessionRepository sessionRepository,
    required ProductRepository productRepository,
  })  : _bookingRepository = bookingRepository,
        _sessionRepository = sessionRepository,
        _productRepository = productRepository;

  final BookingRepository _bookingRepository;
  final SessionRepository _sessionRepository;
  final ProductRepository _productRepository;

  Future<void> complete({
    required BookingRow booking,
    required String businessType,
  }) async {
    // 1. completeBooking()
    await _bookingRepository.completeBooking(booking.id);

    // 2. createSession() — A-24.5: staffId/customerId는 Booking에서 direct,
    //    roomId는 Bookings에 컬럼이 없어 항상 null.
    final session = await _sessionRepository.createSession(
      businessType: businessType,
      staffId: booking.staffId,
      customerId: booking.customerId,
    );

    // 3. watchProducts().first — A-24.6: 기존 메서드만 사용, 새 조회 메서드 없음.
    final products = await _productRepository.watchProducts().first;

    // 4. productIdsCsv 파싱 — A-24.6: split, trim, empty 제거, int 변환.
    final productIds = booking.productIdsCsv
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map(int.parse)
        .toList();

    // 5. addItem() × N — A-24.7 계약 그대로:
    //    itemType='service', itemName=Product.name, unitPrice=Product.price
    //    refType='booking', refId=Booking.id.toString()
    //    매칭 실패한 ID는 조용히 건너뜀(A-24.6의 memory filter only 패턴,
    //    booking_logic.dart의 computeEndAt()과 동일한 firstOrNull 패턴).
    for (final id in productIds) {
      final product = products.where((p) => p.id == id).firstOrNull;
      if (product == null) continue;

      await _sessionRepository.addItem(
        sessionId: session.id,
        itemType: 'service',
        refType: 'booking',
        refId: booking.id.toString(),
        itemName: product.name,
        unitPrice: product.price,
      );
    }
  }
}
