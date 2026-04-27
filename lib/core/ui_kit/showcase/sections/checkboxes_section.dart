import 'package:flutter/material.dart';
import '../../components/inputs/waily_checkbox.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Check Box` state plus the synthesized Disabled.
class CheckboxesSection extends StatefulWidget {
  const CheckboxesSection({super.key});

  @override
  State<CheckboxesSection> createState() => _CheckboxesSectionState();
}

class _CheckboxesSectionState extends State<CheckboxesSection> {
  bool _interactive = false;

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Checkboxes',
      variants: [
        (
          label: 'Default (unchecked)',
          child: WailyCheckbox(value: false, onChanged: (_) {}),
        ),
        (
          label: 'Active (checked)',
          child: WailyCheckbox(value: true, onChanged: (_) {}),
        ),
        (
          label: 'Disabled / unchecked',
          child: WailyCheckbox(
            value: false,
            onChanged: (_) {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Disabled / checked',
          child: WailyCheckbox(
            value: true,
            onChanged: (_) {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Interactive (tap to toggle)',
          child: WailyCheckbox(
            value: _interactive,
            onChanged: (v) => setState(() => _interactive = v),
          ),
        ),
      ],
    );
  }
}
