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
          label: 'Primary / Small',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            size: WailyButtonSize.small,
          ),
        ),
        (
          label: 'Primary / Small / Disabled',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            size: WailyButtonSize.small,
            isDisabled: true,
          ),
        ),
        (
          label: 'Primary / Small / Loading',
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            size: WailyButtonSize.small,
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
          label: 'Secondary / Small',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            size: WailyButtonSize.small,
          ),
        ),
        (
          label: 'Secondary / Small / Disabled',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            size: WailyButtonSize.small,
            isDisabled: true,
          ),
        ),
        (
          label: 'Secondary / Small / Loading',
          child: WailyButton.secondary(
            label: 'Skip',
            onPressed: () {},
            size: WailyButtonSize.small,
            isLoading: true,
          ),
        ),
      ],
    );
  }
}
