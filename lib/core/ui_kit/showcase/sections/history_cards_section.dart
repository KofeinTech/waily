import 'package:flutter/material.dart';
import '../../components/containers/waily_history_card.dart';
import 'variant_grid.dart';

/// Showcases all three Figma `History card` variants.
class HistoryCardsSection extends StatelessWidget {
  const HistoryCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'History cards',
      variants: [
        (
          label: 'Default (daily)',
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(
              title: 'Rest Day · Good',
              subtitle: 'Saturday, March 28',
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Today (with pill)',
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(
              title: 'Strength · Best',
              subtitle: 'Sunday, March 29',
              isToday: true,
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Chat snippet',
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.chat(
              text: 'I trained hard and have low appetite. What should I do?',
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
