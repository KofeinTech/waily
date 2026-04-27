import 'package:flutter/material.dart';
import '../../components/buttons/waily_slide_button.dart';
import 'variant_grid.dart';

/// Showcases `WailySlideButton` enabled and disabled states.
class SlideButtonsSection extends StatelessWidget {
  const SlideButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Slide buttons',
      variants: [
        (
          label: 'Default (drag thumb to confirm)',
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () {},
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () {},
              isDisabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
