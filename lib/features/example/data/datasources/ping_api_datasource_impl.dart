import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../../core/data/gateway/app_gateway.dart';
import '../models/ping_response.dart';
import 'ping_api_datasource.dart';

@Injectable(as: PingApiDatasource)
class PingApiDatasourceImpl extends AppGateway implements PingApiDatasource {
  PingApiDatasourceImpl(super.talker, this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<PingResponse> getPing() => safeCall<PingResponse>(() async {
        final response = await _apiClient.get<Map<String, dynamic>>('/ping');
        return PingResponse.fromJson(response.data!);
      });
}
