import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

/// Placeholder destination for the Meal tab.
class MealScreen extends StatelessWidget {
  const MealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          AppRoutes.tabLabels[AppRoutes.meal]!,
          style: context.appTextStyles.s32w500(),
        ),
      ),
    );
  }
}
