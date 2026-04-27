part of 'env.dart';

abstract class _EnvVariables {
  static String get envType => 'TYPE'.env;
  static String get apiBaseUrl => 'API_BASE_URL'.env;
  static bool get enableLogging => 'ENABLE_LOGGING'.env.toLowerCase() == 'true';
}

_EnvData get _env => _EnvData._(
  apiBaseUrl: _EnvVariables.apiBaseUrl,
  enableLogging: _EnvVariables.enableLogging,
);

class _EnvData extends Equatable {
  const _EnvData._({
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  final String apiBaseUrl;
  final bool enableLogging;

  @override
  List<Object?> get props => [apiBaseUrl, enableLogging];
}
