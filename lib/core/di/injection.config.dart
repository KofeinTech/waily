// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:talker/talker.dart' as _i993;
import 'package:waily/core/database/app_database.dart' as _i938;
import 'package:waily/core/database/database_module.dart' as _i513;
import 'package:waily/core/di/app_module.dart' as _i267;
import 'package:waily/core/network/api_client.dart' as _i176;
import 'package:waily/core/network/api_client_impl.dart' as _i933;
import 'package:waily/core/network/auth/auth_token_refresher.dart' as _i159;
import 'package:waily/core/network/auth/stub_auth_token_refresher.dart'
    as _i332;
import 'package:waily/core/network/auth/token_store.dart' as _i689;
import 'package:waily/core/network/auth/token_store_impl.dart' as _i124;
import 'package:waily/core/network/interceptors/auth_interceptor.dart' as _i208;
import 'package:waily/core/network/interceptors/logging_interceptor.dart'
    as _i399;
import 'package:waily/core/network/network_module.dart' as _i2;
import 'package:waily/core/router/auth_session_gate.dart' as _i670;
import 'package:waily/features/core/data/datasources/local_storage.dart'
    as _i550;
import 'package:waily/features/core/data/datasources/local_storage_impl.dart'
    as _i1013;
import 'package:waily/features/core/data/datasources/secure_storage.dart'
    as _i82;
import 'package:waily/features/core/data/datasources/secure_storage_impl.dart'
    as _i442;
import 'package:waily/features/core/data/managers/notification_manager_impl.dart'
    as _i95;
import 'package:waily/features/core/domain/managers/notification_manager.dart'
    as _i349;
import 'package:waily/features/core/domain/use_cases/trigger_demo_error_use_case.dart'
    as _i374;
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart'
    as _i169;
import 'package:waily/features/example/data/datasources/ping_api_datasource.dart'
    as _i791;
import 'package:waily/features/example/data/datasources/ping_api_datasource_impl.dart'
    as _i373;
import 'package:waily/features/example/data/repositories/ping_repository_impl.dart'
    as _i922;
import 'package:waily/features/example/domain/repositories/ping_repository.dart'
    as _i601;
import 'package:waily/features/hydration/data/datasources/hydration_datasource.dart'
    as _i975;
import 'package:waily/features/hydration/data/datasources/hydration_datasource_impl.dart'
    as _i933;
import 'package:waily/features/hydration/data/repositories/hydration_repository_impl.dart'
    as _i722;
import 'package:waily/features/hydration/domain/repositories/hydration_repository.dart'
    as _i374;
import 'package:waily/features/meal/data/datasources/meal_datasource.dart'
    as _i253;
import 'package:waily/features/meal/data/datasources/meal_datasource_impl.dart'
    as _i617;
import 'package:waily/features/meal/data/repositories/meal_repository_impl.dart'
    as _i241;
import 'package:waily/features/meal/domain/repositories/meal_repository.dart'
    as _i756;
import 'package:waily/features/user/data/datasources/user_datasource.dart'
    as _i558;
import 'package:waily/features/user/data/datasources/user_datasource_impl.dart'
    as _i487;
import 'package:waily/features/user/data/repositories/user_repository_impl.dart'
    as _i164;
import 'package:waily/features/user/domain/repositories/user_repository.dart'
    as _i803;
import 'package:waily/features/workout/data/datasources/workout_datasource.dart'
    as _i244;
import 'package:waily/features/workout/data/datasources/workout_datasource_impl.dart'
    as _i714;
import 'package:waily/features/workout/data/repositories/workout_repository_impl.dart'
    as _i821;
