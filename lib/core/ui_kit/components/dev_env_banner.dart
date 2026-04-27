import 'package:flutter/material.dart';
import 'package:waily/core/env/env.dart';

class DevEnvBanner extends StatelessWidget {
  const DevEnvBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kEnvHelper.isDev) return child;
    return Banner(
      message: 'DEV',
      location: BannerLocation.topEnd,
      child: child,
    );
  }
}
