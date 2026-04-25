import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/cards/waily_card.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyCard(child: const Text('Card content'))),
      );
      expect(find.text('Card content'), findsOneWidget);
    });

    testWidgets('contains a Material widget', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyCard(child: const SizedBox())),
      );
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('custom padding override wraps child in Padding', (
      tester,
    ) async {
      const customPadding = EdgeInsets.all(32);
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyCard(
            padding: customPadding,
            child: const Text('Content'),
          ),
        ),
      );
      final paddingWidgets = tester.widgetList<Padding>(
        find.ancestor(of: find.text('Content'), matching: find.byType(Padding)),
      );
      final hasCustomPadding = paddingWidgets.any(
        (p) => p.padding == customPadding,
      );
      expect(hasCustomPadding, isTrue);
    });

    testWidgets('ClipRRect is present for border radius clipping', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyCard(child: const SizedBox())),
      );
      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
