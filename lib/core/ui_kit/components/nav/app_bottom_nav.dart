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
/// Geometry / fill come straight from the Figma `Nav Bar` frame
/// (393x80, surface fill, MenuList padding 16/12).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  /// Index into [AppRoutes.shellBranchOrder].
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _height = 80;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < AppRoutes.shellBranchOrder.length; i++)
                  Expanded(
                    child: _NavItem(
                      key: ValueKey(
                        'app-bottom-nav-item-${AppRoutes.shellBranchOrder[i]}',
                      ),
                      branch: AppRoutes.shellBranchOrder[i],
                      isActive: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.branch,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final String branch;
  final bool isActive;
  final VoidCallback onTap;

  static const Duration _duration = Duration(milliseconds: 250);
  static const Curve _curve = Curves.easeOutCubic;

  /// Content / Secondary / Disabled — white at 30% alpha.
  static const Color _inactiveIconColor = Color(0x4DFFFFFF);

  /// Content / Primary / Inverted — full white.
  static const Color _activeIconColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final s = context.appMenuItemContainerStyle;
    final t = context.appTextStyles;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          height: s.height,
          padding: EdgeInsets.symmetric(
            horizontal: s.horizontalPadding,
            vertical: s.verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isActive ? s.activeBackgroundColor : Colors.transparent,
            borderRadius: BorderRadius.circular(s.borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TweenAnimationBuilder<Color?>(
                duration: _duration,
                curve: _curve,
                tween: ColorTween(
                  end: isActive ? _activeIconColor : _inactiveIconColor,
                ),
                builder: (context, color, _) => WailyIcon(
                  icon: _iconFor(branch),
                  size: s.iconSize,
                  color: color ?? _inactiveIconColor,
                ),
              ),
              AnimatedSize(
                duration: _duration,
                curve: _curve,
                child: AnimatedSwitcher(
                  duration: _duration,
                  switchInCurve: _curve,
                  switchOutCurve: _curve,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: isActive
                      ? Padding(
                          key: const ValueKey('label'),
                          padding: EdgeInsets.only(left: s.itemSpacing),
                          child: Text(
                            AppRoutes.tabLabels[branch]!,
                            style: t.s12w500(color: _activeIconColor),
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('no-label')),
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
