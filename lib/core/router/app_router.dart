import 'package:go_router/go_router.dart';

import '../../features/core/presentation/screens/demo_home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DemoHomeScreen(),
    ),
  ],
);
