import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// Three-dot animated loader.
///
/// Renders the Figma `Loader` component-set: three dots cycling through five
/// keyframes — one dot at a time switches from [AppLoaderStyle.defaultDotColor]
/// to [AppLoaderStyle.activeDotColor]. Pass [size] to scale the whole control
/// proportionally; defaults read from [AppLoaderStyle].
class WailyLoader extends StatefulWidget {
  const WailyLoader({super.key, this.size});

  /// Optional dot diameter override. Spacing scales with the same factor so
  /// the layout stays in proportion to the Figma reference.
  final double? size;

  @override
  State<WailyLoader> createState() => _WailyLoaderState();
}

class _WailyLoaderState extends State<WailyLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = context.appLoaderStyle;
    _controller.duration = s.cycleDuration;
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.appLoaderStyle;
    final scale = widget.size != null ? widget.size! / s.dotSize : 1.0;
    final dotSize = s.dotSize * scale;
    final spacing = s.dotSpacing * scale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // 5 frames: idle, dot0, dot1, dot2, idle. Highlighted index in {0,1,2,-1}.
        final phase = (_controller.value * 5).floor() % 5;
        final activeIndex = switch (phase) {
          1 => 0,
          2 => 1,
          3 => 2,
          _ => -1,
        };
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : spacing),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: i == activeIndex
                      ? s.activeDotColor
                      : s.defaultDotColor,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
