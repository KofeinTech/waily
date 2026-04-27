import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/containers/waily_chat_tip.dart';
import 'package:waily/core/ui_kit/extensions/app_chat_tip_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyChatTip', () {
    testWidgets('renders the text', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatTip(text: 'I trained hard', onPressed: () {}),
        ),
      );
      expect(find.text('I trained hard'), findsOneWidget);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatTip(
            text: 'I trained hard',
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(WailyChatTip));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('disabled blocks tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatTip(
            text: 'I trained hard',
            onPressed: () => taps++,
            isDisabled: true,
          ),
        ),
      );
      await tester.tap(find.byType(WailyChatTip));
      await tester.pump();
      expect(taps, 0);
    });

    testWidgets('default state paints defaultBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatTip(text: 'tip', onPressed: () {}),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyChatTip));
      final s = Theme.of(context).extension<AppChatTipStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyChatTip),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.defaultBackgroundColor,
      );
    });

    testWidgets('active state paints activeBackgroundColor and activeTextColor',
        (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatTip(
            text: 'tip',
            onPressed: () {},
            isActive: true,
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyChatTip));
      final s = Theme.of(context).extension<AppChatTipStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyChatTip),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.activeBackgroundColor,
      );
      final text = tester.widget<Text>(find.text('tip'));
      expect(text.style!.color, s.activeTextColor);
    });

    testWidgets('disabled state uses disabled colors', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatTip(
            text: 'tip',
            onPressed: () {},
            isDisabled: true,
          ),
        ),
      );
      final BuildContext context = tester.element(find.byType(WailyChatTip));
      final s = Theme.of(context).extension<AppChatTipStyle>()!;
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(WailyChatTip),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.disabledBackgroundColor,
      );
      final text = tester.widget<Text>(find.text('tip'));
      expect(text.style!.color, s.disabledTextColor);
    });
  });
}
