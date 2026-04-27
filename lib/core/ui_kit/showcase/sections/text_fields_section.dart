import 'package:flutter/material.dart';
import '../../components/inputs/waily_text_field.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Input field` variant: type × state.
class TextFieldsSection extends StatefulWidget {
  const TextFieldsSection({super.key});

  @override
  State<TextFieldsSection> createState() => _TextFieldsSectionState();
}

class _TextFieldsSectionState extends State<TextFieldsSection> {
  late final FocusNode _activeFocus = FocusNode()..requestFocus();
  late final TextEditingController _filledPrimary = TextEditingController(
    text: 'hello@waily.app',
  );
  late final TextEditingController _filledSecondary = TextEditingController(
    text: 'Lunch idea…',
  );

  @override
  void dispose() {
    _activeFocus.dispose();
    _filledPrimary.dispose();
    _filledSecondary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Text fields',
      variants: [
        (
          label: 'Primary / Default',
          child: const WailyTextField(label: 'Email', hint: 'you@example.com'),
        ),
        (
          label: 'Primary / Active',
          child: WailyTextField(
            label: 'Email',
            hint: 'you@example.com',
            focusNode: _activeFocus,
          ),
        ),
        (
          label: 'Primary / Filled',
          child: WailyTextField(label: 'Email', controller: _filledPrimary),
        ),
        (
          label: 'Primary / Disabled',
          child: const WailyTextField(
            label: 'Email',
            hint: 'you@example.com',
            enabled: false,
          ),
        ),
        (
          label: 'Primary / Error',
          child: const WailyTextField(
            label: 'Email',
            hint: 'you@example.com',
            errorText: 'Email is required',
          ),
        ),
        (
          label: 'Secondary / Default',
          child: const WailyTextField(
            label: 'Search',
            hint: 'Type something',
            variant: WailyTextFieldVariant.secondary,
          ),
        ),
        (
          label: 'Secondary / Filled',
          child: WailyTextField(
            label: 'Search',
            controller: _filledSecondary,
            variant: WailyTextFieldVariant.secondary,
          ),
        ),
      ],
    );
  }
}
