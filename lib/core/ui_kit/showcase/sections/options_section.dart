import 'package:flutter/material.dart';
import '../../components/inputs/waily_option.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Option` variant.
class OptionsSection extends StatefulWidget {
  const OptionsSection({super.key});

  @override
  State<OptionsSection> createState() => _OptionsSectionState();
}

class _OptionsSectionState extends State<OptionsSection> {
  String _selected = 'hybrid';

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Options',
      variants: [
        (
          label: 'Default',
          child: SizedBox(
            width: 358,
            child: WailyOption(
              title: 'Hybrid',
              description: 'HYROX, run + lift, mixed conditioning',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Selected',
          child: SizedBox(
            width: 358,
            child: WailyOption(
              title: 'Hybrid',
              description: 'HYROX, run + lift, mixed conditioning',
              isSelected: true,
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Title only',
          child: SizedBox(
            width: 358,
            child: WailyOption(
              title: 'Strength training',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 358,
            child: WailyOption(
              title: 'Hybrid',
              description: 'HYROX',
              isSelected: false,
              onPressed: () {},
              isDisabled: true,
            ),
          ),
        ),
        (
          label: 'Interactive group',
          child: SizedBox(
            width: 358,
            child: Column(
              children: [
                WailyOption(
                  title: 'Hybrid',
                  description: 'HYROX, run + lift',
                  isSelected: _selected == 'hybrid',
                  onPressed: () => setState(() => _selected = 'hybrid'),
                ),
                const SizedBox(height: 8),
                WailyOption(
                  title: 'Strength',
                  description: 'Heavy compound lifts',
                  isSelected: _selected == 'strength',
                  onPressed: () => setState(() => _selected = 'strength'),
                ),
                const SizedBox(height: 8),
                WailyOption(
                  title: 'Cardio',
                  description: 'Endurance and zone 2',
                  isSelected: _selected == 'cardio',
                  onPressed: () => setState(() => _selected = 'cardio'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
