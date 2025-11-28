import 'package:habit_tracker/src/features/challenges/data/models/challenge_model.dart';
import 'package:habit_tracker/src/core/data/daos/base_dao.dart';
import 'package:habit_tracker/src/core/error/exceptions.dart';

class ChallengeDao extends BaseDao<ChallengeModel, String> {
  ChallengeDao(super.db);

  @override
  String get tableName => 'challenges';

  @override
  String get primaryKey => 'id';

  @override
  ChallengeModel fromMap(Map<String, dynamic> map) {
    return ChallengeModel(
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String,
      createdBy: map['created_by'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int),
      goalType: map['goal_type'] as String,
      goalTarget: map['goal_target'] as int,
      goalUnit: map['goal_unit'] as String,
      imageUrl: map['image_url'] as String?,
      isPublic: (map['is_public'] as int?) == 1,
      isActive: (map['is_active'] as int?) == 1,
      maxParticipants: map['max_participants'] as int?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap(ChallengeModel model) {
    return {
      'id': model.id,
      'title': model.title,
      'description': model.description,
      'created_by': model.createdBy,
      'start_date': model.startDate.millisecondsSinceEpoch,
      'end_date': model.endDate.millisecondsSinceEpoch,
      'goal_type': model.goalType,
      'goal_target': model.goalTarget,
      'goal_unit': model.goalUnit,
      'image_url': model.imageUrl,
      'is_public': model.isPublic ? 1 : 0,
      'is_active': model.isActive ? 1 : 0,
      'max_participants': model.maxParticipants,
      'created_at': model.createdAt.millisecondsSinceEpoch,
      'updated_at': model.updatedAt.millisecondsSinceEpoch,
    }..removeWhere((key, value) => value == null);
  }

  /// Gets active challenges
  Future<List<ChallengeModel>> findActiveChallenges({
    int? limit,
    int? offset,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final maps = await db.query(
        tableName,
        where: 'is_active = 1 AND start_date <= ? AND end_date >= ?',
        whereArgs: [now, now],
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(message: 'Failed to find active challenges: $e');
    }
  }

  /// Gets challenges created by a specific user
  Future<List<ChallengeModel>> findByCreatedBy(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final maps = await db.query(
        tableName,
        where: 'created_by = ?',
        whereArgs: [userId],
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to find challenges by creator: $e',
      );
    }
  }

  /// Gets public challenges
  Future<List<ChallengeModel>> findPublicChallenges({
    int? limit,
    int? offset,
  }) async {
    try {
      final maps = await db.query(
        tableName,
        where: 'is_public = 1',
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(message: 'Failed to find public challenges: $e');
    }
  }

  /// Searches challenges by title or description
  Future<List<ChallengeModel>> searchChallenges(
    String query, {
    int? limit,
    int? offset,
  }) async {
    try {
      final maps = await db.query(
        tableName,
        where: '(title LIKE ? OR description LIKE ?) AND is_public = 1',
        whereArgs: ['%$query%', '%$query%'],
        limit: limit,
        offset: offset,
        orderBy: 'created_at DESC',
      );
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(message: 'Failed to search challenges: $e');
    }
  }

  @override
  String buildTableDefinition() {
    return '''
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      created_by TEXT NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER NOT NULL,
      goal_type TEXT NOT NULL,
      goal_target INTEGER NOT NULL,
      goal_unit TEXT NOT NULL,
      image_url TEXT,
      is_public INTEGER NOT NULL DEFAULT 1,
      is_active INTEGER NOT NULL DEFAULT 1,
      max_participants INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
    ''';
  }

  @override
  Future<void> createIndexes() async {
    try {
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_challenges_created_by ON $tableName(created_by)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_challenges_is_public ON $tableName(is_public)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_challenges_is_active ON $tableName(is_active)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_challenges_start_date ON $tableName(start_date)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_challenges_end_date ON $tableName(end_date)
      ''');
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create challenge indexes: $e',
      );
    }
  }
}
