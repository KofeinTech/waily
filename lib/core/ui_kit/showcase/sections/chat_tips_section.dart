import 'package:flutter/material.dart';
import '../../components/containers/waily_chat_tip.dart';
import 'variant_grid.dart';

/// Showcases all three Figma `Chat Tip` states.
class ChatTipsSection extends StatelessWidget {
  const ChatTipsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Chat tips',
      variants: [
        (
          label: 'Default',
          child: SizedBox(
            width: 256,
            child: WailyChatTip(
              text: 'I trained hard and have low appetite. What should I do?',
              onPressed: () {},
            ),
          ),
        ),
        (
          label: 'Active',
          child: SizedBox(
            width: 256,
            child: WailyChatTip(
              text: 'I trained hard and have low appetite. What should I do?',
              onPressed: () {},
              isActive: true,
            ),
          ),
        ),
        (
          label: 'Disabled',
          child: SizedBox(
            width: 256,
            child: WailyChatTip(
              text: 'I trained hard and have low appetite. What should I do?',
              onPressed: () {},
              isDisabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
