import 'package:flutter/material.dart';
import '../extensions/theme_context_extension.dart';
import '../theme/app_spacing.dart';

class ShowcaseHome extends StatelessWidget {
  const ShowcaseHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.surface,
        title: Text('UI Kit', style: context.appTextStyles.s18w500()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: const [],
      ),
    );
  }
}
