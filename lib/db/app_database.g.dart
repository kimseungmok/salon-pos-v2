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

class $BookingsTable extends Bookings
    with TableInfo<$BookingsTable, BookingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productIdsCsvMeta = const VerificationMeta(
    'productIdsCsv',
  );
  @override
  late final GeneratedColumn<String> productIdsCsv = GeneratedColumn<String>(
    'product_ids_csv',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _depositEnabledMeta = const VerificationMeta(
    'depositEnabled',
  );
  @override
  late final GeneratedColumn<bool> depositEnabled = GeneratedColumn<bool>(
    'deposit_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deposit_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _depositMethodMeta = const VerificationMeta(
    'depositMethod',
  );
  @override
  late final GeneratedColumn<String> depositMethod = GeneratedColumn<String>(
    'deposit_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depositAmountMeta = const VerificationMeta(
    'depositAmount',
  );
  @override
  late final GeneratedColumn<int> depositAmount = GeneratedColumn<int>(
    'deposit_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depositReceivedMeta = const VerificationMeta(
    'depositReceived',
  );
  @override
  late final GeneratedColumn<bool> depositReceived = GeneratedColumn<bool>(
    'deposit_received',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deposit_received" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _depositRefundedMeta = const VerificationMeta(
    'depositRefunded',
  );
  @override
  late final GeneratedColumn<bool> depositRefunded = GeneratedColumn<bool>(
    'deposit_refunded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deposit_refunded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _refundNoteMeta = const VerificationMeta(
    'refundNote',
  );
  @override
  late final GeneratedColumn<String> refundNote = GeneratedColumn<String>(
    'refund_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('返金は24時間以内に可能です。'),
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
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
  static const VerificationMeta _requiresApprovalMeta = const VerificationMeta(
    'requiresApproval',
  );
  @override
  late final GeneratedColumn<bool> requiresApproval = GeneratedColumn<bool>(
    'requires_approval',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_approval" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('confirmed'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    staffId,
    productIdsCsv,
    startAt,
    endAt,
    depositEnabled,
    depositMethod,
    depositAmount,
    depositReceived,
    depositRefunded,
    refundNote,
    repeatRule,
    memo,
    requiresApproval,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingRow> instance, {
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
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    if (data.containsKey('product_ids_csv')) {
      context.handle(
        _productIdsCsvMeta,
        productIdsCsv.isAcceptableOrUnknown(
          data['product_ids_csv']!,
          _productIdsCsvMeta,
        ),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    } else if (isInserting) {
      context.missing(_endAtMeta);
    }
    if (data.containsKey('deposit_enabled')) {
      context.handle(
        _depositEnabledMeta,
        depositEnabled.isAcceptableOrUnknown(
          data['deposit_enabled']!,
          _depositEnabledMeta,
        ),
      );
    }
    if (data.containsKey('deposit_method')) {
      context.handle(
        _depositMethodMeta,
        depositMethod.isAcceptableOrUnknown(
          data['deposit_method']!,
          _depositMethodMeta,
        ),
      );
    }
    if (data.containsKey('deposit_amount')) {
      context.handle(
        _depositAmountMeta,
        depositAmount.isAcceptableOrUnknown(
          data['deposit_amount']!,
          _depositAmountMeta,
        ),
      );
    }
    if (data.containsKey('deposit_received')) {
      context.handle(
        _depositReceivedMeta,
        depositReceived.isAcceptableOrUnknown(
          data['deposit_received']!,
          _depositReceivedMeta,
        ),
      );
    }
    if (data.containsKey('deposit_refunded')) {
      context.handle(
        _depositRefundedMeta,
        depositRefunded.isAcceptableOrUnknown(
          data['deposit_refunded']!,
          _depositRefundedMeta,
        ),
      );
    }
    if (data.containsKey('refund_note')) {
      context.handle(
        _refundNoteMeta,
        refundNote.isAcceptableOrUnknown(data['refund_note']!, _refundNoteMeta),
      );
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('requires_approval')) {
      context.handle(
        _requiresApprovalMeta,
        requiresApproval.isAcceptableOrUnknown(
          data['requires_approval']!,
          _requiresApprovalMeta,
        ),
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
  BookingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
      productIdsCsv: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_ids_csv'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      )!,
      depositEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deposit_enabled'],
      )!,
      depositMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deposit_method'],
      ),
      depositAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposit_amount'],
      ),
      depositReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deposit_received'],
      )!,
      depositRefunded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deposit_refunded'],
      )!,
      refundNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refund_note'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      requiresApproval: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_approval'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $BookingsTable createAlias(String alias) {
    return $BookingsTable(attachedDatabase, alias);
  }
}

class BookingRow extends DataClass implements Insertable<BookingRow> {
  final String id;
  final String customerId;
  final String? staffId;

  /// 쉼표구분 Product.id 목록(위 메모 참조).
  final String productIdsCsv;
  final DateTime startAt;
  final DateTime endAt;
  final bool depositEnabled;
  final String? depositMethod;
  final int? depositAmount;
  final bool depositReceived;
  final bool depositRefunded;
  final String refundNote;
  final String repeatRule;
  final String? memo;
  final bool requiresApproval;

  /// confirmed/completed/noshow/cancelled.
  final String status;
  const BookingRow({
    required this.id,
    required this.customerId,
    this.staffId,
    required this.productIdsCsv,
    required this.startAt,
    required this.endAt,
    required this.depositEnabled,
    this.depositMethod,
    this.depositAmount,
    required this.depositReceived,
    required this.depositRefunded,
    required this.refundNote,
    required this.repeatRule,
    this.memo,
    required this.requiresApproval,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    map['product_ids_csv'] = Variable<String>(productIdsCsv);
    map['start_at'] = Variable<DateTime>(startAt);
    map['end_at'] = Variable<DateTime>(endAt);
    map['deposit_enabled'] = Variable<bool>(depositEnabled);
    if (!nullToAbsent || depositMethod != null) {
      map['deposit_method'] = Variable<String>(depositMethod);
    }
    if (!nullToAbsent || depositAmount != null) {
      map['deposit_amount'] = Variable<int>(depositAmount);
    }
    map['deposit_received'] = Variable<bool>(depositReceived);
    map['deposit_refunded'] = Variable<bool>(depositRefunded);
    map['refund_note'] = Variable<String>(refundNote);
    map['repeat_rule'] = Variable<String>(repeatRule);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['requires_approval'] = Variable<bool>(requiresApproval);
    map['status'] = Variable<String>(status);
    return map;
  }

  BookingsCompanion toCompanion(bool nullToAbsent) {
    return BookingsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
      productIdsCsv: Value(productIdsCsv),
      startAt: Value(startAt),
      endAt: Value(endAt),
      depositEnabled: Value(depositEnabled),
      depositMethod: depositMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(depositMethod),
      depositAmount: depositAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(depositAmount),
      depositReceived: Value(depositReceived),
      depositRefunded: Value(depositRefunded),
      refundNote: Value(refundNote),
      repeatRule: Value(repeatRule),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      requiresApproval: Value(requiresApproval),
      status: Value(status),
    );
  }

  factory BookingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      staffId: serializer.fromJson<String?>(json['staffId']),
      productIdsCsv: serializer.fromJson<String>(json['productIdsCsv']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime>(json['endAt']),
      depositEnabled: serializer.fromJson<bool>(json['depositEnabled']),
      depositMethod: serializer.fromJson<String?>(json['depositMethod']),
      depositAmount: serializer.fromJson<int?>(json['depositAmount']),
      depositReceived: serializer.fromJson<bool>(json['depositReceived']),
      depositRefunded: serializer.fromJson<bool>(json['depositRefunded']),
      refundNote: serializer.fromJson<String>(json['refundNote']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      memo: serializer.fromJson<String?>(json['memo']),
      requiresApproval: serializer.fromJson<bool>(json['requiresApproval']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'staffId': serializer.toJson<String?>(staffId),
      'productIdsCsv': serializer.toJson<String>(productIdsCsv),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime>(endAt),
      'depositEnabled': serializer.toJson<bool>(depositEnabled),
      'depositMethod': serializer.toJson<String?>(depositMethod),
      'depositAmount': serializer.toJson<int?>(depositAmount),
      'depositReceived': serializer.toJson<bool>(depositReceived),
      'depositRefunded': serializer.toJson<bool>(depositRefunded),
      'refundNote': serializer.toJson<String>(refundNote),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'memo': serializer.toJson<String?>(memo),
      'requiresApproval': serializer.toJson<bool>(requiresApproval),
      'status': serializer.toJson<String>(status),
    };
  }

  BookingRow copyWith({
    String? id,
    String? customerId,
    Value<String?> staffId = const Value.absent(),
    String? productIdsCsv,
    DateTime? startAt,
    DateTime? endAt,
    bool? depositEnabled,
    Value<String?> depositMethod = const Value.absent(),
    Value<int?> depositAmount = const Value.absent(),
    bool? depositReceived,
    bool? depositRefunded,
    String? refundNote,
    String? repeatRule,
    Value<String?> memo = const Value.absent(),
    bool? requiresApproval,
    String? status,
  }) => BookingRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    staffId: staffId.present ? staffId.value : this.staffId,
    productIdsCsv: productIdsCsv ?? this.productIdsCsv,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    depositEnabled: depositEnabled ?? this.depositEnabled,
    depositMethod: depositMethod.present
        ? depositMethod.value
        : this.depositMethod,
    depositAmount: depositAmount.present
        ? depositAmount.value
        : this.depositAmount,
    depositReceived: depositReceived ?? this.depositReceived,
    depositRefunded: depositRefunded ?? this.depositRefunded,
    refundNote: refundNote ?? this.refundNote,
    repeatRule: repeatRule ?? this.repeatRule,
    memo: memo.present ? memo.value : this.memo,
    requiresApproval: requiresApproval ?? this.requiresApproval,
    status: status ?? this.status,
  );
  BookingRow copyWithCompanion(BookingsCompanion data) {
    return BookingRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      productIdsCsv: data.productIdsCsv.present
          ? data.productIdsCsv.value
          : this.productIdsCsv,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      depositEnabled: data.depositEnabled.present
          ? data.depositEnabled.value
          : this.depositEnabled,
      depositMethod: data.depositMethod.present
          ? data.depositMethod.value
          : this.depositMethod,
      depositAmount: data.depositAmount.present
          ? data.depositAmount.value
          : this.depositAmount,
      depositReceived: data.depositReceived.present
          ? data.depositReceived.value
          : this.depositReceived,
      depositRefunded: data.depositRefunded.present
          ? data.depositRefunded.value
          : this.depositRefunded,
      refundNote: data.refundNote.present
          ? data.refundNote.value
          : this.refundNote,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      memo: data.memo.present ? data.memo.value : this.memo,
      requiresApproval: data.requiresApproval.present
          ? data.requiresApproval.value
          : this.requiresApproval,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('staffId: $staffId, ')
          ..write('productIdsCsv: $productIdsCsv, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('depositEnabled: $depositEnabled, ')
          ..write('depositMethod: $depositMethod, ')
          ..write('depositAmount: $depositAmount, ')
          ..write('depositReceived: $depositReceived, ')
          ..write('depositRefunded: $depositRefunded, ')
          ..write('refundNote: $refundNote, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('memo: $memo, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    staffId,
    productIdsCsv,
    startAt,
    endAt,
    depositEnabled,
    depositMethod,
    depositAmount,
    depositReceived,
    depositRefunded,
    refundNote,
    repeatRule,
    memo,
    requiresApproval,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.staffId == this.staffId &&
          other.productIdsCsv == this.productIdsCsv &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.depositEnabled == this.depositEnabled &&
          other.depositMethod == this.depositMethod &&
          other.depositAmount == this.depositAmount &&
          other.depositReceived == this.depositReceived &&
          other.depositRefunded == this.depositRefunded &&
          other.refundNote == this.refundNote &&
          other.repeatRule == this.repeatRule &&
          other.memo == this.memo &&
          other.requiresApproval == this.requiresApproval &&
          other.status == this.status);
}

class BookingsCompanion extends UpdateCompanion<BookingRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String?> staffId;
  final Value<String> productIdsCsv;
  final Value<DateTime> startAt;
  final Value<DateTime> endAt;
  final Value<bool> depositEnabled;
  final Value<String?> depositMethod;
  final Value<int?> depositAmount;
  final Value<bool> depositReceived;
  final Value<bool> depositRefunded;
  final Value<String> refundNote;
  final Value<String> repeatRule;
  final Value<String?> memo;
  final Value<bool> requiresApproval;
  final Value<String> status;
  final Value<int> rowid;
  const BookingsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.staffId = const Value.absent(),
    this.productIdsCsv = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.depositEnabled = const Value.absent(),
    this.depositMethod = const Value.absent(),
    this.depositAmount = const Value.absent(),
    this.depositReceived = const Value.absent(),
    this.depositRefunded = const Value.absent(),
    this.refundNote = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.memo = const Value.absent(),
    this.requiresApproval = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingsCompanion.insert({
    required String id,
    required String customerId,
    this.staffId = const Value.absent(),
    this.productIdsCsv = const Value.absent(),
    required DateTime startAt,
    required DateTime endAt,
    this.depositEnabled = const Value.absent(),
    this.depositMethod = const Value.absent(),
    this.depositAmount = const Value.absent(),
    this.depositReceived = const Value.absent(),
    this.depositRefunded = const Value.absent(),
    this.refundNote = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.memo = const Value.absent(),
    this.requiresApproval = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       startAt = Value(startAt),
       endAt = Value(endAt);
  static Insertable<BookingRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? staffId,
    Expression<String>? productIdsCsv,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<bool>? depositEnabled,
    Expression<String>? depositMethod,
    Expression<int>? depositAmount,
    Expression<bool>? depositReceived,
    Expression<bool>? depositRefunded,
    Expression<String>? refundNote,
    Expression<String>? repeatRule,
    Expression<String>? memo,
    Expression<bool>? requiresApproval,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (staffId != null) 'staff_id': staffId,
      if (productIdsCsv != null) 'product_ids_csv': productIdsCsv,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (depositEnabled != null) 'deposit_enabled': depositEnabled,
      if (depositMethod != null) 'deposit_method': depositMethod,
      if (depositAmount != null) 'deposit_amount': depositAmount,
      if (depositReceived != null) 'deposit_received': depositReceived,
      if (depositRefunded != null) 'deposit_refunded': depositRefunded,
      if (refundNote != null) 'refund_note': refundNote,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (memo != null) 'memo': memo,
      if (requiresApproval != null) 'requires_approval': requiresApproval,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingsCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String?>? staffId,
    Value<String>? productIdsCsv,
    Value<DateTime>? startAt,
    Value<DateTime>? endAt,
    Value<bool>? depositEnabled,
    Value<String?>? depositMethod,
    Value<int?>? depositAmount,
    Value<bool>? depositReceived,
    Value<bool>? depositRefunded,
    Value<String>? refundNote,
    Value<String>? repeatRule,
    Value<String?>? memo,
    Value<bool>? requiresApproval,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return BookingsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      staffId: staffId ?? this.staffId,
      productIdsCsv: productIdsCsv ?? this.productIdsCsv,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      depositEnabled: depositEnabled ?? this.depositEnabled,
      depositMethod: depositMethod ?? this.depositMethod,
      depositAmount: depositAmount ?? this.depositAmount,
      depositReceived: depositReceived ?? this.depositReceived,
      depositRefunded: depositRefunded ?? this.depositRefunded,
      refundNote: refundNote ?? this.refundNote,
      repeatRule: repeatRule ?? this.repeatRule,
      memo: memo ?? this.memo,
      requiresApproval: requiresApproval ?? this.requiresApproval,
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
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (productIdsCsv.present) {
      map['product_ids_csv'] = Variable<String>(productIdsCsv.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (depositEnabled.present) {
      map['deposit_enabled'] = Variable<bool>(depositEnabled.value);
    }
    if (depositMethod.present) {
      map['deposit_method'] = Variable<String>(depositMethod.value);
    }
    if (depositAmount.present) {
      map['deposit_amount'] = Variable<int>(depositAmount.value);
    }
    if (depositReceived.present) {
      map['deposit_received'] = Variable<bool>(depositReceived.value);
    }
    if (depositRefunded.present) {
      map['deposit_refunded'] = Variable<bool>(depositRefunded.value);
    }
    if (refundNote.present) {
      map['refund_note'] = Variable<String>(refundNote.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (requiresApproval.present) {
      map['requires_approval'] = Variable<bool>(requiresApproval.value);
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
    return (StringBuffer('BookingsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('staffId: $staffId, ')
          ..write('productIdsCsv: $productIdsCsv, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('depositEnabled: $depositEnabled, ')
          ..write('depositMethod: $depositMethod, ')
          ..write('depositAmount: $depositAmount, ')
          ..write('depositReceived: $depositReceived, ')
          ..write('depositRefunded: $depositRefunded, ')
          ..write('refundNote: $refundNote, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('memo: $memo, ')
          ..write('requiresApproval: $requiresApproval, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaitingEntriesTable extends WaitingEntries
    with TableInfo<$WaitingEntriesTable, WaitingEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaitingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _menuNoteMeta = const VerificationMeta(
    'menuNote',
  );
  @override
  late final GeneratedColumn<String> menuNote = GeneratedColumn<String>(
    'menu_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredStaffIdMeta = const VerificationMeta(
    'preferredStaffId',
  );
  @override
  late final GeneratedColumn<String> preferredStaffId = GeneratedColumn<String>(
    'preferred_staff_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkInAtMeta = const VerificationMeta(
    'checkInAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkInAt = GeneratedColumn<DateTime>(
    'check_in_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('waiting'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerName,
    phone,
    menuNote,
    preferredStaffId,
    checkInAt,
    sortOrder,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'waiting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaitingEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('menu_note')) {
      context.handle(
        _menuNoteMeta,
        menuNote.isAcceptableOrUnknown(data['menu_note']!, _menuNoteMeta),
      );
    }
    if (data.containsKey('preferred_staff_id')) {
      context.handle(
        _preferredStaffIdMeta,
        preferredStaffId.isAcceptableOrUnknown(
          data['preferred_staff_id']!,
          _preferredStaffIdMeta,
        ),
      );
    }
    if (data.containsKey('check_in_at')) {
      context.handle(
        _checkInAtMeta,
        checkInAt.isAcceptableOrUnknown(data['check_in_at']!, _checkInAtMeta),
      );
    } else if (isInserting) {
      context.missing(_checkInAtMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
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
  WaitingEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaitingEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      menuNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_note'],
      ),
      preferredStaffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_staff_id'],
      ),
      checkInAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $WaitingEntriesTable createAlias(String alias) {
    return $WaitingEntriesTable(attachedDatabase, alias);
  }
}

class WaitingEntryRow extends DataClass implements Insertable<WaitingEntryRow> {
  final String id;
  final String customerName;
  final String? phone;
  final String? menuNote;
  final String? preferredStaffId;
  final DateTime checkInAt;
  final int sortOrder;

  /// waiting/called/seated/cancelled.
  final String status;
  const WaitingEntryRow({
    required this.id,
    required this.customerName,
    this.phone,
    this.menuNote,
    this.preferredStaffId,
    required this.checkInAt,
    required this.sortOrder,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || menuNote != null) {
      map['menu_note'] = Variable<String>(menuNote);
    }
    if (!nullToAbsent || preferredStaffId != null) {
      map['preferred_staff_id'] = Variable<String>(preferredStaffId);
    }
    map['check_in_at'] = Variable<DateTime>(checkInAt);
    map['sort_order'] = Variable<int>(sortOrder);
    map['status'] = Variable<String>(status);
    return map;
  }

  WaitingEntriesCompanion toCompanion(bool nullToAbsent) {
    return WaitingEntriesCompanion(
      id: Value(id),
      customerName: Value(customerName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      menuNote: menuNote == null && nullToAbsent
          ? const Value.absent()
          : Value(menuNote),
      preferredStaffId: preferredStaffId == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredStaffId),
      checkInAt: Value(checkInAt),
      sortOrder: Value(sortOrder),
      status: Value(status),
    );
  }

  factory WaitingEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaitingEntryRow(
      id: serializer.fromJson<String>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      phone: serializer.fromJson<String?>(json['phone']),
      menuNote: serializer.fromJson<String?>(json['menuNote']),
      preferredStaffId: serializer.fromJson<String?>(json['preferredStaffId']),
      checkInAt: serializer.fromJson<DateTime>(json['checkInAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerName': serializer.toJson<String>(customerName),
      'phone': serializer.toJson<String?>(phone),
      'menuNote': serializer.toJson<String?>(menuNote),
      'preferredStaffId': serializer.toJson<String?>(preferredStaffId),
      'checkInAt': serializer.toJson<DateTime>(checkInAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'status': serializer.toJson<String>(status),
    };
  }

  WaitingEntryRow copyWith({
    String? id,
    String? customerName,
    Value<String?> phone = const Value.absent(),
    Value<String?> menuNote = const Value.absent(),
    Value<String?> preferredStaffId = const Value.absent(),
    DateTime? checkInAt,
    int? sortOrder,
    String? status,
  }) => WaitingEntryRow(
    id: id ?? this.id,
    customerName: customerName ?? this.customerName,
    phone: phone.present ? phone.value : this.phone,
    menuNote: menuNote.present ? menuNote.value : this.menuNote,
    preferredStaffId: preferredStaffId.present
        ? preferredStaffId.value
        : this.preferredStaffId,
    checkInAt: checkInAt ?? this.checkInAt,
    sortOrder: sortOrder ?? this.sortOrder,
    status: status ?? this.status,
  );
  WaitingEntryRow copyWithCompanion(WaitingEntriesCompanion data) {
    return WaitingEntryRow(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      menuNote: data.menuNote.present ? data.menuNote.value : this.menuNote,
      preferredStaffId: data.preferredStaffId.present
          ? data.preferredStaffId.value
          : this.preferredStaffId,
      checkInAt: data.checkInAt.present ? data.checkInAt.value : this.checkInAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaitingEntryRow(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('menuNote: $menuNote, ')
          ..write('preferredStaffId: $preferredStaffId, ')
          ..write('checkInAt: $checkInAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerName,
    phone,
    menuNote,
    preferredStaffId,
    checkInAt,
    sortOrder,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaitingEntryRow &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.phone == this.phone &&
          other.menuNote == this.menuNote &&
          other.preferredStaffId == this.preferredStaffId &&
          other.checkInAt == this.checkInAt &&
          other.sortOrder == this.sortOrder &&
          other.status == this.status);
}

class WaitingEntriesCompanion extends UpdateCompanion<WaitingEntryRow> {
  final Value<String> id;
  final Value<String> customerName;
  final Value<String?> phone;
  final Value<String?> menuNote;
  final Value<String?> preferredStaffId;
  final Value<DateTime> checkInAt;
  final Value<int> sortOrder;
  final Value<String> status;
  final Value<int> rowid;
  const WaitingEntriesCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.menuNote = const Value.absent(),
    this.preferredStaffId = const Value.absent(),
    this.checkInAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaitingEntriesCompanion.insert({
    required String id,
    required String customerName,
    this.phone = const Value.absent(),
    this.menuNote = const Value.absent(),
    this.preferredStaffId = const Value.absent(),
    required DateTime checkInAt,
    required int sortOrder,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       checkInAt = Value(checkInAt),
       sortOrder = Value(sortOrder);
  static Insertable<WaitingEntryRow> custom({
    Expression<String>? id,
    Expression<String>? customerName,
    Expression<String>? phone,
    Expression<String>? menuNote,
    Expression<String>? preferredStaffId,
    Expression<DateTime>? checkInAt,
    Expression<int>? sortOrder,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (phone != null) 'phone': phone,
      if (menuNote != null) 'menu_note': menuNote,
      if (preferredStaffId != null) 'preferred_staff_id': preferredStaffId,
      if (checkInAt != null) 'check_in_at': checkInAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaitingEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? customerName,
    Value<String?>? phone,
    Value<String?>? menuNote,
    Value<String?>? preferredStaffId,
    Value<DateTime>? checkInAt,
    Value<int>? sortOrder,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return WaitingEntriesCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      menuNote: menuNote ?? this.menuNote,
      preferredStaffId: preferredStaffId ?? this.preferredStaffId,
      checkInAt: checkInAt ?? this.checkInAt,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (menuNote.present) {
      map['menu_note'] = Variable<String>(menuNote.value);
    }
    if (preferredStaffId.present) {
      map['preferred_staff_id'] = Variable<String>(preferredStaffId.value);
    }
    if (checkInAt.present) {
      map['check_in_at'] = Variable<DateTime>(checkInAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('WaitingEntriesCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('menuNote: $menuNote, ')
          ..write('preferredStaffId: $preferredStaffId, ')
          ..write('checkInAt: $checkInAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, OrderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<int> totalAmount = GeneratedColumn<int>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<int> discountAmount = GeneratedColumn<int>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pointsUsedMeta = const VerificationMeta(
    'pointsUsed',
  );
  @override
  late final GeneratedColumn<int> pointsUsed = GeneratedColumn<int>(
    'points_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _prepaidUsedJsonMeta = const VerificationMeta(
    'prepaidUsedJson',
  );
  @override
  late final GeneratedColumn<String> prepaidUsedJson = GeneratedColumn<String>(
    'prepaid_used_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
    customerId,
    totalAmount,
    discountAmount,
    pointsUsed,
    prepaidUsedJson,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderRow> instance, {
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
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('points_used')) {
      context.handle(
        _pointsUsedMeta,
        pointsUsed.isAcceptableOrUnknown(data['points_used']!, _pointsUsedMeta),
      );
    }
    if (data.containsKey('prepaid_used_json')) {
      context.handle(
        _prepaidUsedJsonMeta,
        prepaidUsedJson.isAcceptableOrUnknown(
          data['prepaid_used_json']!,
          _prepaidUsedJsonMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  OrderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_amount'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_amount'],
      )!,
      pointsUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_used'],
      )!,
      prepaidUsedJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prepaid_used_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class OrderRow extends DataClass implements Insertable<OrderRow> {
  final String id;
  final String? customerId;
  final int totalAmount;
  final int discountAmount;
  final int pointsUsed;
  final String prepaidUsedJson;

  /// pending/completed/cancelled/partially_paid.
  final String status;
  final DateTime createdAt;
  const OrderRow({
    required this.id,
    this.customerId,
    required this.totalAmount,
    required this.discountAmount,
    required this.pointsUsed,
    required this.prepaidUsedJson,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['total_amount'] = Variable<int>(totalAmount);
    map['discount_amount'] = Variable<int>(discountAmount);
    map['points_used'] = Variable<int>(pointsUsed);
    map['prepaid_used_json'] = Variable<String>(prepaidUsedJson);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      totalAmount: Value(totalAmount),
      discountAmount: Value(discountAmount),
      pointsUsed: Value(pointsUsed),
      prepaidUsedJson: Value(prepaidUsedJson),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory OrderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      totalAmount: serializer.fromJson<int>(json['totalAmount']),
      discountAmount: serializer.fromJson<int>(json['discountAmount']),
      pointsUsed: serializer.fromJson<int>(json['pointsUsed']),
      prepaidUsedJson: serializer.fromJson<String>(json['prepaidUsedJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'totalAmount': serializer.toJson<int>(totalAmount),
      'discountAmount': serializer.toJson<int>(discountAmount),
      'pointsUsed': serializer.toJson<int>(pointsUsed),
      'prepaidUsedJson': serializer.toJson<String>(prepaidUsedJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OrderRow copyWith({
    String? id,
    Value<String?> customerId = const Value.absent(),
    int? totalAmount,
    int? discountAmount,
    int? pointsUsed,
    String? prepaidUsedJson,
    String? status,
    DateTime? createdAt,
  }) => OrderRow(
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    totalAmount: totalAmount ?? this.totalAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    pointsUsed: pointsUsed ?? this.pointsUsed,
    prepaidUsedJson: prepaidUsedJson ?? this.prepaidUsedJson,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  OrderRow copyWithCompanion(OrdersCompanion data) {
    return OrderRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      pointsUsed: data.pointsUsed.present
          ? data.pointsUsed.value
          : this.pointsUsed,
      prepaidUsedJson: data.prepaidUsedJson.present
          ? data.prepaidUsedJson.value
          : this.prepaidUsedJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('pointsUsed: $pointsUsed, ')
          ..write('prepaidUsedJson: $prepaidUsedJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    totalAmount,
    discountAmount,
    pointsUsed,
    prepaidUsedJson,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.totalAmount == this.totalAmount &&
          other.discountAmount == this.discountAmount &&
          other.pointsUsed == this.pointsUsed &&
          other.prepaidUsedJson == this.prepaidUsedJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class OrdersCompanion extends UpdateCompanion<OrderRow> {
  final Value<String> id;
  final Value<String?> customerId;
  final Value<int> totalAmount;
  final Value<int> discountAmount;
  final Value<int> pointsUsed;
  final Value<String> prepaidUsedJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.pointsUsed = const Value.absent(),
    this.prepaidUsedJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    this.customerId = const Value.absent(),
    required int totalAmount,
    this.discountAmount = const Value.absent(),
    this.pointsUsed = const Value.absent(),
    this.prepaidUsedJson = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       totalAmount = Value(totalAmount),
       createdAt = Value(createdAt);
  static Insertable<OrderRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<int>? totalAmount,
    Expression<int>? discountAmount,
    Expression<int>? pointsUsed,
    Expression<String>? prepaidUsedJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (pointsUsed != null) 'points_used': pointsUsed,
      if (prepaidUsedJson != null) 'prepaid_used_json': prepaidUsedJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<String?>? customerId,
    Value<int>? totalAmount,
    Value<int>? discountAmount,
    Value<int>? pointsUsed,
    Value<String>? prepaidUsedJson,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      prepaidUsedJson: prepaidUsedJson ?? this.prepaidUsedJson,
      status: status ?? this.status,
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
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<int>(totalAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<int>(discountAmount.value);
    }
    if (pointsUsed.present) {
      map['points_used'] = Variable<int>(pointsUsed.value);
    }
    if (prepaidUsedJson.present) {
      map['prepaid_used_json'] = Variable<String>(prepaidUsedJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('pointsUsed: $pointsUsed, ')
          ..write('prepaidUsedJson: $prepaidUsedJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    productId,
    productName,
    quantity,
    unitPrice,
    staffId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrderItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}staff_id'],
      ),
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItemRow extends DataClass implements Insertable<OrderItemRow> {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final String? staffId;
  const OrderItemRow({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.staffId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<int>(unitPrice);
    if (!nullToAbsent || staffId != null) {
      map['staff_id'] = Variable<String>(staffId);
    }
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      staffId: staffId == null && nullToAbsent
          ? const Value.absent()
          : Value(staffId),
    );
  }

  factory OrderItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItemRow(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
      staffId: serializer.fromJson<String?>(json['staffId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<int>(unitPrice),
      'staffId': serializer.toJson<String?>(staffId),
    };
  }

  OrderItemRow copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    int? quantity,
    int? unitPrice,
    Value<String?> staffId = const Value.absent(),
  }) => OrderItemRow(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    staffId: staffId.present ? staffId.value : this.staffId,
  );
  OrderItemRow copyWithCompanion(OrderItemsCompanion data) {
    return OrderItemRow(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemRow(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('staffId: $staffId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderId,
    productId,
    productName,
    quantity,
    unitPrice,
    staffId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItemRow &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.staffId == this.staffId);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItemRow> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<int> unitPrice;
  final Value<String?> staffId;
  final Value<int> rowid;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.staffId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    required String id,
    required String orderId,
    required String productId,
    required String productName,
    required int quantity,
    required int unitPrice,
    this.staffId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       productId = Value(productId),
       productName = Value(productName),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice);
  static Insertable<OrderItemRow> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<int>? unitPrice,
    Expression<String>? staffId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (staffId != null) 'staff_id': staffId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String>? productId,
    Value<String>? productName,
    Value<int>? quantity,
    Value<int>? unitPrice,
    Value<String?>? staffId,
    Value<int>? rowid,
  }) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      staffId: staffId ?? this.staffId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<String>(staffId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('staffId: $staffId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _splitTypeMeta = const VerificationMeta(
    'splitType',
  );
  @override
  late final GeneratedColumn<String> splitType = GeneratedColumn<String>(
    'split_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashReceivedMeta = const VerificationMeta(
    'cashReceived',
  );
  @override
  late final GeneratedColumn<int> cashReceived = GeneratedColumn<int>(
    'cash_received',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashChangeMeta = const VerificationMeta(
    'cashChange',
  );
  @override
  late final GeneratedColumn<int> cashChange = GeneratedColumn<int>(
    'cash_change',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prepaidBalanceIdMeta = const VerificationMeta(
    'prepaidBalanceId',
  );
  @override
  late final GeneratedColumn<String> prepaidBalanceId = GeneratedColumn<String>(
    'prepaid_balance_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    orderId,
    method,
    amount,
    splitType,
    cashReceived,
    cashChange,
    prepaidBalanceId,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('split_type')) {
      context.handle(
        _splitTypeMeta,
        splitType.isAcceptableOrUnknown(data['split_type']!, _splitTypeMeta),
      );
    }
    if (data.containsKey('cash_received')) {
      context.handle(
        _cashReceivedMeta,
        cashReceived.isAcceptableOrUnknown(
          data['cash_received']!,
          _cashReceivedMeta,
        ),
      );
    }
    if (data.containsKey('cash_change')) {
      context.handle(
        _cashChangeMeta,
        cashChange.isAcceptableOrUnknown(data['cash_change']!, _cashChangeMeta),
      );
    }
    if (data.containsKey('prepaid_balance_id')) {
      context.handle(
        _prepaidBalanceIdMeta,
        prepaidBalanceId.isAcceptableOrUnknown(
          data['prepaid_balance_id']!,
          _prepaidBalanceIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      splitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}split_type'],
      ),
      cashReceived: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_received'],
      ),
      cashChange: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_change'],
      ),
      prepaidBalanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prepaid_balance_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final String orderId;
  final String method;
  final int amount;
  final String? splitType;
  final int? cashReceived;
  final int? cashChange;

  /// method='prepaid_pass'일 때만 사용 — 어느 PrepaidPassBalance에서
  /// 차감했는지 추적(M5의 TODO를 M6에서 이 컬럼으로 해소,
  /// CROSS_VALIDATION.md 수정2 후속).
  final String? prepaidBalanceId;

  /// completed/refunded.
  final String status;
  final DateTime createdAt;
  const PaymentRow({
    required this.id,
    required this.orderId,
    required this.method,
    required this.amount,
    this.splitType,
    this.cashReceived,
    this.cashChange,
    this.prepaidBalanceId,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    map['method'] = Variable<String>(method);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || splitType != null) {
      map['split_type'] = Variable<String>(splitType);
    }
    if (!nullToAbsent || cashReceived != null) {
      map['cash_received'] = Variable<int>(cashReceived);
    }
    if (!nullToAbsent || cashChange != null) {
      map['cash_change'] = Variable<int>(cashChange);
    }
    if (!nullToAbsent || prepaidBalanceId != null) {
      map['prepaid_balance_id'] = Variable<String>(prepaidBalanceId);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      method: Value(method),
      amount: Value(amount),
      splitType: splitType == null && nullToAbsent
          ? const Value.absent()
          : Value(splitType),
      cashReceived: cashReceived == null && nullToAbsent
          ? const Value.absent()
          : Value(cashReceived),
      cashChange: cashChange == null && nullToAbsent
          ? const Value.absent()
          : Value(cashChange),
      prepaidBalanceId: prepaidBalanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(prepaidBalanceId),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      method: serializer.fromJson<String>(json['method']),
      amount: serializer.fromJson<int>(json['amount']),
      splitType: serializer.fromJson<String?>(json['splitType']),
      cashReceived: serializer.fromJson<int?>(json['cashReceived']),
      cashChange: serializer.fromJson<int?>(json['cashChange']),
      prepaidBalanceId: serializer.fromJson<String?>(json['prepaidBalanceId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'method': serializer.toJson<String>(method),
      'amount': serializer.toJson<int>(amount),
      'splitType': serializer.toJson<String?>(splitType),
      'cashReceived': serializer.toJson<int?>(cashReceived),
      'cashChange': serializer.toJson<int?>(cashChange),
      'prepaidBalanceId': serializer.toJson<String?>(prepaidBalanceId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PaymentRow copyWith({
    String? id,
    String? orderId,
    String? method,
    int? amount,
    Value<String?> splitType = const Value.absent(),
    Value<int?> cashReceived = const Value.absent(),
    Value<int?> cashChange = const Value.absent(),
    Value<String?> prepaidBalanceId = const Value.absent(),
    String? status,
    DateTime? createdAt,
  }) => PaymentRow(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    method: method ?? this.method,
    amount: amount ?? this.amount,
    splitType: splitType.present ? splitType.value : this.splitType,
    cashReceived: cashReceived.present ? cashReceived.value : this.cashReceived,
    cashChange: cashChange.present ? cashChange.value : this.cashChange,
    prepaidBalanceId: prepaidBalanceId.present
        ? prepaidBalanceId.value
        : this.prepaidBalanceId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      method: data.method.present ? data.method.value : this.method,
      amount: data.amount.present ? data.amount.value : this.amount,
      splitType: data.splitType.present ? data.splitType.value : this.splitType,
      cashReceived: data.cashReceived.present
          ? data.cashReceived.value
          : this.cashReceived,
      cashChange: data.cashChange.present
          ? data.cashChange.value
          : this.cashChange,
      prepaidBalanceId: data.prepaidBalanceId.present
          ? data.prepaidBalanceId.value
          : this.prepaidBalanceId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('method: $method, ')
          ..write('amount: $amount, ')
          ..write('splitType: $splitType, ')
          ..write('cashReceived: $cashReceived, ')
          ..write('cashChange: $cashChange, ')
          ..write('prepaidBalanceId: $prepaidBalanceId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderId,
    method,
    amount,
    splitType,
    cashReceived,
    cashChange,
    prepaidBalanceId,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.method == this.method &&
          other.amount == this.amount &&
          other.splitType == this.splitType &&
          other.cashReceived == this.cashReceived &&
          other.cashChange == this.cashChange &&
          other.prepaidBalanceId == this.prepaidBalanceId &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String> method;
  final Value<int> amount;
  final Value<String?> splitType;
  final Value<int?> cashReceived;
  final Value<int?> cashChange;
  final Value<String?> prepaidBalanceId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.method = const Value.absent(),
    this.amount = const Value.absent(),
    this.splitType = const Value.absent(),
    this.cashReceived = const Value.absent(),
    this.cashChange = const Value.absent(),
    this.prepaidBalanceId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String orderId,
    required String method,
    required int amount,
    this.splitType = const Value.absent(),
    this.cashReceived = const Value.absent(),
    this.cashChange = const Value.absent(),
    this.prepaidBalanceId = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       method = Value(method),
       amount = Value(amount),
       createdAt = Value(createdAt);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? method,
    Expression<int>? amount,
    Expression<String>? splitType,
    Expression<int>? cashReceived,
    Expression<int>? cashChange,
    Expression<String>? prepaidBalanceId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (method != null) 'method': method,
      if (amount != null) 'amount': amount,
      if (splitType != null) 'split_type': splitType,
      if (cashReceived != null) 'cash_received': cashReceived,
      if (cashChange != null) 'cash_change': cashChange,
      if (prepaidBalanceId != null) 'prepaid_balance_id': prepaidBalanceId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String>? method,
    Value<int>? amount,
    Value<String?>? splitType,
    Value<int?>? cashReceived,
    Value<int?>? cashChange,
    Value<String?>? prepaidBalanceId,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      splitType: splitType ?? this.splitType,
      cashReceived: cashReceived ?? this.cashReceived,
      cashChange: cashChange ?? this.cashChange,
      prepaidBalanceId: prepaidBalanceId ?? this.prepaidBalanceId,
      status: status ?? this.status,
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
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (splitType.present) {
      map['split_type'] = Variable<String>(splitType.value);
    }
    if (cashReceived.present) {
      map['cash_received'] = Variable<int>(cashReceived.value);
    }
    if (cashChange.present) {
      map['cash_change'] = Variable<int>(cashChange.value);
    }
    if (prepaidBalanceId.present) {
      map['prepaid_balance_id'] = Variable<String>(prepaidBalanceId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('method: $method, ')
          ..write('amount: $amount, ')
          ..write('splitType: $splitType, ')
          ..write('cashReceived: $cashReceived, ')
          ..write('cashChange: $cashChange, ')
          ..write('prepaidBalanceId: $prepaidBalanceId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrepaidPassMenusTable extends PrepaidPassMenus
    with TableInfo<$PrepaidPassMenusTable, PrepaidPassMenuRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrepaidPassMenusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
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
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedProductIdMeta = const VerificationMeta(
    'linkedProductId',
  );
  @override
  late final GeneratedColumn<String> linkedProductId = GeneratedColumn<String>(
    'linked_product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _countPerPurchaseMeta = const VerificationMeta(
    'countPerPurchase',
  );
  @override
  late final GeneratedColumn<int> countPerPurchase = GeneratedColumn<int>(
    'count_per_purchase',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bonusTypeMeta = const VerificationMeta(
    'bonusType',
  );
  @override
  late final GeneratedColumn<String> bonusType = GeneratedColumn<String>(
    'bonus_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _bonusAmountMeta = const VerificationMeta(
    'bonusAmount',
  );
  @override
  late final GeneratedColumn<int> bonusAmount = GeneratedColumn<int>(
    'bonus_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bonusCountMeta = const VerificationMeta(
    'bonusCount',
  );
  @override
  late final GeneratedColumn<int> bonusCount = GeneratedColumn<int>(
    'bonus_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryTypeMeta = const VerificationMeta(
    'expiryType',
  );
  @override
  late final GeneratedColumn<String> expiryType = GeneratedColumn<String>(
    'expiry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _expiryCustomDaysMeta = const VerificationMeta(
    'expiryCustomDays',
  );
  @override
  late final GeneratedColumn<int> expiryCustomDays = GeneratedColumn<int>(
    'expiry_custom_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    name,
    linkedProductId,
    price,
    allowCustomPrice,
    countPerPurchase,
    bonusType,
    bonusAmount,
    bonusCount,
    expiryType,
    expiryCustomDays,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prepaid_pass_menus';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrepaidPassMenuRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('linked_product_id')) {
      context.handle(
        _linkedProductIdMeta,
        linkedProductId.isAcceptableOrUnknown(
          data['linked_product_id']!,
          _linkedProductIdMeta,
        ),
      );
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
    if (data.containsKey('count_per_purchase')) {
      context.handle(
        _countPerPurchaseMeta,
        countPerPurchase.isAcceptableOrUnknown(
          data['count_per_purchase']!,
          _countPerPurchaseMeta,
        ),
      );
    }
    if (data.containsKey('bonus_type')) {
      context.handle(
        _bonusTypeMeta,
        bonusType.isAcceptableOrUnknown(data['bonus_type']!, _bonusTypeMeta),
      );
    }
    if (data.containsKey('bonus_amount')) {
      context.handle(
        _bonusAmountMeta,
        bonusAmount.isAcceptableOrUnknown(
          data['bonus_amount']!,
          _bonusAmountMeta,
        ),
      );
    }
    if (data.containsKey('bonus_count')) {
      context.handle(
        _bonusCountMeta,
        bonusCount.isAcceptableOrUnknown(data['bonus_count']!, _bonusCountMeta),
      );
    }
    if (data.containsKey('expiry_type')) {
      context.handle(
        _expiryTypeMeta,
        expiryType.isAcceptableOrUnknown(data['expiry_type']!, _expiryTypeMeta),
      );
    }
    if (data.containsKey('expiry_custom_days')) {
      context.handle(
        _expiryCustomDaysMeta,
        expiryCustomDays.isAcceptableOrUnknown(
          data['expiry_custom_days']!,
          _expiryCustomDaysMeta,
        ),
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
  PrepaidPassMenuRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrepaidPassMenuRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      linkedProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_product_id'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      allowCustomPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_custom_price'],
      )!,
      countPerPurchase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count_per_purchase'],
      ),
      bonusType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bonus_type'],
      )!,
      bonusAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_amount'],
      ),
      bonusCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_count'],
      ),
      expiryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_type'],
      )!,
      expiryCustomDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiry_custom_days'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $PrepaidPassMenusTable createAlias(String alias) {
    return $PrepaidPassMenusTable(attachedDatabase, alias);
  }
}

class PrepaidPassMenuRow extends DataClass
    implements Insertable<PrepaidPassMenuRow> {
  final String id;

  /// amount(금액권) / count(횟수권). 생성 후 변경 불가(앱에서 강제).
  final String type;
  final String name;

  /// count 타입만 필수, 1개만.
  final String? linkedProductId;
  final int price;
  final bool allowCustomPrice;

  /// count 타입만. 1회 구매시 제공 횟수.
  final int? countPerPurchase;

  /// none / bonus.
  final String bonusType;
  final int? bonusAmount;
  final int? bonusCount;

  /// none/90d/180d/1y/2y/3y/fixedDate/custom.
  final String expiryType;

  /// fixedDate면 날짜, custom이면 일수(밀리초가 아니라 "일" 단위 정수를
  /// dateTime 컬럼에 epoch 변환 없이 별도 보관하기보단, 둘 다 단순화해
  /// "일수"로 통일 저장한다 — fixedDate는 호출측에서 일수로 환산해 넘김.
  final int? expiryCustomDays;

  /// active/disabled.
  final String status;
  const PrepaidPassMenuRow({
    required this.id,
    required this.type,
    required this.name,
    this.linkedProductId,
    required this.price,
    required this.allowCustomPrice,
    this.countPerPurchase,
    required this.bonusType,
    this.bonusAmount,
    this.bonusCount,
    required this.expiryType,
    this.expiryCustomDays,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || linkedProductId != null) {
      map['linked_product_id'] = Variable<String>(linkedProductId);
    }
    map['price'] = Variable<int>(price);
    map['allow_custom_price'] = Variable<bool>(allowCustomPrice);
    if (!nullToAbsent || countPerPurchase != null) {
      map['count_per_purchase'] = Variable<int>(countPerPurchase);
    }
    map['bonus_type'] = Variable<String>(bonusType);
    if (!nullToAbsent || bonusAmount != null) {
      map['bonus_amount'] = Variable<int>(bonusAmount);
    }
    if (!nullToAbsent || bonusCount != null) {
      map['bonus_count'] = Variable<int>(bonusCount);
    }
    map['expiry_type'] = Variable<String>(expiryType);
    if (!nullToAbsent || expiryCustomDays != null) {
      map['expiry_custom_days'] = Variable<int>(expiryCustomDays);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  PrepaidPassMenusCompanion toCompanion(bool nullToAbsent) {
    return PrepaidPassMenusCompanion(
      id: Value(id),
      type: Value(type),
      name: Value(name),
      linkedProductId: linkedProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedProductId),
      price: Value(price),
      allowCustomPrice: Value(allowCustomPrice),
      countPerPurchase: countPerPurchase == null && nullToAbsent
          ? const Value.absent()
          : Value(countPerPurchase),
      bonusType: Value(bonusType),
      bonusAmount: bonusAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(bonusAmount),
      bonusCount: bonusCount == null && nullToAbsent
          ? const Value.absent()
          : Value(bonusCount),
      expiryType: Value(expiryType),
      expiryCustomDays: expiryCustomDays == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryCustomDays),
      status: Value(status),
    );
  }

  factory PrepaidPassMenuRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrepaidPassMenuRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      linkedProductId: serializer.fromJson<String?>(json['linkedProductId']),
      price: serializer.fromJson<int>(json['price']),
      allowCustomPrice: serializer.fromJson<bool>(json['allowCustomPrice']),
      countPerPurchase: serializer.fromJson<int?>(json['countPerPurchase']),
      bonusType: serializer.fromJson<String>(json['bonusType']),
      bonusAmount: serializer.fromJson<int?>(json['bonusAmount']),
      bonusCount: serializer.fromJson<int?>(json['bonusCount']),
      expiryType: serializer.fromJson<String>(json['expiryType']),
      expiryCustomDays: serializer.fromJson<int?>(json['expiryCustomDays']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'linkedProductId': serializer.toJson<String?>(linkedProductId),
      'price': serializer.toJson<int>(price),
      'allowCustomPrice': serializer.toJson<bool>(allowCustomPrice),
      'countPerPurchase': serializer.toJson<int?>(countPerPurchase),
      'bonusType': serializer.toJson<String>(bonusType),
      'bonusAmount': serializer.toJson<int?>(bonusAmount),
      'bonusCount': serializer.toJson<int?>(bonusCount),
      'expiryType': serializer.toJson<String>(expiryType),
      'expiryCustomDays': serializer.toJson<int?>(expiryCustomDays),
      'status': serializer.toJson<String>(status),
    };
  }

  PrepaidPassMenuRow copyWith({
    String? id,
    String? type,
    String? name,
    Value<String?> linkedProductId = const Value.absent(),
    int? price,
    bool? allowCustomPrice,
    Value<int?> countPerPurchase = const Value.absent(),
    String? bonusType,
    Value<int?> bonusAmount = const Value.absent(),
    Value<int?> bonusCount = const Value.absent(),
    String? expiryType,
    Value<int?> expiryCustomDays = const Value.absent(),
    String? status,
  }) => PrepaidPassMenuRow(
    id: id ?? this.id,
    type: type ?? this.type,
    name: name ?? this.name,
    linkedProductId: linkedProductId.present
        ? linkedProductId.value
        : this.linkedProductId,
    price: price ?? this.price,
    allowCustomPrice: allowCustomPrice ?? this.allowCustomPrice,
    countPerPurchase: countPerPurchase.present
        ? countPerPurchase.value
        : this.countPerPurchase,
    bonusType: bonusType ?? this.bonusType,
    bonusAmount: bonusAmount.present ? bonusAmount.value : this.bonusAmount,
    bonusCount: bonusCount.present ? bonusCount.value : this.bonusCount,
    expiryType: expiryType ?? this.expiryType,
    expiryCustomDays: expiryCustomDays.present
        ? expiryCustomDays.value
        : this.expiryCustomDays,
    status: status ?? this.status,
  );
  PrepaidPassMenuRow copyWithCompanion(PrepaidPassMenusCompanion data) {
    return PrepaidPassMenuRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      linkedProductId: data.linkedProductId.present
          ? data.linkedProductId.value
          : this.linkedProductId,
      price: data.price.present ? data.price.value : this.price,
      allowCustomPrice: data.allowCustomPrice.present
          ? data.allowCustomPrice.value
          : this.allowCustomPrice,
      countPerPurchase: data.countPerPurchase.present
          ? data.countPerPurchase.value
          : this.countPerPurchase,
      bonusType: data.bonusType.present ? data.bonusType.value : this.bonusType,
      bonusAmount: data.bonusAmount.present
          ? data.bonusAmount.value
          : this.bonusAmount,
      bonusCount: data.bonusCount.present
          ? data.bonusCount.value
          : this.bonusCount,
      expiryType: data.expiryType.present
          ? data.expiryType.value
          : this.expiryType,
      expiryCustomDays: data.expiryCustomDays.present
          ? data.expiryCustomDays.value
          : this.expiryCustomDays,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrepaidPassMenuRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('linkedProductId: $linkedProductId, ')
          ..write('price: $price, ')
          ..write('allowCustomPrice: $allowCustomPrice, ')
          ..write('countPerPurchase: $countPerPurchase, ')
          ..write('bonusType: $bonusType, ')
          ..write('bonusAmount: $bonusAmount, ')
          ..write('bonusCount: $bonusCount, ')
          ..write('expiryType: $expiryType, ')
          ..write('expiryCustomDays: $expiryCustomDays, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    name,
    linkedProductId,
    price,
    allowCustomPrice,
    countPerPurchase,
    bonusType,
    bonusAmount,
    bonusCount,
    expiryType,
    expiryCustomDays,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrepaidPassMenuRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.name == this.name &&
          other.linkedProductId == this.linkedProductId &&
          other.price == this.price &&
          other.allowCustomPrice == this.allowCustomPrice &&
          other.countPerPurchase == this.countPerPurchase &&
          other.bonusType == this.bonusType &&
          other.bonusAmount == this.bonusAmount &&
          other.bonusCount == this.bonusCount &&
          other.expiryType == this.expiryType &&
          other.expiryCustomDays == this.expiryCustomDays &&
          other.status == this.status);
}

class PrepaidPassMenusCompanion extends UpdateCompanion<PrepaidPassMenuRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> name;
  final Value<String?> linkedProductId;
  final Value<int> price;
  final Value<bool> allowCustomPrice;
  final Value<int?> countPerPurchase;
  final Value<String> bonusType;
  final Value<int?> bonusAmount;
  final Value<int?> bonusCount;
  final Value<String> expiryType;
  final Value<int?> expiryCustomDays;
  final Value<String> status;
  final Value<int> rowid;
  const PrepaidPassMenusCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.linkedProductId = const Value.absent(),
    this.price = const Value.absent(),
    this.allowCustomPrice = const Value.absent(),
    this.countPerPurchase = const Value.absent(),
    this.bonusType = const Value.absent(),
    this.bonusAmount = const Value.absent(),
    this.bonusCount = const Value.absent(),
    this.expiryType = const Value.absent(),
    this.expiryCustomDays = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrepaidPassMenusCompanion.insert({
    required String id,
    required String type,
    required String name,
    this.linkedProductId = const Value.absent(),
    required int price,
    this.allowCustomPrice = const Value.absent(),
    this.countPerPurchase = const Value.absent(),
    this.bonusType = const Value.absent(),
    this.bonusAmount = const Value.absent(),
    this.bonusCount = const Value.absent(),
    this.expiryType = const Value.absent(),
    this.expiryCustomDays = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       name = Value(name),
       price = Value(price);
  static Insertable<PrepaidPassMenuRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? linkedProductId,
    Expression<int>? price,
    Expression<bool>? allowCustomPrice,
    Expression<int>? countPerPurchase,
    Expression<String>? bonusType,
    Expression<int>? bonusAmount,
    Expression<int>? bonusCount,
    Expression<String>? expiryType,
    Expression<int>? expiryCustomDays,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (linkedProductId != null) 'linked_product_id': linkedProductId,
      if (price != null) 'price': price,
      if (allowCustomPrice != null) 'allow_custom_price': allowCustomPrice,
      if (countPerPurchase != null) 'count_per_purchase': countPerPurchase,
      if (bonusType != null) 'bonus_type': bonusType,
      if (bonusAmount != null) 'bonus_amount': bonusAmount,
      if (bonusCount != null) 'bonus_count': bonusCount,
      if (expiryType != null) 'expiry_type': expiryType,
      if (expiryCustomDays != null) 'expiry_custom_days': expiryCustomDays,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrepaidPassMenusCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? name,
    Value<String?>? linkedProductId,
    Value<int>? price,
    Value<bool>? allowCustomPrice,
    Value<int?>? countPerPurchase,
    Value<String>? bonusType,
    Value<int?>? bonusAmount,
    Value<int?>? bonusCount,
    Value<String>? expiryType,
    Value<int?>? expiryCustomDays,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return PrepaidPassMenusCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      linkedProductId: linkedProductId ?? this.linkedProductId,
      price: price ?? this.price,
      allowCustomPrice: allowCustomPrice ?? this.allowCustomPrice,
      countPerPurchase: countPerPurchase ?? this.countPerPurchase,
      bonusType: bonusType ?? this.bonusType,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      bonusCount: bonusCount ?? this.bonusCount,
      expiryType: expiryType ?? this.expiryType,
      expiryCustomDays: expiryCustomDays ?? this.expiryCustomDays,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (linkedProductId.present) {
      map['linked_product_id'] = Variable<String>(linkedProductId.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (allowCustomPrice.present) {
      map['allow_custom_price'] = Variable<bool>(allowCustomPrice.value);
    }
    if (countPerPurchase.present) {
      map['count_per_purchase'] = Variable<int>(countPerPurchase.value);
    }
    if (bonusType.present) {
      map['bonus_type'] = Variable<String>(bonusType.value);
    }
    if (bonusAmount.present) {
      map['bonus_amount'] = Variable<int>(bonusAmount.value);
    }
    if (bonusCount.present) {
      map['bonus_count'] = Variable<int>(bonusCount.value);
    }
    if (expiryType.present) {
      map['expiry_type'] = Variable<String>(expiryType.value);
    }
    if (expiryCustomDays.present) {
      map['expiry_custom_days'] = Variable<int>(expiryCustomDays.value);
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
    return (StringBuffer('PrepaidPassMenusCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('linkedProductId: $linkedProductId, ')
          ..write('price: $price, ')
          ..write('allowCustomPrice: $allowCustomPrice, ')
          ..write('countPerPurchase: $countPerPurchase, ')
          ..write('bonusType: $bonusType, ')
          ..write('bonusAmount: $bonusAmount, ')
          ..write('bonusCount: $bonusCount, ')
          ..write('expiryType: $expiryType, ')
          ..write('expiryCustomDays: $expiryCustomDays, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrepaidPassBalancesTable extends PrepaidPassBalances
    with TableInfo<$PrepaidPassBalancesTable, PrepaidPassBalanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrepaidPassBalancesTable(this.attachedDatabase, [this._alias]);
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
  );
  static const VerificationMeta _menuIdMeta = const VerificationMeta('menuId');
  @override
  late final GeneratedColumn<String> menuId = GeneratedColumn<String>(
    'menu_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remainingAmountMeta = const VerificationMeta(
    'remainingAmount',
  );
  @override
  late final GeneratedColumn<int> remainingAmount = GeneratedColumn<int>(
    'remaining_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remainingCountMeta = const VerificationMeta(
    'remainingCount',
  );
  @override
  late final GeneratedColumn<int> remainingCount = GeneratedColumn<int>(
    'remaining_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasedAtMeta = const VerificationMeta(
    'purchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purchasedAt = GeneratedColumn<DateTime>(
    'purchased_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    menuId,
    remainingAmount,
    remainingCount,
    purchasedAt,
    expiresAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prepaid_pass_balances';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrepaidPassBalanceRow> instance, {
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
    if (data.containsKey('menu_id')) {
      context.handle(
        _menuIdMeta,
        menuId.isAcceptableOrUnknown(data['menu_id']!, _menuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_menuIdMeta);
    }
    if (data.containsKey('remaining_amount')) {
      context.handle(
        _remainingAmountMeta,
        remainingAmount.isAcceptableOrUnknown(
          data['remaining_amount']!,
          _remainingAmountMeta,
        ),
      );
    }
    if (data.containsKey('remaining_count')) {
      context.handle(
        _remainingCountMeta,
        remainingCount.isAcceptableOrUnknown(
          data['remaining_count']!,
          _remainingCountMeta,
        ),
      );
    }
    if (data.containsKey('purchased_at')) {
      context.handle(
        _purchasedAtMeta,
        purchasedAt.isAcceptableOrUnknown(
          data['purchased_at']!,
          _purchasedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
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
  PrepaidPassBalanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrepaidPassBalanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      menuId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_id'],
      )!,
      remainingAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_amount'],
      ),
      remainingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remaining_count'],
      ),
      purchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchased_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $PrepaidPassBalancesTable createAlias(String alias) {
    return $PrepaidPassBalancesTable(attachedDatabase, alias);
  }
}

class PrepaidPassBalanceRow extends DataClass
    implements Insertable<PrepaidPassBalanceRow> {
  final String id;
  final String customerId;
  final String menuId;
  final int? remainingAmount;
  final int? remainingCount;
  final DateTime purchasedAt;
  final DateTime? expiresAt;

  /// active/expired/voided.
  final String status;
  const PrepaidPassBalanceRow({
    required this.id,
    required this.customerId,
    required this.menuId,
    this.remainingAmount,
    this.remainingCount,
    required this.purchasedAt,
    this.expiresAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['menu_id'] = Variable<String>(menuId);
    if (!nullToAbsent || remainingAmount != null) {
      map['remaining_amount'] = Variable<int>(remainingAmount);
    }
    if (!nullToAbsent || remainingCount != null) {
      map['remaining_count'] = Variable<int>(remainingCount);
    }
    map['purchased_at'] = Variable<DateTime>(purchasedAt);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  PrepaidPassBalancesCompanion toCompanion(bool nullToAbsent) {
    return PrepaidPassBalancesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      menuId: Value(menuId),
      remainingAmount: remainingAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingAmount),
      remainingCount: remainingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(remainingCount),
      purchasedAt: Value(purchasedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      status: Value(status),
    );
  }

  factory PrepaidPassBalanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrepaidPassBalanceRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      menuId: serializer.fromJson<String>(json['menuId']),
      remainingAmount: serializer.fromJson<int?>(json['remainingAmount']),
      remainingCount: serializer.fromJson<int?>(json['remainingCount']),
      purchasedAt: serializer.fromJson<DateTime>(json['purchasedAt']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'menuId': serializer.toJson<String>(menuId),
      'remainingAmount': serializer.toJson<int?>(remainingAmount),
      'remainingCount': serializer.toJson<int?>(remainingCount),
      'purchasedAt': serializer.toJson<DateTime>(purchasedAt),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'status': serializer.toJson<String>(status),
    };
  }

  PrepaidPassBalanceRow copyWith({
    String? id,
    String? customerId,
    String? menuId,
    Value<int?> remainingAmount = const Value.absent(),
    Value<int?> remainingCount = const Value.absent(),
    DateTime? purchasedAt,
    Value<DateTime?> expiresAt = const Value.absent(),
    String? status,
  }) => PrepaidPassBalanceRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    menuId: menuId ?? this.menuId,
    remainingAmount: remainingAmount.present
        ? remainingAmount.value
        : this.remainingAmount,
    remainingCount: remainingCount.present
        ? remainingCount.value
        : this.remainingCount,
    purchasedAt: purchasedAt ?? this.purchasedAt,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    status: status ?? this.status,
  );
  PrepaidPassBalanceRow copyWithCompanion(PrepaidPassBalancesCompanion data) {
    return PrepaidPassBalanceRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      menuId: data.menuId.present ? data.menuId.value : this.menuId,
      remainingAmount: data.remainingAmount.present
          ? data.remainingAmount.value
          : this.remainingAmount,
      remainingCount: data.remainingCount.present
          ? data.remainingCount.value
          : this.remainingCount,
      purchasedAt: data.purchasedAt.present
          ? data.purchasedAt.value
          : this.purchasedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrepaidPassBalanceRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('menuId: $menuId, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('remainingCount: $remainingCount, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    menuId,
    remainingAmount,
    remainingCount,
    purchasedAt,
    expiresAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrepaidPassBalanceRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.menuId == this.menuId &&
          other.remainingAmount == this.remainingAmount &&
          other.remainingCount == this.remainingCount &&
          other.purchasedAt == this.purchasedAt &&
          other.expiresAt == this.expiresAt &&
          other.status == this.status);
}

class PrepaidPassBalancesCompanion
    extends UpdateCompanion<PrepaidPassBalanceRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String> menuId;
  final Value<int?> remainingAmount;
  final Value<int?> remainingCount;
  final Value<DateTime> purchasedAt;
  final Value<DateTime?> expiresAt;
  final Value<String> status;
  final Value<int> rowid;
  const PrepaidPassBalancesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.menuId = const Value.absent(),
    this.remainingAmount = const Value.absent(),
    this.remainingCount = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrepaidPassBalancesCompanion.insert({
    required String id,
    required String customerId,
    required String menuId,
    this.remainingAmount = const Value.absent(),
    this.remainingCount = const Value.absent(),
    required DateTime purchasedAt,
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       menuId = Value(menuId),
       purchasedAt = Value(purchasedAt);
  static Insertable<PrepaidPassBalanceRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? menuId,
    Expression<int>? remainingAmount,
    Expression<int>? remainingCount,
    Expression<DateTime>? purchasedAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (menuId != null) 'menu_id': menuId,
      if (remainingAmount != null) 'remaining_amount': remainingAmount,
      if (remainingCount != null) 'remaining_count': remainingCount,
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrepaidPassBalancesCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String>? menuId,
    Value<int?>? remainingAmount,
    Value<int?>? remainingCount,
    Value<DateTime>? purchasedAt,
    Value<DateTime?>? expiresAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return PrepaidPassBalancesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      menuId: menuId ?? this.menuId,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      remainingCount: remainingCount ?? this.remainingCount,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
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
    if (menuId.present) {
      map['menu_id'] = Variable<String>(menuId.value);
    }
    if (remainingAmount.present) {
      map['remaining_amount'] = Variable<int>(remainingAmount.value);
    }
    if (remainingCount.present) {
      map['remaining_count'] = Variable<int>(remainingCount.value);
    }
    if (purchasedAt.present) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
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
    return (StringBuffer('PrepaidPassBalancesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('menuId: $menuId, ')
          ..write('remainingAmount: $remainingAmount, ')
          ..write('remainingCount: $remainingCount, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrepaidPassTransactionsTable extends PrepaidPassTransactions
    with TableInfo<$PrepaidPassTransactionsTable, PrepaidPassTransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrepaidPassTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _balanceIdMeta = const VerificationMeta(
    'balanceId',
  );
  @override
  late final GeneratedColumn<String> balanceId = GeneratedColumn<String>(
    'balance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedOrderIdMeta = const VerificationMeta(
    'relatedOrderId',
  );
  @override
  late final GeneratedColumn<String> relatedOrderId = GeneratedColumn<String>(
    'related_order_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    balanceId,
    type,
    amount,
    count,
    relatedOrderId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prepaid_pass_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrepaidPassTransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('balance_id')) {
      context.handle(
        _balanceIdMeta,
        balanceId.isAcceptableOrUnknown(data['balance_id']!, _balanceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_balanceIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('related_order_id')) {
      context.handle(
        _relatedOrderIdMeta,
        relatedOrderId.isAcceptableOrUnknown(
          data['related_order_id']!,
          _relatedOrderIdMeta,
        ),
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
  PrepaidPassTransactionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrepaidPassTransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      balanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}balance_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      ),
      relatedOrderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_order_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PrepaidPassTransactionsTable createAlias(String alias) {
    return $PrepaidPassTransactionsTable(attachedDatabase, alias);
  }
}

class PrepaidPassTransactionRow extends DataClass
    implements Insertable<PrepaidPassTransactionRow> {
  final String id;
  final String balanceId;

  /// charge/use/refund.
  final String type;
  final int? amount;
  final int? count;
  final String? relatedOrderId;
  final DateTime createdAt;
  const PrepaidPassTransactionRow({
    required this.id,
    required this.balanceId,
    required this.type,
    this.amount,
    this.count,
    this.relatedOrderId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['balance_id'] = Variable<String>(balanceId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    if (!nullToAbsent || count != null) {
      map['count'] = Variable<int>(count);
    }
    if (!nullToAbsent || relatedOrderId != null) {
      map['related_order_id'] = Variable<String>(relatedOrderId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PrepaidPassTransactionsCompanion toCompanion(bool nullToAbsent) {
    return PrepaidPassTransactionsCompanion(
      id: Value(id),
      balanceId: Value(balanceId),
      type: Value(type),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      count: count == null && nullToAbsent
          ? const Value.absent()
          : Value(count),
      relatedOrderId: relatedOrderId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedOrderId),
      createdAt: Value(createdAt),
    );
  }

  factory PrepaidPassTransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrepaidPassTransactionRow(
      id: serializer.fromJson<String>(json['id']),
      balanceId: serializer.fromJson<String>(json['balanceId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<int?>(json['amount']),
      count: serializer.fromJson<int?>(json['count']),
      relatedOrderId: serializer.fromJson<String?>(json['relatedOrderId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'balanceId': serializer.toJson<String>(balanceId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<int?>(amount),
      'count': serializer.toJson<int?>(count),
      'relatedOrderId': serializer.toJson<String?>(relatedOrderId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PrepaidPassTransactionRow copyWith({
    String? id,
    String? balanceId,
    String? type,
    Value<int?> amount = const Value.absent(),
    Value<int?> count = const Value.absent(),
    Value<String?> relatedOrderId = const Value.absent(),
    DateTime? createdAt,
  }) => PrepaidPassTransactionRow(
    id: id ?? this.id,
    balanceId: balanceId ?? this.balanceId,
    type: type ?? this.type,
    amount: amount.present ? amount.value : this.amount,
    count: count.present ? count.value : this.count,
    relatedOrderId: relatedOrderId.present
        ? relatedOrderId.value
        : this.relatedOrderId,
    createdAt: createdAt ?? this.createdAt,
  );
  PrepaidPassTransactionRow copyWithCompanion(
    PrepaidPassTransactionsCompanion data,
  ) {
    return PrepaidPassTransactionRow(
      id: data.id.present ? data.id.value : this.id,
      balanceId: data.balanceId.present ? data.balanceId.value : this.balanceId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      count: data.count.present ? data.count.value : this.count,
      relatedOrderId: data.relatedOrderId.present
          ? data.relatedOrderId.value
          : this.relatedOrderId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrepaidPassTransactionRow(')
          ..write('id: $id, ')
          ..write('balanceId: $balanceId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('count: $count, ')
          ..write('relatedOrderId: $relatedOrderId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    balanceId,
    type,
    amount,
    count,
    relatedOrderId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrepaidPassTransactionRow &&
          other.id == this.id &&
          other.balanceId == this.balanceId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.count == this.count &&
          other.relatedOrderId == this.relatedOrderId &&
          other.createdAt == this.createdAt);
}

class PrepaidPassTransactionsCompanion
    extends UpdateCompanion<PrepaidPassTransactionRow> {
  final Value<String> id;
  final Value<String> balanceId;
  final Value<String> type;
  final Value<int?> amount;
  final Value<int?> count;
  final Value<String?> relatedOrderId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PrepaidPassTransactionsCompanion({
    this.id = const Value.absent(),
    this.balanceId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.count = const Value.absent(),
    this.relatedOrderId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrepaidPassTransactionsCompanion.insert({
    required String id,
    required String balanceId,
    required String type,
    this.amount = const Value.absent(),
    this.count = const Value.absent(),
    this.relatedOrderId = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       balanceId = Value(balanceId),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<PrepaidPassTransactionRow> custom({
    Expression<String>? id,
    Expression<String>? balanceId,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<int>? count,
    Expression<String>? relatedOrderId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (balanceId != null) 'balance_id': balanceId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (count != null) 'count': count,
      if (relatedOrderId != null) 'related_order_id': relatedOrderId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrepaidPassTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? balanceId,
    Value<String>? type,
    Value<int?>? amount,
    Value<int?>? count,
    Value<String?>? relatedOrderId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PrepaidPassTransactionsCompanion(
      id: id ?? this.id,
      balanceId: balanceId ?? this.balanceId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      count: count ?? this.count,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
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
    if (balanceId.present) {
      map['balance_id'] = Variable<String>(balanceId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (relatedOrderId.present) {
      map['related_order_id'] = Variable<String>(relatedOrderId.value);
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
    return (StringBuffer('PrepaidPassTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('balanceId: $balanceId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('count: $count, ')
          ..write('relatedOrderId: $relatedOrderId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CouponsTable extends Coupons with TableInfo<$CouponsTable, CouponRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CouponsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _benefitTypeMeta = const VerificationMeta(
    'benefitType',
  );
  @override
  late final GeneratedColumn<String> benefitType = GeneratedColumn<String>(
    'benefit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<String> discountValue = GeneratedColumn<String>(
    'discount_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discountScopeMeta = const VerificationMeta(
    'discountScope',
  );
  @override
  late final GeneratedColumn<String> discountScope = GeneratedColumn<String>(
    'discount_scope',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minOrderAmountMeta = const VerificationMeta(
    'minOrderAmount',
  );
  @override
  late final GeneratedColumn<int> minOrderAmount = GeneratedColumn<int>(
    'min_order_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giftProductIdMeta = const VerificationMeta(
    'giftProductId',
  );
  @override
  late final GeneratedColumn<String> giftProductId = GeneratedColumn<String>(
    'gift_product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryDaysMeta = const VerificationMeta(
    'expiryDays',
  );
  @override
  late final GeneratedColumn<String> expiryDays = GeneratedColumn<String>(
    'expiry_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
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
    code,
    season,
    benefitType,
    discountValue,
    discountScope,
    minOrderAmount,
    giftProductId,
    expiryDays,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coupons';
  @override
  VerificationContext validateIntegrity(
    Insertable<CouponRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('benefit_type')) {
      context.handle(
        _benefitTypeMeta,
        benefitType.isAcceptableOrUnknown(
          data['benefit_type']!,
          _benefitTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_benefitTypeMeta);
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    }
    if (data.containsKey('discount_scope')) {
      context.handle(
        _discountScopeMeta,
        discountScope.isAcceptableOrUnknown(
          data['discount_scope']!,
          _discountScopeMeta,
        ),
      );
    }
    if (data.containsKey('min_order_amount')) {
      context.handle(
        _minOrderAmountMeta,
        minOrderAmount.isAcceptableOrUnknown(
          data['min_order_amount']!,
          _minOrderAmountMeta,
        ),
      );
    }
    if (data.containsKey('gift_product_id')) {
      context.handle(
        _giftProductIdMeta,
        giftProductId.isAcceptableOrUnknown(
          data['gift_product_id']!,
          _giftProductIdMeta,
        ),
      );
    }
    if (data.containsKey('expiry_days')) {
      context.handle(
        _expiryDaysMeta,
        expiryDays.isAcceptableOrUnknown(data['expiry_days']!, _expiryDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDaysMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
  CouponRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CouponRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      benefitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}benefit_type'],
      )!,
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_value'],
      ),
      discountScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_scope'],
      ),
      minOrderAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_order_amount'],
      ),
      giftProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gift_product_id'],
      ),
      expiryDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_days'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CouponsTable createAlias(String alias) {
    return $CouponsTable(attachedDatabase, alias);
  }
}

class CouponRow extends DataClass implements Insertable<CouponRow> {
  final String id;
  final String code;

  /// 시즌 템플릿 키(christmas/valentine/rainy 등) — 자유 텍스트 아님,
  /// 기본 제공 템플릿 내에서만 선택(F-MKT-01 "현재 제공되는 기본
  /// 템플릿 내에서만").
  final String season;

  /// discount / gift.
  final String benefitType;
  final String? discountValue;

  /// total / specific_product.
  final String? discountScope;
  final int? minOrderAmount;
  final String? giftProductId;

  /// '7' / '14' / '30' / 'always'.
  final String expiryDays;

  /// active/upcoming/expired.
  final String status;
  final DateTime createdAt;
  const CouponRow({
    required this.id,
    required this.code,
    required this.season,
    required this.benefitType,
    this.discountValue,
    this.discountScope,
    this.minOrderAmount,
    this.giftProductId,
    required this.expiryDays,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['season'] = Variable<String>(season);
    map['benefit_type'] = Variable<String>(benefitType);
    if (!nullToAbsent || discountValue != null) {
      map['discount_value'] = Variable<String>(discountValue);
    }
    if (!nullToAbsent || discountScope != null) {
      map['discount_scope'] = Variable<String>(discountScope);
    }
    if (!nullToAbsent || minOrderAmount != null) {
      map['min_order_amount'] = Variable<int>(minOrderAmount);
    }
    if (!nullToAbsent || giftProductId != null) {
      map['gift_product_id'] = Variable<String>(giftProductId);
    }
    map['expiry_days'] = Variable<String>(expiryDays);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CouponsCompanion toCompanion(bool nullToAbsent) {
    return CouponsCompanion(
      id: Value(id),
      code: Value(code),
      season: Value(season),
      benefitType: Value(benefitType),
      discountValue: discountValue == null && nullToAbsent
          ? const Value.absent()
          : Value(discountValue),
      discountScope: discountScope == null && nullToAbsent
          ? const Value.absent()
          : Value(discountScope),
      minOrderAmount: minOrderAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(minOrderAmount),
      giftProductId: giftProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(giftProductId),
      expiryDays: Value(expiryDays),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory CouponRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CouponRow(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      season: serializer.fromJson<String>(json['season']),
      benefitType: serializer.fromJson<String>(json['benefitType']),
      discountValue: serializer.fromJson<String?>(json['discountValue']),
      discountScope: serializer.fromJson<String?>(json['discountScope']),
      minOrderAmount: serializer.fromJson<int?>(json['minOrderAmount']),
      giftProductId: serializer.fromJson<String?>(json['giftProductId']),
      expiryDays: serializer.fromJson<String>(json['expiryDays']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'season': serializer.toJson<String>(season),
      'benefitType': serializer.toJson<String>(benefitType),
      'discountValue': serializer.toJson<String?>(discountValue),
      'discountScope': serializer.toJson<String?>(discountScope),
      'minOrderAmount': serializer.toJson<int?>(minOrderAmount),
      'giftProductId': serializer.toJson<String?>(giftProductId),
      'expiryDays': serializer.toJson<String>(expiryDays),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CouponRow copyWith({
    String? id,
    String? code,
    String? season,
    String? benefitType,
    Value<String?> discountValue = const Value.absent(),
    Value<String?> discountScope = const Value.absent(),
    Value<int?> minOrderAmount = const Value.absent(),
    Value<String?> giftProductId = const Value.absent(),
    String? expiryDays,
    String? status,
    DateTime? createdAt,
  }) => CouponRow(
    id: id ?? this.id,
    code: code ?? this.code,
    season: season ?? this.season,
    benefitType: benefitType ?? this.benefitType,
    discountValue: discountValue.present
        ? discountValue.value
        : this.discountValue,
    discountScope: discountScope.present
        ? discountScope.value
        : this.discountScope,
    minOrderAmount: minOrderAmount.present
        ? minOrderAmount.value
        : this.minOrderAmount,
    giftProductId: giftProductId.present
        ? giftProductId.value
        : this.giftProductId,
    expiryDays: expiryDays ?? this.expiryDays,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  CouponRow copyWithCompanion(CouponsCompanion data) {
    return CouponRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      season: data.season.present ? data.season.value : this.season,
      benefitType: data.benefitType.present
          ? data.benefitType.value
          : this.benefitType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      discountScope: data.discountScope.present
          ? data.discountScope.value
          : this.discountScope,
      minOrderAmount: data.minOrderAmount.present
          ? data.minOrderAmount.value
          : this.minOrderAmount,
      giftProductId: data.giftProductId.present
          ? data.giftProductId.value
          : this.giftProductId,
      expiryDays: data.expiryDays.present
          ? data.expiryDays.value
          : this.expiryDays,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CouponRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('season: $season, ')
          ..write('benefitType: $benefitType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountScope: $discountScope, ')
          ..write('minOrderAmount: $minOrderAmount, ')
          ..write('giftProductId: $giftProductId, ')
          ..write('expiryDays: $expiryDays, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    season,
    benefitType,
    discountValue,
    discountScope,
    minOrderAmount,
    giftProductId,
    expiryDays,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CouponRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.season == this.season &&
          other.benefitType == this.benefitType &&
          other.discountValue == this.discountValue &&
          other.discountScope == this.discountScope &&
          other.minOrderAmount == this.minOrderAmount &&
          other.giftProductId == this.giftProductId &&
          other.expiryDays == this.expiryDays &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class CouponsCompanion extends UpdateCompanion<CouponRow> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> season;
  final Value<String> benefitType;
  final Value<String?> discountValue;
  final Value<String?> discountScope;
  final Value<int?> minOrderAmount;
  final Value<String?> giftProductId;
  final Value<String> expiryDays;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CouponsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.season = const Value.absent(),
    this.benefitType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.discountScope = const Value.absent(),
    this.minOrderAmount = const Value.absent(),
    this.giftProductId = const Value.absent(),
    this.expiryDays = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CouponsCompanion.insert({
    required String id,
    required String code,
    required String season,
    required String benefitType,
    this.discountValue = const Value.absent(),
    this.discountScope = const Value.absent(),
    this.minOrderAmount = const Value.absent(),
    this.giftProductId = const Value.absent(),
    required String expiryDays,
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       season = Value(season),
       benefitType = Value(benefitType),
       expiryDays = Value(expiryDays),
       createdAt = Value(createdAt);
  static Insertable<CouponRow> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? season,
    Expression<String>? benefitType,
    Expression<String>? discountValue,
    Expression<String>? discountScope,
    Expression<int>? minOrderAmount,
    Expression<String>? giftProductId,
    Expression<String>? expiryDays,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (season != null) 'season': season,
      if (benefitType != null) 'benefit_type': benefitType,
      if (discountValue != null) 'discount_value': discountValue,
      if (discountScope != null) 'discount_scope': discountScope,
      if (minOrderAmount != null) 'min_order_amount': minOrderAmount,
      if (giftProductId != null) 'gift_product_id': giftProductId,
      if (expiryDays != null) 'expiry_days': expiryDays,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CouponsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? season,
    Value<String>? benefitType,
    Value<String?>? discountValue,
    Value<String?>? discountScope,
    Value<int?>? minOrderAmount,
    Value<String?>? giftProductId,
    Value<String>? expiryDays,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CouponsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      season: season ?? this.season,
      benefitType: benefitType ?? this.benefitType,
      discountValue: discountValue ?? this.discountValue,
      discountScope: discountScope ?? this.discountScope,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      giftProductId: giftProductId ?? this.giftProductId,
      expiryDays: expiryDays ?? this.expiryDays,
      status: status ?? this.status,
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
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (benefitType.present) {
      map['benefit_type'] = Variable<String>(benefitType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<String>(discountValue.value);
    }
    if (discountScope.present) {
      map['discount_scope'] = Variable<String>(discountScope.value);
    }
    if (minOrderAmount.present) {
      map['min_order_amount'] = Variable<int>(minOrderAmount.value);
    }
    if (giftProductId.present) {
      map['gift_product_id'] = Variable<String>(giftProductId.value);
    }
    if (expiryDays.present) {
      map['expiry_days'] = Variable<String>(expiryDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('CouponsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('season: $season, ')
          ..write('benefitType: $benefitType, ')
          ..write('discountValue: $discountValue, ')
          ..write('discountScope: $discountScope, ')
          ..write('minOrderAmount: $minOrderAmount, ')
          ..write('giftProductId: $giftProductId, ')
          ..write('expiryDays: $expiryDays, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignsTable extends Campaigns
    with TableInfo<$CampaignsTable, CampaignRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionTypeMeta = const VerificationMeta(
    'conditionType',
  );
  @override
  late final GeneratedColumn<String> conditionType = GeneratedColumn<String>(
    'condition_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountValueMeta = const VerificationMeta(
    'discountValue',
  );
  @override
  late final GeneratedColumn<String> discountValue = GeneratedColumn<String>(
    'discount_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    conditionType,
    discountValue,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<CampaignRow> instance, {
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
    if (data.containsKey('condition_type')) {
      context.handle(
        _conditionTypeMeta,
        conditionType.isAcceptableOrUnknown(
          data['condition_type']!,
          _conditionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionTypeMeta);
    }
    if (data.containsKey('discount_value')) {
      context.handle(
        _discountValueMeta,
        discountValue.isAcceptableOrUnknown(
          data['discount_value']!,
          _discountValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountValueMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CampaignRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaignRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      conditionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_type'],
      )!,
      discountValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discount_value'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $CampaignsTable createAlias(String alias) {
    return $CampaignsTable(attachedDatabase, alias);
  }
}

class CampaignRow extends DataClass implements Insertable<CampaignRow> {
  final String id;
  final String name;
  final String conditionType;
  final String discountValue;
  final bool enabled;
  const CampaignRow({
    required this.id,
    required this.name,
    required this.conditionType,
    required this.discountValue,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['condition_type'] = Variable<String>(conditionType);
    map['discount_value'] = Variable<String>(discountValue);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  CampaignsCompanion toCompanion(bool nullToAbsent) {
    return CampaignsCompanion(
      id: Value(id),
      name: Value(name),
      conditionType: Value(conditionType),
      discountValue: Value(discountValue),
      enabled: Value(enabled),
    );
  }

  factory CampaignRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      conditionType: serializer.fromJson<String>(json['conditionType']),
      discountValue: serializer.fromJson<String>(json['discountValue']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'conditionType': serializer.toJson<String>(conditionType),
      'discountValue': serializer.toJson<String>(discountValue),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  CampaignRow copyWith({
    String? id,
    String? name,
    String? conditionType,
    String? discountValue,
    bool? enabled,
  }) => CampaignRow(
    id: id ?? this.id,
    name: name ?? this.name,
    conditionType: conditionType ?? this.conditionType,
    discountValue: discountValue ?? this.discountValue,
    enabled: enabled ?? this.enabled,
  );
  CampaignRow copyWithCompanion(CampaignsCompanion data) {
    return CampaignRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      conditionType: data.conditionType.present
          ? data.conditionType.value
          : this.conditionType,
      discountValue: data.discountValue.present
          ? data.discountValue.value
          : this.discountValue,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('conditionType: $conditionType, ')
          ..write('discountValue: $discountValue, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, conditionType, discountValue, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.conditionType == this.conditionType &&
          other.discountValue == this.discountValue &&
          other.enabled == this.enabled);
}

class CampaignsCompanion extends UpdateCompanion<CampaignRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> conditionType;
  final Value<String> discountValue;
  final Value<bool> enabled;
  final Value<int> rowid;
  const CampaignsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.conditionType = const Value.absent(),
    this.discountValue = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsCompanion.insert({
    required String id,
    required String name,
    required String conditionType,
    required String discountValue,
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       conditionType = Value(conditionType),
       discountValue = Value(discountValue);
  static Insertable<CampaignRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? conditionType,
    Expression<String>? discountValue,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (conditionType != null) 'condition_type': conditionType,
      if (discountValue != null) 'discount_value': discountValue,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? conditionType,
    Value<String>? discountValue,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return CampaignsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      conditionType: conditionType ?? this.conditionType,
      discountValue: discountValue ?? this.discountValue,
      enabled: enabled ?? this.enabled,
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
    if (conditionType.present) {
      map['condition_type'] = Variable<String>(conditionType.value);
    }
    if (discountValue.present) {
      map['discount_value'] = Variable<String>(discountValue.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('conditionType: $conditionType, ')
          ..write('discountValue: $discountValue, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PointPoliciesTable extends PointPolicies
    with TableInfo<$PointPoliciesTable, PointPolicyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointPoliciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _earnRateMeta = const VerificationMeta(
    'earnRate',
  );
  @override
  late final GeneratedColumn<double> earnRate = GeneratedColumn<double>(
    'earn_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minUsablePointsMeta = const VerificationMeta(
    'minUsablePoints',
  );
  @override
  late final GeneratedColumn<int> minUsablePoints = GeneratedColumn<int>(
    'min_usable_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _earnScopeMeta = const VerificationMeta(
    'earnScope',
  );
  @override
  late final GeneratedColumn<String> earnScope = GeneratedColumn<String>(
    'earn_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _useScopeMeta = const VerificationMeta(
    'useScope',
  );
  @override
  late final GeneratedColumn<String> useScope = GeneratedColumn<String>(
    'use_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _pointValueYenMeta = const VerificationMeta(
    'pointValueYen',
  );
  @override
  late final GeneratedColumn<double> pointValueYen = GeneratedColumn<double>(
    'point_value_yen',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _expiryDaysMeta = const VerificationMeta(
    'expiryDays',
  );
  @override
  late final GeneratedColumn<int> expiryDays = GeneratedColumn<int>(
    'expiry_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    enabled,
    earnRate,
    minUsablePoints,
    earnScope,
    useScope,
    pointValueYen,
    expiryDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'point_policies';
  @override
  VerificationContext validateIntegrity(
    Insertable<PointPolicyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('earn_rate')) {
      context.handle(
        _earnRateMeta,
        earnRate.isAcceptableOrUnknown(data['earn_rate']!, _earnRateMeta),
      );
    }
    if (data.containsKey('min_usable_points')) {
      context.handle(
        _minUsablePointsMeta,
        minUsablePoints.isAcceptableOrUnknown(
          data['min_usable_points']!,
          _minUsablePointsMeta,
        ),
      );
    }
    if (data.containsKey('earn_scope')) {
      context.handle(
        _earnScopeMeta,
        earnScope.isAcceptableOrUnknown(data['earn_scope']!, _earnScopeMeta),
      );
    }
    if (data.containsKey('use_scope')) {
      context.handle(
        _useScopeMeta,
        useScope.isAcceptableOrUnknown(data['use_scope']!, _useScopeMeta),
      );
    }
    if (data.containsKey('point_value_yen')) {
      context.handle(
        _pointValueYenMeta,
        pointValueYen.isAcceptableOrUnknown(
          data['point_value_yen']!,
          _pointValueYenMeta,
        ),
      );
    }
    if (data.containsKey('expiry_days')) {
      context.handle(
        _expiryDaysMeta,
        expiryDays.isAcceptableOrUnknown(data['expiry_days']!, _expiryDaysMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointPolicyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointPolicyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      earnRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}earn_rate'],
      )!,
      minUsablePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_usable_points'],
      )!,
      earnScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}earn_scope'],
      )!,
      useScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}use_scope'],
      )!,
      pointValueYen: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}point_value_yen'],
      )!,
      expiryDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiry_days'],
      ),
    );
  }

  @override
  $PointPoliciesTable createAlias(String alias) {
    return $PointPoliciesTable(attachedDatabase, alias);
  }
}

class PointPolicyRow extends DataClass implements Insertable<PointPolicyRow> {
  final String id;
  final bool enabled;
  final double earnRate;
  final int minUsablePoints;

  /// all / exclude_some.
  final String earnScope;
  final String useScope;

  /// 보너스(プレシャ参考) — 토스 기본화면에 없는 보조정보.
  final double pointValueYen;
  final int? expiryDays;
  const PointPolicyRow({
    required this.id,
    required this.enabled,
    required this.earnRate,
    required this.minUsablePoints,
    required this.earnScope,
    required this.useScope,
    required this.pointValueYen,
    this.expiryDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['enabled'] = Variable<bool>(enabled);
    map['earn_rate'] = Variable<double>(earnRate);
    map['min_usable_points'] = Variable<int>(minUsablePoints);
    map['earn_scope'] = Variable<String>(earnScope);
    map['use_scope'] = Variable<String>(useScope);
    map['point_value_yen'] = Variable<double>(pointValueYen);
    if (!nullToAbsent || expiryDays != null) {
      map['expiry_days'] = Variable<int>(expiryDays);
    }
    return map;
  }

  PointPoliciesCompanion toCompanion(bool nullToAbsent) {
    return PointPoliciesCompanion(
      id: Value(id),
      enabled: Value(enabled),
      earnRate: Value(earnRate),
      minUsablePoints: Value(minUsablePoints),
      earnScope: Value(earnScope),
      useScope: Value(useScope),
      pointValueYen: Value(pointValueYen),
      expiryDays: expiryDays == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDays),
    );
  }

  factory PointPolicyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointPolicyRow(
      id: serializer.fromJson<String>(json['id']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      earnRate: serializer.fromJson<double>(json['earnRate']),
      minUsablePoints: serializer.fromJson<int>(json['minUsablePoints']),
      earnScope: serializer.fromJson<String>(json['earnScope']),
      useScope: serializer.fromJson<String>(json['useScope']),
      pointValueYen: serializer.fromJson<double>(json['pointValueYen']),
      expiryDays: serializer.fromJson<int?>(json['expiryDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'enabled': serializer.toJson<bool>(enabled),
      'earnRate': serializer.toJson<double>(earnRate),
      'minUsablePoints': serializer.toJson<int>(minUsablePoints),
      'earnScope': serializer.toJson<String>(earnScope),
      'useScope': serializer.toJson<String>(useScope),
      'pointValueYen': serializer.toJson<double>(pointValueYen),
      'expiryDays': serializer.toJson<int?>(expiryDays),
    };
  }

  PointPolicyRow copyWith({
    String? id,
    bool? enabled,
    double? earnRate,
    int? minUsablePoints,
    String? earnScope,
    String? useScope,
    double? pointValueYen,
    Value<int?> expiryDays = const Value.absent(),
  }) => PointPolicyRow(
    id: id ?? this.id,
    enabled: enabled ?? this.enabled,
    earnRate: earnRate ?? this.earnRate,
    minUsablePoints: minUsablePoints ?? this.minUsablePoints,
    earnScope: earnScope ?? this.earnScope,
    useScope: useScope ?? this.useScope,
    pointValueYen: pointValueYen ?? this.pointValueYen,
    expiryDays: expiryDays.present ? expiryDays.value : this.expiryDays,
  );
  PointPolicyRow copyWithCompanion(PointPoliciesCompanion data) {
    return PointPolicyRow(
      id: data.id.present ? data.id.value : this.id,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      earnRate: data.earnRate.present ? data.earnRate.value : this.earnRate,
      minUsablePoints: data.minUsablePoints.present
          ? data.minUsablePoints.value
          : this.minUsablePoints,
      earnScope: data.earnScope.present ? data.earnScope.value : this.earnScope,
      useScope: data.useScope.present ? data.useScope.value : this.useScope,
      pointValueYen: data.pointValueYen.present
          ? data.pointValueYen.value
          : this.pointValueYen,
      expiryDays: data.expiryDays.present
          ? data.expiryDays.value
          : this.expiryDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointPolicyRow(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('earnRate: $earnRate, ')
          ..write('minUsablePoints: $minUsablePoints, ')
          ..write('earnScope: $earnScope, ')
          ..write('useScope: $useScope, ')
          ..write('pointValueYen: $pointValueYen, ')
          ..write('expiryDays: $expiryDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    enabled,
    earnRate,
    minUsablePoints,
    earnScope,
    useScope,
    pointValueYen,
    expiryDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointPolicyRow &&
          other.id == this.id &&
          other.enabled == this.enabled &&
          other.earnRate == this.earnRate &&
          other.minUsablePoints == this.minUsablePoints &&
          other.earnScope == this.earnScope &&
          other.useScope == this.useScope &&
          other.pointValueYen == this.pointValueYen &&
          other.expiryDays == this.expiryDays);
}

class PointPoliciesCompanion extends UpdateCompanion<PointPolicyRow> {
  final Value<String> id;
  final Value<bool> enabled;
  final Value<double> earnRate;
  final Value<int> minUsablePoints;
  final Value<String> earnScope;
  final Value<String> useScope;
  final Value<double> pointValueYen;
  final Value<int?> expiryDays;
  final Value<int> rowid;
  const PointPoliciesCompanion({
    this.id = const Value.absent(),
    this.enabled = const Value.absent(),
    this.earnRate = const Value.absent(),
    this.minUsablePoints = const Value.absent(),
    this.earnScope = const Value.absent(),
    this.useScope = const Value.absent(),
    this.pointValueYen = const Value.absent(),
    this.expiryDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PointPoliciesCompanion.insert({
    required String id,
    this.enabled = const Value.absent(),
    this.earnRate = const Value.absent(),
    this.minUsablePoints = const Value.absent(),
    this.earnScope = const Value.absent(),
    this.useScope = const Value.absent(),
    this.pointValueYen = const Value.absent(),
    this.expiryDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<PointPolicyRow> custom({
    Expression<String>? id,
    Expression<bool>? enabled,
    Expression<double>? earnRate,
    Expression<int>? minUsablePoints,
    Expression<String>? earnScope,
    Expression<String>? useScope,
    Expression<double>? pointValueYen,
    Expression<int>? expiryDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (enabled != null) 'enabled': enabled,
      if (earnRate != null) 'earn_rate': earnRate,
      if (minUsablePoints != null) 'min_usable_points': minUsablePoints,
      if (earnScope != null) 'earn_scope': earnScope,
      if (useScope != null) 'use_scope': useScope,
      if (pointValueYen != null) 'point_value_yen': pointValueYen,
      if (expiryDays != null) 'expiry_days': expiryDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PointPoliciesCompanion copyWith({
    Value<String>? id,
    Value<bool>? enabled,
    Value<double>? earnRate,
    Value<int>? minUsablePoints,
    Value<String>? earnScope,
    Value<String>? useScope,
    Value<double>? pointValueYen,
    Value<int?>? expiryDays,
    Value<int>? rowid,
  }) {
    return PointPoliciesCompanion(
      id: id ?? this.id,
      enabled: enabled ?? this.enabled,
      earnRate: earnRate ?? this.earnRate,
      minUsablePoints: minUsablePoints ?? this.minUsablePoints,
      earnScope: earnScope ?? this.earnScope,
      useScope: useScope ?? this.useScope,
      pointValueYen: pointValueYen ?? this.pointValueYen,
      expiryDays: expiryDays ?? this.expiryDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (earnRate.present) {
      map['earn_rate'] = Variable<double>(earnRate.value);
    }
    if (minUsablePoints.present) {
      map['min_usable_points'] = Variable<int>(minUsablePoints.value);
    }
    if (earnScope.present) {
      map['earn_scope'] = Variable<String>(earnScope.value);
    }
    if (useScope.present) {
      map['use_scope'] = Variable<String>(useScope.value);
    }
    if (pointValueYen.present) {
      map['point_value_yen'] = Variable<double>(pointValueYen.value);
    }
    if (expiryDays.present) {
      map['expiry_days'] = Variable<int>(expiryDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointPoliciesCompanion(')
          ..write('id: $id, ')
          ..write('enabled: $enabled, ')
          ..write('earnRate: $earnRate, ')
          ..write('minUsablePoints: $minUsablePoints, ')
          ..write('earnScope: $earnScope, ')
          ..write('useScope: $useScope, ')
          ..write('pointValueYen: $pointValueYen, ')
          ..write('expiryDays: $expiryDays, ')
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
  late final $BookingsTable bookings = $BookingsTable(this);
  late final $WaitingEntriesTable waitingEntries = $WaitingEntriesTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $PrepaidPassMenusTable prepaidPassMenus = $PrepaidPassMenusTable(
    this,
  );
  late final $PrepaidPassBalancesTable prepaidPassBalances =
      $PrepaidPassBalancesTable(this);
  late final $PrepaidPassTransactionsTable prepaidPassTransactions =
      $PrepaidPassTransactionsTable(this);
  late final $CouponsTable coupons = $CouponsTable(this);
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $PointPoliciesTable pointPolicies = $PointPoliciesTable(this);
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
    bookings,
    waitingEntries,
    orders,
    orderItems,
    payments,
    prepaidPassMenus,
    prepaidPassBalances,
    prepaidPassTransactions,
    coupons,
    campaigns,
    pointPolicies,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('order_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'orders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('payments', kind: UpdateKind.delete)],
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
typedef $$BookingsTableCreateCompanionBuilder =
    BookingsCompanion Function({
      required String id,
      required String customerId,
      Value<String?> staffId,
      Value<String> productIdsCsv,
      required DateTime startAt,
      required DateTime endAt,
      Value<bool> depositEnabled,
      Value<String?> depositMethod,
      Value<int?> depositAmount,
      Value<bool> depositReceived,
      Value<bool> depositRefunded,
      Value<String> refundNote,
      Value<String> repeatRule,
      Value<String?> memo,
      Value<bool> requiresApproval,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$BookingsTableUpdateCompanionBuilder =
    BookingsCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String?> staffId,
      Value<String> productIdsCsv,
      Value<DateTime> startAt,
      Value<DateTime> endAt,
      Value<bool> depositEnabled,
      Value<String?> depositMethod,
      Value<int?> depositAmount,
      Value<bool> depositReceived,
      Value<bool> depositRefunded,
      Value<String> refundNote,
      Value<String> repeatRule,
      Value<String?> memo,
      Value<bool> requiresApproval,
      Value<String> status,
      Value<int> rowid,
    });

class $$BookingsTableFilterComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableFilterComposer({
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

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productIdsCsv => $composableBuilder(
    column: $table.productIdsCsv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get depositEnabled => $composableBuilder(
    column: $table.depositEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get depositMethod => $composableBuilder(
    column: $table.depositMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depositAmount => $composableBuilder(
    column: $table.depositAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get depositReceived => $composableBuilder(
    column: $table.depositReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get depositRefunded => $composableBuilder(
    column: $table.depositRefunded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refundNote => $composableBuilder(
    column: $table.refundNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresApproval => $composableBuilder(
    column: $table.requiresApproval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableOrderingComposer({
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

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productIdsCsv => $composableBuilder(
    column: $table.productIdsCsv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get depositEnabled => $composableBuilder(
    column: $table.depositEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get depositMethod => $composableBuilder(
    column: $table.depositMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depositAmount => $composableBuilder(
    column: $table.depositAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get depositReceived => $composableBuilder(
    column: $table.depositReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get depositRefunded => $composableBuilder(
    column: $table.depositRefunded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refundNote => $composableBuilder(
    column: $table.refundNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresApproval => $composableBuilder(
    column: $table.requiresApproval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingsTable> {
  $$BookingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  GeneratedColumn<String> get productIdsCsv => $composableBuilder(
    column: $table.productIdsCsv,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<bool> get depositEnabled => $composableBuilder(
    column: $table.depositEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get depositMethod => $composableBuilder(
    column: $table.depositMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get depositAmount => $composableBuilder(
    column: $table.depositAmount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get depositReceived => $composableBuilder(
    column: $table.depositReceived,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get depositRefunded => $composableBuilder(
    column: $table.depositRefunded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get refundNote => $composableBuilder(
    column: $table.refundNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<bool> get requiresApproval => $composableBuilder(
    column: $table.requiresApproval,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$BookingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingsTable,
          BookingRow,
          $$BookingsTableFilterComposer,
          $$BookingsTableOrderingComposer,
          $$BookingsTableAnnotationComposer,
          $$BookingsTableCreateCompanionBuilder,
          $$BookingsTableUpdateCompanionBuilder,
          (
            BookingRow,
            BaseReferences<_$AppDatabase, $BookingsTable, BookingRow>,
          ),
          BookingRow,
          PrefetchHooks Function()
        > {
  $$BookingsTableTableManager(_$AppDatabase db, $BookingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<String> productIdsCsv = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime> endAt = const Value.absent(),
                Value<bool> depositEnabled = const Value.absent(),
                Value<String?> depositMethod = const Value.absent(),
                Value<int?> depositAmount = const Value.absent(),
                Value<bool> depositReceived = const Value.absent(),
                Value<bool> depositRefunded = const Value.absent(),
                Value<String> refundNote = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<bool> requiresApproval = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsCompanion(
                id: id,
                customerId: customerId,
                staffId: staffId,
                productIdsCsv: productIdsCsv,
                startAt: startAt,
                endAt: endAt,
                depositEnabled: depositEnabled,
                depositMethod: depositMethod,
                depositAmount: depositAmount,
                depositReceived: depositReceived,
                depositRefunded: depositRefunded,
                refundNote: refundNote,
                repeatRule: repeatRule,
                memo: memo,
                requiresApproval: requiresApproval,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                Value<String?> staffId = const Value.absent(),
                Value<String> productIdsCsv = const Value.absent(),
                required DateTime startAt,
                required DateTime endAt,
                Value<bool> depositEnabled = const Value.absent(),
                Value<String?> depositMethod = const Value.absent(),
                Value<int?> depositAmount = const Value.absent(),
                Value<bool> depositReceived = const Value.absent(),
                Value<bool> depositRefunded = const Value.absent(),
                Value<String> refundNote = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<bool> requiresApproval = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsCompanion.insert(
                id: id,
                customerId: customerId,
                staffId: staffId,
                productIdsCsv: productIdsCsv,
                startAt: startAt,
                endAt: endAt,
                depositEnabled: depositEnabled,
                depositMethod: depositMethod,
                depositAmount: depositAmount,
                depositReceived: depositReceived,
                depositRefunded: depositRefunded,
                refundNote: refundNote,
                repeatRule: repeatRule,
                memo: memo,
                requiresApproval: requiresApproval,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingsTable,
      BookingRow,
      $$BookingsTableFilterComposer,
      $$BookingsTableOrderingComposer,
      $$BookingsTableAnnotationComposer,
      $$BookingsTableCreateCompanionBuilder,
      $$BookingsTableUpdateCompanionBuilder,
      (BookingRow, BaseReferences<_$AppDatabase, $BookingsTable, BookingRow>),
      BookingRow,
      PrefetchHooks Function()
    >;
typedef $$WaitingEntriesTableCreateCompanionBuilder =
    WaitingEntriesCompanion Function({
      required String id,
      required String customerName,
      Value<String?> phone,
      Value<String?> menuNote,
      Value<String?> preferredStaffId,
      required DateTime checkInAt,
      required int sortOrder,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$WaitingEntriesTableUpdateCompanionBuilder =
    WaitingEntriesCompanion Function({
      Value<String> id,
      Value<String> customerName,
      Value<String?> phone,
      Value<String?> menuNote,
      Value<String?> preferredStaffId,
      Value<DateTime> checkInAt,
      Value<int> sortOrder,
      Value<String> status,
      Value<int> rowid,
    });

class $$WaitingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WaitingEntriesTable> {
  $$WaitingEntriesTableFilterComposer({
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

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get menuNote => $composableBuilder(
    column: $table.menuNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredStaffId => $composableBuilder(
    column: $table.preferredStaffId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkInAt => $composableBuilder(
    column: $table.checkInAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaitingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WaitingEntriesTable> {
  $$WaitingEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get menuNote => $composableBuilder(
    column: $table.menuNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredStaffId => $composableBuilder(
    column: $table.preferredStaffId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkInAt => $composableBuilder(
    column: $table.checkInAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaitingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaitingEntriesTable> {
  $$WaitingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get menuNote =>
      $composableBuilder(column: $table.menuNote, builder: (column) => column);

  GeneratedColumn<String> get preferredStaffId => $composableBuilder(
    column: $table.preferredStaffId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get checkInAt =>
      $composableBuilder(column: $table.checkInAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$WaitingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaitingEntriesTable,
          WaitingEntryRow,
          $$WaitingEntriesTableFilterComposer,
          $$WaitingEntriesTableOrderingComposer,
          $$WaitingEntriesTableAnnotationComposer,
          $$WaitingEntriesTableCreateCompanionBuilder,
          $$WaitingEntriesTableUpdateCompanionBuilder,
          (
            WaitingEntryRow,
            BaseReferences<
              _$AppDatabase,
              $WaitingEntriesTable,
              WaitingEntryRow
            >,
          ),
          WaitingEntryRow,
          PrefetchHooks Function()
        > {
  $$WaitingEntriesTableTableManager(
    _$AppDatabase db,
    $WaitingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaitingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaitingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaitingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> menuNote = const Value.absent(),
                Value<String?> preferredStaffId = const Value.absent(),
                Value<DateTime> checkInAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaitingEntriesCompanion(
                id: id,
                customerName: customerName,
                phone: phone,
                menuNote: menuNote,
                preferredStaffId: preferredStaffId,
                checkInAt: checkInAt,
                sortOrder: sortOrder,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerName,
                Value<String?> phone = const Value.absent(),
                Value<String?> menuNote = const Value.absent(),
                Value<String?> preferredStaffId = const Value.absent(),
                required DateTime checkInAt,
                required int sortOrder,
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaitingEntriesCompanion.insert(
                id: id,
                customerName: customerName,
                phone: phone,
                menuNote: menuNote,
                preferredStaffId: preferredStaffId,
                checkInAt: checkInAt,
                sortOrder: sortOrder,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaitingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaitingEntriesTable,
      WaitingEntryRow,
      $$WaitingEntriesTableFilterComposer,
      $$WaitingEntriesTableOrderingComposer,
      $$WaitingEntriesTableAnnotationComposer,
      $$WaitingEntriesTableCreateCompanionBuilder,
      $$WaitingEntriesTableUpdateCompanionBuilder,
      (
        WaitingEntryRow,
        BaseReferences<_$AppDatabase, $WaitingEntriesTable, WaitingEntryRow>,
      ),
      WaitingEntryRow,
      PrefetchHooks Function()
    >;
typedef $$OrdersTableCreateCompanionBuilder =
    OrdersCompanion Function({
      required String id,
      Value<String?> customerId,
      required int totalAmount,
      Value<int> discountAmount,
      Value<int> pointsUsed,
      Value<String> prepaidUsedJson,
      Value<String> status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$OrdersTableUpdateCompanionBuilder =
    OrdersCompanion Function({
      Value<String> id,
      Value<String?> customerId,
      Value<int> totalAmount,
      Value<int> discountAmount,
      Value<int> pointsUsed,
      Value<String> prepaidUsedJson,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, OrderRow> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrderItemsTable, List<OrderItemRow>>
  _orderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orderItems,
    aliasName: 'orders__id__order_items__order_id',
  );

  $$OrderItemsTableProcessedTableManager get orderItemsRefs {
    final manager = $$OrderItemsTableTableManager(
      $_db,
      $_db.orderItems,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_orderItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'orders__id__payments__order_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
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

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsUsed => $composableBuilder(
    column: $table.pointsUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prepaidUsedJson => $composableBuilder(
    column: $table.prepaidUsedJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> orderItemsRefs(
    Expression<bool> Function($$OrderItemsTableFilterComposer f) f,
  ) {
    final $$OrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
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

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsUsed => $composableBuilder(
    column: $table.pointsUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prepaidUsedJson => $composableBuilder(
    column: $table.prepaidUsedJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointsUsed => $composableBuilder(
    column: $table.pointsUsed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prepaidUsedJson => $composableBuilder(
    column: $table.prepaidUsedJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> orderItemsRefs<T extends Object>(
    Expression<T> Function($$OrderItemsTableAnnotationComposer a) f,
  ) {
    final $$OrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orderItems,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.orderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          OrderRow,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (OrderRow, $$OrdersTableReferences),
          OrderRow,
          PrefetchHooks Function({bool orderItemsRefs, bool paymentsRefs})
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<int> totalAmount = const Value.absent(),
                Value<int> discountAmount = const Value.absent(),
                Value<int> pointsUsed = const Value.absent(),
                Value<String> prepaidUsedJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                customerId: customerId,
                totalAmount: totalAmount,
                discountAmount: discountAmount,
                pointsUsed: pointsUsed,
                prepaidUsedJson: prepaidUsedJson,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> customerId = const Value.absent(),
                required int totalAmount,
                Value<int> discountAmount = const Value.absent(),
                Value<int> pointsUsed = const Value.absent(),
                Value<String> prepaidUsedJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                customerId: customerId,
                totalAmount: totalAmount,
                discountAmount: discountAmount,
                pointsUsed: pointsUsed,
                prepaidUsedJson: prepaidUsedJson,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$OrdersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({orderItemsRefs = false, paymentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (orderItemsRefs) db.orderItems,
                    if (paymentsRefs) db.payments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (orderItemsRefs)
                        await $_getPrefetchedData<
                          OrderRow,
                          $OrdersTable,
                          OrderItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._orderItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).orderItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedData<
                          OrderRow,
                          $OrdersTable,
                          PaymentRow
                        >(
                          currentTable: table,
                          referencedTable: $$OrdersTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrdersTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.orderId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      OrderRow,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (OrderRow, $$OrdersTableReferences),
      OrderRow,
      PrefetchHooks Function({bool orderItemsRefs, bool paymentsRefs})
    >;
typedef $$OrderItemsTableCreateCompanionBuilder =
    OrderItemsCompanion Function({
      required String id,
      required String orderId,
      required String productId,
      required String productName,
      required int quantity,
      required int unitPrice,
      Value<String?> staffId,
      Value<int> rowid,
    });
typedef $$OrderItemsTableUpdateCompanionBuilder =
    OrderItemsCompanion Function({
      Value<String> id,
      Value<String> orderId,
      Value<String> productId,
      Value<String> productName,
      Value<int> quantity,
      Value<int> unitPrice,
      Value<String?> staffId,
      Value<int> rowid,
    });

final class $$OrderItemsTableReferences
    extends BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItemRow> {
  $$OrderItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('order_items__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
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

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
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

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get staffId => $composableBuilder(
    column: $table.staffId,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<String> get staffId =>
      $composableBuilder(column: $table.staffId, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrderItemsTable,
          OrderItemRow,
          $$OrderItemsTableFilterComposer,
          $$OrderItemsTableOrderingComposer,
          $$OrderItemsTableAnnotationComposer,
          $$OrderItemsTableCreateCompanionBuilder,
          $$OrderItemsTableUpdateCompanionBuilder,
          (OrderItemRow, $$OrderItemsTableReferences),
          OrderItemRow,
          PrefetchHooks Function({bool orderId})
        > {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
                Value<String?> staffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion(
                id: id,
                orderId: orderId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                staffId: staffId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                required String productId,
                required String productName,
                required int quantity,
                required int unitPrice,
                Value<String?> staffId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrderItemsCompanion.insert(
                id: id,
                orderId: orderId,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                staffId: staffId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrderItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
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
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$OrderItemsTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$OrderItemsTableReferences
                                    ._orderIdTable(db)
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

typedef $$OrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrderItemsTable,
      OrderItemRow,
      $$OrderItemsTableFilterComposer,
      $$OrderItemsTableOrderingComposer,
      $$OrderItemsTableAnnotationComposer,
      $$OrderItemsTableCreateCompanionBuilder,
      $$OrderItemsTableUpdateCompanionBuilder,
      (OrderItemRow, $$OrderItemsTableReferences),
      OrderItemRow,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String id,
      required String orderId,
      required String method,
      required int amount,
      Value<String?> splitType,
      Value<int?> cashReceived,
      Value<int?> cashChange,
      Value<String?> prepaidBalanceId,
      Value<String> status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> id,
      Value<String> orderId,
      Value<String> method,
      Value<int> amount,
      Value<String?> splitType,
      Value<int?> cashReceived,
      Value<int?> cashChange,
      Value<String?> prepaidBalanceId,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) =>
      db.orders.createAlias('payments__order_id__orders__id');

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$OrdersTableTableManager(
      $_db,
      $_db.orders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splitType => $composableBuilder(
    column: $table.splitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashReceived => $composableBuilder(
    column: $table.cashReceived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashChange => $composableBuilder(
    column: $table.cashChange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prepaidBalanceId => $composableBuilder(
    column: $table.prepaidBalanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableFilterComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitType => $composableBuilder(
    column: $table.splitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashReceived => $composableBuilder(
    column: $table.cashReceived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashChange => $composableBuilder(
    column: $table.cashChange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prepaidBalanceId => $composableBuilder(
    column: $table.prepaidBalanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableOrderingComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get splitType =>
      $composableBuilder(column: $table.splitType, builder: (column) => column);

  GeneratedColumn<int> get cashReceived => $composableBuilder(
    column: $table.cashReceived,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cashChange => $composableBuilder(
    column: $table.cashChange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prepaidBalanceId => $composableBuilder(
    column: $table.prepaidBalanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.orders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.orders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool orderId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> splitType = const Value.absent(),
                Value<int?> cashReceived = const Value.absent(),
                Value<int?> cashChange = const Value.absent(),
                Value<String?> prepaidBalanceId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                orderId: orderId,
                method: method,
                amount: amount,
                splitType: splitType,
                cashReceived: cashReceived,
                cashChange: cashChange,
                prepaidBalanceId: prepaidBalanceId,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                required String method,
                required int amount,
                Value<String?> splitType = const Value.absent(),
                Value<int?> cashReceived = const Value.absent(),
                Value<int?> cashChange = const Value.absent(),
                Value<String?> prepaidBalanceId = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                orderId: orderId,
                method: method,
                amount: amount,
                splitType: splitType,
                cashReceived: cashReceived,
                cashChange: cashChange,
                prepaidBalanceId: prepaidBalanceId,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
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
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable: $$PaymentsTableReferences
                                    ._orderIdTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._orderIdTable(db)
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$PrepaidPassMenusTableCreateCompanionBuilder =
    PrepaidPassMenusCompanion Function({
      required String id,
      required String type,
      required String name,
      Value<String?> linkedProductId,
      required int price,
      Value<bool> allowCustomPrice,
      Value<int?> countPerPurchase,
      Value<String> bonusType,
      Value<int?> bonusAmount,
      Value<int?> bonusCount,
      Value<String> expiryType,
      Value<int?> expiryCustomDays,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$PrepaidPassMenusTableUpdateCompanionBuilder =
    PrepaidPassMenusCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> name,
      Value<String?> linkedProductId,
      Value<int> price,
      Value<bool> allowCustomPrice,
      Value<int?> countPerPurchase,
      Value<String> bonusType,
      Value<int?> bonusAmount,
      Value<int?> bonusCount,
      Value<String> expiryType,
      Value<int?> expiryCustomDays,
      Value<String> status,
      Value<int> rowid,
    });

class $$PrepaidPassMenusTableFilterComposer
    extends Composer<_$AppDatabase, $PrepaidPassMenusTable> {
  $$PrepaidPassMenusTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedProductId => $composableBuilder(
    column: $table.linkedProductId,
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

  ColumnFilters<int> get countPerPurchase => $composableBuilder(
    column: $table.countPerPurchase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bonusType => $composableBuilder(
    column: $table.bonusType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusCount => $composableBuilder(
    column: $table.bonusCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiryType => $composableBuilder(
    column: $table.expiryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiryCustomDays => $composableBuilder(
    column: $table.expiryCustomDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrepaidPassMenusTableOrderingComposer
    extends Composer<_$AppDatabase, $PrepaidPassMenusTable> {
  $$PrepaidPassMenusTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedProductId => $composableBuilder(
    column: $table.linkedProductId,
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

  ColumnOrderings<int> get countPerPurchase => $composableBuilder(
    column: $table.countPerPurchase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bonusType => $composableBuilder(
    column: $table.bonusType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusCount => $composableBuilder(
    column: $table.bonusCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryType => $composableBuilder(
    column: $table.expiryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiryCustomDays => $composableBuilder(
    column: $table.expiryCustomDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrepaidPassMenusTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrepaidPassMenusTable> {
  $$PrepaidPassMenusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get linkedProductId => $composableBuilder(
    column: $table.linkedProductId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<bool> get allowCustomPrice => $composableBuilder(
    column: $table.allowCustomPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countPerPurchase => $composableBuilder(
    column: $table.countPerPurchase,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bonusType =>
      $composableBuilder(column: $table.bonusType, builder: (column) => column);

  GeneratedColumn<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusCount => $composableBuilder(
    column: $table.bonusCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expiryType => $composableBuilder(
    column: $table.expiryType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiryCustomDays => $composableBuilder(
    column: $table.expiryCustomDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PrepaidPassMenusTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrepaidPassMenusTable,
          PrepaidPassMenuRow,
          $$PrepaidPassMenusTableFilterComposer,
          $$PrepaidPassMenusTableOrderingComposer,
          $$PrepaidPassMenusTableAnnotationComposer,
          $$PrepaidPassMenusTableCreateCompanionBuilder,
          $$PrepaidPassMenusTableUpdateCompanionBuilder,
          (
            PrepaidPassMenuRow,
            BaseReferences<
              _$AppDatabase,
              $PrepaidPassMenusTable,
              PrepaidPassMenuRow
            >,
          ),
          PrepaidPassMenuRow,
          PrefetchHooks Function()
        > {
  $$PrepaidPassMenusTableTableManager(
    _$AppDatabase db,
    $PrepaidPassMenusTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrepaidPassMenusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrepaidPassMenusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrepaidPassMenusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> linkedProductId = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<bool> allowCustomPrice = const Value.absent(),
                Value<int?> countPerPurchase = const Value.absent(),
                Value<String> bonusType = const Value.absent(),
                Value<int?> bonusAmount = const Value.absent(),
                Value<int?> bonusCount = const Value.absent(),
                Value<String> expiryType = const Value.absent(),
                Value<int?> expiryCustomDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrepaidPassMenusCompanion(
                id: id,
                type: type,
                name: name,
                linkedProductId: linkedProductId,
                price: price,
                allowCustomPrice: allowCustomPrice,
                countPerPurchase: countPerPurchase,
                bonusType: bonusType,
                bonusAmount: bonusAmount,
                bonusCount: bonusCount,
                expiryType: expiryType,
                expiryCustomDays: expiryCustomDays,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String name,
                Value<String?> linkedProductId = const Value.absent(),
                required int price,
                Value<bool> allowCustomPrice = const Value.absent(),
                Value<int?> countPerPurchase = const Value.absent(),
                Value<String> bonusType = const Value.absent(),
                Value<int?> bonusAmount = const Value.absent(),
                Value<int?> bonusCount = const Value.absent(),
                Value<String> expiryType = const Value.absent(),
                Value<int?> expiryCustomDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrepaidPassMenusCompanion.insert(
                id: id,
                type: type,
                name: name,
                linkedProductId: linkedProductId,
                price: price,
                allowCustomPrice: allowCustomPrice,
                countPerPurchase: countPerPurchase,
                bonusType: bonusType,
                bonusAmount: bonusAmount,
                bonusCount: bonusCount,
                expiryType: expiryType,
                expiryCustomDays: expiryCustomDays,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrepaidPassMenusTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrepaidPassMenusTable,
      PrepaidPassMenuRow,
      $$PrepaidPassMenusTableFilterComposer,
      $$PrepaidPassMenusTableOrderingComposer,
      $$PrepaidPassMenusTableAnnotationComposer,
      $$PrepaidPassMenusTableCreateCompanionBuilder,
      $$PrepaidPassMenusTableUpdateCompanionBuilder,
      (
        PrepaidPassMenuRow,
        BaseReferences<
          _$AppDatabase,
          $PrepaidPassMenusTable,
          PrepaidPassMenuRow
        >,
      ),
      PrepaidPassMenuRow,
      PrefetchHooks Function()
    >;
typedef $$PrepaidPassBalancesTableCreateCompanionBuilder =
    PrepaidPassBalancesCompanion Function({
      required String id,
      required String customerId,
      required String menuId,
      Value<int?> remainingAmount,
      Value<int?> remainingCount,
      required DateTime purchasedAt,
      Value<DateTime?> expiresAt,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$PrepaidPassBalancesTableUpdateCompanionBuilder =
    PrepaidPassBalancesCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String> menuId,
      Value<int?> remainingAmount,
      Value<int?> remainingCount,
      Value<DateTime> purchasedAt,
      Value<DateTime?> expiresAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$PrepaidPassBalancesTableFilterComposer
    extends Composer<_$AppDatabase, $PrepaidPassBalancesTable> {
  $$PrepaidPassBalancesTableFilterComposer({
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

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get menuId => $composableBuilder(
    column: $table.menuId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remainingCount => $composableBuilder(
    column: $table.remainingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrepaidPassBalancesTableOrderingComposer
    extends Composer<_$AppDatabase, $PrepaidPassBalancesTable> {
  $$PrepaidPassBalancesTableOrderingComposer({
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

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get menuId => $composableBuilder(
    column: $table.menuId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remainingCount => $composableBuilder(
    column: $table.remainingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrepaidPassBalancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrepaidPassBalancesTable> {
  $$PrepaidPassBalancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get menuId =>
      $composableBuilder(column: $table.menuId, builder: (column) => column);

  GeneratedColumn<int> get remainingAmount => $composableBuilder(
    column: $table.remainingAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remainingCount => $composableBuilder(
    column: $table.remainingCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PrepaidPassBalancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrepaidPassBalancesTable,
          PrepaidPassBalanceRow,
          $$PrepaidPassBalancesTableFilterComposer,
          $$PrepaidPassBalancesTableOrderingComposer,
          $$PrepaidPassBalancesTableAnnotationComposer,
          $$PrepaidPassBalancesTableCreateCompanionBuilder,
          $$PrepaidPassBalancesTableUpdateCompanionBuilder,
          (
            PrepaidPassBalanceRow,
            BaseReferences<
              _$AppDatabase,
              $PrepaidPassBalancesTable,
              PrepaidPassBalanceRow
            >,
          ),
          PrepaidPassBalanceRow,
          PrefetchHooks Function()
        > {
  $$PrepaidPassBalancesTableTableManager(
    _$AppDatabase db,
    $PrepaidPassBalancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrepaidPassBalancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrepaidPassBalancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PrepaidPassBalancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> menuId = const Value.absent(),
                Value<int?> remainingAmount = const Value.absent(),
                Value<int?> remainingCount = const Value.absent(),
                Value<DateTime> purchasedAt = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrepaidPassBalancesCompanion(
                id: id,
                customerId: customerId,
                menuId: menuId,
                remainingAmount: remainingAmount,
                remainingCount: remainingCount,
                purchasedAt: purchasedAt,
                expiresAt: expiresAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required String menuId,
                Value<int?> remainingAmount = const Value.absent(),
                Value<int?> remainingCount = const Value.absent(),
                required DateTime purchasedAt,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrepaidPassBalancesCompanion.insert(
                id: id,
                customerId: customerId,
                menuId: menuId,
                remainingAmount: remainingAmount,
                remainingCount: remainingCount,
                purchasedAt: purchasedAt,
                expiresAt: expiresAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrepaidPassBalancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrepaidPassBalancesTable,
      PrepaidPassBalanceRow,
      $$PrepaidPassBalancesTableFilterComposer,
      $$PrepaidPassBalancesTableOrderingComposer,
      $$PrepaidPassBalancesTableAnnotationComposer,
      $$PrepaidPassBalancesTableCreateCompanionBuilder,
      $$PrepaidPassBalancesTableUpdateCompanionBuilder,
      (
        PrepaidPassBalanceRow,
        BaseReferences<
          _$AppDatabase,
          $PrepaidPassBalancesTable,
          PrepaidPassBalanceRow
        >,
      ),
      PrepaidPassBalanceRow,
      PrefetchHooks Function()
    >;
typedef $$PrepaidPassTransactionsTableCreateCompanionBuilder =
    PrepaidPassTransactionsCompanion Function({
      required String id,
      required String balanceId,
      required String type,
      Value<int?> amount,
      Value<int?> count,
      Value<String?> relatedOrderId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PrepaidPassTransactionsTableUpdateCompanionBuilder =
    PrepaidPassTransactionsCompanion Function({
      Value<String> id,
      Value<String> balanceId,
      Value<String> type,
      Value<int?> amount,
      Value<int?> count,
      Value<String?> relatedOrderId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PrepaidPassTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $PrepaidPassTransactionsTable> {
  $$PrepaidPassTransactionsTableFilterComposer({
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

  ColumnFilters<String> get balanceId => $composableBuilder(
    column: $table.balanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedOrderId => $composableBuilder(
    column: $table.relatedOrderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrepaidPassTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrepaidPassTransactionsTable> {
  $$PrepaidPassTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get balanceId => $composableBuilder(
    column: $table.balanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedOrderId => $composableBuilder(
    column: $table.relatedOrderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrepaidPassTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrepaidPassTransactionsTable> {
  $$PrepaidPassTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get balanceId =>
      $composableBuilder(column: $table.balanceId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get relatedOrderId => $composableBuilder(
    column: $table.relatedOrderId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PrepaidPassTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrepaidPassTransactionsTable,
          PrepaidPassTransactionRow,
          $$PrepaidPassTransactionsTableFilterComposer,
          $$PrepaidPassTransactionsTableOrderingComposer,
          $$PrepaidPassTransactionsTableAnnotationComposer,
          $$PrepaidPassTransactionsTableCreateCompanionBuilder,
          $$PrepaidPassTransactionsTableUpdateCompanionBuilder,
          (
            PrepaidPassTransactionRow,
            BaseReferences<
              _$AppDatabase,
              $PrepaidPassTransactionsTable,
              PrepaidPassTransactionRow
            >,
          ),
          PrepaidPassTransactionRow,
          PrefetchHooks Function()
        > {
  $$PrepaidPassTransactionsTableTableManager(
    _$AppDatabase db,
    $PrepaidPassTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrepaidPassTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PrepaidPassTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PrepaidPassTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> balanceId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<String?> relatedOrderId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrepaidPassTransactionsCompanion(
                id: id,
                balanceId: balanceId,
                type: type,
                amount: amount,
                count: count,
                relatedOrderId: relatedOrderId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String balanceId,
                required String type,
                Value<int?> amount = const Value.absent(),
                Value<int?> count = const Value.absent(),
                Value<String?> relatedOrderId = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PrepaidPassTransactionsCompanion.insert(
                id: id,
                balanceId: balanceId,
                type: type,
                amount: amount,
                count: count,
                relatedOrderId: relatedOrderId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrepaidPassTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrepaidPassTransactionsTable,
      PrepaidPassTransactionRow,
      $$PrepaidPassTransactionsTableFilterComposer,
      $$PrepaidPassTransactionsTableOrderingComposer,
      $$PrepaidPassTransactionsTableAnnotationComposer,
      $$PrepaidPassTransactionsTableCreateCompanionBuilder,
      $$PrepaidPassTransactionsTableUpdateCompanionBuilder,
      (
        PrepaidPassTransactionRow,
        BaseReferences<
          _$AppDatabase,
          $PrepaidPassTransactionsTable,
          PrepaidPassTransactionRow
        >,
      ),
      PrepaidPassTransactionRow,
      PrefetchHooks Function()
    >;
typedef $$CouponsTableCreateCompanionBuilder =
    CouponsCompanion Function({
      required String id,
      required String code,
      required String season,
      required String benefitType,
      Value<String?> discountValue,
      Value<String?> discountScope,
      Value<int?> minOrderAmount,
      Value<String?> giftProductId,
      required String expiryDays,
      Value<String> status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CouponsTableUpdateCompanionBuilder =
    CouponsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> season,
      Value<String> benefitType,
      Value<String?> discountValue,
      Value<String?> discountScope,
      Value<int?> minOrderAmount,
      Value<String?> giftProductId,
      Value<String> expiryDays,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CouponsTableFilterComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get benefitType => $composableBuilder(
    column: $table.benefitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountScope => $composableBuilder(
    column: $table.discountScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minOrderAmount => $composableBuilder(
    column: $table.minOrderAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get giftProductId => $composableBuilder(
    column: $table.giftProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiryDays => $composableBuilder(
    column: $table.expiryDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CouponsTableOrderingComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get benefitType => $composableBuilder(
    column: $table.benefitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountScope => $composableBuilder(
    column: $table.discountScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minOrderAmount => $composableBuilder(
    column: $table.minOrderAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get giftProductId => $composableBuilder(
    column: $table.giftProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryDays => $composableBuilder(
    column: $table.expiryDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CouponsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CouponsTable> {
  $$CouponsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get benefitType => $composableBuilder(
    column: $table.benefitType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountScope => $composableBuilder(
    column: $table.discountScope,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minOrderAmount => $composableBuilder(
    column: $table.minOrderAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get giftProductId => $composableBuilder(
    column: $table.giftProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expiryDays => $composableBuilder(
    column: $table.expiryDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CouponsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CouponsTable,
          CouponRow,
          $$CouponsTableFilterComposer,
          $$CouponsTableOrderingComposer,
          $$CouponsTableAnnotationComposer,
          $$CouponsTableCreateCompanionBuilder,
          $$CouponsTableUpdateCompanionBuilder,
          (CouponRow, BaseReferences<_$AppDatabase, $CouponsTable, CouponRow>),
          CouponRow,
          PrefetchHooks Function()
        > {
  $$CouponsTableTableManager(_$AppDatabase db, $CouponsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CouponsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CouponsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CouponsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<String> benefitType = const Value.absent(),
                Value<String?> discountValue = const Value.absent(),
                Value<String?> discountScope = const Value.absent(),
                Value<int?> minOrderAmount = const Value.absent(),
                Value<String?> giftProductId = const Value.absent(),
                Value<String> expiryDays = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CouponsCompanion(
                id: id,
                code: code,
                season: season,
                benefitType: benefitType,
                discountValue: discountValue,
                discountScope: discountScope,
                minOrderAmount: minOrderAmount,
                giftProductId: giftProductId,
                expiryDays: expiryDays,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String season,
                required String benefitType,
                Value<String?> discountValue = const Value.absent(),
                Value<String?> discountScope = const Value.absent(),
                Value<int?> minOrderAmount = const Value.absent(),
                Value<String?> giftProductId = const Value.absent(),
                required String expiryDays,
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CouponsCompanion.insert(
                id: id,
                code: code,
                season: season,
                benefitType: benefitType,
                discountValue: discountValue,
                discountScope: discountScope,
                minOrderAmount: minOrderAmount,
                giftProductId: giftProductId,
                expiryDays: expiryDays,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CouponsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CouponsTable,
      CouponRow,
      $$CouponsTableFilterComposer,
      $$CouponsTableOrderingComposer,
      $$CouponsTableAnnotationComposer,
      $$CouponsTableCreateCompanionBuilder,
      $$CouponsTableUpdateCompanionBuilder,
      (CouponRow, BaseReferences<_$AppDatabase, $CouponsTable, CouponRow>),
      CouponRow,
      PrefetchHooks Function()
    >;
typedef $$CampaignsTableCreateCompanionBuilder =
    CampaignsCompanion Function({
      required String id,
      required String name,
      required String conditionType,
      required String discountValue,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$CampaignsTableUpdateCompanionBuilder =
    CampaignsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> conditionType,
      Value<String> discountValue,
      Value<bool> enabled,
      Value<int> rowid,
    });

class $$CampaignsTableFilterComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableFilterComposer({
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

  ColumnFilters<String> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableOrderingComposer({
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

  ColumnOrderings<String> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableAnnotationComposer({
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

  GeneratedColumn<String> get conditionType => $composableBuilder(
    column: $table.conditionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discountValue => $composableBuilder(
    column: $table.discountValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$CampaignsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampaignsTable,
          CampaignRow,
          $$CampaignsTableFilterComposer,
          $$CampaignsTableOrderingComposer,
          $$CampaignsTableAnnotationComposer,
          $$CampaignsTableCreateCompanionBuilder,
          $$CampaignsTableUpdateCompanionBuilder,
          (
            CampaignRow,
            BaseReferences<_$AppDatabase, $CampaignsTable, CampaignRow>,
          ),
          CampaignRow,
          PrefetchHooks Function()
        > {
  $$CampaignsTableTableManager(_$AppDatabase db, $CampaignsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> conditionType = const Value.absent(),
                Value<String> discountValue = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion(
                id: id,
                name: name,
                conditionType: conditionType,
                discountValue: discountValue,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String conditionType,
                required String discountValue,
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion.insert(
                id: id,
                name: name,
                conditionType: conditionType,
                discountValue: discountValue,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampaignsTable,
      CampaignRow,
      $$CampaignsTableFilterComposer,
      $$CampaignsTableOrderingComposer,
      $$CampaignsTableAnnotationComposer,
      $$CampaignsTableCreateCompanionBuilder,
      $$CampaignsTableUpdateCompanionBuilder,
      (
        CampaignRow,
        BaseReferences<_$AppDatabase, $CampaignsTable, CampaignRow>,
      ),
      CampaignRow,
      PrefetchHooks Function()
    >;
typedef $$PointPoliciesTableCreateCompanionBuilder =
    PointPoliciesCompanion Function({
      required String id,
      Value<bool> enabled,
      Value<double> earnRate,
      Value<int> minUsablePoints,
      Value<String> earnScope,
      Value<String> useScope,
      Value<double> pointValueYen,
      Value<int?> expiryDays,
      Value<int> rowid,
    });
typedef $$PointPoliciesTableUpdateCompanionBuilder =
    PointPoliciesCompanion Function({
      Value<String> id,
      Value<bool> enabled,
      Value<double> earnRate,
      Value<int> minUsablePoints,
      Value<String> earnScope,
      Value<String> useScope,
      Value<double> pointValueYen,
      Value<int?> expiryDays,
      Value<int> rowid,
    });

class $$PointPoliciesTableFilterComposer
    extends Composer<_$AppDatabase, $PointPoliciesTable> {
  $$PointPoliciesTableFilterComposer({
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

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get earnRate => $composableBuilder(
    column: $table.earnRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minUsablePoints => $composableBuilder(
    column: $table.minUsablePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get earnScope => $composableBuilder(
    column: $table.earnScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get useScope => $composableBuilder(
    column: $table.useScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pointValueYen => $composableBuilder(
    column: $table.pointValueYen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiryDays => $composableBuilder(
    column: $table.expiryDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PointPoliciesTableOrderingComposer
    extends Composer<_$AppDatabase, $PointPoliciesTable> {
  $$PointPoliciesTableOrderingComposer({
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

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get earnRate => $composableBuilder(
    column: $table.earnRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minUsablePoints => $composableBuilder(
    column: $table.minUsablePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get earnScope => $composableBuilder(
    column: $table.earnScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get useScope => $composableBuilder(
    column: $table.useScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pointValueYen => $composableBuilder(
    column: $table.pointValueYen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiryDays => $composableBuilder(
    column: $table.expiryDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PointPoliciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointPoliciesTable> {
  $$PointPoliciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<double> get earnRate =>
      $composableBuilder(column: $table.earnRate, builder: (column) => column);

  GeneratedColumn<int> get minUsablePoints => $composableBuilder(
    column: $table.minUsablePoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get earnScope =>
      $composableBuilder(column: $table.earnScope, builder: (column) => column);

  GeneratedColumn<String> get useScope =>
      $composableBuilder(column: $table.useScope, builder: (column) => column);

  GeneratedColumn<double> get pointValueYen => $composableBuilder(
    column: $table.pointValueYen,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expiryDays => $composableBuilder(
    column: $table.expiryDays,
    builder: (column) => column,
  );
}

class $$PointPoliciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PointPoliciesTable,
          PointPolicyRow,
          $$PointPoliciesTableFilterComposer,
          $$PointPoliciesTableOrderingComposer,
          $$PointPoliciesTableAnnotationComposer,
          $$PointPoliciesTableCreateCompanionBuilder,
          $$PointPoliciesTableUpdateCompanionBuilder,
          (
            PointPolicyRow,
            BaseReferences<_$AppDatabase, $PointPoliciesTable, PointPolicyRow>,
          ),
          PointPolicyRow,
          PrefetchHooks Function()
        > {
  $$PointPoliciesTableTableManager(_$AppDatabase db, $PointPoliciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointPoliciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointPoliciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointPoliciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<double> earnRate = const Value.absent(),
                Value<int> minUsablePoints = const Value.absent(),
                Value<String> earnScope = const Value.absent(),
                Value<String> useScope = const Value.absent(),
                Value<double> pointValueYen = const Value.absent(),
                Value<int?> expiryDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PointPoliciesCompanion(
                id: id,
                enabled: enabled,
                earnRate: earnRate,
                minUsablePoints: minUsablePoints,
                earnScope: earnScope,
                useScope: useScope,
                pointValueYen: pointValueYen,
                expiryDays: expiryDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<bool> enabled = const Value.absent(),
                Value<double> earnRate = const Value.absent(),
                Value<int> minUsablePoints = const Value.absent(),
                Value<String> earnScope = const Value.absent(),
                Value<String> useScope = const Value.absent(),
                Value<double> pointValueYen = const Value.absent(),
                Value<int?> expiryDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PointPoliciesCompanion.insert(
                id: id,
                enabled: enabled,
                earnRate: earnRate,
                minUsablePoints: minUsablePoints,
                earnScope: earnScope,
                useScope: useScope,
                pointValueYen: pointValueYen,
                expiryDays: expiryDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PointPoliciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PointPoliciesTable,
      PointPolicyRow,
      $$PointPoliciesTableFilterComposer,
      $$PointPoliciesTableOrderingComposer,
      $$PointPoliciesTableAnnotationComposer,
      $$PointPoliciesTableCreateCompanionBuilder,
      $$PointPoliciesTableUpdateCompanionBuilder,
      (
        PointPolicyRow,
        BaseReferences<_$AppDatabase, $PointPoliciesTable, PointPolicyRow>,
      ),
      PointPolicyRow,
      PrefetchHooks Function()
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
  $$BookingsTableTableManager get bookings =>
      $$BookingsTableTableManager(_db, _db.bookings);
  $$WaitingEntriesTableTableManager get waitingEntries =>
      $$WaitingEntriesTableTableManager(_db, _db.waitingEntries);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$PrepaidPassMenusTableTableManager get prepaidPassMenus =>
      $$PrepaidPassMenusTableTableManager(_db, _db.prepaidPassMenus);
  $$PrepaidPassBalancesTableTableManager get prepaidPassBalances =>
      $$PrepaidPassBalancesTableTableManager(_db, _db.prepaidPassBalances);
  $$PrepaidPassTransactionsTableTableManager get prepaidPassTransactions =>
      $$PrepaidPassTransactionsTableTableManager(
        _db,
        _db.prepaidPassTransactions,
      );
  $$CouponsTableTableManager get coupons =>
      $$CouponsTableTableManager(_db, _db.coupons);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$PointPoliciesTableTableManager get pointPolicies =>
      $$PointPoliciesTableTableManager(_db, _db.pointPolicies);
}
