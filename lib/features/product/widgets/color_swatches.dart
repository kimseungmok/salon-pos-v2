import 'package:flutter/material.dart';

/// design/spec/v3/product/feature_spec.md F-PROD-01: "색상 스와치 11개
/// 선택(백색 포함)". 토스 실 화면 확인 색상 그대로(흰색만 살롱 톤에
/// 맞게 살짝 보정).
const List<String> kCategorySwatches = [
  '#FFFFFF',
  '#8E44AD',
  '#3B5BDB',
  '#117A65',
  '#D35400',
  '#E74C3C',
  '#1E3A8A',
  '#B7950B',
  '#16A085',
  '#6C3483',
  '#34495E',
];

Color hexToColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}

/// 흰 배경 스와치는 테두리가 안 보여 선택 상태 구분이 어려우므로
/// 보더를 항상 그려준다.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
  });

  final String? selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kCategorySwatches.map((hex) {
        final isSelected = hex == selectedHex;
        return GestureDetector(
          onTap: () => onSelected(hex),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hexToColor(hex),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF1E3A8A) : _grey300,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

const Color _grey300 = Color(0xFFD1D5DB);
