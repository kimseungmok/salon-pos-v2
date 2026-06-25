import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../features/booking/data/booking_tables.dart';
import '../features/cash_management/data/cash_tables.dart';
import '../features/customer/data/customer_tables.dart';
import '../features/inventory/data/inventory_tables.dart';
import '../features/marketing/data/marketing_tables.dart';
import '../features/payment_pos/data/payment_tables.dart';
import '../features/prepaid_pass/data/prepaid_pass_tables.dart';
import '../features/product/data/product_tables.dart';
import '../features/session/data/session_tables.dart';
import '../features/staff/data/staff_tables.dart';

part 'app_database.g.dart';

/// 앱 전체 SQLite DB. 오프라인 우선 정책(README.md) — 네트워크 없이도
/// 항상 동작해야 하므로 모든 데이터는 로컬 파일 DB에만 저장한다.
///
/// 모듈을 추가할 때마다 해당 모듈의 테이블 파일을 import하고
/// [tables] 목록에 추가한다(M2~M10 진행 시 동일 패턴 반복).
@DriftDatabase(
  tables: [
    Categories,
    Products,
    Staff,
    Shifts,
    Customers,
    VisitRecords,
    Bookings,
    WaitingEntries,
    Orders,
    OrderItems,
    Payments,
    PrepaidPassMenus,
    PrepaidPassBalances,
    PrepaidPassTransactions,
    Coupons,
    Campaigns,
    PointPolicies,
    CashCounts,
    ClosingChecklistItems,
    InventoryItems,
    InventoryLogs,
    // A-8 SESSION ENGINE(docs/A8_SESSION_ENGINE.md).
    PaymentSessions,
    PaymentSessionItems,
    StaffEarningLedgers,
    PaymentMethodBreakdowns,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._(super.e);

  static AppDatabase? _instance;

  /// 앱 전체에서 단일 인스턴스를 공유한다(provider에서 Provider.autoDispose
  /// 하지 않고 keepAlive로 유지 — providers.dart 참조).
  factory AppDatabase() {
    return _instance ??= AppDatabase._(_openConnection());
  }

  /// 단위테스트 전용 — 매번 새로운 인메모리 DB(파일 없음)를 만든다.
  /// 운영 코드에서는 절대 사용하지 않는다(데이터가 앱 종료 시 사라짐).
  @visibleForTesting
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        // 향후 스키마 변경 시 onUpgrade에 단계별 마이그레이션 추가.
        // 절대 기존 데이터를 삭제하는 마이그레이션을 작성하지 않는다
        // (영업 매출 데이터 — 운영 중인 매장의 데이터 손실은 치명적).
        //
        // 예외(v2→v3, A-9 ID 통일): 기존 21개 테이블의 PK를 UUID TEXT
        // 에서 INTEGER AUTOINCREMENT로 바꾸는 변경은 데이터 보존
        // 마이그레이션이 불가능하다(문자열 UUID를 정수로 치환하면서
        // 모든 FK 참조까지 일관되게 재매핑하는 것은 단순 ALTER로
        // 표현할 수 없음). **본 앱이 아직 정식 출시 전(라이브 사용자
        // 데이터 없음)이라는 전제**로, v3은 onCreate 경로(신규 설치)
        // 만 지원하고 v1/v2에서의 onUpgrade 경로는 작성하지 않았다 —
        // 출시 이후라면 이런 방식의 PK 타입 변경 자체를 시도하면 안
        // 된다(docs/A9_ID_UNIFICATION.md 참조).
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'salon_pos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
