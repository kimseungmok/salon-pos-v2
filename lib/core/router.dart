import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/booking/screens/waiting_list_screen.dart';
import '../features/cash_management/screens/store_open_screen.dart';
import '../features/customer/screens/customer_list_screen.dart';
import '../features/inventory/screens/inventory_list_screen.dart';
import '../features/marketing/screens/coupon_screen.dart';
import '../features/payment_pos/screens/pos_order_screen.dart';
import '../features/prepaid_pass/screens/prepaid_pass_menu_screen.dart';
import '../features/product/screens/product_list_screen.dart';
import '../features/sales_report/screens/sales_report_screen.dart';
import '../features/staff/screens/staff_invite_screen.dart';

/// 정식 내비게이션(go_router). 기존 main.dart의 임시 `_DevHomeTabs`
/// (IndexedStack + setState로 손수 구현한 탭 전환)를 대체한다.
///
/// 경로는 design/spec/v3의 화면 번호를 그대로 슬러그에 반영해, 정의서
/// 찾아가기/코드 찾아가기가 항상 짝지어지게 한다(IMPLEMENTATION_PLAN.md
/// §1 "폴더명 1:1 매칭" 원칙을 라우팅에도 동일 적용).
///
/// [StatefulShellRoute.indexedStack]을 쓰는 이유: 탭을 넘나들 때마다
/// 화면이 다시 빌드되면(예: 注文 화면의 카트 상태) 사용자가 입력 중인
/// 데이터가 날아간다 — 기존 수동 IndexedStack 구현과 동일하게 각 탭의
/// 위젯 트리/상태를 탭 전환 후에도 보존해야 한다.
final GoRouter appRouter = GoRouter(
  initialLocation: '/pos',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/pos', builder: (_, _) => const PosOrderScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/products', builder: (_, _) => const ProductListScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/staff', builder: (_, _) => const StaffInviteScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/customers', builder: (_, _) => const CustomerListScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/waiting', builder: (_, _) => const WaitingListScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/prepaid-pass', builder: (_, _) => const PrepaidPassMenuScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/coupons', builder: (_, _) => const CouponScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/store-open', builder: (_, _) => const StoreOpenScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/inventory', builder: (_, _) => const InventoryListScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/sales-report', builder: (_, _) => const SalesReportScreen()),
          ],
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.point_of_sale), label: '注文'),
    NavigationDestination(icon: Icon(Icons.spa), label: '商品'),
    NavigationDestination(icon: Icon(Icons.people), label: 'スタッフ'),
    NavigationDestination(icon: Icon(Icons.groups), label: '顧客'),
    NavigationDestination(icon: Icon(Icons.event_seat), label: '待機'),
    NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'プリペイド'),
    NavigationDestination(icon: Icon(Icons.local_offer), label: 'クーポン'),
    NavigationDestination(icon: Icon(Icons.lock_clock), label: '開店'),
    NavigationDestination(icon: Icon(Icons.inventory_2), label: '在庫'),
    NavigationDestination(icon: Icon(Icons.bar_chart), label: '売上'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        // goBranch(index)는 해당 브랜치를 다시 탭했을 때 해당 브랜치의
        // 첫 화면으로 초기화(initialLocation:true)할지, 마지막 상태를
        // 유지할지 선택 가능 — 여기서는 항상 마지막 상태 유지(기존
        // IndexedStack 동작과 동일하게).
        onDestinationSelected: navigationShell.goBranch,
        destinations: _destinations,
      ),
    );
  }
}
