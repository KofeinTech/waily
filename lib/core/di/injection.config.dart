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
import 'package:waily/core/database/app_database.dart' as _i938;
import 'package:waily/core/database/database_module.dart' as _i513;
import 'package:waily/core/di/app_module.dart' as _i267;
import 'package:waily/features/core/data/managers/notification_manager_impl.dart'
    as _i95;
import 'package:waily/features/core/data/sources/local_storage_impl.dart'
    as _i284;
import 'package:waily/features/core/data/sources/secure_storage_impl.dart'
    as _i1044;
import 'package:waily/features/core/domain/managers/notification_manager.dart'
    as _i349;
import 'package:waily/features/core/domain/sources/local_storage.dart' as _i891;
import 'package:waily/features/core/domain/sources/secure_storage.dart'
    as _i501;
import 'package:waily/features/core/domain/use_cases/trigger_demo_error_use_case.dart'
    as _i374;
import 'package:waily/features/core/presentation/bloc/app_notification_cubit.dart'
    as _i169;
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
    gh.singleton<_i993.Talker>(() => appModule.talker);
    gh.lazySingleton<_i938.AppDatabase>(
      () => databaseModule.appDatabase(),
      dispose: _i513.closeDatabase,
    );
    gh.lazySingleton<_i501.SecureStorage>(() => _i1044.SecureStorageImpl());
    gh.singleton<_i349.NotificationManager>(
      () => _i95.NotificationManagerImpl(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i891.LocalStorage>(() => _i284.LocalStorageImpl());
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
    return this;
  }
}

class _$AppModule extends _i267.AppModule {}

class _$DatabaseModule extends _i513.DatabaseModule {}
