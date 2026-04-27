import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

abstract class AppGateway {
  AppGateway(this._talker);

  final Talker _talker;

  @protected
  Future<T> safeCall<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (e, st) {
      _talker.handle(e, st, 'AppGateway DioException');
      rethrow;
    } catch (e, st) {
      _talker.handle(e, st, 'AppGateway error');
      rethrow;
    }
  }

  @protected
  Future<void> voidSafeCall(Future<void> Function() operation) async {
    await safeCall<void>(operation);
  }
}
