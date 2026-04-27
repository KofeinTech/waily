import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/gen/assets.gen.dart';
import 'package:waily/core/ui_kit/components/containers/waily_menu_item_container.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import 'package:waily/core/ui_kit/extensions/app_menu_item_container_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyMenuItemContainer', () {
    testWidgets('default state shows the icon only (no label)', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('active state shows icon + label', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: true,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: false,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailyMenuItemContainer));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: false,
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyMenuItemContainer));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('active state paints activeBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: true,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailyMenuItemContainer),
      );
      final s = Theme.of(context).extension<AppMenuItemContainerStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyMenuItemContainer),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.activeBackgroundColor,
      );
    });

    testWidgets('default state paints defaultBackgroundColor (transparent)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailyMenuItemContainer),
      );
      final s = Theme.of(context).extension<AppMenuItemContainerStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyMenuItemContainer),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.defaultBackgroundColor,
      );
    });

    testWidgets('container height equals AppMenuItemContainerStyle.height (40)',
        (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMenuItemContainer(
            icon: Assets.icons.nav.home,
            label: 'Home',
            isActive: true,
            onPressed: () {},
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyMenuItemContainer));
      expect(size.height, 40);
    });
  });
}
