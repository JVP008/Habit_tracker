import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:habit_tracker/src/core/database/database_service.dart';
import 'package:habit_tracker/src/core/data/daos/user_dao.dart';
import 'package:habit_tracker/src/features/auth/data/repositories/user_repository.dart';

/// Global service locator
final GetIt getIt = GetIt.instance;

@injectableInit
Future<void> configureDependencies() async {
  // Register the database service
  await DatabaseService.register();
  
  // Register DAOs
  getIt.registerLazySingleton<UserDao>(
    () => UserDao(getIt<DatabaseService>().db),
  );
  
  // Register repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<UserDao>()),
  );
}

/// Extension methods for easy access to services
extension ServiceLocatorX on GetIt {
  /// Gets the user repository
  UserRepository get userRepository => get<UserRepository>();
  
  /// Gets the user DAO
  UserDao get userDao => get<UserDao>();
  
  /// Gets the database service
  DatabaseService get databaseService => get<DatabaseService>();
}
