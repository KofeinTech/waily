import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/ui_kit/extensions/app_icon_button_style.dart';
import 'package:waily/core/ui_kit/theme/app_border_radius.dart';
import 'package:waily/core/ui_kit/theme/app_colors.dart';

void main() {
  group('AppIconButtonStyle', () {
    test('dark() backgroundColor is white at 6% opacity', () {
      final style = AppIconButtonStyle.dark();
      expect(style.backgroundColor, AppColors.white.withValues(alpha: 0.06));
    });

    test('dark() iconColorDefault is AppColors.white', () {
      expect(AppIconButtonStyle.dark().iconColorDefault, AppColors.white);
    });

    test('dark() iconColorPressed is AppColors.white', () {
      expect(AppIconButtonStyle.dark().iconColorPressed, AppColors.white);
    });

    test('dark() iconColorDisabled is AppColors.textSecondary (#9EA3AE)', () {
      expect(
        AppIconButtonStyle.dark().iconColorDisabled,
        AppColors.textSecondary,
      );
    });

    test('dark() borderRadius is AppBorderRadius.m (12)', () {
      expect(AppIconButtonStyle.dark().borderRadius, AppBorderRadius.m);
    });

    test('dark() sizeDefault is 48 (Figma Default 48x48)', () {
      expect(AppIconButtonStyle.dark().sizeDefault, 48);
    });

    test('dark() sizeBig is 52 (Figma Big 52x52)', () {
      expect(AppIconButtonStyle.dark().sizeBig, 52);
    });

    test('dark() iconSizeDefault is 24 (Figma Default icon canvas)', () {
      expect(AppIconButtonStyle.dark().iconSizeDefault, 24);
    });

    test('dark() iconSizeBig is 28 (Figma Big icon canvas)', () {
      expect(AppIconButtonStyle.dark().iconSizeBig, 28);
    });

    test('copyWith overrides backgroundColor only', () {
      final style = AppIconButtonStyle.dark();
      final modified = style.copyWith(backgroundColor: AppColors.error);
      expect(modified.backgroundColor, AppColors.error);
      expect(modified.iconColorDefault, style.iconColorDefault);
      expect(modified.sizeDefault, style.sizeDefault);
    });

    test('copyWith overrides sizeBig only', () {
      final style = AppIconButtonStyle.dark();
      final modified = style.copyWith(sizeBig: 64);
      expect(modified.sizeBig, 64);
      expect(modified.sizeDefault, style.sizeDefault);
      expect(modified.iconSizeBig, style.iconSizeBig);
    });
  });
}
