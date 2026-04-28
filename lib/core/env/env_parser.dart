part of 'env.dart';

final _parser = dotenv;

extension _Parse on String {
  String get env => _parser.env[this] ?? '';
}
