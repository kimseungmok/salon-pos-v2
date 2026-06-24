import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/formatters.dart';
import '../logic/sales_report_logic.dart';
import '../providers.dart';

/// design/spec/v3/sales_report/screen_spec.md 화면17 — 売上ダッシュボード
/// 中 売上概況 탭(토스 핵심화면 그대로, F-SALES-01).
///
/// 구현 범위 메모(M10, resumable 작업 기록 — 마지막 모듈):
/// - 売上概況 탭만 구현(토스 핵심화면). 商品売上/決済取引/顧客分析/
///   スタッフ実績/売上カレンダー/店舗比較(F-SALES-02 보너스 영역) 탭은
///   다음 차수 — 이 영역들은 customer의 groupOf(), staff의 매출집계
///   등 여러 모듈을 더 엮어야 해서 별도 차수로 분리하는 게 합리적.
/// - F-SALES-03(PIN 잠금)도 다음 차수 — gitbook 실 화면 대조가 아직
///   미완료 상태(toss_benchmarking.md §2 잔여 항목)라 구현 근거 보강
///   먼저 필요.
class SalesReportScreen extends ConsumerWidget {
  const SalesReportScreen({super.key});

  static const _periodLabel = {
    ReportPeriod.day: '今日', ReportPeriod.week: '今週', ReportPeriod.month: '今月',
  };
  static const _methodLabel = {
    'cash': '現金', 'card': 'カード', 'paypay': 'PayPay', 'linepay': 'LINE Pay',
    'bank_transfer': '銀行振込', 'credit': '後払い', 'kakeuri': '掛け売り',
    'prepaid_pass': 'プリペイド券',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(selectedPeriodProvider);
    final summaryAsync = ref.watch(salesSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('売上ダッシュボード'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: ReportPeriod.values.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_periodLabel[p]!),
                    selected: period == p,
                    onSelected: (_) => ref.read(selectedPeriodProvider.notifier).state = p,
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: summaryAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
              data: (summary) => _SummaryBody(summary: summary, methodLabel: _methodLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.summary, required this.methodLabel});

  final SalesSummary summary;
  final Map<String, String> methodLabel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxMethodAmount = summary.byPaymentMethod.values.isEmpty
        ? 1
        : summary.byPaymentMethod.values.reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatTimeJp(now)}基準の累計データです',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _row('実売上', formatYen(summary.netSales), big: true),
                  const Divider(),
                  _row('注文件数', '${summary.orderCount}件'),
                  const Divider(),
                  _row('返品', '−${formatYen(summary.refundAmount)}', color: Colors.red),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('決済手段別売上', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (summary.byPaymentMethod.isEmpty)
                    const Text('決済データがありません。', style: TextStyle(color: Colors.grey)),
                  ...summary.byPaymentMethod.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(width: 90, child: Text(methodLabel[e.key] ?? e.key)),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value / maxMethodAmount,
                                minHeight: 10,
                                backgroundColor: const Color(0xFFF0F2F7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(formatYen(e.value)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('決済内訳を見る'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('出力する'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool big = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontSize: big ? 22 : 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
