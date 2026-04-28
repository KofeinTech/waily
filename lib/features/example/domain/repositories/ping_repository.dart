import '../entities/ping_status.dart';

abstract class PingRepository {
  Future<PingStatus> ping();
}
