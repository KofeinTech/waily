import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/gen/assets.gen.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_icon_button.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import 'package:waily/core/ui_kit/extensions/app_icon_button_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyIconButton', () {
    testWidgets('renders the supplied icon via WailyIcon', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.arrow,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsOneWidget);
      final widget = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(widget.icon, Assets.icons.common.arrow);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.close,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailyIconButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.close,
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyIconButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('defaultSize yields a 48x48 container', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.copy,
            onPressed: () {},
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyIconButton));
      expect(size.width, 48);
      expect(size.height, 48);
    });

    testWidgets('big size yields a 52x52 container', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.copy,
            onPressed: () {},
            size: WailyIconButtonSize.big,
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyIconButton));
      expect(size.width, 52);
      expect(size.height, 52);
    });

    testWidgets('default size icon is 24, big size icon is 28', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.arrow,
            onPressed: () {},
          ),
        ),
      );
      final defaultIcon = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(defaultIcon.size, 24);

      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.arrow,
            onPressed: () {},
            size: WailyIconButtonSize.big,
          ),
        ),
      );
      final bigIcon = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(bigIcon.size, 28);
    });

    testWidgets('disabled paints the icon with iconColorDisabled (#9EA3AE)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.arrow,
            onPressed: () {},
            isDisabled: true,
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(WailyIconButton));
      final style = Theme.of(context).extension<AppIconButtonStyle>()!;

      final icon = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(icon.color, style.iconColorDisabled);
    });

    testWidgets('enabled paints the icon with iconColorDefault (white)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIconButton(
            icon: Assets.icons.common.arrow,
            onPressed: () {},
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(WailyIconButton));
      final style = Theme.of(context).extension<AppIconButtonStyle>()!;

      final icon = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(icon.color, style.iconColorDefault);
    });
  });
}
