import 'package:flutter/material.dart';
import '../../components/containers/waily_list_element.dart';
import 'variant_grid.dart';

/// Showcases the Figma `List element` variants.
class ListElementsSection extends StatelessWidget {
  const ListElementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'List elements',
      variants: [
        (
          label: 'Default (label only)',
          child: SizedBox(
            width: 361,
            child: WailyListElement(label: 'Account', onPressed: () {}),
          ),
        ),
        (
          label: '2 text (label + value)',
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Plan',
              value: 'Pro',
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Locked option',
              value: 'Soon',
              onPressed: () {},
              isDisabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
