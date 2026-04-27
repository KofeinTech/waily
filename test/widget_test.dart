import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waily/app.dart';
import 'package:waily/core/di/injection.dart';
import 'package:waily/core/env/env.dart';

void main() {
  setUp(() {
    resetEnvForTesting();
    dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
ENABLE_LOGGING=false
''');
    SharedPreferences.setMockInitialValues({});
    configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
    resetEnvForTesting();
  });

  testWidgets('App boots into the Home tab via the always-on stub gate',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // The Home placeholder body and the active bottom-nav label both
    // render the string 'Home', so a plain text find is ambiguous.
    expect(find.text('Home'), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey('app-bottom-nav-item-home')),
      findsOneWidget,
    );
  });
}
