import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_button.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyButton', () {
    testWidgets('primary variant renders ElevatedButton with label', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton(label: 'Continue', onPressed: () {}),
        ),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('secondary variant renders ElevatedButton', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton(
            label: 'Skip',
            onPressed: () {},
            variant: WailyButtonVariant.secondary,
          ),
        ),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('outlined variant renders OutlinedButton', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton(
            label: 'Cancel',
            onPressed: () {},
            variant: WailyButtonVariant.outlined,
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: const WailyButton(label: 'Disabled', onPressed: null),
        ),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('tap calls onPressed callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyButton(label: 'Tap me', onPressed: () => tapped = true),
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });
  });
}
