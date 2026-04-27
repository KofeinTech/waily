import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../extensions/theme_context_extension.dart';
import '../icons/waily_icon.dart';

/// Slide-to-confirm button — Figma `Slide Button`.
///
/// Idle: thumb pinned left, label fully visible. During horizontal drag the
/// thumb follows the finger; the shape behind it grows toward the right and
/// the label fades proportionally (`opacity = 1 - progress`,
/// `progress = dx / maxDx`). On release at `progress >= 0.9` the thumb
/// snaps to the right edge (200 ms, ease-out), triggers a medium haptic,
/// fires [onConfirmed], and the widget locks via `IgnorePointer` until
/// [WailySlideButtonState.reset] is called through a [GlobalKey]. Below
/// 0.9 the thumb springs back to the start (300 ms, ease-out-back).
class WailySlideButton extends StatefulWidget {
  const WailySlideButton({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.isDisabled = false,
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool isDisabled;

  @override
  State<WailySlideButton> createState() => WailySlideButtonState();
}

class WailySlideButtonState extends State<WailySlideButton>
    with SingleTickerProviderStateMixin {
  static const Duration _confirmSnapDuration = Duration(milliseconds: 200);
  static const Duration _springBackDuration = Duration(milliseconds: 300);

  double _offset = 0;
  double _maxOffset = 0;
  bool _confirmed = false;

  late final AnimationController _settle;
  Animation<double>? _settleAnim;

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(vsync: this);
    _settle.addListener(_onSettleTick);
  }

  @override
  void dispose() {
    _settle
      ..removeListener(_onSettleTick)
      ..dispose();
    super.dispose();
  }

  void _onSettleTick() {
    final value = _settleAnim?.value;
    if (value == null) return;
    setState(() => _offset = value);
  }

  void _settleTo(
    double target, {
    required Duration duration,
    required Curve curve,
    VoidCallback? onDone,
  }) {
    _settle.stop();
    _settle.duration = duration;
    _settleAnim = Tween<double>(begin: _offset, end: target)
        .chain(CurveTween(curve: curve))
        .animate(_settle);
    _settle.forward(from: 0).then((_) {
      if (!mounted) return;
      if (onDone != null) onDone();
    });
  }

  /// Resets the button to its idle state. Call via a [GlobalKey] after the
  /// caller has finished handling the confirmed action.
  void reset() {
    if (!mounted) return;
    _settle.stop();
    setState(() {
      _offset = 0;
      _confirmed = false;
      _settleAnim = null;
    });
  }

  void _onDragStart(DragStartDetails _) {
    if (widget.isDisabled || _confirmed) return;
    if (_settle.isAnimating) {
      _settle.stop();
      _settleAnim = null;
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (widget.isDisabled || _confirmed) return;
    if (_settle.isAnimating) {
      _settle.stop();
      _settleAnim = null;
    }
    final next = (_offset + d.delta.dx).clamp(0.0, _maxOffset);
    setState(() => _offset = next);
  }

  void _onDragEnd(DragEndDetails _) {
    if (widget.isDisabled || _confirmed) return;
    final progress = _maxOffset > 0 ? _offset / _maxOffset : 0.0;
    final threshold = context.appSlideButtonStyle.confirmThreshold;
    if (progress >= threshold) {
      _confirmed = true;
      _settleTo(
        _maxOffset,
        duration: _confirmSnapDuration,
        curve: Curves.easeOut,
        onDone: () {
          HapticFeedback.mediumImpact();
          widget.onConfirmed();
        },
      );
    } else {
      _settleTo(
        0,
        duration: _springBackDuration,
        curve: Curves.easeOutBack,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.appSlideButtonStyle;
    final t = context.appTextStyles;

    final Color trackColor = widget.isDisabled
        ? s.disabledTrackColor
        : s.trackColor;
    final Color iconColor =
        widget.isDisabled ? s.disabledIconColor : s.iconColor;
    final Color labelColor =
        widget.isDisabled ? s.disabledLabelColor : s.labelColor;
    final Color shapeColor =
        widget.isDisabled ? s.disabledTrackColor : s.thumbHaloColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        // Thumb sits inside a 4px inset (Figma); horizontal travel is the
        // remaining interior width.
        _maxOffset = trackWidth - s.padding * 2 - s.thumbWidth;

        // Visible drag fraction (clamped because easeOutBack overshoots).
        final double rawProgress =
            _maxOffset > 0 ? _offset / _maxOffset : 0.0;
        final double progress = rawProgress.clamp(0.0, 1.0);

        final double thumbLeft = s.padding + _offset;
        // Shape trails behind the thumb: starts at the track's left edge and
        // grows from 0 up to the thumb's left edge as the user drags right.
        // At full drag the extra padding+thumb area is filled in with
        // progress so the shape covers the entire button.
        final double overflowAtEnd = s.padding * 2 + s.thumbWidth;
        final double shapeWidth = _offset + overflowAtEnd * progress;

        final Widget content = Container(
          height: s.height,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(s.borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: s.padding),
                child: Text(
                  widget.label,
                  style: t.s16w400(
                    color: labelColor.withValues(
                      alpha: (1 - progress).clamp(0.0, 1.0),
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (shapeWidth > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: shapeWidth,
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _LiquidShapePainter(
                        color: shapeColor,
                        progress: progress,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: thumbLeft,
                top: s.padding,
                bottom: s.padding,
                child: IgnorePointer(
                  child: Container(
                    width: s.thumbWidth,
                    decoration: BoxDecoration(
                      gradient: widget.isDisabled
                          ? null
                          : RadialGradient(
                              colors: [
                                s.thumbGradientStart,
                                s.thumbGradientEnd,
                              ],
                            ),
                      color: widget.isDisabled ? s.disabledTrackColor : null,
                      borderRadius: BorderRadius.circular(
                        s.thumbBorderRadius,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: WailyIcon(
                      icon: Assets.icons.common.arrows,
                      size: s.iconSize,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              // Drag area covers the whole track so the finger can move
              // anywhere across the button without losing the gesture.
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                ),
              ),
            ],
          ),
        );

        return IgnorePointer(ignoring: _confirmed, child: content);
      },
    );
  }
}

/// Paints the trailing shape with a Bezier-curved right edge so the leading
/// silhouette feels organic — a "liquid" wave that ripples outward as the
/// shape grows. The bulge softens to a flush vertical edge as progress
/// approaches 1 so the confirmed end-state lands cleanly against the track's
/// rounded clip.
class _LiquidShapePainter extends CustomPainter {
  _LiquidShapePainter({required this.color, required this.progress});

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    // Bulge: peak in the middle of drag, decays to 0 at both ends.
    // sin(progress * pi) gives a 0 → 1 → 0 curve.
    final double bulgeAmount = 18 * _bell(progress);

    final double w = size.width;
    final double h = size.height;
    final double midY = h / 2;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w - bulgeAmount, 0)
      // Right edge: cubic Bezier bulging outward to the right.
      ..cubicTo(
        w + bulgeAmount * 0.6,
        midY * 0.4,
        w + bulgeAmount * 0.6,
        h - midY * 0.4,
        w - bulgeAmount,
        h,
      )
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// Parabolic bell: 0 at t=0 and t=1, peak 1 at t=0.5.
  double _bell(double t) {
    final c = t.clamp(0.0, 1.0);
    return 4 * c * (1 - c);
  }

  @override
  bool shouldRepaint(_LiquidShapePainter old) =>
      old.color != color || old.progress != progress;
}
