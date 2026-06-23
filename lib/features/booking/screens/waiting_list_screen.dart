import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../logic/booking_logic.dart';
import '../providers.dart';

/// design/spec/v3/booking/screen_spec.md 화면08 — ウェイティング管理.
/// 토스 근거 없는 살롱 고유 자산(F-BOOK-03) — 배지 표시 필수.
///
/// 구현 범위 메모(M4, resumable 작업 기록):
/// - 본 화면(08)만 우선 구현. 06(予約カレンダー)/07(予約登録フォーム)
///   UI는 다음 차수로 미룸 — BookingRepository(createBooking/
///   cancelBooking/F-BOOK-04)는 이미 완성해뒀으니 데이터 계층은
///   막혀있지 않음.
class WaitingListScreen extends ConsumerWidget {
  const WaitingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitingAsync = ref.watch(waitingListStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('ウェイティング管理'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Chip(
              label: Text('※トスにない独自機能', style: TextStyle(fontSize: 11)),
              backgroundColor: Color(0xFFF5EEF8),
              labelStyle: TextStyle(color: Color(0xFF8E44AD)),
            ),
          ),
          FilledButton.icon(
            onPressed: () => _openAddDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('ウェイティング追加'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: waitingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
        data: (entries) {
          final waiting = entries.where((e) => e.status == 'waiting').toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          if (waiting.isEmpty) {
            return const Center(
              child: Text('待機中のお客様はいません。',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return _LiveList(entries: waiting, ref: ref);
        },
      ),
    );
  }

  Future<void> _openAddDialog(BuildContext context, WidgetRef ref) {
    return showDialog(context: context, builder: (_) => _AddWaitingDialog(ref: ref));
  }
}

/// 대기시간(waitColor)이 분 단위로 변하므로 1분마다 새로 그린다.
class _LiveList extends StatefulWidget {
  const _LiveList({required this.entries, required this.ref});

  final List<WaitingEntryRow> entries;
  final WidgetRef ref;

  @override
  State<_LiveList> createState() => _LiveListState();
}

class _LiveListState extends State<_LiveList> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: widget.entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final e = widget.entries[i];
        final color = waitColor(e.checkInAt, now);
        final minutes = now.difference(e.checkInAt).inMinutes;
        final dotColor = switch (color) {
          WaitColor.gray => Colors.grey,
          WaitColor.orange => Colors.orange,
          WaitColor.red => Colors.red,
        };
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(e.customerName),
            subtitle: Text(
              '${e.phone ?? ''}${e.menuNote != null ? ' / ${e.menuNote}' : ''}\n'
              '$minutes分待ち',
            ),
            isThreeLine: true,
            leadingAndTrailingTextStyle: TextStyle(color: dotColor),
            trailing: Wrap(
              spacing: 8,
              children: [
                Icon(Icons.circle, size: 10, color: dotColor),
                FilledButton(
                  onPressed: () => _handle(
                    context,
                    () => widget.ref.read(bookingRepositoryProvider).callWaiting(e.id),
                  ),
                  child: const Text('呼び出す'),
                ),
                OutlinedButton(
                  onPressed: () => _handle(
                    context,
                    () => widget.ref.read(bookingRepositoryProvider).cancelWaiting(e.id),
                  ),
                  child: const Text('取消'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handle(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _AddWaitingDialog extends StatefulWidget {
  const _AddWaitingDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_AddWaitingDialog> createState() => _AddWaitingDialogState();
}

class _AddWaitingDialogState extends State<_AddWaitingDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _menuController = TextEditingController();
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await widget.ref.read(bookingRepositoryProvider).addWaiting(
            customerName: _nameController.text,
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            menuNote: _menuController.text.trim().isEmpty
                ? null
                : _menuController.text.trim(),
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
      title: const Text('ウェイティング追加'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'お客様の名前'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '電話番号（任意）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _menuController,
              decoration: const InputDecoration(labelText: 'メニュー（任意）'),
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
              : const Text('追加する'),
        ),
      ],
    );
  }
}
