import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/app.dart';
import 'package:waily/core/env/env.dart';

void main() {
  setUp(() {
    resetEnvForTesting();
  });

  testWidgets('WailyApp builds without error', (WidgetTester tester) async {
    dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
ENABLE_LOGGING=true
''');

    await tester.pumpWidget(const WailyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
