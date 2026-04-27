import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_checkbox.dart';
import 'package:waily/core/ui_kit/extensions/app_checkbox_style.dart';
import '../helpers/test_theme_wrapper.dart';

Container _findContainer(WidgetTester tester) {
  return tester.widget<Container>(
    find.descendant(
      of: find.byType(WailyCheckbox),
      matching: find.byType(Container),
    ),
  );
}

void main() {
  group('WailyCheckbox', () {
    testWidgets('renders 24x24 by default', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: false, onChanged: (_) {}),
        ),
      );
      final size = tester.getSize(find.byType(WailyCheckbox));
      expect(size.width, 24);
      expect(size.height, 24);
    });

    testWidgets('value=false hides the checkmark', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: false, onChanged: (_) {}),
        ),
      );
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('value=true shows the checkmark', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: true, onChanged: (_) {}),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tap fires onChanged with negated value', (tester) async {
      bool? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: false, onChanged: (v) => received = v),
        ),
      );
      await tester.tap(find.byType(WailyCheckbox));
      await tester.pump();
      expect(received, true);
    });

    testWidgets('tap on active fires onChanged(false)', (tester) async {
      bool? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: true, onChanged: (v) => received = v),
        ),
      );
      await tester.tap(find.byType(WailyCheckbox));
      await tester.pump();
      expect(received, false);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(
            value: false,
            onChanged: (_) => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyCheckbox));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('null onChanged blocks tap without exception', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyCheckbox(value: false, onChanged: null),
        ),
      );
      await tester.tap(find.byType(WailyCheckbox));
      await tester.pump();
      expect(find.byType(WailyCheckbox), findsOneWidget);
    });

    testWidgets('default state paints transparent fill + borderStrong stroke', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: false, onChanged: (_) {}),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyCheckbox));
      final s = Theme.of(context).extension<AppCheckboxStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.defaultFillColor);
      expect(deco.border!.top.color, s.defaultBorderColor);
      expect(deco.shape, BoxShape.circle);
    });

    testWidgets('active state paints solid activeFillColor disc', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: true, onChanged: (_) {}),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyCheckbox));
      final s = Theme.of(context).extension<AppCheckboxStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.activeFillColor);
      expect(deco.shape, BoxShape.circle);
    });

    testWidgets('checkmark icon size matches AppCheckboxStyle.iconSize', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(value: true, onChanged: (_) {}),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      final BuildContext context = tester.element(find.byType(WailyCheckbox));
      final s = Theme.of(context).extension<AppCheckboxStyle>()!;
      expect(icon.size, s.iconSize);
      expect(icon.color, s.checkmarkColor);
    });

    testWidgets('disabled + active uses disabled fill and checkmark color', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCheckbox(
            value: true,
            onChanged: (_) {},
            isDisabled: true,
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyCheckbox));
      final s = Theme.of(context).extension<AppCheckboxStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.disabledFillColor);
      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(icon.color, s.disabledCheckmarkColor);
    });
  });
}
