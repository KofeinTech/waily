import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/gen/assets.gen.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_button.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import 'package:waily/core/ui_kit/extensions/app_button_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyButton', () {
    testWidgets('primary renders label and fires onPressed on tap', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.byType(WailyButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('secondary renders label and fires onPressed on tap', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.secondary(label: 'Skip', onPressed: () => taps++),
        ),
      );
      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.byType(WailyButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Disabled',
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('loading shows CircularProgressIndicator and blocks tap', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Loading',
            onPressed: () => taps++,
            isLoading: true,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Label hidden while loading.
      expect(find.text('Loading'), findsNothing);
      await tester.tap(find.byType(WailyButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('small size yields height ~42 (shorter than default)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Small',
            onPressed: () {},
            size: WailyButtonSize.small,
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyButton));
      expect(size.height, greaterThanOrEqualTo(42));
      expect(size.height, lessThan(52));
    });

    testWidgets('default size yields height ~52', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(label: 'Default', onPressed: () {}),
        ),
      );
      final size = tester.getSize(find.byType(WailyButton));
      expect(size.height, 52);
    });

    testWidgets(
      'primary with leadingIcon renders WailyIcon at the leading position',
      (tester) async {
        await tester.pumpWidget(
          TestThemeWrapper(
            child: WailyButton.primary(
              label: 'Continue',
              onPressed: () {},
              leadingIcon: Assets.icons.common.arrow,
            ),
          ),
        );
        expect(find.byType(WailyIcon), findsOneWidget);
        final icon = tester.widget<WailyIcon>(find.byType(WailyIcon));
        expect(icon.icon, Assets.icons.common.arrow);
      },
    );

    testWidgets(
      'primary with both leading and action icons renders two WailyIcons',
      (tester) async {
        await tester.pumpWidget(
          TestThemeWrapper(
            child: WailyButton.primary(
              label: 'Continue',
              onPressed: () {},
              leadingIcon: Assets.icons.common.copy,
              actionIcon: Assets.icons.common.arrow,
            ),
          ),
        );
        expect(find.byType(WailyIcon), findsNWidgets(2));
      },
    );

    testWidgets('loading hides icons', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Loading',
            onPressed: () {},
            isLoading: true,
            leadingIcon: Assets.icons.common.copy,
            actionIcon: Assets.icons.common.arrow,
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('leadingIconColor overrides foreground', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            leadingIcon: Assets.icons.common.arrow,
            leadingIconColor: Colors.red,
          ),
        ),
      );
      final icon = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(icon.color, Colors.red);
    });

    testWidgets('leadingIconSize overrides default', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Continue',
            onPressed: () {},
            leadingIcon: Assets.icons.common.arrow,
            leadingIconSize: 24,
          ),
        ),
      );
      final icon = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(icon.size, 24);
    });

    testWidgets(
      'primary swaps to pressed background on press-down via WidgetState',
      (tester) async {
        await tester.pumpWidget(
          TestThemeWrapper(
            child: WailyButton.primary(label: 'Press', onPressed: () {}),
          ),
        );

        Color materialColor() {
          final material = tester.widget<Material>(
            find.descendant(
              of: find.byType(WailyButton),
              matching: find.byType(Material),
            ),
          );
          return material.color!;
        }

        // Resolve the expected pressed token from the theme — keep the
        // assertion source-of-truth aligned with AppButtonStyle.dark().
        final BuildContext context = tester.element(find.byType(WailyButton));
        final style = Theme.of(context).extension<AppButtonStyle>()!;

        expect(materialColor(), style.primaryBackground);

        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(WailyButton)),
        );
        await tester.pump(const Duration(milliseconds: 50));

        expect(materialColor(), style.primaryPressedBackground);

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
  });
}
