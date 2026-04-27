import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/indicators/waily_progress_bar.dart';
import 'package:waily/core/ui_kit/extensions/app_progress_bar_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyProgressBar', () {
    testWidgets('determinate at 0 renders without exception', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyProgressBar(progress: 0)),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0);
    });

    testWidgets('determinate at 0.5 reaches the indicator value', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyProgressBar(progress: 0.5)),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
    });

    testWidgets('determinate at 1 reaches the indicator value', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyProgressBar(progress: 1)),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 1);
    });

    testWidgets('null progress (indeterminate) renders without exception', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyProgressBar()),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, isNull);
    });

    testWidgets('uses AppProgressBarStyle fillColor and trackColor', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyProgressBar(progress: 0.5)),
      );
      final BuildContext context = tester.element(
        find.byType(WailyProgressBar),
      );
      final s = Theme.of(context).extension<AppProgressBarStyle>()!;
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.valueColor!.value, s.fillColor);
      expect(indicator.backgroundColor, s.trackColor);
      expect(indicator.minHeight, s.height);
    });

    testWidgets('asserts when progress is out of [0, 1]', (tester) async {
      expect(() => WailyProgressBar(progress: -0.1), throwsAssertionError);
      expect(() => WailyProgressBar(progress: 1.1), throwsAssertionError);
    });
  });
}
