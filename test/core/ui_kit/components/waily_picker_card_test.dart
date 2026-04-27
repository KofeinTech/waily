import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/containers/waily_picker_card.dart';
import 'package:waily/core/ui_kit/extensions/app_picker_card_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyPickerCard', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('Hybrid'), findsOneWidget);
    });

    testWidgets('subtitle hidden when null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('subtitle rendered when provided', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              subtitle: 'HYROX, run + lift',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.text('HYROX, run + lift'), findsOneWidget);
    });

    testWidgets('selected shows trailing checkmark', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('default hides the trailing checkmark', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: false,
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WailyPickerCard));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: false,
              onPressed: () => taps++,
              isDisabled: true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WailyPickerCard));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('selected paints activeBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: true,
              onPressed: () {},
            ),
          ),
        ),
      );
      final BuildContext context =
          tester.element(find.byType(WailyPickerCard));
      final s = Theme.of(context).extension<AppPickerCardStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyPickerCard),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.activeBackgroundColor,
      );
    });

    testWidgets('default paints defaultBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 361,
            child: WailyPickerCard(
              title: 'Hybrid',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      final BuildContext context =
          tester.element(find.byType(WailyPickerCard));
      final s = Theme.of(context).extension<AppPickerCardStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyPickerCard),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.defaultBackgroundColor,
      );
    });
  });
}
