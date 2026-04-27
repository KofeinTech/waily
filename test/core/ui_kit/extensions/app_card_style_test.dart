import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_card_style.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';

void main() {
  group('AppCardStyle', () {
    test('dark() backgroundColor is AppColors.surface', () {
      expect(AppCardStyle.dark().backgroundColor, AppColors.surface);
    });

    test('dark() borderRadius is AppBorderRadius.l', () {
      expect(AppCardStyle.dark().borderRadius, AppBorderRadius.l);
    });

    test('dark() elevation is 0', () {
      expect(AppCardStyle.dark().elevation, 0.0);
    });

    test('copyWith overrides backgroundColor', () {
      final style = AppCardStyle.dark();
      final modified = style.copyWith(
        backgroundColor: AppColors.surfaceVariant,
      );
      expect(modified.backgroundColor, AppColors.surfaceVariant);
      expect(modified.borderRadius, style.borderRadius);
    });
  });
}
