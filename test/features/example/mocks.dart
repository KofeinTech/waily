import 'package:mockito/annotations.dart';
import 'package:talker/talker.dart';
import 'package:waily/core/network/api_client.dart';
import 'package:waily/features/example/data/datasources/ping_api_datasource.dart';

@GenerateMocks([
  ApiClient,
  PingApiDatasource,
  Talker,
])
void main() {}
