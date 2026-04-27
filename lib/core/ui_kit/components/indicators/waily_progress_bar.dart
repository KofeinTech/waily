import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Linear progress bar.
///
/// Renders the Figma `Progress Bar`: a full-radius pill, white fill on a
/// surface track. Pass [progress] in [0, 1] for determinate mode; pass null
/// to switch to indeterminate animation. Reads height/colors from
/// [AppProgressBarStyle].
class WailyProgressBar extends StatelessWidget {
  const WailyProgressBar({super.key, this.progress})
    : assert(
        progress == null || (progress >= 0 && progress <= 1),
        'progress must be null or within [0, 1]',
      );

  /// Determinate fill ratio in [0, 1]. Null → indeterminate animation.
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final s = context.appProgressBarStyle;
    return ClipRRect(
      borderRadius: BorderRadius.circular(s.height / 2),
      child: SizedBox(
        height: s.height,
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: s.trackColor,
          valueColor: AlwaysStoppedAnimation<Color>(s.fillColor),
          minHeight: s.height,
        ),
      ),
    );
  }
}
