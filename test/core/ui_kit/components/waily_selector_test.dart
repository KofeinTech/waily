import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_selector.dart';
import 'package:waily/core/ui_kit/extensions/app_selector_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailySelector', () {
    testWidgets('renders the label', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySelector(
            label: '32',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      expect(find.text('32'), findsOneWidget);
    });

    testWidgets('default uses textPlaceholder color and weight 400', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySelector(
            label: '32',
            isActive: false,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailySelector));
      final s = Theme.of(context).extension<AppSelectorStyle>()!;
      final text = tester.widget<Text>(find.text('32'));
      expect(text.style!.color, s.defaultColor);
      expect(text.style!.fontWeight, FontWeight.w400);
    });

    testWidgets('active uses white color and weight 500', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySelector(
            label: '32',
            isActive: true,
            onPressed: () {},
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailySelector));
      final s = Theme.of(context).extension<AppSelectorStyle>()!;
      final text = tester.widget<Text>(find.text('32'));
      expect(text.style!.color, s.activeColor);
      expect(text.style!.fontWeight, FontWeight.w500);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySelector(
            label: '32',
            isActive: false,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailySelector));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap and uses disabledColor', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailySelector(
            label: '32',
            isActive: false,
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailySelector));
      await tester.pump();
      expect(taps, 0);
      final BuildContext context = tester.element(find.byType(WailySelector));
      final s = Theme.of(context).extension<AppSelectorStyle>()!;
      final text = tester.widget<Text>(find.text('32'));
      expect(text.style!.color, s.disabledColor);
    });
  });
}
