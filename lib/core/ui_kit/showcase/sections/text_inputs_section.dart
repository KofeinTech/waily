import 'package:flutter/material.dart';
import '../../components/inputs/waily_text_input.dart';
import 'variant_grid.dart';

/// Showcases `WailyTextInput` states: default / focused (interactive) /
/// filled / error / disabled.
class TextInputsSection extends StatefulWidget {
  const TextInputsSection({super.key});

  @override
  State<TextInputsSection> createState() => _TextInputsSectionState();
}

class _TextInputsSectionState extends State<TextInputsSection> {
  late final TextEditingController _empty;
  late final TextEditingController _filled;
  late final TextEditingController _error;
  late final TextEditingController _disabled;

  @override
  void initState() {
    super.initState();
    _empty = TextEditingController();
    _filled = TextEditingController(text: 'Hybrid training');
    _error = TextEditingController(text: 'invalid@');
    _disabled = TextEditingController(text: 'Locked value');
  }

  @override
  void dispose() {
    _empty.dispose();
    _filled.dispose();
    _error.dispose();
    _disabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Text inputs',
      variants: [
        (
          label: 'Default (empty, tap to focus)',
          child: SizedBox(
            width: 361,
            child: WailyTextInput(
              controller: _empty,
              placeholder: 'Search',
            ),
          ),
        ),
        (
          label: 'With label',
          child: SizedBox(
            width: 361,
            child: WailyTextInput(
              controller: _empty,
              label: 'Search query',
              placeholder: 'Search',
            ),
          ),
        ),
        (
          label: 'Filled',
          child: SizedBox(
            width: 361,
            child: WailyTextInput(
              controller: _filled,
              placeholder: 'Search',
            ),
          ),
        ),
        (
          label: 'Error',
          child: SizedBox(
            width: 361,
            child: WailyTextInput(
              controller: _error,
              hasError: true,
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 361,
            child: WailyTextInput(
              controller: _disabled,
              isDisabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
