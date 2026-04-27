import 'package:flutter/material.dart';

import '../../../../core/ui_kit/extensions/theme_context_extension.dart';

/// Stand-in for the future sign-in screen. Exists so that the auth
/// guard has a valid redirect target while the real auth feature is
/// being built.
class SignInPlaceholderScreen extends StatelessWidget {
  const SignInPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: Center(
        child: Text(
          'Sign-in coming soon',
          style: context.appTextStyles.s20w500(),
        ),
      ),
    );
  }
}
