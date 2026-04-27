import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:waily/main.dart';

void main() {
  testWidgets('WailyApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const WailyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
