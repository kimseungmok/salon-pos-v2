import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/product/screens/product_list_screen.dart';
import 'features/staff/screens/staff_invite_screen.dart';

/// salon-pos-v2 엔트리포인트.
///
/// 현지화 원칙(design/spec/v3/00_overview.md §3): 앱 자체는 항상
/// 일본어로 동작한다. locale을 ja_JP로 고정하고, 추후 다국어 지원이
/// 필요해지면 그때 가서 MaterialApp의 localizationsDelegates를 확장한다
/// (지금은 일본 단일 매장 타겟이라 과설계하지 않음).
void main() {
  runApp(const ProviderScope(child: SalonPosApp()));
}

class SalonPosApp extends StatelessWidget {
  const SalonPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'salon pos',
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [Locale('ja', 'JP')],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E3A8A),
        fontFamily: 'Hiragino Sans',
      ),
      // M1~M2 단계의 임시 홈. 정식 go_router 내비게이션(01_login_main
      // 시작)은 M3(customer) 이후 도입 — IMPLEMENTATION_PLAN.md §1 참조.
      home: const _DevHomeTabs(),
    );
  }
}

/// 개발 중 화면 전환용 임시 탭(go_router 도입 전까지만 사용).
class _DevHomeTabs extends StatefulWidget {
  const _DevHomeTabs();

  @override
  State<_DevHomeTabs> createState() => _DevHomeTabsState();
}

class _DevHomeTabsState extends State<_DevHomeTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const ProductListScreen(),
      const StaffInviteScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.spa), label: '商品'),
          NavigationDestination(icon: Icon(Icons.people), label: 'スタッフ'),
        ],
      ),
    );
  }
}
