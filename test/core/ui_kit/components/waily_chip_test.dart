import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/gen/assets.gen.dart';
import 'package:waily/core/ui_kit/components/chips/waily_chip.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import 'package:waily/core/ui_kit/extensions/app_chip_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyChip', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyChip(label: 'Coffee')),
      );
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('value text is hidden when value is null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyChip(label: 'Coffee')),
      );
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('value text is rendered when value is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyChip(label: 'Coffee', value: '0 oz')),
      );
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('0 oz'), findsOneWidget);
    });

    testWidgets('close icon is hidden when onClose is null', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyChip(label: 'Coffee')),
      );
      expect(find.byType(WailyIcon), findsNothing);
    });

    testWidgets('close icon is rendered when onClose is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChip(label: 'Coffee', onClose: () {}),
        ),
      );
      expect(find.byType(WailyIcon), findsOneWidget);
      final icon = tester.widget<WailyIcon>(find.byType(WailyIcon));
      expect(icon.icon, Assets.icons.common.close);
    });

    testWidgets('tapping close icon fires onClose', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChip(label: 'Coffee', onClose: () => taps++),
        ),
      );
      await tester.tap(find.byType(WailyIcon));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks close-icon tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChip(
            label: 'Coffee',
            onClose: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyIcon));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('Dark color uses darkBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChip(label: 'Coffee'),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyChip));
      final s = Theme.of(context).extension<AppChipStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyChip),
          matching: find.byType(Container),
        ),
      );
      expect((container.decoration as BoxDecoration).color, s.darkBackgroundColor);
    });

    testWidgets('Light color uses lightBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChip(label: 'Coffee', color: WailyChipColor.light),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyChip));
      final s = Theme.of(context).extension<AppChipStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyChip),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.lightBackgroundColor,
      );
    });

    testWidgets('disabled background overrides Dark/Light variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChip(
            label: 'Coffee',
            color: WailyChipColor.light,
            isDisabled: true,
            onClose: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyChip));
      final s = Theme.of(context).extension<AppChipStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyChip),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.disabledBackgroundColor,
      );
    });

    testWidgets('container height equals AppChipStyle.height (36)', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyChip(label: 'Coffee')),
      );
      final size = tester.getSize(find.byType(WailyChip));
      expect(size.height, 36);
    });
  });
}
