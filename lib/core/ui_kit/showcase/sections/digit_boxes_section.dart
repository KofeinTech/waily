import 'package:flutter/material.dart';
import '../../components/inputs/waily_digit_box.dart';
import 'variant_grid.dart';

/// Showcases all four Figma `digit box` states.
class DigitBoxesSection extends StatelessWidget {
  const DigitBoxesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Digit boxes',
      variants: [
        (
          label: 'Default (empty)',
          child: const WailyDigitBox(),
        ),
        (
          label: 'Filled',
          child: const WailyDigitBox(digit: '7'),
        ),
        (
          label: 'Active (focus, empty)',
          child: const WailyDigitBox(hasFocus: true),
        ),
        (
          label: 'Active (focus, digit)',
          child: const WailyDigitBox(digit: '4', hasFocus: true),
        ),
        (
          label: 'Error',
          child: const WailyDigitBox(digit: '9', hasError: true),
        ),
        (
          label: 'OTP row (4 digits)',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              WailyDigitBox(digit: '1'),
              SizedBox(width: 8),
              WailyDigitBox(digit: '2'),
              SizedBox(width: 8),
              WailyDigitBox(hasFocus: true),
              SizedBox(width: 8),
              WailyDigitBox(),
            ],
          ),
        ),
      ],
    );
  }
}
