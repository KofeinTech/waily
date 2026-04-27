import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/containers/waily_history_card.dart';
import 'package:waily/core/ui_kit/extensions/app_history_card_style.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyHistoryCard', () {
    testWidgets('daily renders title and subtitle', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(
              title: 'Rest Day · Good',
              subtitle: 'Saturday, March 28',
            ),
          ),
        ),
      );
      expect(find.text('Rest Day · Good'), findsOneWidget);
      expect(find.text('Saturday, March 28'), findsOneWidget);
    });

    testWidgets('daily without isToday hides the pill', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(title: 'Rest', subtitle: 'Sat'),
          ),
        ),
      );
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('daily with isToday renders the trailing pill', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(
              title: 'Rest',
              subtitle: 'Sat',
              isToday: true,
            ),
          ),
        ),
      );
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('chat renders only the snippet', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.chat(text: 'I trained hard.'),
          ),
        ),
      );
      expect(find.text('I trained hard.'), findsOneWidget);
    });

    testWidgets('tap fires onPressed', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(
              title: 'Rest',
              subtitle: 'Sat',
              onPressed: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(WailyHistoryCard));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('today variant uses todayBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(
              title: 'Rest',
              subtitle: 'Sat',
              isToday: true,
            ),
          ),
        ),
      );
      final BuildContext context =
          tester.element(find.byType(WailyHistoryCard));
      final s = Theme.of(context).extension<AppHistoryCardStyle>()!;
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WailyHistoryCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.todayBackgroundColor,
      );
    });

    testWidgets('default daily uses dailyBackgroundColor', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: SizedBox(
            width: 316,
            child: WailyHistoryCard.daily(title: 'Rest', subtitle: 'Sat'),
          ),
        ),
      );
      final BuildContext context =
          tester.element(find.byType(WailyHistoryCard));
      final s = Theme.of(context).extension<AppHistoryCardStyle>()!;
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(WailyHistoryCard),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(
        (container.decoration as BoxDecoration).color,
        s.dailyBackgroundColor,
      );
    });
  });
}
