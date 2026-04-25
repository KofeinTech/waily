import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// General-purpose card container.
///
/// Reads visual properties from [AppCardStyle]. Accepts any [child].
/// Use [padding] to override the theme default.
///
/// Example:
/// ```dart
/// WailyCard(
///   child: Column(children: [...]),
/// )
/// ```
class WailyCard extends StatelessWidget {
  const WailyCard({super.key, required this.child, this.padding});

  final Widget child;

  /// Overrides [AppCardStyle.padding] when provided.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final s = context.appCardStyle;
    final radius = BorderRadius.circular(s.borderRadius);

    return Material(
      color: s.backgroundColor,
      elevation: s.elevation,
      shadowColor: s.shadowColor,
      borderRadius: radius,
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(padding: padding ?? s.padding, child: child),
      ),
    );
  }
}
