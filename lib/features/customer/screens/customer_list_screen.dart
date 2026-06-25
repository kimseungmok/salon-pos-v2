import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../logic/group_of.dart';
import '../providers.dart';

/// design/spec/v3/customer/screen_spec.md 화면09 — 顧客リスト.
///
/// 구현 범위 메모(M3, resumable 작업 기록):
/// - 09(리스트)만 구현. 10(顧客詳細, メモ/ポイント/プリペイド券/カルテ)
///   는 다음 차수 — 선불권(M6)이 아직 없어 10을 완성해도 일부가
///   placeholder가 될 것이므로, 의존성 순서대로(IMPLEMENTATION_PLAN.md
///   §3) M6 이후 한번에 만드는 게 더 깔끔하다.
class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersStreamProvider);
    final visitsAsync = ref.watch(visitsStreamProvider);
    final selectedGroup = ref.watch(selectedGroupProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('顧客リスト'),
        actions: [
          FilledButton.icon(
            onPressed: () => _openAddDialog(context, ref),
            icon: const Icon(Icons.person_add),
            label: const Text('顧客登録'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
        data: (customers) {
          return visitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
            data: (visits) {
              final today = DateTime.now();
              final groupByCustomer = {
                for (final c in customers) c.id: groupOf(c.id, visits, today),
              };

              final filtered = customers.where((c) {
                if (selectedGroup != null &&
                    groupByCustomer[c.id] != selectedGroup) {
                  return false;
                }
                if (query.isNotEmpty &&
                    !c.name.contains(query) &&
                    !c.phone.contains(query)) {
                  return false;
                }
                return true;
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: '番号、名前で検索',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                      ),
                      onChanged: (v) =>
                          ref.read(searchQueryProvider.notifier).state = v,
                    ),
                  ),
                  _GroupTabs(
                    customers: customers,
                    groupByCustomer: groupByCustomer,
                    selected: selectedGroup,
                    onSelect: (g) =>
                        ref.read(selectedGroupProvider.notifier).state = g,
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('該当するお客様が見つかりません。',
                                style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final c = filtered[i];
                              final group = groupByCustomer[c.id]!;
                              return ListTile(
                                leading: Text(kGroupIcon[group]!,
                                    style: const TextStyle(fontSize: 20)),
                                title: Text('${kGroupLabel[group]} | ${c.name}'),
                                subtitle: Text(_maskPhone(c.phone)),
                                trailing: Text('${c.points}P'),
                              );
                            },
                          ),
                  ),
                  _Legend(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) {
    return showDialog(context: context, builder: (_) => _AddCustomerDialog(ref: ref));
  }
}

String _maskPhone(String phone) {
  final digits = phone.replaceAll('-', '');
  if (digits.length < 8) return phone;
  final last4 = digits.substring(digits.length - 4);
  final first = digits.substring(0, digits.length - 8);
  return '$first-****-$last4';
}

class _GroupTabs extends StatelessWidget {
  const _GroupTabs({
    required this.customers,
    required this.groupByCustomer,
    required this.selected,
    required this.onSelect,
  });

  final List<CustomerRow> customers;
  final Map<int, CustomerGroup> groupByCustomer;
  final CustomerGroup? selected;
  final ValueChanged<CustomerGroup?> onSelect;

  @override
  Widget build(BuildContext context) {
    int countOf(CustomerGroup? g) => g == null
        ? customers.length
        : groupByCustomer.values.where((v) => v == g).length;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          ChoiceChip(
            label: Text('すべて (${countOf(null)})'),
            selected: selected == null,
            onSelected: (_) => onSelect(null),
          ),
          for (final g in CustomerGroup.values)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ChoiceChip(
                label: Text('${kGroupIcon[g]}${kGroupLabel[g]} (${countOf(g)})'),
                selected: selected == g,
                onSelected: (_) => onSelect(g),
              ),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: const Text(
        '顧客グループ定義 ※トスプレイス基準\n'
        '🐣 初回来店 — はじめてご来店のお客様\n'
        '🟡 予備常連 — 2回以上ご来店、まだ常連ではない方\n'
        '🔴 常連 — 直近90日間で7回以上ご来店の方\n'
        '⚪ 休眠ぎみ — 予備常連・常連だったが45日以上来店がない方',
        style: TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

class _AddCustomerDialog extends StatefulWidget {
  const _AddCustomerDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<_AddCustomerDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await widget.ref.read(customerRepositoryProvider).createCustomer(
            name: _nameController.text,
            phone: _phoneController.text,
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
      title: const Text('新規顧客登録'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '名前'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '電話番号'),
              keyboardType: TextInputType.phone,
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
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('登録する'),
        ),
      ],
    );
  }
}
