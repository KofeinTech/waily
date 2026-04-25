import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_text_field.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyTextField', () {
    testWidgets('renders a TextField', (tester) async {
      await tester.pumpWidget(TestThemeWrapper(child: const WailyTextField()));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays hint text', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: const WailyTextField(hint: 'Enter your email')),
      );
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('displays error text when provided', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: const WailyTextField(errorText: 'Field is required'),
        ),
      );
      expect(find.text('Field is required'), findsOneWidget);
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: const WailyTextField(obscureText: true)),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changed;
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyTextField(onChanged: (v) => changed = v)),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(changed, 'hello');
    });
  });
}
