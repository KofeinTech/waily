import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'env_parser.dart';
part 'env_variables.dart';

Future<void> initEnv() async {
  if (_parser.isInitialized) return;
  await _parser.load();
}

_EnvData get kEnv {
  assert(_parser.isInitialized, 'kEnv not initialized, call initEnv() first');
  return _env;
}

@visibleForTesting
void resetEnvForTesting() {
  _parser.clean();
}
