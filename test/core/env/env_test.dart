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

    test('unknown TYPE value defaults to dev variant', () {
      dotenv.testLoad(fileInput: '''
TYPE=staging
API_BASE_URL=https://example.com
ENABLE_LOGGING=true
''');

      expect(kEnvHelper.isDev, isTrue);
    });

    test('kEnv exposes typed apiBaseUrl', () {
      dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://api.example.com/v1
ENABLE_LOGGING=true
''');

      expect(kEnv.apiBaseUrl, 'https://api.example.com/v1');
    });

    test('ENABLE_LOGGING parses true / false / missing as bool', () {
      dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
ENABLE_LOGGING=false
''');
      expect(kEnv.enableLogging, isFalse);

      resetEnvForTesting();
      dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
''');
      expect(kEnv.enableLogging, isFalse);

      resetEnvForTesting();
      dotenv.testLoad(fileInput: '''
TYPE=DEV
API_BASE_URL=https://example.com
ENABLE_LOGGING=true
''');
      expect(kEnv.enableLogging, isTrue);
    });
  });
}
