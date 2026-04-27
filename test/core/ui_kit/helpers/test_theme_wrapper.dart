import 'package:flutter/material.dart';
import 'package:waily/core/ui_kit/theme/app_theme.dart';

/// Wraps [child] in a [MaterialApp] configured with [darkTheme].
///
/// Use this in every UI kit widget test:
/// ```dart
/// await tester.pumpWidget(TestThemeWrapper(child: WailyButton(...)));
/// ```
class TestThemeWrapper extends StatelessWidget {
  const TestThemeWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: darkTheme,
    home: Scaffold(body: Center(child: child)),
  );
}
