import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';

import '../entities/notification_exception.dart';
import '../managers/notification_manager.dart';

abstract class SyncUseCase<P, R> {
  SyncUseCase(this.talker, this.notificationManager, {this.isSilent = false});

  final Talker talker;
  final NotificationManager notificationManager;
  final bool isSilent;

  @protected
  R onExecute(P params);

  Either<Exception, R> call(P params) {
    try {
      final result = onExecute(params);
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
