import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:talker/talker.dart';
import 'package:waily/features/core/domain/managers/notification_manager.dart';
import 'package:waily/features/core/data/datasources/secure_storage.dart';

@GenerateMocks([Talker, NotificationManager, Dio, SecureStorage])
void main() {}
