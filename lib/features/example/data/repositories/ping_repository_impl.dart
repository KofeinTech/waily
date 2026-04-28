import 'package:injectable/injectable.dart';

import '../../domain/entities/ping_status.dart';
import '../../domain/repositories/ping_repository.dart';
import '../datasources/ping_api_datasource.dart';
import '../mappers/ping_response_mapper.dart';

@LazySingleton(as: PingRepository)
class PingRepositoryImpl implements PingRepository {
  PingRepositoryImpl(this._datasource);

  final PingApiDatasource _datasource;

  @override
  Future<PingStatus> ping() async {
    final response = await _datasource.getPing();
    return response.toEntity();
  }
}
