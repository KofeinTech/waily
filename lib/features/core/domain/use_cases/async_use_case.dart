import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

import '../entities/notification_exception.dart';
import '../managers/notification_manager.dart';

abstract class AsyncUseCase<P, R> {
  AsyncUseCase(this.talker, this.notificationManager, {this.isSilent = false});

  final Talker talker;
  final NotificationManager notificationManager;
  final bool isSilent;

  @protected
  Future<R> onExecute(P params);

  Future<Either<Exception, R>> call(P params) async {
    try {
      final result = await onExecute(params);
      return Right(result);
    } catch (error, stackTrace) {
      talker.handle(
        error,
        stackTrace,
        'Unhandled Exception in $runtimeType with params: $params',
      );

      if (error is NotificationException && !isSilent) {
        notificationManager.sendNotification(error.notification);
        return Left(error);
      } else if (error is Exception) {
        return Left(error);
      }
      return Left(Exception(error.toString()));
    }
  }
}
