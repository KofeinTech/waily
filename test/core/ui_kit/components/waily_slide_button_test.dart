import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_slide_button.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailySlideButton', () {
    testWidgets('renders the supplied label', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Slide to Start'), findsOneWidget);
    });

    testWidgets('renders the thumb arrow icon', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsOneWidget);
    });

    testWidgets('container height equals AppSlideButtonStyle.height (52)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () {},
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailySlideButton));
      expect(size.height, 52);
    });

    testWidgets('release at progress >= 0.9 fires onConfirmed', (tester) async {
      var confirmed = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      );
      final start = tester.getCenter(find.byType(WailyIcon));
      await tester.dragFrom(start, const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(confirmed, 1);
    });

    testWidgets('release below 0.9 springs back without firing onConfirmed', (
      tester,
    ) async {
      var confirmed = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      );
      final start = tester.getCenter(find.byType(WailyIcon));
      // 50px out of ~282 max → ~0.18 progress, well below 0.9.
      await tester.dragFrom(start, const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(confirmed, 0);
    });

    testWidgets('disabled blocks drag', (tester) async {
      var confirmed = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () => confirmed++,
              isDisabled: true,
            ),
          ),
        ),
      );
      final start = tester.getCenter(find.byType(WailyIcon));
      await tester.dragFrom(start, const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(confirmed, 0);
    });

    testWidgets('after confirm widget locks via IgnorePointer', (tester) async {
      var confirmed = 0;
      final key = GlobalKey<WailySlideButtonState>();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              key: key,
              label: 'Slide to Start',
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      );
      await tester.dragFrom(
        tester.getCenter(find.byType(WailyIcon)),
        const Offset(400, 0),
      );
      await tester.pumpAndSettle();
      expect(confirmed, 1);

      // Subsequent drag should be blocked by the IgnorePointer wrapper.
      await tester.dragFrom(
        tester.getCenter(find.byType(WailyIcon)),
        const Offset(-400, 0),
      );
      await tester.pumpAndSettle();
      expect(confirmed, 1);
    });

    testWidgets('reset() unlocks the widget and returns the thumb to start', (
      tester,
    ) async {
      var confirmed = 0;
      final key = GlobalKey<WailySlideButtonState>();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              key: key,
              label: 'Slide to Start',
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      );
      await tester.dragFrom(
        tester.getCenter(find.byType(WailyIcon)),
        const Offset(400, 0),
      );
      await tester.pumpAndSettle();
      expect(confirmed, 1);

      key.currentState!.reset();
      await tester.pumpAndSettle();

      // After reset the widget can confirm again.
      await tester.dragFrom(
        tester.getCenter(find.byType(WailyIcon)),
        const Offset(400, 0),
      );
      await tester.pumpAndSettle();
      expect(confirmed, 2);
    });

    testWidgets('confirm fires medium haptic feedback', (tester) async {
      final calls = <MethodCall>[];
      final binding = tester.binding;
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          calls.add(call);
          return null;
        },
      );

      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailySlideButton(
              label: 'Slide to Start',
              onConfirmed: () {},
            ),
          ),
        ),
      );
      await tester.dragFrom(
        tester.getCenter(find.byType(WailyIcon)),
        const Offset(400, 0),
      );
      await tester.pumpAndSettle();

      final hapticCalls = calls.where(
        (c) =>
            c.method == 'HapticFeedback.vibrate' &&
            c.arguments == 'HapticFeedbackType.mediumImpact',
      );
      expect(hapticCalls, isNotEmpty);

      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  });
}
