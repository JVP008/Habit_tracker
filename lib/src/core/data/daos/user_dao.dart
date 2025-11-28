import 'package:habit_tracker/src/features/auth/data/models/user_model.dart';
import 'package:habit_tracker/src/core/data/daos/base_dao.dart';
import 'package:habit_tracker/src/core/error/exceptions.dart' as app_exceptions;
import 'package:injectable/injectable.dart';

@injectable
class UserDao extends BaseDao<UserModel, String> {
  UserDao(super.db);

  @override
  String get tableName => 'users';

  @override
  String get primaryKey => 'id';

  @override
  UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String?,
      displayName: map['display_name'] as String,
      email: map['email'] as String,
      photoUrl: map['photo_url'] as String?,
      bio: map['bio'] as String?,
      streakDays: map['streak_days'] as int? ?? 0,
      completedChallenges: map['completed_challenges'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      lastActive: map['last_active'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_active'] as int)
          : null,
      settings: map['settings'] != null
          ? Map<String, dynamic>.from(map['settings'] as Map)
          : null,
      isPremium: (map['is_premium'] as int?) == 1,
      subscriptionExpiry: map['subscription_expiry'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['subscription_expiry'] as int,
            )
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap(UserModel model) {
    return {
      'id': model.id,
      'display_name': model.displayName,
      'email': model.email,
      'photo_url': model.photoUrl,
      'bio': model.bio,
      'streak_days': model.streakDays,
      'completed_challenges': model.completedChallenges,
      'created_at': model.createdAt.millisecondsSinceEpoch,
      'updated_at': model.updatedAt.millisecondsSinceEpoch,
      'last_active': model.lastActive?.millisecondsSinceEpoch,
      'settings': model.settings,
      'is_premium': model.isPremium ? 1 : 0,
      'subscription_expiry': model.subscriptionExpiry?.millisecondsSinceEpoch,
    }..removeWhere((key, value) => value == null);
  }

  /// Finds a user by email
  Future<UserModel?> findByEmail(String email) async {
    try {
      final maps = await db.query(
        tableName,
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to find user by email: $e',
      );
    }
  }

  /// Updates the user's last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await db.update(
        tableName,
        {
          'last_active': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: '$primaryKey = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update last active: $e',
      );
    }
  }

  /// Increments the user's streak
  Future<void> incrementStreak(String userId) async {
    try {
      await db.rawUpdate(
        '''
        UPDATE $tableName 
        SET streak_days = streak_days + 1, 
            updated_at = ?
        WHERE $primaryKey = ?
      ''',
        [DateTime.now().millisecondsSinceEpoch, userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to increment streak: $e',
      );
    }
  }

  /// Resets the user's streak to 0
  Future<void> resetStreak(String userId) async {
    try {
      await db.update(
        tableName,
        {'streak_days': 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: '$primaryKey = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to reset streak: $e',
      );
    }
  }

  /// Increments the user's completed challenges count
  Future<void> incrementCompletedChallenges(String userId) async {
    try {
      await db.rawUpdate(
        '''
        UPDATE $tableName 
        SET completed_challenges = completed_challenges + 1, 
            updated_at = ?
        WHERE $primaryKey = ?
      ''',
        [DateTime.now().millisecondsSinceEpoch, userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to increment completed challenges: $e',
      );
    }
  }

  /// Updates the user's profile information
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
    String? bio,
  }) async {
    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      if (displayName != null) data['display_name'] = displayName;
      if (photoUrl != null) data['photo_url'] = photoUrl;
      if (bio != null) data['bio'] = bio;

      await db.update(
        tableName,
        data,
        where: '$primaryKey = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update profile: $e',
      );
    }
  }

  /// Updates the user's settings
  Future<void> updateSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await db.update(
        tableName,
        {
          'settings': settings,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: '$primaryKey = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to update settings: $e',
      );
    }
  }

  /// Upgrades the user to premium
  Future<void> upgradeToPremium(String userId, Duration duration) async {
    try {
      final expiry = DateTime.now().add(duration);
      await db.update(
        tableName,
        {
          'is_premium': 1,
          'subscription_expiry': expiry.millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: '$primaryKey = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to upgrade to premium: $e',
      );
    }
  }

  /// Downgrades the user from premium
  Future<void> downgradeFromPremium(String userId) async {
    try {
      await db.update(
        tableName,
        {
          'is_premium': 0,
          'subscription_expiry': null,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: '$primaryKey = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to downgrade from premium: $e',
      );
    }
  }

  /// Builds the table definition
  @override
  String buildTableDefinition() {
    return '''
      id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      photo_url TEXT,
      bio TEXT,
      streak_days INTEGER NOT NULL DEFAULT 0,
      completed_challenges INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      last_active INTEGER,
      settings TEXT,
      is_premium INTEGER NOT NULL DEFAULT 0,
      subscription_expiry INTEGER
    ''';
  }

  /// Creates indexes for the users table
  @override
  Future<void> createIndexes() async {
    try {
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_users_email ON $tableName(email)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_users_created_at ON $tableName(created_at)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_users_is_premium ON $tableName(is_premium)
      ''');
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to create indexes: $e',
      );
    }
  }
}
