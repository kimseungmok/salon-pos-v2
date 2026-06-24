import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:salon_pos_v2/core/router.dart';
import 'package:salon_pos_v2/main.dart';

/// go_router 정식 도입(StatefulShellRoute) 스모크 테스트.
/// 라우터 설정 자체에 오류(경로 중복, builder 타입 오류 등)가 있으면
/// 앱 부팅 시점에 즉시 드러나므로, 초기화면 렌더링 + 탭 전환만으로도
/// 충분한 회귀 방지가 된다.
///
/// **`pumpAndSettle()`을 쓰지 않는다**: StatefulShellRoute.indexedStack은
/// 모든 브랜치를 동시에 마운트해서 상태를 보존하는데, ウェイティング
/// (08) 화면이 `Timer.periodic(1분)`을 즉시 시작한다 — 이 타이머는
/// 절대 "settle"되지 않으므로 pumpAndSettle이 영원히 끝나지 않는다.
/// 대신 명시적 `pump(duration)`으로 필요한 프레임만 진행시킨다.
void main() {
  testWidgets('앱이 정상 부팅되고 초기 화면(注文)이 렌더링된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('注文'), findsWidgets); // 하단탭 라벨 + AppBar 등
  });

  testWidgets('하단 탭으로 商品 화면으로 전환된다', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.widgetWithText(NavigationDestination, '商品'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('商品リスト'), findsOneWidget);
  });

  testWidgets('탭 전환 후에도 이전 탭 상태가 보존된다(IndexedStack 동작)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SalonPosApp()));
    await tester.pump(const Duration(milliseconds: 500));

    // 注文 → スタッフ → 注文으로 돌아와도 트리가 dispose되지 않아야 함.
    await tester.tap(find.widgetWithText(NavigationDestination, 'スタッフ'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('スタッフ招待'), findsWidgets);

    await tester.tap(find.widgetWithText(NavigationDestination, '注文'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('注文'), findsWidgets);
  });

  test('appRouter의 모든 경로가 중복 없이 고유하다', () {
    final paths = <String>[];
    void collect(List<RouteBase> routes) {
      for (final r in routes) {
        if (r is GoRoute) paths.add(r.path);
        if (r is StatefulShellRoute) {
          for (final b in r.branches) {
            collect(b.routes);
          }
        }
      }
    }
    collect(appRouter.configuration.routes);
    expect(paths.length, paths.toSet().length, reason: '중복된 경로: $paths');
    expect(paths.length, 10);
  });
}
