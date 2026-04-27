import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_segmented_picker.dart';
import 'package:waily/core/ui_kit/extensions/app_segmented_picker_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailySegmentedPicker', () {
    testWidgets('renders all item labels', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('cm'), findsOneWidget);
      expect(find.text('ft/in'), findsOneWidget);
    });

    testWidgets('tap on non-selected item fires onChanged with that value', (
      tester,
    ) async {
      String? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.tap(find.text('ft/in'));
      await tester.pump();
      expect(received, 'ft');
    });

    testWidgets('tap on selected item does not fire onChanged', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) => taps++,
          ),
        ),
      );
      await tester.tap(find.text('cm'));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('disabled blocks all taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.text('ft/in'));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('selected item paints activeItemBackgroundColor', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) {},
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailySegmentedPicker<String>),
      );
      final s = Theme.of(context).extension<AppSegmentedPickerStyle>()!;
      final cmContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('cm'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (cmContainer.decoration as BoxDecoration).color,
        s.activeItemBackgroundColor,
      );
    });

    testWidgets('selected item label uses activeLabelColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) {},
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailySegmentedPicker<String>),
      );
      final s = Theme.of(context).extension<AppSegmentedPickerStyle>()!;
      final selected = tester.widget<Text>(find.text('cm'));
      expect(selected.style!.color, s.activeLabelColor);
    });

    testWidgets('non-selected item label uses defaultLabelColor', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) {},
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailySegmentedPicker<String>),
      );
      final s = Theme.of(context).extension<AppSegmentedPickerStyle>()!;
      final other = tester.widget<Text>(find.text('ft/in'));
      expect(other.style!.color, s.defaultLabelColor);
    });

    testWidgets('container height matches AppSegmentedPickerStyle', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<String>(
            items: const [
              (value: 'cm', label: 'cm'),
              (value: 'ft', label: 'ft/in'),
            ],
            value: 'cm',
            onChanged: (_) {},
          ),
        ),
      );
      final size = tester.getSize(find.byType(WailySegmentedPicker<String>));
      expect(size.height, 46);
    });

    testWidgets('asserts when items list is empty', (tester) async {
      expect(
        () => WailySegmentedPicker<String>(
          items: const [],
          value: 'cm',
          onChanged: (_) {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('works with int generics', (tester) async {
      int? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySegmentedPicker<int>(
            items: const [
              (value: 1, label: 'One'),
              (value: 2, label: 'Two'),
            ],
            value: 1,
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.tap(find.text('Two'));
      await tester.pump();
      expect(received, 2);
    });
  });
}
