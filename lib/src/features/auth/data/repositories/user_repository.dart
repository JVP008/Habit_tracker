import 'package:dartz/dartz.dart';
import 'package:habit_tracker/src/core/data/daos/user_dao.dart';
import 'package:habit_tracker/src/core/error/failures.dart';
import 'package:habit_tracker/src/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserRepository {
  final UserDao _userDao;

  UserRepository(this._userDao);

  /// Creates a new user
  Future<Either<Failure, UserModel>> createUser(UserModel user) async {
    try {
      final createdUser = await _userDao.create(user);
      return Right(createdUser);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Gets a user by ID
  Future<Either<Failure, UserModel?>> getUser(String userId) async {
    try {
      final user = await _userDao.findById(userId);
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Gets a user by email
  Future<Either<Failure, UserModel?>> getUserByEmail(String email) async {
    try {
      final user = await _userDao.findByEmail(email);
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Updates a user
  Future<Either<Failure, UserModel>> updateUser(UserModel user) async {
    try {
      final updatedUser = await _userDao.update(user);
      return Right(updatedUser);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Deletes a user
  Future<Either<Failure, void>> deleteUser(String userId) async {
    try {
      await _userDao.delete(userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Updates the user's last active timestamp
  Future<Either<Failure, void>> updateLastActive(String userId) async {
    try {
      await _userDao.updateLastActive(userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Increments the user's streak
  Future<Either<Failure, void>> incrementStreak(String userId) async {
    try {
      await _userDao.incrementStreak(userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Resets the user's streak to 0
  Future<Either<Failure, void>> resetStreak(String userId) async {
    try {
      await _userDao.resetStreak(userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Increments the user's completed challenges count
  Future<Either<Failure, void>> incrementCompletedChallenges(String userId) async {
    try {
      await _userDao.incrementCompletedChallenges(userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Updates the user's profile information
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      await _userDao.updateProfile(
        userId: userId,
        displayName: displayName,
        photoUrl: photoUrl,
        bio: bio,
      );
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Updates the user's settings
  Future<Either<Failure, void>> updateSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _userDao.updateSettings(userId, settings);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Upgrades the user to premium
  Future<Either<Failure, void>> upgradeToPremium(
    String userId,
    Duration duration,
  ) async {
    try {
      await _userDao.upgradeToPremium(userId, duration);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Downgrades the user from premium
  Future<Either<Failure, void>> downgradeFromPremium(String userId) async {
    try {
      await _userDao.downgradeFromPremium(userId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Gets all users (for admin purposes)
  Future<Either<Failure, List<UserModel>>> getAllUsers({
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      final users = await _userDao.findAll(
        limit: limit,
        offset: offset,
        orderBy: orderBy,
        descending: descending,
      );
      return Right(users);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Counts the total number of users
  Future<Either<Failure, int>> countUsers() async {
    try {
      final count = await _userDao.count();
      return Right(count);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Gets premium users
  Future<Either<Failure, List<UserModel>>> getPremiumUsers({
    int? limit,
    int? offset,
  }) async {
    try {
      final users = await _userDao.findAll(
        filters: {'is_premium': 1},
        limit: limit,
        offset: offset,
        orderBy: 'subscription_expiry',
        descending: true,
      );
      return Right(users);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Gets users with active streaks
  Future<Either<Failure, List<UserModel>>> getUsersWithStreaks({
    int? minStreak,
    int? limit,
    int? offset,
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (minStreak != null) {
        filters['streak_days'] = minStreak;
      }
      
      final users = await _userDao.findAll(
        filters: filters,
        limit: limit,
        offset: offset,
        orderBy: 'streak_days',
        descending: true,
      );
      return Right(users);
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }

  /// Searches users by display name or email
  Future<Either<Failure, List<UserModel>>> searchUsers(String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      final users = await _userDao.db.rawQuery('''
        SELECT * FROM ${_userDao.tableName}
        WHERE display_name LIKE ? OR email LIKE ?
        ORDER BY display_name ASC
        ${limit != null ? 'LIMIT $limit' : ''}
        ${offset != null ? 'OFFSET $offset' : ''}
      ''', ['%$query%', '%$query%']);
      
      return Right(users.map((map) => _userDao.fromMap(map)).toList());
    } catch (e) {
      return Left(DatabaseFailure.fromException(e));
    }
  }
}
