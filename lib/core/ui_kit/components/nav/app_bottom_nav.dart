import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../router/app_routes.dart';
import '../../extensions/theme_context_extension.dart';
import '../../theme/app_colors.dart';
import '../icons/waily_icon.dart';

/// Bottom navigation bar driving the 5-branch shell.
///
/// Receives the active branch index and a tap callback from the
/// hosting `StatefulShellRoute`. Keeps zero state of its own.
///
/// Geometry / fill come straight from the Figma `Menu List` frame
/// inside `Nav Bar` (393x58, surface fill, padding 16/12/16/6). The
/// extra 30pt the Figma `Nav Bar` adds below is the iOS home
/// indicator zone, contributed at runtime by `SafeArea(top: false)`.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.currentIndex, required this.onTap, super.key});

  /// Index into [AppRoutes.shellBranchOrder].
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _height = 58;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < AppRoutes.shellBranchOrder.length; i++)
                  _NavItem(
                    key: ValueKey('app-bottom-nav-item-${AppRoutes.shellBranchOrder[i]}'),
                    branch: AppRoutes.shellBranchOrder[i],
                    isActive: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({required this.branch, required this.isActive, required this.onTap, super.key});

  final String branch;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 350);
  static const Curve _curve = Curves.easeOutCubic;

  /// Content / Secondary / Disabled — white at 30% alpha.
  static const Color _inactiveIconColor = Color(0x4DFFFFFF);

  /// Content / Primary / Inverted — full white.
  static const Color _activeIconColor = Color(0xFFFFFFFF);

  late final AnimationController _controller;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration, value: widget.isActive ? 1.0 : 0.0);
    _expand = CurvedAnimation(parent: _controller, curve: _curve);
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.appMenuItemContainerStyle;
    final t = context.appTextStyles;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(s.borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(s.borderRadius),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          height: s.height,
          padding: EdgeInsets.symmetric(horizontal: s.horizontalPadding, vertical: s.verticalPadding),
          decoration: BoxDecoration(
            color: widget.isActive ? s.activeBackgroundColor : Colors.transparent,
            borderRadius: BorderRadius.circular(s.borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WailyIcon(
                icon: _iconFor(widget.branch),
                size: s.iconSize,
                color: widget.isActive ? _activeIconColor : _inactiveIconColor,
              ),
              ClipRect(
                child: AnimatedBuilder(
                  animation: _expand,
                  builder: (context, child) {
                    // heightFactor: 1.0 keeps the Align tight to the child's
                    // intrinsic height. Without it Align expands to the row's
                    // full 24px and the inner Alignment(_, 0) reproduces the
                    // 4px optical offset reported earlier — with it, the
                    // outer Row's crossAxis.center centers the label box
                    // exactly the way the original WailyMenuItemContainer
                    // does (no extra wrapper geometry to drift through).
                    return Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _expand.value,
                      heightFactor: 1.0,
                      child: FadeTransition(opacity: _expand, child: child),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: s.itemSpacing),
                      Text(
                        AppRoutes.tabLabels[widget.branch]!,
                        style: t.s12w500(color: _activeIconColor),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SvgGenImage _iconFor(String branch) {
    switch (branch) {
      case AppRoutes.home:
        return Assets.icons.nav.home;
      case AppRoutes.meal:
        return Assets.icons.nav.meal;
      case AppRoutes.chat:
        return Assets.icons.nav.waily;
      case AppRoutes.hydration:
        return Assets.icons.nav.hydration;
      case AppRoutes.profile:
        return Assets.icons.nav.profile;
    }
    throw StateError('Unknown nav branch: $branch');
  }
}
