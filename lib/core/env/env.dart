import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'env.freezed.dart';
part 'env_parser.dart';
part 'env_variables.dart';

Future<void> initEnv() async {
  if (_parser.isInitialized) return;
  await _parser.load();
}

_EnvData get kEnv => kEnvHelper.data;

_Env get kEnvHelper => _buildEnv();

_Env? _envInstance;

_Env _buildEnv() {
  assert(_parser.isInitialized, 'kEnv not initialized, call initEnv() first');
  return _envInstance ??= switch (_EnvVariables.envType.toUpperCase()) {
    'PROD' => _Env.prod(_env),
    _ => _Env.dev(_env),
  };
}

@freezed
sealed class _Env with _$Env {
  const factory _Env.dev(_EnvData data) = _Dev;
  const factory _Env.prod(_EnvData data) = _Prod;
}

extension EnvX on _Env {
  bool get isDev => this is _Dev;
  bool get isProd => this is _Prod;

  _EnvData get data => switch (this) {
        _Dev(:final data) => data,
        _Prod(:final data) => data,
      };
}

@visibleForTesting
void resetEnvForTesting() {
  _envInstance = null;
  _parser.clean();
}
