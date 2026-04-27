import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_segmented_button.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import 'package:waily/core/ui_kit/extensions/app_segmented_button_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailySegmentedButton', () {
    testWidgets('renders the supplied label', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('body tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailySegmentedButton));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks body tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailySegmentedButton));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('close icon hidden when onClose is null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsNothing);
    });

    testWidgets('close icon rendered when onClose is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
            onClose: () {},
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsOneWidget);
    });

    testWidgets('tapping close icon fires onClose, not onPressed', (
      tester,
    ) async {
      var pressTaps = 0;
      var closeTaps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () => pressTaps++,
            onClose: () => closeTaps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailyIcon));
      await tester.pump();
      expect(closeTaps, 1);
      expect(pressTaps, 0);
    });

    testWidgets('active state paints activeBackgroundColor and activeLabelColor',
        (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: true,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailySegmentedButton),
      );
      final s = Theme.of(context).extension<AppSegmentedButtonStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailySegmentedButton),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.activeBackgroundColor,
      );
      final text = tester.widget<Text>(find.text('Coffee'));
      expect(text.style!.color, s.activeLabelColor);
    });

    testWidgets('default state paints defaultBackgroundColor (white@12%)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailySegmentedButton),
      );
      final s = Theme.of(context).extension<AppSegmentedButtonStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailySegmentedButton),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.defaultBackgroundColor,
      );
    });

    testWidgets('container height equals AppSegmentedButtonStyle.height (48)',
        (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedButton(
            label: 'Coffee',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailySegmentedButton));
      expect(size.height, 48);
    });
  });
}
