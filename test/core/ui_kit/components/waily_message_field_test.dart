import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_message_field.dart';
import 'package:waily/core/ui_kit/extensions/app_message_field_style.dart';
import '../helpers/test_theme_wrapper.dart';

Container _findContainer(WidgetTester tester) {
  return tester.widget<Container>(
    find
        .descendant(
          of: find.byType(WailyMessageField),
          matching: find.byType(Container),
        )
        .first,
  );
}

void main() {
  group('WailyMessageField', () {
    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyMessageField(
            text: 'Hi, I am Waily',
            sender: WailyMessageSender.ai,
          ),
        ),
      );
      expect(find.text('Hi, I am Waily'), findsOneWidget);
    });

    testWidgets('user variant uses primary fill and surfaceVariant text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyMessageField(
            text: 'How do I adjust?',
            sender: WailyMessageSender.user,
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailyMessageField),
      );
      final s = Theme.of(context).extension<AppMessageFieldStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.userBackgroundColor);
      // User variant has no border.
      expect(deco.border, isNull);
      final text = tester.widget<Text>(find.text('How do I adjust?'));
      expect(text.style!.color, s.userTextColor);
    });

    testWidgets('AI variant uses transparent fill + white border', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyMessageField(
            text: 'Hi',
            sender: WailyMessageSender.ai,
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailyMessageField),
      );
      final s = Theme.of(context).extension<AppMessageFieldStyle>()!;
      final deco = _findContainer(tester).decoration as BoxDecoration;
      expect(deco.color, s.aiBackgroundColor);
      expect(deco.border!.top.color, s.aiBorderColor);
      final text = tester.widget<Text>(find.text('Hi'));
      expect(text.style!.color, s.aiTextColor);
    });

    testWidgets('AI + onCopy renders the copy icon', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMessageField(
            text: 'Hi',
            sender: WailyMessageSender.ai,
            onCopy: () {},
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsOneWidget);
    });

    testWidgets('AI without onCopy hides the copy icon', (tester) async {
      await tester.pumpWidget(
        const TestThemeWrapper(
          child: WailyMessageField(
            text: 'Hi',
            sender: WailyMessageSender.ai,
          ),
        ),
      );
      expect(find.byType(WailyIcon), findsNothing);
    });

    testWidgets('user variant ignores onCopy', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMessageField(
            text: 'Hi',
            sender: WailyMessageSender.user,
            onCopy: () {},
          ),
        ),
      );
      // No copy icon for user bubbles even when onCopy is provided.
      expect(find.byType(WailyIcon), findsNothing);
    });

    testWidgets('tapping copy icon fires onCopy', (tester) async {
      var copied = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyMessageField(
            text: 'Hi',
            sender: WailyMessageSender.ai,
            onCopy: () => copied++,
          ),
        ),
      );
      await tester.tap(find.byType(WailyIcon));
      await tester.pump();
      expect(copied, 1);
    });
  });
}