import 'package:waily/features/workout/domain/repositories/workout_repository.dart'
    as _i106;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final databaseModule = _$DatabaseModule();
    final networkModule = _$NetworkModule();
    gh.singleton<_i993.Talker>(() => appModule.talker);
    gh.lazySingleton<_i938.AppDatabase>(
      () => databaseModule.appDatabase(),
      dispose: _i513.closeDatabase,
    );
    gh.lazySingleton<_i550.LocalStorage>(() => _i1013.LocalStorageImpl());
    gh.factory<_i399.LoggingInterceptor>(
      () => _i399.LoggingInterceptor(gh<_i993.Talker>()),
    );
    gh.lazySingleton<_i82.SecureStorage>(() => _i442.SecureStorageImpl());
    gh.lazySingleton<_i159.AuthTokenRefresher>(
      () => _i332.StubAuthTokenRefresher(),
    );
    gh.lazySingleton<_i689.TokenStore>(
      () => _i124.TokenStoreImpl(gh<_i82.SecureStorage>()),
    );
    gh.singleton<_i349.NotificationManager>(
      () => _i95.NotificationManagerImpl(),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i558.UserDatasource>(
      () =>
          _i487.UserDatasourceImpl(gh<_i993.Talker>(), gh<_i938.AppDatabase>()),
    );
    gh.factory<_i975.HydrationDatasource>(
      () => _i933.HydrationDatasourceImpl(
        gh<_i993.Talker>(),
        gh<_i938.AppDatabase>(),
      ),
    );
    gh.lazySingleton<_i803.UserRepository>(
      () => _i164.UserRepositoryImpl(gh<_i558.UserDatasource>()),
    );
    gh.factory<_i244.WorkoutDatasource>(
      () => _i714.WorkoutDatasourceImpl(
        gh<_i993.Talker>(),
        gh<_i938.AppDatabase>(),
      ),
    );
    gh.factory<_i253.MealDatasource>(
      () =>
          _i617.MealDatasourceImpl(gh<_i993.Talker>(), gh<_i938.AppDatabase>()),
    );
    gh.lazySingleton<_i670.AuthSessionGate>(
      () => _i670.StubAuthSessionGate(gh<_i82.SecureStorage>()),
    );
    gh.lazySingleton<_i756.MealRepository>(
      () => _i241.MealRepositoryImpl(gh<_i253.MealDatasource>()),
    );
    gh.lazySingleton<_i169.AppNotificationCubit>(
      () => _i169.AppNotificationCubit(gh<_i349.NotificationManager>()),
      dispose: (i) => i.close(),
    );
    gh.lazySingleton<_i106.WorkoutRepository>(
      () => _i821.WorkoutRepositoryImpl(gh<_i244.WorkoutDatasource>()),
    );
    gh.lazySingleton<_i374.TriggerDemoErrorUseCase>(
      () => _i374.TriggerDemoErrorUseCase(
        gh<_i993.Talker>(),
        gh<_i349.NotificationManager>(),
      ),
    );
    gh.lazySingleton<_i374.HydrationRepository>(
      () => _i722.HydrationRepositoryImpl(gh<_i975.HydrationDatasource>()),
    );
    gh.lazySingleton<_i208.AuthInterceptor>(
      () => _i208.AuthInterceptor(
        gh<_i689.TokenStore>(),
        gh<_i159.AuthTokenRefresher>(),
        gh<_i670.AuthSessionGate>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => networkModule.dio(
        gh<_i208.AuthInterceptor>(),
        gh<_i399.LoggingInterceptor>(),
      ),
    );
    gh.lazySingleton<_i176.ApiClient>(
      () => _i933.ApiClientImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i791.PingApiDatasource>(
      () => _i373.PingApiDatasourceImpl(
        gh<_i993.Talker>(),
        gh<_i176.ApiClient>(),
      ),
    );
    gh.lazySingleton<_i601.PingRepository>(
      () => _i922.PingRepositoryImpl(gh<_i791.PingApiDatasource>()),
    );
    return this;
  }
}

class _$AppModule extends _i267.AppModule {}

class _$DatabaseModule extends _i513.DatabaseModule {}

class _$NetworkModule extends _i2.NetworkModule {}
