import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../containers/waily_menu_item_container.dart';

/// Bottom navigation bar driving the 5-branch shell.
///
/// Receives the active branch index and a tap callback from the
/// hosting `StatefulShellRoute`. Keeps zero state of its own.
///
/// Geometry / fill come straight from the Figma `Nav Bar` frame
/// (393x88, surface fill, MenuList padding 16/12).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  /// Index into [AppRoutes.shellBranchOrder].
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _height = 88;

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
                  _buildItem(context, i),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final branch = AppRoutes.shellBranchOrder[index];
    return WailyMenuItemContainer(
      key: ValueKey('app-bottom-nav-item-$branch'),
      icon: _iconFor(branch),
      label: AppRoutes.tabLabels[branch]!,
      isActive: index == currentIndex,
      onPressed: () => onTap(index),
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
