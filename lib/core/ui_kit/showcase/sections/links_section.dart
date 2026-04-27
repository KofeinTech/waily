import 'package:flutter/material.dart';
import '../../components/buttons/waily_link.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Link` variant: Default / Pressed (press-and-hold)
/// plus the synthesized Disabled state.
class LinksSection extends StatelessWidget {
  const LinksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Links',
      variants: [
        (
          label: 'Default',
          child: WailyLink(label: 'Log in', onPressed: () {}),
        ),
        (
          label: 'Pressed (tap and hold)',
          child: WailyLink(label: 'Forgot password?', onPressed: () {}),
        ),
        (
          label: 'Disabled',
          child: WailyLink(
            label: 'Resend code',
            onPressed: () {},
            isDisabled: true,
          ),
        ),
      ],
    );
  }
}
