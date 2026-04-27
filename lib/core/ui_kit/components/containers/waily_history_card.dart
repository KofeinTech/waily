import 'package:flutter/material.dart';
import '../../extensions/theme_context_extension.dart';

/// History card — Figma `History card` component-set.
///
/// Two factories surface the three Figma variants:
/// - [WailyHistoryCard.daily] for `Type=Default` and `Type=Today`. Pass
///   `isToday: true` to surface the trailing primary "Today" pill on a
///   slightly brighter card background (white@6% instead of white@4%).
/// - [WailyHistoryCard.chat] for `Type=Chat`, a low-density card showing a
///   single short chat snippet.
class WailyHistoryCard extends StatelessWidget {
  const WailyHistoryCard._({
    super.key,
    required this.isChat,
    this.title,
    this.subtitle,
    this.text,
    this.isToday = false,
    this.todayLabel = 'Today',
    this.onPressed,
  });

  factory WailyHistoryCard.daily({
    Key? key,
    required String title,
    required String subtitle,
    bool isToday = false,
    String todayLabel = 'Today',
    VoidCallback? onPressed,
  }) => WailyHistoryCard._(
    key: key,
    isChat: false,
    title: title,
    subtitle: subtitle,
    isToday: isToday,
    todayLabel: todayLabel,
    onPressed: onPressed,
  );

  factory WailyHistoryCard.chat({
    Key? key,
    required String text,
    VoidCallback? onPressed,
  }) => WailyHistoryCard._(
    key: key,
    isChat: true,
    text: text,
    onPressed: onPressed,
  );

  final bool isChat;
  final String? title;
  final String? subtitle;
  final String? text;
  final bool isToday;
  final String todayLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final s = context.appHistoryCardStyle;
    final t = context.appTextStyles;

    final Color background;
    if (isChat) {
      background = s.chatBackgroundColor;
    } else if (isToday) {
      background = s.todayBackgroundColor;
    } else {
      background = s.dailyBackgroundColor;
    }

    final Widget body;
    if (isChat) {
      body = Text(text!, style: t.s14w500(color: s.chatTextColor));
    } else {
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title!, style: t.s20w500(color: s.titleColor)),
          SizedBox(height: s.itemSpacing),
          Text(subtitle!, style: t.s14w500(color: s.subtitleColor)),
        ],
      );
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: content),
          if (isToday)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: s.todayPillHorizontalPadding,
                vertical: s.todayPillVerticalPadding,
              ),
              decoration: BoxDecoration(
                color: s.todayPillColor,
                borderRadius: BorderRadius.circular(s.todayPillRadius),
              ),
              child: Text(
                todayLabel,
                style: t.s14w500(color: s.todayPillTextColor),
              ),
            ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(s.padding),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(s.borderRadius),
        ),
        child: body,
      ),
    );
  }
}
