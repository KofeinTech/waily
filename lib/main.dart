import 'package:flutter/material.dart';
import 'core/ui_kit/theme/app_theme.dart';

void main() => runApp(const WailyApp());

class WailyApp extends StatelessWidget {
  const WailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const Scaffold(),
    );
  }
}
