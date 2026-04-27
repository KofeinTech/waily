import 'package:flutter/material.dart';
import '../../components/inputs/waily_switcher.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Switcher` state plus the synthesized Disabled.
class SwitchersSection extends StatefulWidget {
  const SwitchersSection({super.key});

  @override
  State<SwitchersSection> createState() => _SwitchersSectionState();
}

class _SwitchersSectionState extends State<SwitchersSection> {
  bool _interactive = false;

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Switchers',
      variants: [
        (
          label: 'Off',
          child: WailySwitcher(value: false, onChanged: (_) {}),
        ),
        (
          label: 'On',
          child: WailySwitcher(value: true, onChanged: (_) {}),
        ),
        (
          label: 'Disabled / off',
          child: WailySwitcher(
            value: false,
            onChanged: (_) {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Disabled / on',
          child: WailySwitcher(
            value: true,
            onChanged: (_) {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Interactive (tap to toggle)',
          child: WailySwitcher(
            value: _interactive,
            onChanged: (v) => setState(() => _interactive = v),
          ),
        ),
      ],
    );
  }
}
