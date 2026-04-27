import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../components/buttons/waily_icon_button.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Icon button` variant: size x state.
class IconButtonsSection extends StatelessWidget {
  const IconButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Icon buttons',
      variants: [
        (
          label: 'Default / Default',
          child: WailyIconButton(
            icon: Assets.icons.common.arrow,
            onPressed: () {},
          ),
        ),
        (
          label: 'Default / Pressed (tap to feel ripple)',
          child: WailyIconButton(
            icon: Assets.icons.common.copy,
            onPressed: () {},
          ),
        ),
        (
          label: 'Default / Disabled',
          child: WailyIconButton(
            icon: Assets.icons.common.close,
            onPressed: () {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Big / Default',
          child: WailyIconButton(
            icon: Assets.icons.common.arrow,
            onPressed: () {},
            size: WailyIconButtonSize.big,
          ),
        ),
        (
          label: 'Big / Pressed (tap to feel ripple)',
          child: WailyIconButton(
            icon: Assets.icons.common.copy,
            onPressed: () {},
            size: WailyIconButtonSize.big,
          ),
        ),
        (
          label: 'Big / Disabled',
          child: WailyIconButton(
            icon: Assets.icons.common.close,
            onPressed: () {},
            size: WailyIconButtonSize.big,
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
