import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/core/presentation/bloc/app_notification_cubit.dart';
import 'features/core/presentation/widgets/app_notification_builder.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppNotificationCubit>(
          create: (_) => getIt<AppNotificationCubit>(),
        ),
        // Future app-scope cubits go here.
      ],
      child: MaterialApp.router(
        title: 'Waily',
        builder: (context, child) => AppNotificationBuilder(
          child: child ?? const SizedBox.shrink(),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
