import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

/// Placeholder destination for the Profile tab. Hosts a link to the
/// internal dev-tools page so back navigation can be exercised
/// end-to-end (AC #4).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppRoutes.tabLabels[AppRoutes.profile]!,
              style: context.appTextStyles.s32w500(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.goNamed(AppRoutes.devTools),
              child: const Text('Dev tools'),
            ),
          ],
        ),
      ),
    );
  }
}
