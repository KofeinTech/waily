import 'package:flutter/material.dart';
import '../../components/containers/waily_picker_card.dart';
import 'variant_grid.dart';

/// Showcases all Figma `Picker Card` states.
class PickerCardsSection extends StatefulWidget {
  const PickerCardsSection({super.key});

  @override
  State<PickerCardsSection> createState() => _PickerCardsSectionState();
}

class _PickerCardsSectionState extends State<PickerCardsSection> {
  String _selected = 'hybrid';

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Picker cards',
      variants: [
        (
          label: 'Default',
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              subtitle: 'HYROX, run + lift, mixed conditioning',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Selected (with checkmark)',
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              subtitle: 'HYROX, run + lift, mixed conditioning',
              isSelected: true,
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Title only',
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Strength',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              subtitle: 'Locked option',
              isSelected: false,
              onPressed: () {},
              isDisabled: true,
            ),
          ),
        ),
        (
          label: 'Interactive group',
          child: SizedBox(
            width: 361,
            child: Column(
              children: [
                WailyPickerCard(
                  title: 'Hybrid',
                  subtitle: 'HYROX, run + lift',
                  isSelected: _selected == 'hybrid',
                  onPressed: () => setState(() => _selected = 'hybrid'),
                ),
                const SizedBox(height: 8),
                WailyPickerCard(
                  title: 'Strength',
                  subtitle: 'Heavy compound lifts',
                  isSelected: _selected == 'strength',
                  onPressed: () => setState(() => _selected = 'strength'),
                ),
                const SizedBox(height: 8),
                WailyPickerCard(
                  title: 'Cardio',
                  subtitle: 'Endurance and zone 2',
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
