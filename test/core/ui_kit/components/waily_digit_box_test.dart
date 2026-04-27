import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_digit_box.dart';
import 'package:waily/core/ui_kit/extensions/app_digit_box_style.dart';
import '../helpers/test_theme_wrapper.dart';

Container _findContainer(WidgetTester tester) {
  return tester.widget<Container>(
    find.descendant(
      of: find.byType(WailyDigitBox),
      matching: find.byType(Container),
    ),
  );
}

void main() {
  group('WailyDigitBox', () {
    testWidgets('default state size is 48x52', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyDigitBox()),
      );
      final size = tester.getSize(find.byType(WailyDigitBox));
      expect(size.width, 48);
      expect(size.height, 52);
    });

    testWidgets('default state renders no digit and no border', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyDigitBox()),
      );
      final BuildContext context = tester.element(find.byType(WailyDigitBox));
      final s = Theme.of(context).extension<AppDigitBoxStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.filledBackgroundColor);
      expect(deco.border!.top.color, Colors.transparent);
      // Empty Text rendered.
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('filled state shows the digit with digitColor', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyDigitBox(digit: '7')),
      );
      final BuildContext context = tester.element(find.byType(WailyDigitBox));
      final s = Theme.of(context).extension<AppDigitBoxStyle>()!;
      final text = tester.widget<Text>(find.text('7'));
      expect(text.style!.color, s.digitColor);
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.filledBackgroundColor);
      expect(deco.border!.top.color, Colors.transparent);
    });

    testWidgets('focus + empty digit shows blinking cursor and active border',
        (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyDigitBox(hasFocus: true)),
      );
      final BuildContext context = tester.element(find.byType(WailyDigitBox));
      final s = Theme.of(context).extension<AppDigitBoxStyle>()!;
      expect(find.text('|'), findsOneWidget);
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.border!.top.color, s.activeBorderColor);
    });

    testWidgets('focus + digit shows the digit with active border', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyDigitBox(digit: '4', hasFocus: true),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyDigitBox));
      final s = Theme.of(context).extension<AppDigitBoxStyle>()!;
      expect(find.text('4'), findsOneWidget);
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.border!.top.color, s.activeBorderColor);
    });

    testWidgets('error state uses errorBorderColor and transparent bg', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyDigitBox(digit: '9', hasError: true),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyDigitBox));
      final s = Theme.of(context).extension<AppDigitBoxStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.errorBackgroundColor);
      expect(deco.border!.top.color, s.errorBorderColor);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('error state takes precedence over focus', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyDigitBox(digit: '9', hasFocus: true, hasError: true),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyDigitBox));
      final s = Theme.of(context).extension<AppDigitBoxStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.border!.top.color, s.errorBorderColor);
    });

    testWidgets('empty digit string treated as no digit', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyDigitBox(digit: '')),
      );
      // Empty string should render as default state (empty text).
      expect(find.text(''), findsOneWidget);
    });
  });
}
