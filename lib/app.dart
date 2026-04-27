import 'package:flutter/material.dart';
import 'package:waily/core/ui_kit/components/dev_env_banner.dart';
import 'package:waily/core/ui_kit/theme/app_theme.dart';

class WailyApp extends StatelessWidget {
  const WailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: const Scaffold(),
      builder: (context, child) =>
          DevEnvBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
