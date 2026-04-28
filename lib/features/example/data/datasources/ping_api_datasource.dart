import '../models/ping_response.dart';

abstract class PingApiDatasource {
  Future<PingResponse> getPing();
}
