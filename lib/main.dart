import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';

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
    return MaterialApp.router(
      title: 'salon pos',
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [Locale('ja', 'JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E3A8A),
        fontFamily: 'Hiragino Sans',
      ),
      // 정식 내비게이션 — core/router.dart 참조(IMPLEMENTATION_PLAN.md
      // §1에서 예고했던 go_router 정식 도입).
      routerConfig: appRouter,
    );
  }
}
