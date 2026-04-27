import 'package:flutter/material.dart';
import '../../components/inputs/waily_selector.dart';
import 'variant_grid.dart';

/// Showcases the Figma `Selector` text-only states.
class SelectorsSection extends StatefulWidget {
  const SelectorsSection({super.key});

  @override
  State<SelectorsSection> createState() => _SelectorsSectionState();
}

class _SelectorsSectionState extends State<SelectorsSection> {
  int _active = 32;

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Selectors',
      variants: [
        (
          label: 'Default',
          child: WailySelector(
            label: '32',
            isActive: false,
            onPressed: () {},
          ),
        ),
        (
          label: 'Active',
          child: WailySelector(
            label: '32',
            isActive: true,
            onPressed: () {},
          ),
        ),
        (
          label: 'Disabled',
          child: WailySelector(
            label: '32',
            isActive: false,
            onPressed: () {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Wheel-style group',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final v in [30, 31, 32, 33, 34]) ...[
                WailySelector(
                  label: '$v',
                  isActive: _active == v,
                  onPressed: () => setState(() => _active = v),
                ),
                const SizedBox(width: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
