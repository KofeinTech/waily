// lib/main.dart
import 'package:flutter/material.dart';
import 'core/ui_kit/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
