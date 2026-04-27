import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'showcase_home.dart';

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const ShowcaseHome(),
    );
  }
}
