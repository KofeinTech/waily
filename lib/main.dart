import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:talker/talker.dart';
import 'package:waily/core/env/env.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/observers/app_bloc_observer.dart';
import 'core/router/auth_session_gate.dart';

Future<void> main() async {
  // Hold the native splash on screen until the first Flutter frame is
  // ready — without this there is a white flash between the OS splash
  // and our app, since the LaunchTheme drawable is dropped as soon as
  // the engine attaches.
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await initEnv();
  configureDependencies();
  Bloc.observer = AppBlocObserver(getIt<Talker>());
  await getIt<AuthSessionGate>().refresh();
  runApp(const App());
  FlutterNativeSplash.remove();
}
