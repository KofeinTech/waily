import 'package:flutter/material.dart';
import '../extensions/theme_context_extension.dart';

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
        padding: const EdgeInsets.all(16),
        children: const [
          // Sections appended by later tasks. Order: Typography, Colors,
          // Buttons, IconButtons, Inputs, Checkboxes, Switchers, Chips,
          // Loaders, ProgressBar, Segmented, Cards, Lists, Calendar, Nav.
        ],
      ),
    );
  }
}
