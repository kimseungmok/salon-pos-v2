import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../core/formatters.dart';
import '../../../db/app_database.dart';
import '../providers.dart';
import '../widgets/color_swatches.dart';

/// design/spec/v3/product/screen_spec.md 화면25 — 商品リスト + 등록모달.
///
/// 구현 범위 메모(M1 단계, resumable 작업 기록):
/// - 商品/カテゴリ 탭만 구현. オプション/割引 탭은 M1 범위에서 제외
///   (product/feature_spec.md F-PROD-01의 옵션 칩 다중선택은 다음
///   차수에서 OptionGroups 테이블과 함께 추가).
/// - 색상 스와치는 화면정의서 원문과 달리 **상품이 아니라 카테고리에만**
///   부여한다(product/data_spec.md F-PROD-02 결정 — 타일색 고정 매핑
///   버그 방지). 상품 등록 모달에는 선택된 카테고리의 색을 읽기전용
///   미리보기로만 보여준다.
class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final selectedCategoryId = ref.watch(selectedCategoryIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('商品リスト'),
        actions: [
          TextButton.icon(
            onPressed: () => _openCategoryDialog(context, ref),
            icon: const Icon(Icons.local_offer_outlined),
            label: const Text('カテゴリ追加'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () =>
                _openProductDialog(context, ref, categoriesAsync.value ?? []),
            icon: const Icon(Icons.add),
            label: const Text('商品追加'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _ErrorView(error: wrapUnknown(e, st)),
        data: (categories) {
          return Column(
            children: [
              _CategoryTabs(
                categories: categories,
                selectedId: selectedCategoryId,
                onSelect: (id) =>
                    ref.read(selectedCategoryIdProvider.notifier).state = id,
              ),
              const Divider(height: 1),
              Expanded(
                child: productsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => _ErrorView(error: wrapUnknown(e, st)),
                  data: (products) {
                    final filtered = selectedCategoryId == null
                        ? products
                        : products
                            .where((p) => p.categoryId == selectedCategoryId)
                            .toList();
                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          '商品がまだ登録されていません。右上の「商品追加」から登録してください。',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    final categoryById = {for (final c in categories) c.id: c};
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final product = filtered[i];
                        final category = categoryById[product.categoryId];
                        return _ProductCard(
                          product: product,
                          category: category,
                          onTap: () => _openProductDialog(
                            context,
                            ref,
                            categories,
                            existing: product,
                          ),
                        );
                      },
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

  Future<void> _openCategoryDialog(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (_) => _CategoryFormDialog(ref: ref),
    );
  }

  Future<void> _openProductDialog(
    BuildContext context,
    WidgetRef ref,
    List<CategoryRow> categories, {
    ProductRow? existing,
  }) {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先にカテゴリを作成してください。')),
      );
      return Future.value();
    }
    return showDialog(
      context: context,
      builder: (_) => _ProductFormDialog(
        ref: ref,
        categories: categories,
        existing: existing,
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CategoryRow> categories;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _TabChip(
            label: 'すべて',
            selected: selectedId == null,
            color: Colors.white,
            onTap: () => onSelect(null),
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _TabChip(
                label: c.name,
                selected: selectedId == c.id,
                color: hexToColor(c.colorHex),
                onTap: () => onSelect(c.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      avatar: CircleAvatar(backgroundColor: color, radius: 7),
      onSelected: (_) => onTap(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.category,
    required this.onTap,
  });

  final ProductRow product;
  final CategoryRow? category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        category != null ? hexToColor(category!.colorHex) : Colors.grey;
    final isLight = category?.colorHex.toUpperCase() == '#FFFFFF';
    final fgColor = isLight ? Colors.black87 : Colors.white;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        color: fgColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.allowCustomPrice
                          ? '価格：都度入力'
                          : formatYen(product.price),
                      style: TextStyle(color: fgColor.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              if (product.durationMin != null)
                Text(
                  '${product.durationMin}分',
                  style: TextStyle(color: fgColor.withValues(alpha: 0.8)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final AppException error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(error.message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _nameController = TextEditingController();
  String? _selectedHex = kCategorySwatches[1];
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await widget.ref.read(productRepositoryProvider).createCategory(
            name: _nameController.text,
            colorHex: _selectedHex ?? '',
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
      title: const Text('新規カテゴリ'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'カテゴリ名'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ColorSwatchPicker(
              selectedHex: _selectedHex,
              onSelected: (hex) => setState(() => _selectedHex = hex),
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
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('作成する'),
        ),
      ],
    );
  }
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({
    required this.ref,
    required this.categories,
    this.existing,
  });

  final WidgetRef ref;
  final List<CategoryRow> categories;
  final ProductRow? existing;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late int? _categoryId;
  late bool _allowCustomPrice;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _priceController =
        TextEditingController(text: e != null ? '${e.price}' : '');
    _durationController =
        TextEditingController(text: e?.durationMin?.toString() ?? '');
    _categoryId = e?.categoryId ?? widget.categories.first.id;
    _allowCustomPrice = e?.allowCustomPrice ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      final priceText = _priceController.text.trim();
      if (!_allowCustomPrice && int.tryParse(priceText) == null) {
        throw const ValidationException('価格は0円以上の数字で入力してください。');
      }
      final price = int.tryParse(priceText) ?? 0;
      final durationText = _durationController.text.trim();
      if (durationText.isNotEmpty && int.tryParse(durationText) == null) {
        throw const ValidationException('施術時間は数字（分）で入力してください。');
      }
      final duration = durationText.isEmpty ? null : int.tryParse(durationText);

      await widget.ref.read(productRepositoryProvider).upsertProduct(
            id: widget.existing?.id,
            name: _nameController.text,
            categoryId: _categoryId!,
            price: price < 0 ? 0 : price,
            allowCustomPrice: _allowCustomPrice,
            durationMin: duration,
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
    final selectedCategory = widget.categories
        .where((c) => c.id == _categoryId)
        .firstOrNull;

    return AlertDialog(
      title: Text(widget.existing == null ? '商品追加' : '商品編集'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedCategory != null)
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: hexToColor(selectedCategory.colorHex),
                    radius: 8,
                  ),
                  const SizedBox(width: 8),
                  Text('カテゴリ色プレビュー（カテゴリ単位で固定）',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '商品名'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text('カテゴリ', style: Theme.of(context).textTheme.labelMedium),
            Wrap(
              spacing: 8,
              children: widget.categories.map((c) {
                return ChoiceChip(
                  label: Text(c.name),
                  selected: _categoryId == c.id,
                  avatar:
                      CircleAvatar(backgroundColor: hexToColor(c.colorHex), radius: 7),
                  onSelected: (_) => setState(() => _categoryId = c.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              enabled: !_allowCustomPrice,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '価格（円）'),
            ),
            CheckboxListTile(
              value: _allowCustomPrice,
              onChanged: (v) => setState(() => _allowCustomPrice = v ?? false),
              title: const Text('毎回直接入力する（時価メニュー）'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: '施術時間（分、任意・予約に使用）'),
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
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('保存する'),
        ),
      ],
    );
  }
}
