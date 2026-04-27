import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_chat_input_field.dart';
import 'package:waily/core/ui_kit/extensions/app_chat_input_field_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyChatInputField', () {
    testWidgets('renders placeholder when controller is empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            placeholder: 'Type a message',
          ),
        ),
      );
      expect(find.text('Type a message'), findsOneWidget);
    });

    testWidgets('typing fires onChanged', (tester) async {
      final controller = TextEditingController();
      String? received;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onChanged: (v) => received = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pump();
      expect(received, 'hi');
    });

    testWidgets('mic shown when empty + onMic provided', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onMic: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('send shown when text present + onSend provided', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'hi');
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('no trailing button when callbacks are null', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(controller: controller),
        ),
      );
      expect(find.byIcon(Icons.mic), findsNothing);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('tapping send fires onSend', (tester) async {
      final controller = TextEditingController(text: 'hi');
      var sent = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onSend: () => sent++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      expect(sent, 1);
    });

    testWidgets('tapping mic fires onMic when empty', (tester) async {
      final controller = TextEditingController();
      var mics = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onMic: () => mics++,
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pump();
      expect(mics, 1);
    });

    testWidgets('disabled state uses disabledBackgroundColor and blocks editing',
        (tester) async {
      final controller = TextEditingController(text: 'hi');
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onSend: () {},
            isDisabled: true,
          ),
        ),
      );
      final BuildContext context = tester.element(
        find.byType(WailyChatInputField),
      );
      final s = Theme.of(context).extension<AppChatInputFieldStyle>()!;
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WailyChatInputField),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.disabledBackgroundColor,
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, false);
    });

    testWidgets('disabled blocks send button tap', (tester) async {
      final controller = TextEditingController(text: 'hi');
      var sent = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onSend: () => sent++,
            isDisabled: true,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      expect(sent, 0);
    });

    testWidgets('action button is 40x40 circular', (tester) async {
      final controller = TextEditingController(text: 'hi');
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyChatInputField(
            controller: controller,
            onSend: () {},
          ),
        ),
      );
      await tester.pump();
      // Find the action button container — the circle child of the row.
      final btn = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WailyChatInputField),
              matching: find.byType(Container),
            )
            .last,
      );
      final deco = btn.decoration as BoxDecoration;
      expect(deco.shape, BoxShape.circle);
      expect(btn.constraints!.maxWidth, 40);
      expect(btn.constraints!.maxHeight, 40);
    });
  });
}
