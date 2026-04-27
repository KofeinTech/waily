import 'package:flutter/material.dart';
import 'package:waily/app.dart';
import 'package:waily/core/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initEnv();
  runApp(const WailyApp());
}
