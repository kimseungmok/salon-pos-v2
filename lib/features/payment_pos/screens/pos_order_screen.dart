import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/formatters.dart';
import '../../../db/app_database.dart';
import '../../product/providers.dart';
import '../../product/widgets/color_swatches.dart';
import '../logic/payment_logic.dart';
import '../providers.dart';

/// design/spec/v3/payment_pos/screen_spec.md 화면02 — 注文(메뉴 선택+
/// 카트) + 화면03 결제수단 선택의 단순화 버전(결제 다이얼로그로 통합).
///
/// 구현 범위 메모(M5, resumable 작업 기록):
/// - F-PAY-04(분할결제: 金額で決済/割り勘/メニュー別決済)의 3-tab UI는
///   다음 차수로 미룸 — PaymentRepository.pay()/remainingAmount()는
///   이미 분할결제를 지원하므로 데이터 계층은 막혀있지 않음. 본 화면은
///   "전액 1회 결제"만 다이얼로그로 제공한다.
/// - プリペイド券 결제수단은 prepaid_pass(M6) 완성 후 그리드에 추가
///   (F-PAY-02 결정사항).
class PosOrderScreen extends ConsumerWidget {
  const PosOrderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(title: const Text('注文')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
        data: (categories) {
          return productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
            data: (products) {
              final categoryById = {for (final c in categories) c.id: c};
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.3,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        final p = products[i];
                        final category = categoryById[p.categoryId];
                        final color = category != null
                            ? hexToColor(category.colorHex)
                            : Colors.grey;
                        final isLight =
                            category?.colorHex.toUpperCase() == '#FFFFFF';
                        return _ProductTile(
                          product: p,
                          color: color,
                          textColor: isLight ? Colors.black87 : Colors.white,
                          onTap: () {
                            final next = Map<String, int>.from(cart);
                            next[p.id] = (next[p.id] ?? 0) + 1;
                            ref.read(cartProvider.notifier).state = next;
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _CartPanel(products: products, ref: ref),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final ProductRow product;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(product.name,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              Text(
                product.allowCustomPrice ? '価格：都度入力' : formatYen(product.price),
                style: TextStyle(color: textColor.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends ConsumerWidget {
  const _CartPanel({required this.products, required this.ref});

  final List<ProductRow> products;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final cart = ref.watch(cartProvider);
    final productById = {for (final p in products) p.id: p};
    final entries = cart.entries
        .where((e) => productById.containsKey(e.key) && e.value > 0)
        .toList();
    final total = entries.fold<int>(
      0,
      (sum, e) => sum + productById[e.key]!.price * e.value,
    );

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('商品を選択してください。', style: TextStyle(color: Colors.grey)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = entries[i];
                      final p = productById[e.key]!;
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text(formatYen(p.price * e.value)),
                        leading: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _updateQty(e.key, e.value - 1),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${e.value}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _updateQty(e.key, e.value + 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: entries.isEmpty
                  ? null
                  : () => _openPaymentDialog(context, entries, productById, total),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text('${formatYen(total)} 決済'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQty(String productId, int qty) {
    final next = Map<String, int>.from(ref.read(cartProvider));
    if (qty <= 0) {
      next.remove(productId);
    } else {
      next[productId] = qty;
    }
    ref.read(cartProvider.notifier).state = next;
  }

  Future<void> _openPaymentDialog(
    BuildContext context,
    List<MapEntry<String, int>> entries,
    Map<String, ProductRow> productById,
    int total,
  ) {
    return showDialog(
      context: context,
      builder: (_) => _PaymentDialog(
        entries: entries,
        productById: productById,
        total: total,
        ref: ref,
      ),
    );
  }
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({
    required this.entries,
    required this.productById,
    required this.total,
    required this.ref,
  });

  final List<MapEntry<String, int>> entries;
  final Map<String, ProductRow> productById;
  final int total;
  final WidgetRef ref;

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  String _method = 'cash';
  final _cashController = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  static const _methodLabels = {
    'cash': '現金',
    'card': 'カード',
    'paypay': 'PayPay',
    'linepay': 'LINE Pay',
    'bank_transfer': '銀行振込',
    'credit': '後払い',
    'kakeuri': '掛け売り',
  };

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final order = await widget.ref.read(paymentRepositoryProvider).createOrder(
            items: widget.entries
                .map((e) => (
                      productId: e.key,
                      productName: widget.productById[e.key]!.name,
                      quantity: e.value,
                      unitPrice: widget.productById[e.key]!.price,
                      staffId: null,
                    ))
                .toList(),
          );
      final cashReceived = _method == 'cash'
          ? int.tryParse(_cashController.text.trim())
          : null;
      await widget.ref.read(paymentRepositoryProvider).pay(
            orderId: order.id,
            method: _method,
            amount: widget.total,
            cashReceived: cashReceived,
          );
      widget.ref.read(cartProvider.notifier).state = {};
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final received = int.tryParse(_cashController.text.trim()) ?? 0;
    final change = computeChange(received, widget.total);

    return AlertDialog(
      title: Text('${formatYen(widget.total)}を決済します'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('決済方法', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _methodLabels.entries.map((e) {
                return ChoiceChip(
                  label: Text(e.value),
                  selected: _method == e.key,
                  onSelected: (_) => setState(() => _method = e.key),
                );
              }).toList(),
            ),
            if (_method == 'cash') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '受取金額'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text('お釣り：${formatYen(change)}'),
            ],
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
              : const Text('決済する'),
        ),
      ],
    );
  }
}
