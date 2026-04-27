// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:talker/talker.dart' as _i993;
import 'package:waily/core/di/app_module.dart' as _i267;
import 'package:waily/features/core/data/managers/notification_manager_impl.dart'
    as _i95;
import 'package:waily/features/core/domain/managers/notification_manager.dart'
    as _i349;
import 'package:waily/features/core/domain/use_cases/trigger_demo_error_use_case.dart'
    as _i374;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.singleton<_i993.Talker>(() => appModule.talker);
    gh.singleton<_i349.NotificationManager>(
      () => _i95.NotificationManagerImpl(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i374.TriggerDemoErrorUseCase>(
      () => _i374.TriggerDemoErrorUseCase(
        gh<_i993.Talker>(),
        gh<_i349.NotificationManager>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i267.AppModule {}
