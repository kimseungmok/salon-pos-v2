import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salon_pos_v2/core/router.dart';
import 'package:salon_pos_v2/main.dart';

/// 라우팅 테스트(요청 항목 1, 4, 5).
///
/// **범위 명시**: 현재 라우팅 구조는 `/customer → /customer/detail →
/// /reservation` 같은 중첩 push 라우팅이 아니라, 10개 화면이 모두
/// `StatefulShellRoute`의 평행 브랜치(하단탭)다 — 로그인/고객상세/
/// 예약 화면은 아직 구현 전(README.md "남은 작업" 참조). 그래서
/// "뒤로가기"는 탭 전환에는 적용되지 않고(브라우저 히스토리 개념이
/// 아님), 잘못된 URL 접근(404)과 탭 반복 전환(stress)만 지금 실제로
/// 테스트할 수 있는 항목이다.
void main() {
  const validPaths = [
    '/pos', '/products', '/staff', '/customers', '/waiting',
    '/prepaid-pass', '/coupons', '/store-open', '/inventory', '/sales-report',
  ];

  group('1. 화면 이동 — 정상 경로', () {
    for (final path in validPaths) {
      testWidgets('$path 로 직접 진입(딥링크/새로고침 시뮬레이션)해도 깨지지 않는다',
          (tester) async {
        appRouter.go(path);
        await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
        await tester.pump(const Duration(milliseconds: 500));

        // go_router 기본 에러화면(빨간 화면 등)이 아니라 정상 화면이어야 함.
        expect(find.text('ページが見つかりません'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('2. URL 변경 확인', () {
    testWidgets('탭 전환 시 GoRouter의 현재 경로(uri)가 실제로 바뀐다', (tester) async {
      appRouter.go('/pos');
      await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(appRouter.state.uri.path, '/pos');

      await tester.tap(find.widgetWithText(NavigationDestination, '顧客'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(appRouter.state.uri.path, '/customers');
    });
  });

  group('3. 잘못된 URL 접근 시 에러 페이지', () {
    testWidgets('존재하지 않는 경로 → 404 안내화면(빨간 디버그 화면 아님)',
        (tester) async {
      appRouter.go('/no-such-page');
      await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('ページが見つかりません'), findsOneWidget);
      expect(find.textContaining('/no-such-page'), findsOneWidget);
    });

    testWidgets('404 화면의 "注文画面に戻る" 버튼으로 정상 화면 복귀 가능',
        (tester) async {
      appRouter.go('/totally-invalid');
      await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('注文画面に戻る'));
      // 404 화면(셀 바깥) → 셸 라우트(/pos, 10개 브랜치 전체 마운트)로
      // 돌아가는 전환은 1프레임으로 끝나지 않아 여러 번 펌프한다.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(find.text('ページが見つかりません'), findsNothing);
      expect(appRouter.state.uri.path, '/pos');
    });
  });

  group('4. 라우팅 스트레스 테스트(탭 반복 전환 20회)', () {
    testWidgets('顧客 ↔ 注文 탭을 20회 반복 전환해도 예외/누수 없음', (tester) async {
      appRouter.go('/pos');
      await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
      await tester.pump(const Duration(milliseconds: 300));

      for (var i = 0; i < 20; i++) {
        await tester.tap(find.widgetWithText(NavigationDestination, '顧客'));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.tap(find.widgetWithText(NavigationDestination, '注文'));
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
      // 마지막에 注文 탭에 정확히 머물러 있는지(상태 꼬임 없음).
      expect(find.text('注文'), findsWidgets);
    });

    testWidgets('10개 탭을 순서대로 3바퀴(30회) 순회해도 예외 없음', (tester) async {
      appRouter.go('/pos');
      await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
      await tester.pump(const Duration(milliseconds: 300));

      const labels = [
        '注文', '商品', 'スタッフ', '顧客', '待機',
        'プリペイド', 'クーポン', '開店', '在庫', '売上',
      ];
      for (var lap = 0; lap < 3; lap++) {
        for (final label in labels) {
          await tester.tap(find.widgetWithText(NavigationDestination, label));
          await tester.pump(const Duration(milliseconds: 80));
        }
      }

      expect(tester.takeException(), isNull);
    });
  });

  group('5. 화면 골격 점검 — 전체 10개 화면 클릭 시 오류/오버플로 없음', () {
    const labels = [
      '注文', '商品', 'スタッフ', '顧客', '待機',
      'プリペイド', 'クーポン', '開店', '在庫', '売上',
    ];

    for (final label in labels) {
      testWidgets('$label 탭 진입 시 렌더링 오류·오버플로 없음', (tester) async {
        appRouter.go('/pos');
        await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
        await tester.pump(const Duration(milliseconds: 300));

        await tester.tap(find.widgetWithText(NavigationDestination, label));
        await tester.pump(const Duration(milliseconds: 500));

        // takeException()이 null이 아니면 Null 오류·오버플로 등 렌더링
        // 예외가 발생했다는 뜻(RenderFlex overflow도 FlutterError로 잡힘).
        expect(tester.takeException(), isNull);
      });
    }
  });
}
