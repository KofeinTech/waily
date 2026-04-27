import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

class ShowcaseSectionHeader extends StatelessWidget {
  const ShowcaseSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Text(
        title,
        style: context.appTextStyles.s20w500(color: context.appColors.primary),
      ),
    );
  }
}
