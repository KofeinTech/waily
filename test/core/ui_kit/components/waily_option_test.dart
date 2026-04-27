import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_option.dart';
import 'package:waily/core/ui_kit/extensions/app_option_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyOption', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyOption(
            title: 'Hybrid',
            isSelected: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('Hybrid'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyOption(
            title: 'Hybrid',
            description: 'HYROX',
            isSelected: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('HYROX'), findsOneWidget);
    });

    testWidgets('description hidden when null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyOption(
            title: 'Hybrid',
            isSelected: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyOption(
            title: 'Hybrid',
            isSelected: false,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailyOption));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyOption(
            title: 'Hybrid',
            isSelected: false,
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyOption));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('selected paints selectedBackgroundColor and selectedTitleColor',
        (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyOption(
            title: 'Hybrid',
            isSelected: true,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyOption));
      final s = Theme.of(context).extension<AppOptionStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyOption),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.selectedBackgroundColor,
      );
      final title = tester.widget<Text>(find.text('Hybrid'));
      expect(title.style!.color, s.selectedTitleColor);
    });

    testWidgets('default state title uses defaultTitleColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyOption(
            title: 'Hybrid',
            isSelected: false,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyOption));
      final s = Theme.of(context).extension<AppOptionStyle>()!;
      final title = tester.widget<Text>(find.text('Hybrid'));
      expect(title.style!.color, s.defaultTitleColor);
    });

    testWidgets('container height equals AppOptionStyle.height (70)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 358,
            child: WailyOption(
              title: 'Hybrid',
              isSelected: false,
              onPressed: () {},
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailyOption));
      expect(size.height, 70);
    });
  });
}
