import 'package:flutter/material.dart';
import 'package:waily/core/ui_kit/components/buttons/waily_button.dart';
import 'package:waily/core/ui_kit/components/cards/waily_card.dart';
import 'package:waily/core/ui_kit/components/inputs/waily_text_field.dart';
import 'package:waily/core/ui_kit/extensions/theme_context_extension.dart';
import 'core/ui_kit/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(darkTheme: darkTheme, themeMode: ThemeMode.dark, home: const _UIKitShowcase());
  }
}

class _UIKitShowcase extends StatelessWidget {
  const _UIKitShowcase();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text('UI Kit', style: context.appTextStyles.s18w500()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _TypographySection(),
          SizedBox(height: 32),
          _ColorsSection(),
          SizedBox(height: 32),
          _ButtonsSection(),
          SizedBox(height: 32),
          _CardsSection(),
          SizedBox(height: 32),
          _TextFieldsSection(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: context.appTextStyles.s20w500(color: context.appColors.primary)),
    );
  }
}

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final t = context.appTextStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Typography'),
        Text('s44w500 — Display', style: t.s44w500()),
        const SizedBox(height: 4),
        Text('s32w500 — Headline', style: t.s32w500()),
        const SizedBox(height: 4),
        Text('s28w500 — Title large', style: t.s28w500()),
        const SizedBox(height: 4),
        Text('s24w500 — Title', style: t.s24w500()),
        const SizedBox(height: 4),
        Text('s20w500 — Title small', style: t.s20w500()),
        const SizedBox(height: 4),
        Text('s18w500 — Body large bold', style: t.s18w500()),
        const SizedBox(height: 4),
        Text('s18w400 — Body large', style: t.s18w400()),
        const SizedBox(height: 4),
        Text('s16w500 — Body bold', style: t.s16w500()),
        const SizedBox(height: 4),
        Text('s16w400 — Body', style: t.s16w400()),
        const SizedBox(height: 4),
        Text('s14w500 — Caption bold', style: t.s14w500()),
        const SizedBox(height: 4),
        Text('s14w400 — Caption', style: t.s14w400()),
        const SizedBox(height: 4),
        Text('s12w500 — Label', style: t.s12w500()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    final swatches = [
      ('background', c.background),
      ('surface', c.surface),
      ('surfaceVariant', c.surfaceVariant),
      ('primary', c.primary),
      ('primaryLight', c.primaryLight),
      ('textPrimary', c.textPrimary),
      ('textSecondary', c.textSecondary),
      ('textDisabled', c.textDisabled),
      ('error', c.error),
      ('success', c.success),
      ('icon', c.icon),
      ('iconDisabled', c.iconDisabled),
      ('border', c.border),
      ('divider', c.divider),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Colors'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: swatches.map((entry) {
            return Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: entry.$2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.border),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 72,
                  child: Text(
                    entry.$1,
                    style: context.appTextStyles.s12w500(color: c.textSecondary),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Buttons'),
        WailyButton(label: 'Primary', onPressed: () {}),
        const SizedBox(height: 8),
        WailyButton(label: 'Secondary', onPressed: () {}, variant: WailyButtonVariant.secondary),
        const SizedBox(height: 8),
        WailyButton(label: 'Outlined', onPressed: () {}, variant: WailyButtonVariant.outlined),
        const SizedBox(height: 8),
        const WailyButton(label: 'Disabled', onPressed: null),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cards
// ---------------------------------------------------------------------------

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Cards'),
        WailyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Card title', style: context.appTextStyles.s16w500()),
              const SizedBox(height: 4),
              Text(
                'Card body text goes here. Cards use AppCardStyle tokens for background, radius, and padding.',
                style: context.appTextStyles.s14w400(color: context.appColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        WailyCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: context.appColors.primary, borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text('Card with custom padding', style: context.appTextStyles.s14w500())),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Text Fields
// ---------------------------------------------------------------------------

class _TextFieldsSection extends StatelessWidget {
  const _TextFieldsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Text Fields'),
        const WailyTextField(label: 'Email', hint: 'you@example.com'),
        const SizedBox(height: 12),
        const WailyTextField(label: 'Password', hint: 'Enter password', obscureText: true),
        const SizedBox(height: 12),
        const WailyTextField(label: 'Email', hint: 'you@example.com', errorText: 'Invalid email address'),
      ],
    );
  }
}
