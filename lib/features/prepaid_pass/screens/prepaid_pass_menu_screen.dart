import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/formatters.dart';
import '../../product/providers.dart' show productsStreamProvider;
import '../providers.dart';

/// design/spec/v3/prepaid_pass/screen_spec.md 화면27 — プリペイド券管理.
///
/// 구현 범위 메모(M6, resumable 작업 기록):
/// - 메뉴 생성/목록만 구현. 화면28(チャージ／使用モーダル)과 F-PP-05
///   (紙の回数券・利用券を移行) UI는 다음 차수 — PrepaidPassRepository
///   의 chargeMenu()/useAmountBalance()/useCountBalance()/
///   migratePaperTicket()는 이미 완성+테스트되어 있어 막히지 않음.
/// - 10(顧客詳細)의 プリペイド券 카드 연동도 다음 차수(02 注文 화면의
///   결제수단 그리드에 プリペイド券 추가도 함께 — F-PAY-02 결정사항).
class PrepaidPassMenuScreen extends ConsumerWidget {
  const PrepaidPassMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(prepaidPassMenusStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('プリペイド券管理'),
        actions: [
          FilledButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _CreateMenuDialog(
                ref: ref,
                products: productsAsync.value ?? [],
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('プリペイド券作成'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: menusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
        data: (menus) {
          if (menus.isEmpty) {
            return const Center(
              child: Text('プリペイド券メニューがまだありません。',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: menus.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = menus[i];
              final isAmount = m.type == 'amount';
              return Card(
                child: ListTile(
                  leading: Icon(
                    isAmount ? Icons.account_balance_wallet : Icons.confirmation_number,
                    color: const Color(0xFF1E3A8A),
                  ),
                  title: Text(m.name),
                  subtitle: Text(
                    isAmount
                        ? '金額チャージ券 / ${m.allowCustomPrice ? "都度入力" : formatYen(m.price)}'
                        : '回数券 / ${m.countPerPurchase}回 / ${formatYen(m.price)}',
                  ),
                  trailing: Text(
                    m.expiryType == 'none' ? '無期限' : '期限あり（${m.expiryType}）',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CreateMenuDialog extends StatefulWidget {
  const _CreateMenuDialog({required this.ref, required this.products});

  final WidgetRef ref;
  final List<dynamic> products;

  @override
  State<_CreateMenuDialog> createState() => _CreateMenuDialogState();
}

class _CreateMenuDialogState extends State<_CreateMenuDialog> {
  String _type = 'amount';
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _countController = TextEditingController();
  String? _linkedProductId;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _countController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await widget.ref.read(prepaidPassRepositoryProvider).createMenu(
            type: _type,
            name: _nameController.text,
            linkedProductId: _type == 'count' ? _linkedProductId : null,
            price: int.tryParse(_priceController.text.trim()) ?? 0,
            countPerPurchase:
                _type == 'count' ? int.tryParse(_countController.text.trim()) : null,
          );
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プリペイド券作成'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('① 種類', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('金額チャージ券'),
                  selected: _type == 'amount',
                  onSelected: (_) => setState(() => _type = 'amount'),
                ),
                ChoiceChip(
                  label: const Text('回数券'),
                  selected: _type == 'count',
                  onSelected: (_) => setState(() => _type = 'count'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '② メニュー名'),
            ),
            if (_type == 'count') ...[
              const SizedBox(height: 12),
              const Text('③ 適用商品（1つだけ）'),
              Wrap(
                spacing: 8,
                children: widget.products.map<Widget>((p) {
                  return ChoiceChip(
                    label: Text(p.name as String),
                    selected: _linkedProductId == p.id,
                    onSelected: (_) => setState(() => _linkedProductId = p.id as String),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '④ 回数'),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '決済価格（円）'),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('作成する'),
        ),
      ],
    );
  }
}
