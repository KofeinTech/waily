/// Typed route names and paths for go_router.
///
/// Names are used with `context.goNamed(...)`. Paths are used inside
/// the [GoRoute] / [StatefulShellBranch] tree.
class AppRoutes {
  AppRoutes._();

  // --- Public ---
  static const String signIn = 'signIn';
  static const String signInPath = '/sign-in';

  // --- Shell branches ---
  static const String home = 'home';
  static const String homePath = '/home';

  static const String meal = 'meal';
  static const String mealPath = '/meal';

  static const String chat = 'chat';
  static const String chatPath = '/chat';

  static const String hydration = 'hydration';
  static const String hydrationPath = '/hydration';

  static const String profile = 'profile';
  static const String profilePath = '/profile';

  // --- Profile sub-routes ---
  static const String devTools = 'devTools';
  static const String devToolsSubPath = 'dev-tools';
  static const String devToolsFullPath = '/profile/dev-tools';

  /// Order of the 5 bottom-nav branches. Index here drives
  /// `StatefulShellRoute.indexedStack` and `AppBottomNav`.
  static const List<String> shellBranchOrder = [
    home,
    meal,
    chat,
    hydration,
    profile,
  ];

  /// Centered placeholder labels until per-tab features are built.
  static const Map<String, String> tabLabels = {
    home: 'Home',
    meal: 'Meal',
    chat: 'Chat',
    hydration: 'Hydration',
    profile: 'Profile',
  };
}
