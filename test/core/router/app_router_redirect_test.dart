import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:waily/core/router/app_routes.dart';
import 'package:waily/core/router/auth_session_gate.dart';

class _FakeGate extends ChangeNotifier implements AuthSessionGate {
  bool _isAuthenticated;

  _FakeGate({required bool initial}) : _isAuthenticated = initial;

  @override
  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    if (value == _isAuthenticated) return;
    _isAuthenticated = value;
    notifyListeners();
  }

  @override
  Future<void> refresh() async {}
}

GoRouter _routerFor(_FakeGate gate) {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    refreshListenable: gate,
    redirect: (context, state) {
      final atSignIn = state.matchedLocation == AppRoutes.signInPath;
      if (!gate.isAuthenticated && !atSignIn) return AppRoutes.signInPath;
      if (gate.isAuthenticated && atSignIn) return AppRoutes.homePath;
      return null;
    },
    routes: [
      GoRoute(
        name: AppRoutes.signIn,
        path: AppRoutes.signInPath,
        builder: (_, _) => const Scaffold(body: Text('sign-in')),
      ),
      GoRoute(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        builder: (_, _) => const Scaffold(body: Text('home')),
      ),
    ],
  );
}

void main() {
  testWidgets('unauthenticated user is sent from /home to /sign-in',
      (tester) async {
    final gate = _FakeGate(initial: false);
    final router = _routerFor(gate);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('sign-in'), findsOneWidget);
    expect(find.text('home'), findsNothing);
  });

  testWidgets('authenticated user is sent from /sign-in to /home',
      (tester) async {
    final gate = _FakeGate(initial: true);
    final router = _routerFor(gate);
    router.go(AppRoutes.signInPath);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.text('sign-in'), findsNothing);
  });

  testWidgets('changing gate state re-evaluates redirect', (tester) async {
    final gate = _FakeGate(initial: false);
    final router = _routerFor(gate);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(find.text('sign-in'), findsOneWidget);

    gate.setAuthenticated(true);
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
