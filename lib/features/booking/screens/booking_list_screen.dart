import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../../../db/app_database.dart';
import '../providers.dart';

/// 予約一覧 — 来店完了処理画面(A-29, REQ-A26).
///
/// confirmed 状態の予約に対して BookingCompletionCaller.complete() を
/// 呼び出す。businessType は 'salon' 固定(A-29 PART 7 Change Control 参照).
///
/// ルート: /waiting/bookings (go_router サブルート, docs/A28_DESIGN_DEFINITION.md D-3)
final _bookingListProvider = StreamProvider<List<BookingRow>>((ref) {
  return ref.watch(bookingRepositoryProvider).watchBookings();
});

class BookingListScreen extends ConsumerWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(_bookingListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(title: const Text('予約来店完了処理')),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
        data: (bookings) {
          final active = bookings
              .where((b) => b.status == 'confirmed')
              .toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt));
          if (active.isEmpty) {
            return const Center(
              child: Text(
                '処理対象の予約はありません。',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: active.length,
            itemBuilder: (context, i) =>
                _BookingItem(booking: active[i]),
          );
        },
      ),
    );
  }
}

class _BookingItem extends ConsumerStatefulWidget {
  const _BookingItem({required this.booking});
  final BookingRow booking;

  @override
  ConsumerState<_BookingItem> createState() => _BookingItemState();
}

class _BookingItemState extends ConsumerState<_BookingItem> {
  bool _loading = false;

  Future<void> _complete() async {
    setState(() => _loading = true);
    try {
      await ref.read(bookingCompletionCallerProvider).complete(
            booking: widget.booking,
            businessType: 'salon',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('来店完了処理が完了しました。')),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エラーが発生しました。')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final dateStr = b.startAt.toLocal().toString().substring(0, 16);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text('予約 #${b.id}'),
        subtitle: Text(dateStr),
        trailing: _loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton(
                onPressed: _complete,
                child: const Text('来店完了'),
              ),
      ),
    );
  }
}
