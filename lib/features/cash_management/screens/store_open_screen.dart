import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/formatters.dart';
import '../logic/cash_logic.dart';
import '../providers.dart';

/// design/spec/v3/cash_management/screen_spec.md 화면22 — 開店準備.
///
/// 구현 범위 메모(M8, resumable 작업 기록):
/// - 22(개점)만 구현. 23(レジ締め, 매출연동+체크리스트 게이팅) UI는
///   다음 차수 — CashManagementRepository(recordCount/checklist 전부)
///   는 이미 완성+테스트되어 있어 막히지 않음.
/// - F-CASH-03(本日のスタッフ在店状況)은 staff 모듈의 Shift 데이터와
///   연동 가능하나 본 화면 1차 구현에서는 생략(다음 차수에서 연동).
class StoreOpenScreen extends ConsumerStatefulWidget {
  const StoreOpenScreen({super.key});

  @override
  ConsumerState<StoreOpenScreen> createState() => _StoreOpenScreenState();
}

class _StoreOpenScreenState extends ConsumerState<StoreOpenScreen> {
  final Map<int, int> _quantities = {for (final k in kDenomUnits.keys) k: 0};
  int? _expectedAmount;
  bool _loadingExpected = true;
  bool _submitting = false;
  String? _errorText;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _loadExpected();
  }

  Future<void> _loadExpected() async {
    final repo = ref.read(cashManagementRepositoryProvider);
    final prev = await repo.previousCloseTotal(DateTime.now());
    setState(() {
      _expectedAmount = prev ?? 0;
      _loadingExpected = false;
    });
  }

  int get _total => computeTotal(_quantities);
  int get _diff => computeDiff(_total, _expectedAmount ?? 0);

  void _adjust(int denom, int delta) {
    setState(() {
      final next = (_quantities[denom] ?? 0) + delta;
      _quantities[denom] = next < 0 ? 0 : next;
    });
  }

  Future<void> _confirmOpen() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await ref.read(cashManagementRepositoryProvider).recordCount(
            type: 'open',
            date: DateTime.now(),
            denominations: _quantities,
            expectedAmount: _expectedAmount ?? 0,
          );
      setState(() => _confirmed = true);
    } on AppException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('開店準備'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: (_total > 0 && !_confirmed && !_submitting) ? _confirmOpen : null,
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF117A65)),
              child: Text(_confirmed ? '確定済み' : '開店確定'),
            ),
          ),
        ],
      ),
      body: _loadingExpected
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('現在のレジ金額（開始金カウント）',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('総額', style: TextStyle(color: Colors.grey)),
                          Text(formatYen(_total),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...kDenomUnits.entries.map((entry) {
                      final denom = entry.key;
                      final unit = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(width: 90, child: Text(formatYen(denom))),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _adjust(denom, -1),
                            ),
                            SizedBox(
                              width: 60,
                              child: Text('${_quantities[denom]}',
                                  textAlign: TextAlign.center),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _adjust(denom, 1),
                            ),
                            Text(unit, style: const TextStyle(color: Colors.grey)),
                            const Spacer(),
                            Text(formatYen(denom * (_quantities[denom] ?? 0))),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    _summaryRow('合計', formatYen(_total)),
                    _summaryRow('前日締め予想額', formatYen(_expectedAmount ?? 0)),
                    _summaryRow(
                      '差額',
                      _total == 0
                          ? '-'
                          : (_diff == 0 ? '¥0（一致）' : '${_diff > 0 ? '+' : ''}${formatYen(_diff)}'),
                      color: _total == 0
                          ? Colors.grey
                          : (_diff == 0 ? const Color(0xFF117A65) : Colors.red),
                    ),
                    if (_diff != 0 && _total > 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('差額があります。再確認してください。',
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorText!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
