import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_link.dart';
import 'package:waily/core/ui_kit/extensions/app_link_style.dart';
import '../helpers/test_theme_wrapper.dart';

Text _findLinkText(WidgetTester tester) {
  return tester.widget<Text>(
    find.descendant(
      of: find.byType(WailyLink),
      matching: find.byType(Text),
    ),
  );
}

void main() {
  group('WailyLink', () {
    testWidgets('renders the supplied label', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(label: 'Log in', onPressed: () {}),
        ),
      );
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('fires onPressed on tap when enabled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(label: 'Log in', onPressed: () => taps++),
        ),
      );
      await tester.tap(find.byType(WailyLink));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(
            label: 'Log in',
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyLink));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('null onPressed renders without firing', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyLink(label: 'Log in', onPressed: null),
        ),
      );
      await tester.tap(find.byType(WailyLink));
      await tester.pump();
      // No exception. Widget still rendered.
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('default color is AppLinkStyle.colorDefault', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(label: 'Log in', onPressed: () {}),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyLink));
      final style = Theme.of(context).extension<AppLinkStyle>()!;
      expect(_findLinkText(tester).style!.color, style.colorDefault);
    });

    testWidgets('disabled color is AppLinkStyle.colorDisabled', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(
            label: 'Log in',
            onPressed: () {},
            isDisabled: true,
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyLink));
      final style = Theme.of(context).extension<AppLinkStyle>()!;
      expect(_findLinkText(tester).style!.color, style.colorDisabled);
    });

    testWidgets('press-down swaps color to AppLinkStyle.colorPressed', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(label: 'Log in', onPressed: () {}),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyLink));
      final style = Theme.of(context).extension<AppLinkStyle>()!;

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(WailyLink)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(_findLinkText(tester).style!.color, style.colorPressed);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('label uses s16w500 metrics (size 16, weight 500)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(label: 'Log in', onPressed: () {}),
        ),
      );
      final textStyle = _findLinkText(tester).style!;
      expect(textStyle.fontSize, 16);
      expect(textStyle.fontWeight, FontWeight.w500);
    });

    testWidgets('vertical padding matches AppLinkStyle.verticalPadding', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyLink(label: 'Log in', onPressed: () {}),
        ),
      );
      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(WailyLink),
          matching: find.byType(Padding),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyLink));
      final style = Theme.of(context).extension<AppLinkStyle>()!;
      expect(
        padding.padding,
        EdgeInsets.symmetric(vertical: style.verticalPadding),
      );
    });
  });
}
