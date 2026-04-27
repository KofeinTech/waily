import 'package:flutter/material.dart';
import '../../components/inputs/waily_message_field.dart';
import 'variant_grid.dart';

/// Showcases every Figma `Message Field` variant.
class MessageFieldsSection extends StatelessWidget {
  const MessageFieldsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseVariantGrid(
      title: 'Message bubbles',
      variants: [
        (
          label: 'By=User, Copy=Off',
          child: SizedBox(
            width: 276,
            child: WailyMessageField(
              text: 'I missed a meal. How do I adjust?',
              sender: WailyMessageSender.user,
            ),
          ),
        ),
        (
          label: 'By=AI, Copy=Off',
          child: SizedBox(
            width: 276,
            child: WailyMessageField(
              text: 'Hi, I am Waily',
              sender: WailyMessageSender.ai,
            ),
          ),
        ),
        (
          label: 'By=AI, Copy=On',
          child: SizedBox(
            width: 276,
            child: WailyMessageField(
              text: 'Hi, I am Waily',
              sender: WailyMessageSender.ai,
              onCopy: () {},
            ),
          ),
        ),
      ],
    );
  }
}
