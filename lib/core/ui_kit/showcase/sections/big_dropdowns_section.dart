import 'package:flutter/material.dart';
import '../../components/inputs/waily_big_dropdown.dart';
import 'variant_grid.dart';

/// Showcases `WailyBigDropdown` trigger surface variants.
class BigDropdownsSection extends StatelessWidget {
  const BigDropdownsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Big dropdowns',
      variants: [
        (
          label: 'Title + Subtitle',
          child: SizedBox(
            width: 358,
            child: WailyBigDropdown(
              title: 'Hybrid',
              subtitle: 'HYROX, run + lift, mixed conditioning',
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Title only',
          child: SizedBox(
            width: 358,
            child: WailyBigDropdown(
              title: 'Strength training',
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 358,
            child: WailyBigDropdown(
              title: 'Hybrid',
              subtitle: 'HYROX, run + lift',
              onPressed: () {},
              isDisabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
