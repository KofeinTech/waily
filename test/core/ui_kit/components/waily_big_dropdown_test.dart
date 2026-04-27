import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_big_dropdown.dart';
import 'package:waily/core/ui_kit/extensions/app_big_dropdown_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyBigDropdown', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyBigDropdown(title: 'Hybrid', onPressed: () {}),
        ),
      );
      expect(find.text('Hybrid'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyBigDropdown(
            title: 'Hybrid',
            subtitle: 'HYROX, run + lift',
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('HYROX, run + lift'), findsOneWidget);
    });

    testWidgets('subtitle hidden when null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyBigDropdown(title: 'Hybrid', onPressed: () {}),
        ),
      );
      // Only title text widget rendered.
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyBigDropdown(
            title: 'Hybrid',
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailyBigDropdown));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyBigDropdown(
            title: 'Hybrid',
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyBigDropdown));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('renders trailing chevron icon', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyBigDropdown(title: 'Hybrid', onPressed: () {}),
        ),
      );
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('container height equals AppBigDropdownStyle.height (70)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailyBigDropdown(title: 'Hybrid', onPressed: () {}),
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyBigDropdown));
      expect(size.height, 70);
    });

    testWidgets('disabled state uses disabled colors', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyBigDropdown(
            title: 'Hybrid',
            subtitle: 'HYROX',
            onPressed: () {},
            isDisabled: true,
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailyBigDropdown),
      );
      final s = Theme.of(context).extension<AppBigDropdownStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyBigDropdown),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.disabledBackgroundColor,
      );
      final title = tester.widget<Text>(find.text('Hybrid'));
      expect(title.style!.color, s.disabledTitleColor);
      final subtitle = tester.widget<Text>(find.text('HYROX'));
      expect(subtitle.style!.color, s.disabledSubtitleColor);
    });
  });
}
