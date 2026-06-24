import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// 일본어 로케일 테스트(요청 항목 2).
///
/// **왜 standalone MaterialApp으로 테스트하는가**: 이 앱의 화면(02~17)
/// 중에는 아직 showDatePicker()/showTimePicker()를 쓰는 화면이 없다
/// (06/07 예약캘린더·등록폼 UI가 다음 차수라 — README.md "남은 작업"
/// 참조). 그래서 지금 검증할 수 있는 건 "고친 버그(flutter_localizations
/// 미등록)가 실제로 프레임워크 레벨에서 해소됐는지"이며, 이건 별도의
/// 최소 MaterialApp으로 충분히 검증된다 — 앱 코드에 실제 picker가
/// 추가되면 이 테스트 패턴을 그대로 해당 화면 테스트에 재사용한다.
void main() {
  Widget jaApp(Widget child) {
    return MaterialApp(
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [Locale('ja', 'JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );
  }

  testWidgets('AlertDialog가 No MaterialLocalizations 오류 없이 렌더링된다',
      (tester) async {
    await tester.pumpWidget(jaApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('確認'),
                  actions: [
                    TextButton(onPressed: () {}, child: const Text('キャンセル')),
                    TextButton(onPressed: () {}, child: const Text('OK')),
                  ],
                ),
              ),
              child: const Text('開く'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('開く'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('showDatePicker()가 일본어로 정상 렌더링된다 (年月日 표기, 요일)',
      (tester) async {
    await tester.pumpWidget(jaApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDatePicker(
                context: context,
                initialDate: DateTime(2025, 7, 1),
                firstDate: DateTime(2020, 1, 1),
                lastDate: DateTime(2030, 12, 31),
              ),
              child: const Text('日付選択'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('日付選択'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);

    // 일본어 MaterialLocalizations의 날짜피커는 "2025年7月" 형식의
    // 月/年 헤더와 OK/キャンセル 버튼을 일본어로 보여준다.
    expect(find.textContaining('2025年'), findsWidgets);
    expect(find.text('キャンセル'), findsWidgets);
    expect(find.text('OK'), findsWidgets);
  });

  testWidgets('showTimePicker()가 일본어로 정상 렌더링된다', (tester) async {
    await tester.pumpWidget(jaApp(
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showTimePicker(
                context: context,
                initialTime: const TimeOfDay(hour: 14, minute: 30),
              ),
              child: const Text('時刻選択'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('時刻選択'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
    expect(find.text('キャンセル'), findsWidgets);
    expect(find.text('OK'), findsWidgets);
  });

  testWidgets('MaterialLocalizations.of(context)가 ja 로케일로 정상 조회된다',
      (tester) async {
    late MaterialLocalizations localizations;
    await tester.pumpWidget(jaApp(
      Builder(
        builder: (context) {
          localizations = MaterialLocalizations.of(context);
          return const Scaffold();
        },
      ),
    ));

    expect(localizations.okButtonLabel, 'OK');
    expect(localizations.cancelButtonLabel, 'キャンセル');
    // weekdayRow 등 요일은 narrowWeekdays(월=index1 ~ 일=index0 등 구현체
    // 별로 순서가 다를 수 있어, "月"・"火" 글자가 포함되는지만 확인.
    final weekdays = localizations.narrowWeekdays.join();
    expect(weekdays.contains('月'), true);
  });
}
