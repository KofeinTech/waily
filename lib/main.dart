import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/observers/app_bloc_observer.dart';
import 'package:waily/core/env/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initEnv();
  configureDependencies();
  Bloc.observer = AppBlocObserver(getIt<Talker>());
  runApp(const App());
}
