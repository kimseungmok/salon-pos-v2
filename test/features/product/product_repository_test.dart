import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/errors.dart';
import 'package:salon_pos_v2/db/app_database.dart';
import 'package:salon_pos_v2/features/product/data/product_repository.dart';

/// design/spec/v3/product/feature_spec.md F-PROD-01/F-PROD-02 규칙을
/// 그대로 검증. 정상 동작뿐 아니라 **예외 케이스**를 빠짐없이 테스트한다
/// (사용자 요청: "예외처리 에러 리스트 필수").
void main() {
  late AppDatabase db;
  late ProductRepository repo;

  setUp(() {
    db = AppDatabase.forTesting();
    repo = ProductRepository(db);
  });

  tearDown(() => db.close());

  group('createCategory', () {
    test('정상 생성', () async {
      final c = await repo.createCategory(name: 'カット', colorHex: '#8E44AD');
      expect(c.name, 'カット');
      expect(c.colorHex, '#8E44AD');
    });

    test('이름 공백 → ValidationException', () async {
      expect(
        () => repo.createCategory(name: '   ', colorHex: '#8E44AD'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('색상 형식 오류 → ValidationException', () async {
      expect(
        () => repo.createCategory(name: 'カット', colorHex: 'purple'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('이름 중복 → BusinessRuleException', () async {
      await repo.createCategory(name: 'カット', colorHex: '#8E44AD');
      expect(
        () => repo.createCategory(name: 'カット', colorHex: '#3B5BDB'),
        throwsA(isA<BusinessRuleException>()),
      );
    });
  });

  group('upsertProduct', () {
    test('정상 생성(고정가)', () async {
      final c = await repo.createCategory(name: 'カラー', colorHex: '#D35400');
      final p = await repo.upsertProduct(
        name: 'ワンカラー',
        categoryId: c.id,
        price: 8000,
        allowCustomPrice: false,
        durationMin: 60,
      );
      expect(p.price, 8000);
      expect(p.durationMin, 60);
    });

    test('시가상품은 price를 0으로 강제', () async {
      final c = await repo.createCategory(name: 'パーマ', colorHex: '#16A085');
      final p = await repo.upsertProduct(
        name: 'デザインパーマ',
        categoryId: c.id,
        price: 99999, // allowCustomPrice=true면 무시되어야 함
        allowCustomPrice: true,
      );
      expect(p.price, 0);
      expect(p.allowCustomPrice, true);
    });

    test('상품명 공백 → ValidationException', () async {
      final c = await repo.createCategory(name: 'カット', colorHex: '#8E44AD');
      expect(
        () => repo.upsertProduct(
          name: '',
          categoryId: c.id,
          price: 1000,
          allowCustomPrice: false,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('존재하지 않는 카테고리 → ValidationException', () async {
      expect(
        () => repo.upsertProduct(
          name: 'テスト',
          categoryId: 999999,
          price: 1000,
          allowCustomPrice: false,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('고정가인데 음수 가격 → ValidationException', () async {
      final c = await repo.createCategory(name: 'カット', colorHex: '#8E44AD');
      expect(
        () => repo.upsertProduct(
          name: 'カット',
          categoryId: c.id,
          price: -100,
          allowCustomPrice: false,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('deleteCategory', () {
    test('상품이 연결된 카테고리는 삭제 불가 → BusinessRuleException', () async {
      final c = await repo.createCategory(name: 'カット', colorHex: '#8E44AD');
      await repo.upsertProduct(
        name: 'カット',
        categoryId: c.id,
        price: 5000,
        allowCustomPrice: false,
      );
      expect(
        () => repo.deleteCategory(c.id),
        throwsA(isA<BusinessRuleException>()),
      );
    });

    test('존재하지 않는 카테고리 삭제 → NotFoundException', () async {
      expect(
        () => repo.deleteCategory(999999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('tileColorOf (F-PAY-01 연동)', () {
    test('카테고리 고정색을 그대로 반환', () async {
      final c = await repo.createCategory(name: 'カット', colorHex: '#8E44AD');
      final color = await repo.tileColorOf(c.id);
      expect(color, '#8E44AD');
    });

    test('존재하지 않는 카테고리 → NotFoundException', () async {
      expect(
        () => repo.tileColorOf(999999),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}

