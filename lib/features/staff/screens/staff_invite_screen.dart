import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../providers.dart';

/// design/spec/v3/staff/screen_spec.md 화면33 — スタッフ招待(토스 그대로).
///
/// 구현 범위 메모(M2, resumable 작업 기록):
/// - 본 화면(33, 초대)만 구현. 11(一覧)/12(詳細)/13(シフト) UI는 다음
///   차수로 미룸 — Shift 데이터 모델과 isOnShift()는 이미 만들어둬서
///   M4(booking)가 막히지 않게 해둠.
/// - F-STAFF-00 절대 원칙: 이 화면에 로그인ID/PIN/권한레벨 입력란을
///   절대 추가하지 않는다.
class StaffInviteScreen extends ConsumerWidget {
  const StaffInviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('スタッフ招待'),
        actions: [
          FilledButton.icon(
            onPressed: () => _openInviteDialog(context, ref),
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('スタッフ招待'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: staffAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
              data: (staffList) {
                if (staffList.isEmpty) {
                  return const Center(
                    child: Text(
                      'まだスタッフが招待されていません。右上の「スタッフ招待」から始めてください。',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: staffList.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) =>
                      _StaffRow(staff: staffList[i], ref: ref),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: const Text(
              '※ トスプレイス実画面の通り：招待された人にアルリムトークが送信され、招待状を受けて同意すると'
              '売上が連動されます。PIN・権限レベルの管理はPOSの範囲外（勤怠管理サイトで運用）。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInviteDialog(BuildContext context, WidgetRef ref) {
    return showDialog(
      context: context,
      builder: (_) => _InviteDialog(ref: ref),
    );
  }
}

class _StaffRow extends ConsumerWidget {
  const _StaffRow({required this.staff, required this.ref});

  final StaffRow staff;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef _) {
    final isPending = staff.accountStatus == '待機中';
    return ListTile(
      title: Text(staff.name),
      subtitle: Text(staff.phone),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(staff.accountStatus ?? '未招待'),
            backgroundColor:
                isPending ? const Color(0xFFFEF9E7) : const Color(0xFFEAFAF1),
            labelStyle: TextStyle(
              color: isPending ? const Color(0xFFB7950B) : const Color(0xFF117A65),
            ),
          ),
          const SizedBox(width: 8),
          if (isPending)
            TextButton(
              onPressed: () => _handle(
                context,
                () => ref.read(staffRepositoryProvider).resendInvite(staff.id),
              ),
              child: const Text('再送信'),
            )
          else
            TextButton(
              onPressed: () => _handle(
                context,
                () => ref.read(staffRepositoryProvider).removeStaff(staff.id),
              ),
              child: const Text('削除', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Future<void> _handle(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _InviteDialog extends StatefulWidget {
  const _InviteDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends State<_InviteDialog> {
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
      await widget.ref.read(staffRepositoryProvider).inviteStaff(
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
      title: const Text('スタッフ招待'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'スタッフ名'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '携帯電話番号',
                hintText: '090-1234-5678',
              ),
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('招待する'),
        ),
      ],
    );
  }
}
