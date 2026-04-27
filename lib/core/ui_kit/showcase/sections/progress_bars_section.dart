import 'package:flutter/material.dart';
import '../../components/indicators/waily_progress_bar.dart';
import '../../theme/app_spacing.dart';
import 'variant_grid.dart';

/// Showcases determinate and indeterminate `Progress Bar` states.
class ProgressBarsSection extends StatelessWidget {
  const ProgressBarsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Progress bars',
      variants: [
        (
          label: '0%',
          child: SizedBox(
            width: 240,
            child: WailyProgressBar(progress: 0),
          ),
        ),
        (
          label: '50%',
          child: SizedBox(
            width: 240,
            child: WailyProgressBar(progress: 0.5),
          ),
        ),
        (
          label: '100%',
          child: SizedBox(
            width: 240,
            child: WailyProgressBar(progress: 1),
          ),
        ),
        (
          label: 'Indeterminate',
          child: SizedBox(
            width: 240,
            child: const WailyProgressBar(),
          ),
        ),
        (
          label: 'Stretches with constraints',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: const WailyProgressBar(progress: 0.7),
          ),
        ),
      ],
    );
  }
}
