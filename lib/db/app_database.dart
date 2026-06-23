import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../features/product/data/product_tables.dart';
import '../features/staff/data/staff_tables.dart';

part 'app_database.g.dart';

/// 앱 전체 SQLite DB. 오프라인 우선 정책(README.md) — 네트워크 없이도
/// 항상 동작해야 하므로 모든 데이터는 로컬 파일 DB에만 저장한다.
///
/// 모듈을 추가할 때마다 해당 모듈의 테이블 파일을 import하고
/// [tables] 목록에 추가한다(M2~M10 진행 시 동일 패턴 반복).
@DriftDatabase(tables: [Categories, Products, Staff, Shifts])
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        // 향후 스키마 변경 시 onUpgrade에 단계별 마이그레이션 추가.
        // 절대 기존 데이터를 삭제하는 마이그레이션을 작성하지 않는다
        // (영업 매출 데이터 — 운영 중인 매장의 데이터 손실은 치명적).
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'salon_pos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
