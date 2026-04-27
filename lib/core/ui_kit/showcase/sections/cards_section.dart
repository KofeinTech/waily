import 'package:flutter/material.dart';
import '../../components/cards/waily_card.dart';
import '../../extensions/theme_context_extension.dart';
import '../../theme/app_spacing.dart';
import 'variant_grid.dart';

/// Showcases the general-purpose [WailyCard] (default + custom padding).
class CardsSection extends StatelessWidget {
  const CardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Cards',
      variants: [
        (
          label: 'Default',
          child: WailyCard(
            child: Text('Default card', style: context.appTextStyles.s16w500()),
          ),
        ),
        (
          label: 'Custom padding (32)',
          child: WailyCard(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text('Padded', style: context.appTextStyles.s16w500()),
          ),
        ),
      ],
    );
  }
}
