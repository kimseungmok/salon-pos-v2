import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/booking/data/booking_completion_caller.dart';
import 'package:salon_pos_v2/features/booking/data/booking_repository.dart';
import 'package:salon_pos_v2/features/product/data/product_repository.dart';
import 'package:salon_pos_v2/features/session/data/session_repository.dart';
import 'package:salon_pos_v2/features/staff/data/staff_repository.dart';

/// A-25 Booking Completion Caller 검증.
void main() {
  late AppDatabase db;
  late BookingCompletionCaller caller;
  late BookingRepository bookingRepo;
  late ProductRepository productRepo;
  late SessionRepository sessionRepo;

  // 테스트용 고객 ID 삽입(Customers FK 충족)
  Future<int> insertCustomer() async {
    return db.into(db.customers).insert(
          CustomersCompanion.insert(
            name: 'テスト顧客',
            phone: '000-0000-0000',
            createdAt: DateTime.now(),
          ),
        );
  }

  // 테스트용 카테고리 + 상품 삽입
  Future<ProductRow> insertProduct({
    required String name,
    required int price,
    int durationMin = 30,
  }) async {
    final catId = await db.into(db.categories).insert(
          CategoriesCompanion.insert(name: 'テスト', colorHex: '#000000'),
        );
    final id = await db.into(db.products).insert(
          ProductsCompanion.insert(
            name: name,
            categoryId: catId,
            price: price,
            durationMin: Value(durationMin),
          ),
        );
    return (db.select(db.products)..where((p) => p.id.equals(id))).getSingle();
  }

  setUp(() {
    db = AppDatabase.forTesting();
    final staffRepo = StaffRepository(db);
    bookingRepo = BookingRepository(db, staffRepo);
    productRepo = ProductRepository(db);
    sessionRepo = SessionRepository(db);
    caller = BookingCompletionCaller(
      bookingRepository: bookingRepo,
      sessionRepository: sessionRepo,
      productRepository: productRepo,
    );
  });

  tearDown(() => db.close());

  group('BookingCompletionCaller.complete()', () {
    test('단일 상품 예약 → Session 1건 + SessionItem 1건 생성', () async {
      final customerId = await insertCustomer();
      final product = await insertProduct(name: 'カット', price: 3000);

      final booking = await bookingRepo.createBooking(
        customerId: customerId,
        productIds: [product.id],
        startAt: DateTime(2026, 7, 1, 10, 0),
        endAt: DateTime(2026, 7, 1, 11, 0),
      );

      await caller.complete(booking: booking, businessType: 'salon');

      // Booking 상태 'completed' 확인
      final updatedBooking = await (db.select(db.bookings)
            ..where((b) => b.id.equals(booking.id)))
          .getSingle();
      expect(updatedBooking.status, 'completed');

      // Session 1건 생성 확인
      final sessions = await db.select(db.paymentSessions).get();
      expect(sessions, hasLength(1));
      expect(sessions.single.businessType, 'salon');
      expect(sessions.single.customerId, customerId);

      // SessionItem 1건 확인 — A-24.7 계약 검증
      final items = await db.select(db.paymentSessionItems).get();
      expect(items, hasLength(1));
      expect(items.single.itemType, 'service');
      expect(items.single.refType, 'booking');
      expect(items.single.refId, booking.id.toString());
      expect(items.single.itemName, 'カット');
      expect(items.single.unitPrice, 3000);
    });

    test('복수 상품 예약 → addItem() N회 순차 실행', () async {
      final customerId = await insertCustomer();
      final p1 = await insertProduct(name: 'カット', price: 3000);
      final p2 = await insertProduct(name: 'カラー', price: 5000);

      final booking = await bookingRepo.createBooking(
        customerId: customerId,
        productIds: [p1.id, p2.id],
        startAt: DateTime(2026, 7, 1, 10, 0),
        endAt: DateTime(2026, 7, 1, 12, 0),
      );

      await caller.complete(booking: booking, businessType: 'salon');

      final items = await db.select(db.paymentSessionItems).get();
      expect(items, hasLength(2));
      expect(items.map((i) => i.itemType).toSet(), {'service'});
      expect(items.map((i) => i.refType).toSet(), {'booking'});
      final names = items.map((i) => i.itemName).toSet();
      expect(names, containsAll(['カット', 'カラー']));
    });

    test('productIdsCsv가 비어 있으면 Session만 생성, addItem() 없음', () async {
      // completeBooking()을 직접 호출하면 productIds=empty → ValidationException
      // 따라서 직접 DB insert로 빈 CSV 상태를 만든다.
      final customerId = await insertCustomer();
      final bookingId = await db.into(db.bookings).insert(
            BookingsCompanion.insert(
              customerId: customerId,
              productIdsCsv: const Value(''),
              startAt: DateTime(2026, 7, 1, 10, 0),
              endAt: DateTime(2026, 7, 1, 11, 0),
            ),
          );
      final booking =
          await (db.select(db.bookings)..where((b) => b.id.equals(bookingId)))
              .getSingle();

      await caller.complete(booking: booking, businessType: 'salon');

      // Session은 생성됨
      final sessions = await db.select(db.paymentSessions).get();
      expect(sessions, hasLength(1));

      // SessionItem은 없음
      final items = await db.select(db.paymentSessionItems).get();
      expect(items, isEmpty);
    });

    test('productIdsCsv의 ID 중 일부가 Products에 없으면 해당 항목만 건너뜀', () async {
      final customerId = await insertCustomer();
      final product = await insertProduct(name: 'カット', price: 3000);

      // productIdsCsv에 존재하지 않는 ID(99999)를 포함
      final bookingId = await db.into(db.bookings).insert(
            BookingsCompanion.insert(
              customerId: customerId,
              productIdsCsv: Value('${product.id},99999'),
              startAt: DateTime(2026, 7, 1, 10, 0),
              endAt: DateTime(2026, 7, 1, 11, 0),
            ),
          );
      final booking =
          await (db.select(db.bookings)..where((b) => b.id.equals(bookingId)))
              .getSingle();

      await caller.complete(booking: booking, businessType: 'salon');

      // 존재하는 상품 1건만 Item으로 추가됨
      final items = await db.select(db.paymentSessionItems).get();
      expect(items, hasLength(1));
      expect(items.single.itemName, 'カット');
    });
  });
}
