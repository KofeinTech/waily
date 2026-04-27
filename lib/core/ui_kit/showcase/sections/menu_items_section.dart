import 'package:flutter/material.dart';
import 'package:waily/core/gen/assets.gen.dart';
import '../../components/containers/waily_menu_item_container.dart';
import 'variant_grid.dart';

/// Showcases `WailyMenuItemContainer` default vs active states.
class MenuItemsSection extends StatefulWidget {
  const MenuItemsSection({super.key});

  @override
  State<MenuItemsSection> createState() => _MenuItemsSectionState();
}

class _MenuItemsSectionState extends State<MenuItemsSection> {
  String _active = 'home';

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Menu items',
      variants: [
        (
          label: 'Default',
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: false,
            onPressed: () {},
          ),
        ),
        (
          label: 'Active',
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: true,
            onPressed: () {},
          ),
        ),
        (
          label: 'Disabled',
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: true,
            onPressed: () {},
            isDisabled: true,
          ),
        ),
        (
          label: 'Interactive nav',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WailyMenuItemContainer(
                icon: Assets.icons.nav.home,
                label: 'Home',
                isActive: _active == 'home',
                onPressed: () => setState(() => _active = 'home'),
              ),
              const SizedBox(width: 4),
              WailyMenuItemContainer(
                icon: Assets.icons.nav.meal,
                label: 'Meal',
                isActive: _active == 'meal',
                onPressed: () => setState(() => _active = 'meal'),
              ),
              const SizedBox(width: 4),
              WailyMenuItemContainer(
                icon: Assets.icons.nav.profile,
                label: 'Profile',
                isActive: _active == 'profile',
                onPressed: () => setState(() => _active = 'profile'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
