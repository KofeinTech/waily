import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/env/env.dart';
import 'package:waily/core/ui_kit/components/dev_env_banner.dart';

void main() {
  group('DevEnvBanner', () {
    setUp(() {
      resetEnvForTesting();
    });

    testWidgets('shows DEV banner when kEnvHelper.isDev', (tester) async {
      dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
ENABLE_LOGGING=true
''');

      await tester.pumpWidget(
        const MaterialApp(
          home: DevEnvBanner(child: Scaffold(body: Text('child'))),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Banner && w.message == 'DEV',
        ),
        findsOneWidget,
      );
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('does NOT show banner when kEnvHelper.isProd', (tester) async {
      dotenv.testLoad(fileInput: '''
TYPE=PROD
API_BASE_URL=https://example.com
ENABLE_LOGGING=false
''');

      await tester.pumpWidget(
        const MaterialApp(
          home: DevEnvBanner(child: Scaffold(body: Text('child'))),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Banner && w.message == 'DEV',
        ),
        findsNothing,
      );
      expect(find.text('child'), findsOneWidget);
    });
  });
}
