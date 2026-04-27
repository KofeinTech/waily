import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/router/app_routes.dart';
import 'package:waily/core/ui_kit/components/nav/app_bottom_nav.dart';

import '../../helpers/test_theme_wrapper.dart';

class _FakeShell extends StatelessWidget {
  const _FakeShell({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(currentIndex: currentIndex, onTap: onTap);
  }
}

void main() {
  testWidgets('renders 5 items, one per shell branch', (tester) async {
    await tester.pumpWidget(
      TestThemeWrapper(child: _FakeShell(currentIndex: 0, onTap: (_) {})),
    );

    for (final branch in AppRoutes.shellBranchOrder) {
      expect(
        find.byKey(ValueKey('app-bottom-nav-item-$branch')),
        findsOneWidget,
        reason: 'missing nav item for $branch',
      );
    }
  });

  testWidgets('shows label only on the active item', (tester) async {
    await tester.pumpWidget(
      TestThemeWrapper(child: _FakeShell(currentIndex: 2, onTap: (_) {})),
    );

    expect(find.text(AppRoutes.tabLabels[AppRoutes.chat]!), findsOneWidget);
    expect(find.text(AppRoutes.tabLabels[AppRoutes.home]!), findsNothing);
    expect(find.text(AppRoutes.tabLabels[AppRoutes.profile]!), findsNothing);
  });

  testWidgets('tapping an item invokes onTap with that index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      TestThemeWrapper(
        child: _FakeShell(currentIndex: 0, onTap: (i) => tapped = i),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('app-bottom-nav-item-hydration')),
    );
    await tester.pump();

    expect(tapped, 3);
  });
}
