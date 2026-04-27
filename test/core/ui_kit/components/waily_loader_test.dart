import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/indicators/waily_loader.dart';
import 'package:waily/core/ui_kit/extensions/app_loader_style.dart';
import '../helpers/test_theme_wrapper.dart';

Iterable<Container> _dotContainers(WidgetTester tester) {
  return tester.widgetList<Container>(
    find.descendant(
      of: find.byType(WailyLoader),
      matching: find.byType(Container),
    ),
  );
}

void main() {
  group('WailyLoader', () {
    testWidgets('renders three circular dots', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyLoader()),
      );
      await tester.pump(); // settle one frame
      final dots = _dotContainers(tester)
          .where((c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle)
          .toList();
      expect(dots, hasLength(3));
      // Stop animation before tearDown so the test cleans up cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('default size respects AppLoaderStyle.dotSize', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyLoader()),
      );
      await tester.pump();
      final BuildContext context = tester.element(find.byType(WailyLoader));
      final s = Theme.of(context).extension<AppLoaderStyle>()!;
      final dot = _dotContainers(tester).first;
      expect(dot.constraints!.maxWidth, s.dotSize);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('size override scales dots proportionally', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyLoader(size: 12)),
      );
      await tester.pump();
      final dot = _dotContainers(tester).first;
      // size=12 → 50% of dotSize 24, so dot is 12 wide.
      expect(dot.constraints!.maxWidth, 12);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('dot colors are drawn from AppLoaderStyle palette', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyLoader()),
      );
      await tester.pump();
      final BuildContext context = tester.element(find.byType(WailyLoader));
      final s = Theme.of(context).extension<AppLoaderStyle>()!;
      final dotColors = _dotContainers(tester)
          .where(
            (c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle,
          )
          .map((c) => (c.decoration as BoxDecoration).color)
          .toSet();
      // At any frame, every dot uses one of the two palette colors.
      for (final color in dotColors) {
        expect(
          color == s.defaultDotColor || color == s.activeDotColor,
          isTrue,
          reason: 'Unexpected dot color: $color',
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('disposes its animation controller cleanly', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyLoader()),
      );
      await tester.pump();
      // Replace tree to force the State to dispose. No exception should fire.
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  });
}
