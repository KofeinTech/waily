import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waily/core/env/env.dart';

void main() {
  group('kEnvHelper', () {
    setUp(() {
      resetEnvForTesting();
    });

    test('returns dev variant when TYPE=DEV', () {
      dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
ENABLE_LOGGING=true
''');

      expect(kEnvHelper.isDev, isTrue);
      expect(kEnvHelper.isProd, isFalse);
    });

    test('returns prod variant when TYPE=PROD', () {
      dotenv.testLoad(fileInput: '''
TYPE=PROD
API_BASE_URL=https://example.com
ENABLE_LOGGING=false
''');

      expect(kEnvHelper.isProd, isTrue);
      expect(kEnvHelper.isDev, isFalse);
    });
  });
}
