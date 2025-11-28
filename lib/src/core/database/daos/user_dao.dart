import '../../../features/auth/data/models/user_model.dart';
import '../../database/base_dao.dart';
import '../../database/database_config.dart';

class UserDao extends BaseDao<UserModel> {
  @override
  String get tableName => DatabaseConfig.tableUsers;

  @override
  UserModel fromMap(Map<String, dynamic> map) => UserModelExtension.fromFirestoreData(map);

  @override
  Map<String, dynamic> toMap(UserModel item) => item.toFirestoreData();

  /// Gets a user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final db = database;
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
  }

  /// Checks if a user exists with the given email
  Future<bool> userExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }
  
  /// Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    final db = database;
    await db.update(
      tableName,
      {'last_active': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
