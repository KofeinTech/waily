import 'package:flutter_svg/flutter_svg.dart';
import 'package:waily/core/gen/assets.gen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/components/icons/waily_icon.dart';
import '../helpers/test_theme_wrapper.dart';

void main() {
  group('WailyIcon', () {
    testWidgets('renders an SvgPicture with a known icon', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(child: WailyIcon(icon: Assets.icons.common.arrow)),
      );
      await tester.pump();
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('applies provided size to SvgPicture width', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIcon(icon: Assets.icons.common.arrow, size: 48),
        ),
      );
      await tester.pump();
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 48.0);
    });

    testWidgets('applies provided size to SvgPicture height', (tester) async {
      await tester.pumpWidget(
        TestThemeWrapper(
          child: WailyIcon(icon: Assets.icons.common.close, size: 32),
        ),
      );
      await tester.pump();
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.height, 32.0);
    });
  });
}
