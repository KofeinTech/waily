import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

@module
abstract class AppModule {
  @singleton
  Talker get talker => Talker();
}
