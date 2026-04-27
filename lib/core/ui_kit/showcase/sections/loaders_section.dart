import 'package:flutter/material.dart';
import '../../components/indicators/waily_loader.dart';
import 'variant_grid.dart';

/// Showcases `WailyLoader` at the default Figma size and a few overrides.
class LoadersSection extends StatelessWidget {
  const LoadersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Loaders',
      variants: [
        (
          label: 'Default (24)',
          child: WailyLoader(),
        ),
        (
          label: 'Small (12)',
          child: WailyLoader(size: 12),
        ),
        (
          label: 'Large (32)',
          child: WailyLoader(size: 32),
        ),
      ],
    );
  }
}
