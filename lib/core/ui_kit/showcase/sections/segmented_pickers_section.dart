import 'package:flutter/material.dart';
import '../../components/inputs/waily_segmented_picker.dart';
import 'variant_grid.dart';

/// Showcases `WailySegmentedPicker` with two- and three-item lists.
class SegmentedPickersSection extends StatefulWidget {
  const SegmentedPickersSection({super.key});

  @override
  State<SegmentedPickersSection> createState() =>
      _SegmentedPickersSectionState();
}

class _SegmentedPickersSectionState extends State<SegmentedPickersSection> {
  String _unit = 'cm';
  String _gender = 'female';

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Segmented pickers',
      variants: [
        (
          label: 'State=Left (cm selected)',
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) {},
          ),
        ),
        (
          label: 'State=Right (ft/in selected)',
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'ft',
            onChanged: (_) {},
          ),
        ),
        (
          label: 'Interactive 2-item',
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: _unit,
            onChanged: (v) => setState(() => _unit = v),
          ),
        ),
        (
          label: 'Interactive 3-item',
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'female', label: 'Female'),
              (value: 'male', label: 'Male'),
              (value: 'other', label: 'Other'),
            ],
            value: _gender,
            onChanged: (v) => setState(() => _gender = v),
          ),
        ),
        (
          label: 'Disabled',
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) {},
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
