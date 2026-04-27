import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';

/// App icon widget backed by a typed [SvgGenImage] from flutter_gen.
///
/// Color defaults to [AppColorStyle.icon]. Override with [color].
///
/// Example:
/// ```dart
/// WailyIcon(icon: Assets.icons.home)
/// WailyIcon(icon: Assets.icons.close, size: 20, color: context.appColors.error)
/// ```
class WailyIcon extends StatelessWidget {
  const WailyIcon({super.key, required this.icon, this.size, this.color});

  final SvgGenImage icon;

  /// Width and height in logical pixels.
  final double? size;

  /// Icon color. Defaults to [AppColorStyle.icon].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? context.appColors.icon;
    return icon.svg(
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}
