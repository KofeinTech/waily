import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waily/app.dart';
import 'package:waily/core/di/injection.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('App boots and shows the demo home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();

    expect(find.text('Waily — state mgmt demo'), findsOneWidget);
    expect(find.text('Show notification (direct)'), findsOneWidget);
    expect(find.text('Trigger error via use case'), findsOneWidget);
  });
}
