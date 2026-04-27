import 'package:flutter/material.dart';
import '../../components/chips/waily_chip.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Chip` variant: Type x Color, plus the synthesized
/// Disabled state and a read-only chip without a close icon.
class ChipsSection extends StatelessWidget {
  const ChipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Chips',
      variants: [
        (
          label: 'Default / Dark',
          child: WailyChip(label: 'Coffee', onClose: () {}),
        ),
        (
          label: 'Default / Light',
          child: WailyChip(
            label: 'Coffee',
            onClose: () {},
            color: WailyChipColor.light,
          ),
        ),
        (
          label: '2 items / Dark',
          child: WailyChip(label: 'Coffee', value: '0 oz', onClose: () {}),
        ),
        (
          label: '2 items / Light',
          child: WailyChip(
            label: 'Coffee',
            value: '0 oz',
            onClose: () {},
            color: WailyChipColor.light,
          ),
        ),
        (
          label: 'Read-only (no close)',
          child: WailyChip(label: 'Coffee'),
        ),
        (
          label: 'Disabled',
          child: WailyChip(
            label: 'Coffee',
            value: '0 oz',
            onClose: () {},
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
