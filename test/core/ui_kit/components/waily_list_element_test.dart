import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/containers/waily_list_element.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyListElement', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Account',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Account'), findsOneWidget);
    });

    testWidgets('value hidden when null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Account',
              onPressed: () {},
            ),
          ),
        ),
      );
      // Only the label Text — no second info text.
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('value rendered when provided', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Account',
              value: 'Pro',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
    });

    testWidgets('renders the trailing chevron', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Account',
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Account',
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WailyListElement));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Account',
              onPressed: () => taps++,
              isDisabled: true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WailyListElement));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('row height is AppListElementStyle.height (56)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyListElement(
              label: 'Account',
              onPressed: () {},
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyListElement));
      expect(size.height, 56);
    });
  });
}
