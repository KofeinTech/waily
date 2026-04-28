import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

/// Placeholder destination for the Home tab. Replaced when the real
/// home feature ships.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          AppRoutes.tabLabels[AppRoutes.home]!,
          style: context.appTextStyles.s32w500(),
        ),
      ),
    );
  }
}
