import 'package:flutter/material.dart';
import '../../components/buttons/waily_button.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Button` variant: type × size × state.
class ButtonsSection extends StatelessWidget {
  const ButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Buttons',
      variants: [
        (
          label: 'Primary / Default',
          child: WailyButton.primary(label: 'Continue', onPressed: () {}),
        ),
        (
          label: 'Primary / Default / Disabled',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Primary / Default / Loading',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            isLoading: true,
          ),
        ),
        (
          label: 'Primary / Big',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            size: WailyButtonSize.big,
          ),
        ),
        (
          label: 'Primary / Big / Disabled',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            size: WailyButtonSize.big,
            isDisabled: true,
          ),
        ),
        (
          label: 'Primary / Big / Loading',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            size: WailyButtonSize.big,
            isLoading: true,
          ),
        ),
        (
          label: 'Secondary / Default',
          child: WailyButton.secondary(label: 'Skip', onPressed: () {}),
        ),
        (
          label: 'Secondary / Default / Disabled',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Secondary / Default / Loading',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            isLoading: true,
          ),
        ),
        (
          label: 'Secondary / Big',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            size: WailyButtonSize.big,
          ),
        ),
        (
          label: 'Secondary / Big / Disabled',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            size: WailyButtonSize.big,
            isDisabled: true,
          ),
        ),
        (
          label: 'Secondary / Big / Loading',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            size: WailyButtonSize.big,
            isLoading: true,
          ),
        ),
      ],
    );
  }
}
