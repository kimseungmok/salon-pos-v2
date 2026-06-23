import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors.dart';
import '../providers.dart';

/// design/spec/v3/marketing/screen_spec.md 화면19 — クーポン発行.
/// F-MKT-01의 3-step(시즌템플릿→혜택→유효기간) 그대로.
///
/// 구현 범위 메모(M7, resumable 작업 기록):
/// - 19(쿠폰)만 우선 구현. 20(キャンペーン管理)/21(ポイント政策) UI는
///   다음 차수 — MarketingRepository는 둘 다 이미 완성+테스트되어
///   있어 막히지 않음.
class CouponScreen extends ConsumerWidget {
  const CouponScreen({super.key});

  static const _seasonLabels = {
    'whiteday': '🍬ホワイトデー', 'sakura': '🌸お花見', 'graduation': '🎓卒業',
    'snow': '❄️雪の日', 'valentine': '❤️バレンタイン', 'birthday': '🎂お誕生日',
    'christmas': '🎄クリスマス', 'newyear': '🎍お正月', 'kidsday': '🧒こどもの日',
    'parentsday': '💐親の日', 'exam': '📝試験期間', 'halloween': '🎃ハロウィン',
    'rainy': '☔雨の日', 'summer': '🍉真夏日',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponsStreamProvider);
    final repo = ref.watch(marketingRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text('クーポン発行'),
        actions: [
          FilledButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => _CreateCouponDialog(ref: ref)),
            icon: const Icon(Icons.local_offer),
            label: const Text('クーポン発行'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: couponsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(wrapUnknown(e, st).message)),
        data: (coupons) {
          if (coupons.isEmpty) {
            return const Center(child: Text('クーポンがまだありません。', style: TextStyle(color: Colors.grey)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = coupons[i];
              final expired = repo.isCouponExpired(c);
              return Card(
                child: ListTile(
                  leading: Text(_seasonLabels[c.season]?.substring(0, 2) ?? '🎁',
                      style: const TextStyle(fontSize: 22)),
                  title: Text('${_seasonLabels[c.season] ?? c.season}クーポン'),
                  subtitle: Text(c.benefitType == 'discount'
                      ? '割引：${c.discountValue}'
                      : 'プレゼント'),
                  trailing: Chip(
                    label: Text(expired ? '終了' : '有効'),
                    backgroundColor: expired ? const Color(0xFFF4F4F0) : const Color(0xFFEAFAF1),
                    labelStyle: TextStyle(color: expired ? Colors.grey : const Color(0xFF117A65)),
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

class _CreateCouponDialog extends StatefulWidget {
  const _CreateCouponDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_CreateCouponDialog> createState() => _CreateCouponDialogState();
}

class _CreateCouponDialogState extends State<_CreateCouponDialog> {
  String _season = 'rainy';
  String _benefitType = 'discount';
  final _discountController = TextEditingController(text: '10%');
  String _expiryDays = '30';
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _errorText = null;
    });
    try {
      await widget.ref.read(marketingRepositoryProvider).createCoupon(
            season: _season,
            benefitType: _benefitType,
            discountValue: _benefitType == 'discount' ? _discountController.text : null,
            giftProductId: _benefitType == 'gift' ? 'dummy-product' : null,
            expiryDays: _expiryDays,
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
      title: const Text('クーポン発行'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. クーポン発行シーズン', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: CouponScreen._seasonLabels.entries.map((e) {
                  return ChoiceChip(
                    label: Text(e.value, style: const TextStyle(fontSize: 11)),
                    selected: _season == e.key,
                    onSelected: (_) => setState(() => _season = e.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('2. クーポン特典', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('割引'),
                      selected: _benefitType == 'discount',
                      onSelected: (_) => setState(() => _benefitType = 'discount'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('プレゼント'),
                      selected: _benefitType == 'gift',
                      onSelected: (_) => setState(() => _benefitType = 'gift'),
                    ),
                  ),
                ],
              ),
              if (_benefitType == 'discount') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: '割引額（例：10% または ¥1,000）'),
                ),
              ],
              const SizedBox(height: 16),
              const Text('3. クーポン有効期間', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: ['7', '14', '30', 'always'].map((d) {
                  return ChoiceChip(
                    label: Text(d == 'always' ? '常時' : '$d日'),
                    selected: _expiryDays == d,
                    onSelected: (_) => setState(() => _expiryDays = d),
                  );
                }).toList(),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(_errorText!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
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
              : const Text('発行する'),
        ),
      ],
    );
  }
}
