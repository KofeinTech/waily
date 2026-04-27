import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';
import 'section_header.dart';

class ShowcaseVariantGrid extends StatelessWidget {
  const ShowcaseVariantGrid({
    super.key,
    required this.title,
    required this.variants,
    this.crossAxisCount = 2,
    this.spacing = 12,
  });

  final String title;
  final List<({String label, Widget child})> variants;
  final int crossAxisCount;
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
              constraints: const BoxConstraints(minWidth: 160, maxWidth: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  v.child,
                  const SizedBox(height: 6),
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
