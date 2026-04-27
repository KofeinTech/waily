import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_button.dart';
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

    testWidgets('big size yields height >= 64', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton.primary(
            label: 'Big',
            onPressed: () {},
            size: WailyButtonSize.big,
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyButton));
      expect(size.height, greaterThanOrEqualTo(64));
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
  });
}
