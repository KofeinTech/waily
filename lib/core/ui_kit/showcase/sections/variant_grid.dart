import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';
import '../../theme/app_spacing.dart';
import 'section_header.dart';

class ShowcaseVariantGrid extends StatelessWidget {
  const ShowcaseVariantGrid({
    super.key,
    required this.title,
    required this.variants,
    this.spacing = AppSpacing.sm,
  });

  static const double _tileMinWidth = 160;
  static const double _tileMaxWidth = 200;
  static const double _labelGap = 6;

  final String title;
  final List<({String label, Widget child})> variants;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowcaseSectionHeader(title),
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: variants.map((v) {
            return ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: _tileMinWidth,
                maxWidth: _tileMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  v.child,
                  const SizedBox(height: _labelGap),
                  Text(
                    v.label,
                    style: context.appTextStyles.s12w500(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
