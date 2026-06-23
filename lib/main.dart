import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/product/screens/product_list_screen.dart';

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
      // M1(product) 단계에서는 商品リスト를 임시 홈으로 둔다.
      // M2(staff) 이후 go_router로 전환해 01_login_main부터 시작하는
      // 정식 내비게이션 구조를 만든다 — IMPLEMENTATION_PLAN.md §1 참조.
      home: const ProductListScreen(),
    );
  }
}
