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

  testWidgets('only the active item renders its label at non-zero width', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestThemeWrapper(child: _FakeShell(currentIndex: 2, onTap: (_) {})),
    );
    await tester.pumpAndSettle();

    // All five labels live in the tree (each cell renders its own Text);
    // SizeTransition collapses inactive ones to zero width on its outer
    // render box even though the inner Text keeps its intrinsic size.
    for (final branch in AppRoutes.shellBranchOrder) {
      expect(find.text(AppRoutes.tabLabels[branch]!), findsOneWidget);
    }

    expect(_labelTransitionWidth(tester, AppRoutes.chat), greaterThan(0));
    expect(_labelTransitionWidth(tester, AppRoutes.home), 0);
    expect(_labelTransitionWidth(tester, AppRoutes.profile), 0);
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

  testWidgets('switching the active branch animates the label widths', (
    tester,
  ) async {
    int currentIndex = 0;
    late StateSetter setOuterState;

    await tester.pumpWidget(
      TestThemeWrapper(
        child: StatefulBuilder(
          builder: (context, setState) {
            setOuterState = setState;
            return _FakeShell(
              currentIndex: currentIndex,
              onTap: (i) => setState(() => currentIndex = i),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_labelTransitionWidth(tester, AppRoutes.home), greaterThan(0));
    expect(_labelTransitionWidth(tester, AppRoutes.profile), 0);

    setOuterState(() => currentIndex = 4);
    await tester.pump();
    // Mid-animation: both items have non-final widths.
    await tester.pump(const Duration(milliseconds: 150));
    final homeMid = _labelTransitionWidth(tester, AppRoutes.home);
    final profileMid = _labelTransitionWidth(tester, AppRoutes.profile);
    expect(homeMid, greaterThan(0));
    expect(profileMid, greaterThan(0));

    await tester.pumpAndSettle();
    expect(_labelTransitionWidth(tester, AppRoutes.home), 0);
    expect(_labelTransitionWidth(tester, AppRoutes.profile), greaterThan(0));
  });
}

double _labelTransitionWidth(WidgetTester tester, String branch) {
  final transition = find.descendant(
    of: find.byKey(ValueKey('app-bottom-nav-item-$branch')),
    matching: find.byType(SizeTransition),
  );
  expect(transition, findsOneWidget);
  return tester.getSize(transition).width;
}
