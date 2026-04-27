import 'package:flutter/material.dart';
import '../../components/inputs/waily_chat_input_field.dart';
import 'variant_grid.dart';

/// Showcases `WailyChatInputField` across the empty / typing / disabled flow.
class ChatInputFieldsSection extends StatefulWidget {
  const ChatInputFieldsSection({super.key});

  @override
  State<ChatInputFieldsSection> createState() => _ChatInputFieldsSectionState();
}

class _ChatInputFieldsSectionState extends State<ChatInputFieldsSection> {
  late final TextEditingController _empty;
  late final TextEditingController _typed;
  late final TextEditingController _multi;
  late final TextEditingController _disabled;

  @override
  void initState() {
    super.initState();
    _empty = TextEditingController();
    _typed = TextEditingController(text: 'Some text');
    _multi = TextEditingController(
      text:
          'A longer message that spans multiple lines so the composer has room to grow vertically.',
    );
    _disabled = TextEditingController(text: 'Cannot edit this');
  }

  @override
  void dispose() {
    _empty.dispose();
    _typed.dispose();
    _multi.dispose();
    _disabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Chat input fields',
      variants: [
        (
          label: 'Basic (mic affordance)',
          child: SizedBox(
            width: 361,
            child: WailyChatInputField(
              controller: _empty,
              placeholder: 'Type a message',
              onMic: () {},
            ),
          ),
        ),
        (
          label: 'Filled (send affordance)',
          child: SizedBox(
            width: 361,
            child: WailyChatInputField(
              controller: _typed,
              placeholder: 'Type a message',
              onSend: () {},
            ),
          ),
        ),
        (
          label: 'Filled, multi-line',
          child: SizedBox(
            width: 361,
            child: WailyChatInputField(
              controller: _multi,
              placeholder: 'Type a message',
              onSend: () {},
            ),
          ),
        ),
        (
          label: 'No trailing affordance',
          child: SizedBox(
            width: 361,
            child: WailyChatInputField(
              controller: _empty,
              placeholder: 'Read-only style with no callbacks',
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 361,
            child: WailyChatInputField(
              controller: _disabled,
              onSend: () {},
              isDisabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
