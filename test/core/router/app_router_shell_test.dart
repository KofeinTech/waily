import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter _buildShellRouter() {
  return GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => Scaffold(
          body: shell,
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < 2; i++)
                TextButton(
                  key: ValueKey('tab-$i'),
                  onPressed: () => shell.goBranch(
                    i,
                    initialLocation: i == shell.currentIndex,
                  ),
                  child: Text('tab $i'),
                ),
            ],
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/a',
                builder: (_, _) => const Scaffold(body: Text('A root')),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (_, _) => const Scaffold(body: Text('A detail')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                builder: (_, _) => const Scaffold(body: Text('B root')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('tab switch preserves nested route on the inactive branch',
      (tester) async {
    final router = _buildShellRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('A root'), findsOneWidget);

    router.go('/a/detail');
    await tester.pumpAndSettle();
    expect(find.text('A detail'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('B root'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();
    expect(find.text('A detail'), findsOneWidget);
  });

  testWidgets('re-tapping the active tab pops to its branch root',
      (tester) async {
    final router = _buildShellRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/a/detail');
    await tester.pumpAndSettle();
    expect(find.text('A detail'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();

    expect(find.text('A root'), findsOneWidget);
    expect(find.text('A detail'), findsNothing);
  });
}
