import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../components/icons/waily_icon.dart';
import '../../extensions/theme_context_extension.dart';
import '../../theme/app_spacing.dart';
import 'variant_grid.dart';

/// Showcases [WailyIcon] in multiple sizes and colors using the typed
/// flutter_gen `Assets.icons.*` accessors.
class IconsSection extends StatelessWidget {
  const IconsSection({super.key});

  static const _sizes = [16.0, 20.0, 24.0, 32.0];

  @override
  Widget build(BuildContext context) {
    final primary = context.appColors.primary;
    final icons = [
      ('home', Assets.icons.nav.home),
      ('arrow', Assets.icons.common.arrow),
      ('close', Assets.icons.common.close),
      ('send', Assets.icons.chat.send),
    ];

    return ShowcaseVariantGrid(
      title: 'Icons',
      variants: [
        for (final (name, icon) in icons)
          (
            label: '$name / default',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final size in _sizes) ...[
                  WailyIcon(icon: icon, size: size),
                  if (size != _sizes.last) const SizedBox(width: AppSpacing.s),
                ],
              ],
            ),
          ),
        for (final (name, icon) in icons)
          (
            label: '$name / primary',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final size in _sizes) ...[
                  WailyIcon(icon: icon, size: size, color: primary),
                  if (size != _sizes.last) const SizedBox(width: AppSpacing.s),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
