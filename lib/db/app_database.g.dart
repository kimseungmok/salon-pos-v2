// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kioskVisibleMeta = const VerificationMeta(
    'kioskVisible',
  );
  @override
  late final GeneratedColumn<bool> kioskVisible = GeneratedColumn<bool>(
    'kiosk_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("kiosk_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorHex,
    kioskVisible,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('kiosk_visible')) {
      context.handle(
        _kioskVisibleMeta,
        kioskVisible.isAcceptableOrUnknown(
          data['kiosk_visible']!,
          _kioskVisibleMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      kioskVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}kiosk_visible'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;

  /// '#RRGGBB' 형식의 hex 색상.
  final String colorHex;
  final bool kioskVisible;
  final int sortOrder;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.kioskVisible,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color_hex'] = Variable<String>(colorHex);
    map['kiosk_visible'] = Variable<bool>(kioskVisible);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      kioskVisible: Value(kioskVisible),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      kioskVisible: serializer.fromJson<bool>(json['kioskVisible']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'kioskVisible': serializer.toJson<bool>(kioskVisible),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    String? colorHex,
    bool? kioskVisible,
    int? sortOrder,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    kioskVisible: kioskVisible ?? this.kioskVisible,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      kioskVisible: data.kioskVisible.present
          ? data.kioskVisible.value
          : this.kioskVisible,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('kioskVisible: $kioskVisible, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorHex, kioskVisible, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.kioskVisible == this.kioskVisible &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<bool> kioskVisible;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.kioskVisible = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String colorHex,
    this.kioskVisible = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorHex = Value(colorHex);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<bool>? kioskVisible,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (kioskVisible != null) 'kiosk_visible': kioskVisible,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<bool>? kioskVisible,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      kioskVisible: kioskVisible ?? this.kioskVisible,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (kioskVisible.present) {
      map['kiosk_visible'] = Variable<bool>(kioskVisible.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('kioskVisible: $kioskVisible, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowCustomPriceMeta = const VerificationMeta(
    'allowCustomPrice',
  );
  @override
  late final GeneratedColumn<bool> allowCustomPrice = GeneratedColumn<bool>(
    'allow_custom_price',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_custom_price" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _kioskVisibleMeta = const VerificationMeta(
    'kioskVisible',
  );
  @override
  late final GeneratedColumn<bool> kioskVisible = GeneratedColumn<bool>(
    'kiosk_visible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("kiosk_visible" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayStockMeta = const VerificationMeta(
    'displayStock',
  );
  @override
  late final GeneratedColumn<int> displayStock = GeneratedColumn<int>(
    'display_stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    categoryId,
    price,
    allowCustomPrice,
    kioskVisible,
    durationMin,
    displayStock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('allow_custom_price')) {
      context.handle(
        _allowCustomPriceMeta,
        allowCustomPrice.isAcceptableOrUnknown(
          data['allow_custom_price']!,
          _allowCustomPriceMeta,
        ),
      );
    }
    if (data.containsKey('kiosk_visible')) {
      context.handle(
        _kioskVisibleMeta,
        kioskVisible.isAcceptableOrUnknown(
          data['kiosk_visible']!,
          _kioskVisibleMeta,
        ),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('display_stock')) {
      context.handle(
        _displayStockMeta,
        displayStock.isAcceptableOrUnknown(
          data['display_stock']!,
          _displayStockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      allowCustomPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_custom_price'],
      )!,
      kioskVisible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}kiosk_visible'],
      )!,
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      ),
      displayStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_stock'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final String name;
  final String categoryId;
  final int price;

  /// F-PROD-03: 시가 상품(매번 직접 입력) 여부.
  final bool allowCustomPrice;
  final bool kioskVisible;

  /// 시술시간(분) — F-BOOK-02의 computeEndAt()에서 사용. 시술이 아닌
  /// 단순 판매상품(샴푸 등)은 null.
  final int? durationMin;

  /// 우상단 잔여수량 배지 표시값. F-PAY-01 결정: "있으면 표시, 없으면
  /// 숨김" — 14/15(재고관리)와는 의도적으로 미연동(F-INV-00).
  final int? displayStock;
  const ProductRow({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.allowCustomPrice,
    required this.kioskVisible,
    this.durationMin,
    this.displayStock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category_id'] = Variable<String>(categoryId);
    map['price'] = Variable<int>(price);
    map['allow_custom_price'] = Variable<bool>(allowCustomPrice);
    map['kiosk_visible'] = Variable<bool>(kioskVisible);
    if (!nullToAbsent || durationMin != null) {
      map['duration_min'] = Variable<int>(durationMin);
    }
    if (!nullToAbsent || displayStock != null) {
      map['display_stock'] = Variable<int>(displayStock);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      categoryId: Value(categoryId),
      price: Value(price),
      allowCustomPrice: Value(allowCustomPrice),
      kioskVisible: Value(kioskVisible),
      durationMin: durationMin == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMin),
      displayStock: displayStock == null && nullToAbsent
          ? const Value.absent()
          : Value(displayStock),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      price: serializer.fromJson<int>(json['price']),
      allowCustomPrice: serializer.fromJson<bool>(json['allowCustomPrice']),
      kioskVisible: serializer.fromJson<bool>(json['kioskVisible']),
      durationMin: serializer.fromJson<int?>(json['durationMin']),
      displayStock: serializer.fromJson<int?>(json['displayStock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'categoryId': serializer.toJson<String>(categoryId),
      'price': serializer.toJson<int>(price),
      'allowCustomPrice': serializer.toJson<bool>(allowCustomPrice),
      'kioskVisible': serializer.toJson<bool>(kioskVisible),
      'durationMin': serializer.toJson<int?>(durationMin),
      'displayStock': serializer.toJson<int?>(displayStock),
    };
  }

  ProductRow copyWith({
    String? id,
    String? name,
    String? categoryId,
    int? price,
    bool? allowCustomPrice,
    bool? kioskVisible,
    Value<int?> durationMin = const Value.absent(),
    Value<int?> displayStock = const Value.absent(),
  }) => ProductRow(
    id: id ?? this.id,
    name: name ?? this.name,
    categoryId: categoryId ?? this.categoryId,
    price: price ?? this.price,
    allowCustomPrice: allowCustomPrice ?? this.allowCustomPrice,
    kioskVisible: kioskVisible ?? this.kioskVisible,
    durationMin: durationMin.present ? durationMin.value : this.durationMin,
    displayStock: displayStock.present ? displayStock.value : this.displayStock,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      price: data.price.present ? data.price.value : this.price,
      allowCustomPrice: data.allowCustomPrice.present
          ? data.allowCustomPrice.value
          : this.allowCustomPrice,
      kioskVisible: data.kioskVisible.present
          ? data.kioskVisible.value
          : this.kioskVisible,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      displayStock: data.displayStock.present
          ? data.displayStock.value
          : this.displayStock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('price: $price, ')
          ..write('allowCustomPrice: $allowCustomPrice, ')
          ..write('kioskVisible: $kioskVisible, ')
          ..write('durationMin: $durationMin, ')
          ..write('displayStock: $displayStock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    categoryId,
    price,
    allowCustomPrice,
    kioskVisible,
    durationMin,
    displayStock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.categoryId == this.categoryId &&
          other.price == this.price &&
          other.allowCustomPrice == this.allowCustomPrice &&
          other.kioskVisible == this.kioskVisible &&
          other.durationMin == this.durationMin &&
          other.displayStock == this.displayStock);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> categoryId;
  final Value<int> price;
  final Value<bool> allowCustomPrice;
  final Value<bool> kioskVisible;
  final Value<int?> durationMin;
  final Value<int?> displayStock;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.price = const Value.absent(),
    this.allowCustomPrice = const Value.absent(),
    this.kioskVisible = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.displayStock = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String categoryId,
    required int price,
    this.allowCustomPrice = const Value.absent(),
    this.kioskVisible = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.displayStock = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       categoryId = Value(categoryId),
       price = Value(price);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? categoryId,
    Expression<int>? price,
    Expression<bool>? allowCustomPrice,
    Expression<bool>? kioskVisible,
    Expression<int>? durationMin,
    Expression<int>? displayStock,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (categoryId != null) 'category_id': categoryId,
      if (price != null) 'price': price,
      if (allowCustomPrice != null) 'allow_custom_price': allowCustomPrice,
      if (kioskVisible != null) 'kiosk_visible': kioskVisible,
      if (durationMin != null) 'duration_min': durationMin,
      if (displayStock != null) 'display_stock': displayStock,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? categoryId,
    Value<int>? price,
    Value<bool>? allowCustomPrice,
    Value<bool>? kioskVisible,
    Value<int?>? durationMin,
    Value<int?>? displayStock,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      allowCustomPrice: allowCustomPrice ?? this.allowCustomPrice,
      kioskVisible: kioskVisible ?? this.kioskVisible,
      durationMin: durationMin ?? this.durationMin,
      displayStock: displayStock ?? this.displayStock,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (allowCustomPrice.present) {
      map['allow_custom_price'] = Variable<bool>(allowCustomPrice.value);
    }
    if (kioskVisible.present) {
      map['kiosk_visible'] = Variable<bool>(kioskVisible.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (displayStock.present) {
      map['display_stock'] = Variable<int>(displayStock.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('categoryId: $categoryId, ')
          ..write('price: $price, ')
          ..write('allowCustomPrice: $allowCustomPrice, ')
          ..write('kioskVisible: $kioskVisible, ')
          ..write('durationMin: $durationMin, ')
          ..write('displayStock: $displayStock, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StaffTable extends Staff with TableInfo<$StaffTable, StaffRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('スタイリスト'),
  );
  static const VerificationMeta _accountStatusMeta = const VerificationMeta(
    'accountStatus',
  );
  @override
  late final GeneratedColumn<String> accountStatus = GeneratedColumn<String>(
    'account_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invitedAtMeta = const VerificationMeta(
    'invitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> invitedAt = GeneratedColumn<DateTime>(
    'invited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    role,
    accountStatus,
    invitedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('account_status')) {
      context.handle(
        _accountStatusMeta,
        accountStatus.isAcceptableOrUnknown(
          data['account_status']!,
          _accountStatusMeta,
        ),
      );
    }
    if (data.containsKey('invited_at')) {
      context.handle(
        _invitedAtMeta,
        invitedAt.isAcceptableOrUnknown(data['invited_at']!, _invitedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      accountStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_status'],
      ),
      invitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invited_at'],
      ),
    );
  }

  @override
  $StaffTable createAlias(String alias) {
    return $StaffTable(attachedDatabase, alias);
  }
}

class StaffRow extends DataClass implements Insertable<StaffRow> {
  final String id;
  final String name;
  final String phone;

  /// 표시 전용. 본 앱(POS)에서는 절대 수정 UI를 만들지 않는다.
  final String role;

  /// F-STAFF-01: 招待 흐름 결과. 초대 안 한 스태프는 null.
  final String? accountStatus;
  final DateTime? invitedAt;
  const StaffRow({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.accountStatus,
    this.invitedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || accountStatus != null) {
      map['account_status'] = Variable<String>(accountStatus);
    }
    if (!nullToAbsent || invitedAt != null) {
      map['invited_at'] = Variable<DateTime>(invitedAt);
    }
    return map;
  }

  StaffCompanion toCompanion(bool nullToAbsent) {
    return StaffCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      role: Value(role),
      accountStatus: accountStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(accountStatus),
      invitedAt: invitedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(invitedAt),
    );
  }

  factory StaffRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      role: serializer.fromJson<String>(json['role']),
      accountStatus: serializer.fromJson<String?>(json['accountStatus']),
      invitedAt: serializer.fromJson<DateTime?>(json['invitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'role': serializer.toJson<String>(role),
      'accountStatus': serializer.toJson<String?>(accountStatus),
      'invitedAt': serializer.toJson<DateTime?>(invitedAt),
    };
  }

  StaffRow copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    Value<String?> accountStatus = const Value.absent(),
    Value<DateTime?> invitedAt = const Value.absent(),
  }) => StaffRow(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    role: role ?? this.role,
    accountStatus: accountStatus.present
        ? accountStatus.value
        : this.accountStatus,
    invitedAt: invitedAt.present ? invitedAt.value : this.invitedAt,
  );
  StaffRow copyWithCompanion(StaffCompanion data) {
    return StaffRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      role: data.role.present ? data.role.value : this.role,
      accountStatus: data.accountStatus.present
          ? data.accountStatus.value
          : this.accountStatus,
      invitedAt: data.invitedAt.present ? data.invitedAt.value : this.invitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('accountStatus: $accountStatus, ')
          ..write('invitedAt: $invitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, role, accountStatus, invitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.role == this.role &&
          other.accountStatus == this.accountStatus &&
          other.invitedAt == this.invitedAt);
}

class StaffCompanion extends UpdateCompanion<StaffRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> role;
  final Value<String?> accountStatus;
  final Value<DateTime?> invitedAt;
  final Value<int> rowid;
  const StaffCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.role = const Value.absent(),
    this.accountStatus = const Value.absent(),
    this.invitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StaffCompanion.insert({
    required String id,
    required String name,
    required String phone,
    this.role = const Value.absent(),
    this.accountStatus = const Value.absent(),
    this.invitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone);
  static Insertable<StaffRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? role,
    Expression<String>? accountStatus,
    Expression<DateTime>? invitedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (accountStatus != null) 'account_status': accountStatus,
      if (invitedAt != null) 'invited_at': invitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StaffCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String>? role,
    Value<String?>? accountStatus,
    Value<DateTime?>? invitedAt,
    Value<int>? rowid,
  }) {
    return StaffCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      invitedAt: invitedAt ?? this.invitedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (accountStatus.present) {
      map['account_status'] = Variable<String>(accountStatus.value);
    }
    if (invitedAt.present) {
      map['invited_at'] = Variable<DateTime>(invitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('role: $role, ')
          ..write('accountStatus: $accountStatus, ')
          ..write('invitedAt: $invitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, ShiftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES staff (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, staffId, date, startTime, endTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShiftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      ),
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class ShiftRow extends DataClass implements Insertable<ShiftRow> {
  final String id;
  final String staffId;
  final DateTime date;

  /// null이면 휴무일.
  final DateTime? startTime;
  final DateTime? endTime;
  const ShiftRow({
    required this.id,
    required this.staffId,
    required this.date,
    this.startTime,
    this.endTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['staff_id'] = Variable<String>(staffId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || startTime != null) {
      map['start_time'] = Variable<DateTime>(startTime);
    }
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      staffId: Value(staffId),
      date: Value(date),
      startTime: startTime == null && nullToAbsent
          ? const Value.absent()
          : Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
    );
  }

  factory ShiftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftRow(
      id: serializer.fromJson<String>(json['id']),
      staffId: serializer.fromJson<String>(json['staffId']),
      date: serializer.fromJson<DateTime>(json['date']),
      startTime: serializer.fromJson<DateTime?>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'staffId': serializer.toJson<String>(staffId),
      'date': serializer.toJson<DateTime>(date),
      'startTime': serializer.toJson<DateTime?>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
    };
  }

  ShiftRow copyWith({
    String? id,
    String? staffId,
    DateTime? date,
    Value<DateTime?> startTime = const Value.absent(),
    Value<DateTime?> endTime = const Value.absent(),
  }) => ShiftRow(
    id: id ?? this.id,
    staffId: staffId ?? this.staffId,
    date: date ?? this.date,
    startTime: startTime.present ? startTime.value : this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
  );
  ShiftRow copyWithCompanion(ShiftsCompanion data) {
    return ShiftRow(
      id: data.id.present ? data.id.value : this.id,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      date: data.date.present ? data.date.value : this.date,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftRow(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, staffId, date, startTime, endTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftRow &&
          other.id == this.id &&
          other.staffId == this.staffId &&
          other.date == this.date &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime);
}

class ShiftsCompanion extends UpdateCompanion<ShiftRow> {
  final Value<String> id;
  final Value<String> staffId;
  final Value<DateTime> date;
  final Value<DateTime?> startTime;
  final Value<DateTime?> endTime;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.staffId = const Value.absent(),
    this.date = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required String staffId,
    required DateTime date,
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       staffId = Value(staffId),
       date = Value(date);
  static Insertable<ShiftRow> custom({
    Expression<String>? id,
    Expression<String>? staffId,
    Expression<DateTime>? date,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (staffId != null) 'staff_id': staffId,
      if (date != null) 'date': date,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith({
    Value<String>? id,
    Value<String>? staffId,
    Value<DateTime>? date,
    Value<DateTime?>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? rowid,
  }) {
    return ShiftsCompanion(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('date: $date, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    memo,
    points,
    birthday,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birthday'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String name;
  final String phone;
  final String? memo;
  final int points;
  final DateTime? birthday;
  final DateTime createdAt;
  const CustomerRow({
    required this.id,
    required this.name,
    required this.phone,
    this.memo,
    required this.points,
    this.birthday,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['points'] = Variable<int>(points);
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<DateTime>(birthday);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      points: Value(points),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      createdAt: Value(createdAt),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      memo: serializer.fromJson<String?>(json['memo']),
      points: serializer.fromJson<int>(json['points']),
      birthday: serializer.fromJson<DateTime?>(json['birthday']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'memo': serializer.toJson<String?>(memo),
      'points': serializer.toJson<int>(points),
      'birthday': serializer.toJson<DateTime?>(birthday),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomerRow copyWith({
    String? id,
    String? name,
    String? phone,
    Value<String?> memo = const Value.absent(),
    int? points,
    Value<DateTime?> birthday = const Value.absent(),
    DateTime? createdAt,
  }) => CustomerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    memo: memo.present ? memo.value : this.memo,
    points: points ?? this.points,
    birthday: birthday.present ? birthday.value : this.birthday,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      memo: data.memo.present ? data.memo.value : this.memo,
      points: data.points.present ? data.points.value : this.points,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('memo: $memo, ')
          ..write('points: $points, ')
          ..write('birthday: $birthday, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, memo, points, birthday, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.memo == this.memo &&
          other.points == this.points &&
          other.birthday == this.birthday &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> memo;
  final Value<int> points;
  final Value<DateTime?> birthday;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.memo = const Value.absent(),
    this.points = const Value.absent(),
    this.birthday = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    required String phone,
    this.memo = const Value.absent(),
    this.points = const Value.absent(),
    this.birthday = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone),
       createdAt = Value(createdAt);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? memo,
    Expression<int>? points,
    Expression<DateTime>? birthday,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (memo != null) 'memo': memo,
      if (points != null) 'points': points,
      if (birthday != null) 'birthday': birthday,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? memo,
    Value<int>? points,
    Value<DateTime?>? birthday,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      memo: memo ?? this.memo,
      points: points ?? this.points,
      birthday: birthday ?? this.birthday,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('memo: $memo, ')
          ..write('points: $points, ')
          ..write('birthday: $birthday, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitRecordsTable extends VisitRecords
    with TableInfo<$VisitRecordsTable, VisitRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _visitDateMeta = const VerificationMeta(
    'visitDate',
  );
  @override
  late final GeneratedColumn<DateTime> visitDate = GeneratedColumn<DateTime>(
    'visit_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<String> staffId = GeneratedColumn<String>(
    'staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    visitDate,
    staffId,
    amount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('visit_date')) {
      context.handle(
        _visitDateMeta,
        visitDate.isAcceptableOrUnknown(data['visit_date']!, _visitDateMeta),
      );
    } else if (isInserting) {
      context.missing(_visitDateMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      visitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visit_date'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $VisitRecordsTable createAlias(String alias) {
    return $VisitRecordsTable(attachedDatabase, alias);
  }
}

class VisitRecordRow extends DataClass implements Insertable<VisitRecordRow> {
  final String id;
  final String customerId;
  final DateTime visitDate;
  final String? staffId;
  final int amount;

  /// completed/noshow/cancelled. F-CUST-01 그룹산출은 completed만 카운트.
  final String status;
  const VisitRecordRow({
    required this.id,
    required this.customerId,
    required this.visitDate,
    this.staffId,
    required this.amount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['visit_date'] = Variable<DateTime>(visitDate);
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    map['amount'] = Variable<int>(amount);
    map['status'] = Variable<String>(status);
    return map;
  }

  VisitRecordsCompanion toCompanion(bool nullToAbsent) {
    return VisitRecordsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      visitDate: Value(visitDate),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
      amount: Value(amount),
      status: Value(status),
    );
  }

  factory VisitRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitRecordRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      visitDate: serializer.fromJson<DateTime>(json['visitDate']),
      staffId: serializer.fromJson<String?>(json['staffId']),
      amount: serializer.fromJson<int>(json['amount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'visitDate': serializer.toJson<DateTime>(visitDate),
      'staffId': serializer.toJson<String?>(staffId),
      'amount': serializer.toJson<int>(amount),
      'status': serializer.toJson<String>(status),
    };
  }

  VisitRecordRow copyWith({
    String? id,
    String? customerId,
    DateTime? visitDate,
    Value<String?> staffId = const Value.absent(),
    int? amount,
    String? status,
  }) => VisitRecordRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    visitDate: visitDate ?? this.visitDate,
    staffId: staffId.present ? staffId.value : this.staffId,
    amount: amount ?? this.amount,
    status: status ?? this.status,
  );
  VisitRecordRow copyWithCompanion(VisitRecordsCompanion data) {
    return VisitRecordRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      visitDate: data.visitDate.present ? data.visitDate.value : this.visitDate,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      amount: data.amount.present ? data.amount.value : this.amount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitRecordRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('visitDate: $visitDate, ')
          ..write('staffId: $staffId, ')
          ..write('amount: $amount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, customerId, visitDate, staffId, amount, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitRecordRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.visitDate == this.visitDate &&
          other.staffId == this.staffId &&
          other.amount == this.amount &&
          other.status == this.status);
}

class VisitRecordsCompanion extends UpdateCompanion<VisitRecordRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<DateTime> visitDate;
  final Value<String?> staffId;
  final Value<int> amount;
  final Value<String> status;
  final Value<int> rowid;
  const VisitRecordsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.visitDate = const Value.absent(),
    this.staffId = const Value.absent(),
    this.amount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitRecordsCompanion.insert({
    required String id,
    required String customerId,
    required DateTime visitDate,
    this.staffId = const Value.absent(),
    this.amount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       visitDate = Value(visitDate);
  static Insertable<VisitRecordRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<DateTime>? visitDate,
    Expression<String>? staffId,
    Expression<int>? amount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (visitDate != null) 'visit_date': visitDate,
      if (staffId != null) 'staff_id': staffId,
      if (amount != null) 'amount': amount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<DateTime>? visitDate,
    Value<String?>? staffId,
    Value<int>? amount,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return VisitRecordsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      visitDate: visitDate ?? this.visitDate,
      staffId: staffId ?? this.staffId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (visitDate.present) {
      map['visit_date'] = Variable<DateTime>(visitDate.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitRecordsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('visitDate: $visitDate, ')
          ..write('staffId: $staffId, ')
          ..write('amount: $amount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $StaffTable staff = $StaffTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $VisitRecordsTable visitRecords = $VisitRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    products,
    staff,
    shifts,
    customers,
    visitRecords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'staff',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shifts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('visit_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String colorHex,
      Value<bool> kioskVisible,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> colorHex,
      Value<bool> kioskVisible,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: 'categories__id__products__category_id',
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get kioskVisible => $composableBuilder(
    column: $table.kioskVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get kioskVisible => $composableBuilder(
    column: $table.kioskVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get kioskVisible => $composableBuilder(
    column: $table.kioskVisible,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> kioskVisible = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                kioskVisible: kioskVisible,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String colorHex,
                Value<bool> kioskVisible = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                kioskVisible: kioskVisible,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      ProductRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String id,
      required String name,
      required String categoryId,
      required int price,
      Value<bool> allowCustomPrice,
      Value<bool> kioskVisible,
      Value<int?> durationMin,
      Value<int?> displayStock,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> categoryId,
      Value<int> price,
      Value<bool> allowCustomPrice,
      Value<bool> kioskVisible,
      Value<int?> durationMin,
      Value<int?> displayStock,
      Value<int> rowid,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('products__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowCustomPrice => $composableBuilder(
    column: $table.allowCustomPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get kioskVisible => $composableBuilder(
    column: $table.kioskVisible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayStock => $composableBuilder(
    column: $table.displayStock,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowCustomPrice => $composableBuilder(
    column: $table.allowCustomPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get kioskVisible => $composableBuilder(
    column: $table.kioskVisible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayStock => $composableBuilder(
    column: $table.displayStock,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get allowCustomPrice => $composableBuilder(
    column: $table.allowCustomPrice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get kioskVisible => $composableBuilder(
    column: $table.kioskVisible,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayStock => $composableBuilder(
    column: $table.displayStock,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductsTableReferences),
          ProductRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<bool> allowCustomPrice = const Value.absent(),
                Value<bool> kioskVisible = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int?> displayStock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                categoryId: categoryId,
                price: price,
                allowCustomPrice: allowCustomPrice,
                kioskVisible: kioskVisible,
                durationMin: durationMin,
                displayStock: displayStock,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String categoryId,
                required int price,
                Value<bool> allowCustomPrice = const Value.absent(),
                Value<bool> kioskVisible = const Value.absent(),
                Value<int?> durationMin = const Value.absent(),
                Value<int?> displayStock = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                categoryId: categoryId,
                price: price,
                allowCustomPrice: allowCustomPrice,
                kioskVisible: kioskVisible,
                durationMin: durationMin,
                displayStock: displayStock,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$ProductsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$ProductsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductsTableReferences),
      ProductRow,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$StaffTableCreateCompanionBuilder =
    StaffCompanion Function({
      required String id,
      required String name,
      required String phone,
      Value<String> role,
      Value<String?> accountStatus,
      Value<DateTime?> invitedAt,
      Value<int> rowid,
    });
typedef $$StaffTableUpdateCompanionBuilder =
    StaffCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String> role,
      Value<String?> accountStatus,
      Value<DateTime?> invitedAt,
      Value<int> rowid,
    });

final class $$StaffTableReferences
    extends BaseReferences<_$AppDatabase, $StaffTable, StaffRow> {
  $$StaffTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ShiftsTable, List<ShiftRow>> _shiftsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.shifts,
    aliasName: 'staff__id__shifts__staff_id',
  );

  $$ShiftsTableProcessedTableManager get shiftsRefs {
    final manager = $$ShiftsTableTableManager(
      $_db,
      $_db.shifts,
    ).filter((f) => f.staffId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_shiftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StaffTableFilterComposer extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountStatus => $composableBuilder(
    column: $table.accountStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invitedAt => $composableBuilder(
    column: $table.invitedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> shiftsRefs(
    Expression<bool> Function($$ShiftsTableFilterComposer f) f,
  ) {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.staffId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableFilterComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StaffTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountStatus => $composableBuilder(
    column: $table.accountStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invitedAt => $composableBuilder(
    column: $table.invitedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffTable> {
  $$StaffTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get accountStatus => $composableBuilder(
    column: $table.accountStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get invitedAt =>
      $composableBuilder(column: $table.invitedAt, builder: (column) => column);

  Expression<T> shiftsRefs<T extends Object>(
    Expression<T> Function($$ShiftsTableAnnotationComposer a) f,
  ) {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shifts,
      getReferencedColumn: (t) => t.staffId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShiftsTableAnnotationComposer(
            $db: $db,
            $table: $db.shifts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StaffTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffTable,
          StaffRow,
          $$StaffTableFilterComposer,
          $$StaffTableOrderingComposer,
          $$StaffTableAnnotationComposer,
          $$StaffTableCreateCompanionBuilder,
          $$StaffTableUpdateCompanionBuilder,
          (StaffRow, $$StaffTableReferences),
          StaffRow,
          PrefetchHooks Function({bool shiftsRefs})
        > {
  $$StaffTableTableManager(_$AppDatabase db, $StaffTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> accountStatus = const Value.absent(),
                Value<DateTime?> invitedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffCompanion(
                id: id,
                name: name,
                phone: phone,
                role: role,
                accountStatus: accountStatus,
                invitedAt: invitedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phone,
                Value<String> role = const Value.absent(),
                Value<String?> accountStatus = const Value.absent(),
                Value<DateTime?> invitedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StaffCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                role: role,
                accountStatus: accountStatus,
                invitedAt: invitedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$StaffTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({shiftsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (shiftsRefs) db.shifts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shiftsRefs)
                    await $_getPrefetchedData<StaffRow, $StaffTable, ShiftRow>(
                      currentTable: table,
                      referencedTable: $$StaffTableReferences._shiftsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$StaffTableReferences(db, table, p0).shiftsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.staffId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StaffTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffTable,
      StaffRow,
      $$StaffTableFilterComposer,
      $$StaffTableOrderingComposer,
      $$StaffTableAnnotationComposer,
      $$StaffTableCreateCompanionBuilder,
      $$StaffTableUpdateCompanionBuilder,
      (StaffRow, $$StaffTableReferences),
      StaffRow,
      PrefetchHooks Function({bool shiftsRefs})
    >;
typedef $$ShiftsTableCreateCompanionBuilder =
    ShiftsCompanion Function({
      required String id,
      required String staffId,
      required DateTime date,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<int> rowid,
    });
typedef $$ShiftsTableUpdateCompanionBuilder =
    ShiftsCompanion Function({
      Value<String> id,
      Value<String> staffId,
      Value<DateTime> date,
      Value<DateTime?> startTime,
      Value<DateTime?> endTime,
      Value<int> rowid,
    });

final class $$ShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftsTable, ShiftRow> {
  $$ShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StaffTable _staffIdTable(_$AppDatabase db) =>
      db.staff.createAlias('shifts__staff_id__staff__id');

  $$StaffTableProcessedTableManager get staffId {
    final $_column = $_itemColumn<String>('staff_id')!;

    final manager = $$StaffTableTableManager(
      $_db,
      $_db.staff,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_staffIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  $$StaffTableFilterComposer get staffId {
    final $$StaffTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.staff,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffTableFilterComposer(
            $db: $db,
            $table: $db.staff,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  $$StaffTableOrderingComposer get staffId {
    final $$StaffTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.staff,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffTableOrderingComposer(
            $db: $db,
            $table: $db.staff,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  $$StaffTableAnnotationComposer get staffId {
    final $$StaffTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.staff,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffTableAnnotationComposer(
            $db: $db,
            $table: $db.staff,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShiftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShiftsTable,
          ShiftRow,
          $$ShiftsTableFilterComposer,
          $$ShiftsTableOrderingComposer,
          $$ShiftsTableAnnotationComposer,
          $$ShiftsTableCreateCompanionBuilder,
          $$ShiftsTableUpdateCompanionBuilder,
          (ShiftRow, $$ShiftsTableReferences),
          ShiftRow,
          PrefetchHooks Function({bool staffId})
        > {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> staffId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion(
                id: id,
                staffId: staffId,
                date: date,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String staffId,
                required DateTime date,
                Value<DateTime?> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShiftsCompanion.insert(
                id: id,
                staffId: staffId,
                date: date,
                startTime: startTime,
                endTime: endTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ShiftsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({staffId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (staffId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.staffId,
                                referencedTable: $$ShiftsTableReferences
                                    ._staffIdTable(db),
                                referencedColumn: $$ShiftsTableReferences
                                    ._staffIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShiftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShiftsTable,
      ShiftRow,
      $$ShiftsTableFilterComposer,
      $$ShiftsTableOrderingComposer,
      $$ShiftsTableAnnotationComposer,
      $$ShiftsTableCreateCompanionBuilder,
      $$ShiftsTableUpdateCompanionBuilder,
      (ShiftRow, $$ShiftsTableReferences),
      ShiftRow,
      PrefetchHooks Function({bool staffId})
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String name,
      required String phone,
      Value<String?> memo,
      Value<int> points,
      Value<DateTime?> birthday,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String?> memo,
      Value<int> points,
      Value<DateTime?> birthday,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VisitRecordsTable, List<VisitRecordRow>>
  _visitRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.visitRecords,
    aliasName: 'customers__id__visit_records__customer_id',
  );

  $$VisitRecordsTableProcessedTableManager get visitRecordsRefs {
    final manager = $$VisitRecordsTableTableManager(
      $_db,
      $_db.visitRecords,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> visitRecordsRefs(
    Expression<bool> Function($$VisitRecordsTableFilterComposer f) f,
  ) {
    final $$VisitRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitRecords,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitRecordsTableFilterComposer(
            $db: $db,
            $table: $db.visitRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> visitRecordsRefs<T extends Object>(
    Expression<T> Function($$VisitRecordsTableAnnotationComposer a) f,
  ) {
    final $$VisitRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitRecords,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.visitRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomersTableReferences),
          CustomerRow,
          PrefetchHooks Function({bool visitRecordsRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<DateTime?> birthday = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                memo: memo,
                points: points,
                birthday: birthday,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phone,
                Value<String?> memo = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<DateTime?> birthday = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                memo: memo,
                points: points,
                birthday: birthday,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (visitRecordsRefs) db.visitRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (visitRecordsRefs)
                    await $_getPrefetchedData<
                      CustomerRow,
                      $CustomersTable,
                      VisitRecordRow
                    >(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._visitRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(
                            db,
                            table,
                            p0,
                          ).visitRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.customerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomersTableReferences),
      CustomerRow,
      PrefetchHooks Function({bool visitRecordsRefs})
    >;
typedef $$VisitRecordsTableCreateCompanionBuilder =
    VisitRecordsCompanion Function({
      required String id,
      required String customerId,
      required DateTime visitDate,
      Value<String?> staffId,
      Value<int> amount,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$VisitRecordsTableUpdateCompanionBuilder =
    VisitRecordsCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<DateTime> visitDate,
      Value<String?> staffId,
      Value<int> amount,
      Value<String> status,
      Value<int> rowid,
    });

final class $$VisitRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $VisitRecordsTable, VisitRecordRow> {
  $$VisitRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('visit_records__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VisitRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitRecordsTable> {
  $$VisitRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitRecordsTable> {
  $$VisitRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitDate => $composableBuilder(
    column: $table.visitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitRecordsTable> {
  $$VisitRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get visitDate =>
      $composableBuilder(column: $table.visitDate, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitRecordsTable,
          VisitRecordRow,
          $$VisitRecordsTableFilterComposer,
          $$VisitRecordsTableOrderingComposer,
          $$VisitRecordsTableAnnotationComposer,
          $$VisitRecordsTableCreateCompanionBuilder,
          $$VisitRecordsTableUpdateCompanionBuilder,
          (VisitRecordRow, $$VisitRecordsTableReferences),
          VisitRecordRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$VisitRecordsTableTableManager(_$AppDatabase db, $VisitRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<DateTime> visitDate = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitRecordsCompanion(
                id: id,
                customerId: customerId,
                visitDate: visitDate,
                staffId: staffId,
                amount: amount,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required DateTime visitDate,
                Value<String?> staffId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitRecordsCompanion.insert(
                id: id,
                customerId: customerId,
                visitDate: visitDate,
                staffId: staffId,
                amount: amount,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VisitRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$VisitRecordsTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$VisitRecordsTableReferences
                                    ._customerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VisitRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitRecordsTable,
      VisitRecordRow,
      $$VisitRecordsTableFilterComposer,
      $$VisitRecordsTableOrderingComposer,
      $$VisitRecordsTableAnnotationComposer,
      $$VisitRecordsTableCreateCompanionBuilder,
      $$VisitRecordsTableUpdateCompanionBuilder,
      (VisitRecordRow, $$VisitRecordsTableReferences),
      VisitRecordRow,
      PrefetchHooks Function({bool customerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$StaffTableTableManager get staff =>
      $$StaffTableTableManager(_db, _db.staff);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$VisitRecordsTableTableManager get visitRecords =>
      $$VisitRecordsTableTableManager(_db, _db.visitRecords);
}
