import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_text_field.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyTextField', () {
    testWidgets('primary renders label and hint', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyTextField(label: 'Email', hint: 'you@example.com'),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('you@example.com'), findsOneWidget);
    });

    testWidgets('shows errorText when provided', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyTextField(label: 'Email', errorText: 'Required'),
        ),
      );
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('forwards onChanged events', (tester) async {
      String? value;
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyTextField(onChanged: (v) => value = v)),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(value, 'hello');
    });

    testWidgets('disabled blocks input (enabled=false)', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyTextField(enabled: false)),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('secondary variant renders without error', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyTextField(
            label: 'Search',
            hint: 'Type something',
            variant: WailyTextFieldVariant.secondary,
          ),
        ),
      );
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Type something'), findsOneWidget);
    });

    testWidgets('obscureText is forwarded', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(child: WailyTextField(obscureText: true)),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });
  });
}
