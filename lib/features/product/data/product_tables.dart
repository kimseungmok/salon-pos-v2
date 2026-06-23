import 'package:drift/drift.dart';

/// design/spec/v3/product/data_spec.md "엔티티: Category" 그대로.
/// 색상은 카테고리에 1:1 고정(F-PROD-02) — 상품 타일 배경색의 단일
/// 소스. 과거 v2 목업의 "순환 인덱스로 색이 매번 바뀌는" 버그를
/// 방지하기 위한 결정(payment_pos/feature_spec.md F-PAY-01 참조).
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 30)();

  /// '#RRGGBB' 형식의 hex 색상.
  TextColumn get colorHex => text().withLength(min: 7, max: 7)();
  BoolColumn get kioskVisible => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// design/spec/v3/product/data_spec.md "엔티티: Product" 그대로.
@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  IntColumn get price => integer()();

  /// F-PROD-03: 시가 상품(매번 직접 입력) 여부.
  BoolColumn get allowCustomPrice =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get kioskVisible => boolean().withDefault(const Constant(true))();

  /// 시술시간(분) — F-BOOK-02의 computeEndAt()에서 사용. 시술이 아닌
  /// 단순 판매상품(샴푸 등)은 null.
  IntColumn get durationMin => integer().nullable()();

  /// 우상단 잔여수량 배지 표시값. F-PAY-01 결정: "있으면 표시, 없으면
  /// 숨김" — 14/15(재고관리)와는 의도적으로 미연동(F-INV-00).
  IntColumn get displayStock => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
