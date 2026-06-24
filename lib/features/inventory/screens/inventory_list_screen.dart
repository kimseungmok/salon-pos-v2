import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../logic/inventory_logic.dart';
import '../providers.dart';

/// design/spec/v3/inventory/screen_spec.md 화면14 — 在庫現況.
/// 토스 근거 없는 살롱 고유 자산(F-INV-00) — 독자기능 배지 필수.
///
/// 구현 범위 메모(M9, resumable 작업 기록):
/// - 14(在庫現況)만 구현. 15(在庫変動履歴)는 다음 차수 — watchLogsForDate()
///   는 이미 완성되어 있어 막히지 않음.
/// - F-INV-00 절대원칙: 이 화면도 Product/Order를 참조하지 않는다.
class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(inventoryItemsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('在庫現況'),
            const SizedBox(width: 8),
            const Chip(
              label: Text('※トスにない独自機能', style: TextStyle(fontSize: 11)),
              backgroundColor: Color(0xFFF5EEF8),
              labelStyle: TextStyle(color: Color(0xFF8E44AD)),
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => _CreateItemDialog(ref: ref)),
            icon: const Icon(Icons.add),
            label: const Text('品目追加'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('品目がまだ登録されていません。', style: TextStyle(color: Colors.grey)));
          }
          final lowCount = items.where((i) => statusOf(i) == InventoryStatus.low).length;
          final outCount = items.where((i) => statusOf(i) == InventoryStatus.outOfStock).length;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    Text('総品目数 ${items.length}点'),
                    const SizedBox(width: 16),
                    Text('在庫不足 $lowCount点', style: const TextStyle(color: Color(0xFFB7950B))),
                    const SizedBox(width: 16),
                    Text('品切れ $outCount点', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final status = statusOf(item);
                    final color = switch (status) {
                      InventoryStatus.normal => const Color(0xFF117A65),
                      InventoryStatus.low => const Color(0xFFB7950B),
                      InventoryStatus.outOfStock => Colors.red,
                    };
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.category),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _adjust(context, ref, item.id, -1),
                          ),
                          Text('${item.quantity}${item.unit ?? ''}'),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _adjust(context, ref, item.id, 1),
                          ),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(kInventoryStatusLabel[status]!),
                        backgroundColor: color.withValues(alpha: 0.12),
                        labelStyle: TextStyle(color: color),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _adjust(BuildContext context, WidgetRef ref, String itemId, int delta) async {
    try {
      await ref.read(inventoryRepositoryProvider).adjustQuantity(
            itemId: itemId,
            delta: delta,
            reason: 'adjustment',
          );
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _CreateItemDialog extends StatefulWidget {
  const _CreateItemDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_CreateItemDialog> createState() => _CreateItemDialogState();
}

class _CreateItemDialogState extends State<_CreateItemDialog> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _thresholdController = TextEditingController(text: '5');
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await widget.ref.read(inventoryRepositoryProvider).createItem(
            name: _nameController.text,
            category: _categoryController.text,
            quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
            threshold: int.tryParse(_thresholdController.text.trim()) ?? 0,
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
      title: const Text('品目追加'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '品目名')),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'カテゴリ')),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '在庫数'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'しきい値'),
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
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('追加する'),
        ),
      ],
    );
  }
}
