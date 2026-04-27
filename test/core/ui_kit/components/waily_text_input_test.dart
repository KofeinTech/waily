import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_text_input.dart';
import 'package:waily/core/ui_kit/extensions/app_text_input_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyTextInput', () {
    testWidgets('renders placeholder when controller is empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(
            controller: controller,
            placeholder: 'Search',
          ),
        ),
      );
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('typing fires onChanged with the new value', (tester) async {
      final controller = TextEditingController();
      String? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(
            controller: controller,
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pump();
      expect(received, 'hi');
    });

    testWidgets('clear icon hidden when controller is empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(controller: controller),
        ),
      );
      expect(find.byType(WailyIcon), findsNothing);
    });

    testWidgets('clear icon shown when controller has text', (tester) async {
      final controller = TextEditingController(text: 'hello');
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(controller: controller),
        ),
      );
      await tester.pump();
      expect(find.byType(WailyIcon), findsOneWidget);
    });

    testWidgets('clear icon empties controller and fires onChanged', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'hello');
      String? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(
            controller: controller,
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(WailyIcon));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(received, '');
    });

    testWidgets('label rendered above input when provided', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(controller: controller, label: 'Email'),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('disabled blocks editing and hides clear icon', (tester) async {
      final controller = TextEditingController(text: 'hello');
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(controller: controller, isDisabled: true),
        ),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, false);
      expect(find.byType(WailyIcon), findsNothing);
    });

    testWidgets('error state uses errorBorderColor', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(controller: controller, hasError: true),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyTextInput));
      final s = Theme.of(context).extension<AppTextInputStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyTextInput),
          matching: find.byType(Container),
        ),
      );
      expect((container.decoration as BoxDecoration).border!.top.color,
          s.errorBorderColor);
    });

    testWidgets('focus switches border to activeBorderColor', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyTextInput(controller: controller),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final BuildContext context = tester.element(find.byType(WailyTextInput));
      final s = Theme.of(context).extension<AppTextInputStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyTextInput),
          matching: find.byType(Container),
        ),
      );
      expect((container.decoration as BoxDecoration).border!.top.color,
          s.activeBorderColor);
    });
  });
}
