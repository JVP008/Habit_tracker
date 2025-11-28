// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:habit_tracker/src/core/data/daos/user_dao.dart' as _i511;
import 'package:habit_tracker/src/features/auth/data/repositories/user_repository.dart'
    as _i160;
import 'package:habit_tracker/src/features/auth/domain/use_cases/get_user_use_case.dart'
    as _i969;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sqflite/sqflite.dart' as _i779;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i511.UserDao>(() => _i511.UserDao(gh<_i779.Database>()));
    gh.factory<_i160.UserRepository>(
        () => _i160.UserRepository(gh<_i511.UserDao>()));
    gh.factory<_i969.GetUserUseCase>(
        () => _i969.GetUserUseCase(gh<_i160.UserRepository>()));
    return this;
  }
}
