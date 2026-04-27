import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_switcher.dart';
import 'package:waily/core/ui_kit/extensions/app_switcher_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailySwitcher', () {
    testWidgets('renders 64x32 by default', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(value: false, onChanged: (_) {}),
        ),
      );
      final size = tester.getSize(find.byType(WailySwitcher));
      expect(size.width, 64);
      expect(size.height, 32);
    });

    testWidgets('tap toggles via negated value', (tester) async {
      bool? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(value: false, onChanged: (v) => received = v),
        ),
      );
      await tester.tap(find.byType(WailySwitcher));
      await tester.pump();
      expect(received, true);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(
            value: false,
            onChanged: (_) => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailySwitcher));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('null onChanged blocks tap without exception', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailySwitcher(value: false, onChanged: null),
        ),
      );
      await tester.tap(find.byType(WailySwitcher));
      await tester.pump();
      expect(find.byType(WailySwitcher), findsOneWidget);
    });

    testWidgets('off state thumb sits at thumbPadding', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(value: false, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      final BuildContext context = tester.element(find.byType(WailySwitcher));
      final s = Theme.of(context).extension<AppSwitcherStyle>()!;
      final positioned = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(positioned.left, s.thumbPadding);
    });

    testWidgets('on state thumb sits at trackWidth - thumbSize - padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(value: true, onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      final BuildContext context = tester.element(find.byType(WailySwitcher));
      final s = Theme.of(context).extension<AppSwitcherStyle>()!;
      final positioned = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(positioned.left, s.trackWidth - s.thumbSize - s.thumbPadding);
    });

    testWidgets('off state paints trackColorOff and thumbColorOff', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(value: false, onChanged: (_) {}),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailySwitcher));
      final s = Theme.of(context).extension<AppSwitcherStyle>()!;
      final track = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect((track.decoration as BoxDecoration).color, s.trackColorOff);

      final thumbContainers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(WailySwitcher),
              matching: find.byType(Container),
            ),
          )
          .toList();
      // The Container with circle shape is the thumb.
      final thumb = thumbContainers.firstWhere(
        (c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
      expect((thumb.decoration as BoxDecoration).color, s.thumbColorOff);
    });

    testWidgets('on state paints trackColorOn and thumbColorOn', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(value: true, onChanged: (_) {}),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailySwitcher));
      final s = Theme.of(context).extension<AppSwitcherStyle>()!;
      final track = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect((track.decoration as BoxDecoration).color, s.trackColorOn);

      final thumbContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(WailySwitcher),
          matching: find.byType(Container),
        ),
      );
      final thumb = thumbContainers.firstWhere(
        (c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
      expect((thumb.decoration as BoxDecoration).color, s.thumbColorOn);
    });

    testWidgets('disabled state paints disabled track + thumb colors', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySwitcher(
            value: true,
            onChanged: (_) {},
            isDisabled: true,
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailySwitcher));
      final s = Theme.of(context).extension<AppSwitcherStyle>()!;
      final track = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect((track.decoration as BoxDecoration).color, s.trackColorDisabled);

      final thumbContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(WailySwitcher),
          matching: find.byType(Container),
        ),
      );
      final thumb = thumbContainers.firstWhere(
        (c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle,
      );
      expect((thumb.decoration as BoxDecoration).color, s.thumbColorDisabled);
    });
  });
}
