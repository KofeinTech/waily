import 'package:flutter/material.dart';
import '../../components/buttons/waily_segmented_button.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Segmented btn` variant plus the synthesized states.
class SegmentedButtonsSection extends StatefulWidget {
  const SegmentedButtonsSection({super.key});

  @override
  State<SegmentedButtonsSection> createState() =>
      _SegmentedButtonsSectionState();
}

class _SegmentedButtonsSectionState extends State<SegmentedButtonsSection> {
  bool _interactive = false;

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Segmented buttons',
      variants: [
        (
          label: 'Default',
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
          ),
        ),
        (
          label: 'Active',
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: true,
            onPressed: () {},
          ),
        ),
        (
          label: 'Default + close',
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
            onClose: () {},
          ),
        ),
        (
          label: 'Active + close',
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: true,
            onPressed: () {},
            onClose: () {},
          ),
        ),
        (
          label: 'Disabled',
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
            onClose: () {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Interactive (tap body)',
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: _interactive,
            onPressed: () => setState(() => _interactive = !_interactive),
          ),
        ),
      ],
    );
  }
}
