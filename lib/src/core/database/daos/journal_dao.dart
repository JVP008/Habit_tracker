import '../../../features/journal/data/models/journal_entry_model.dart';
import '../../database/base_dao.dart';
import '../../database/database_config.dart';

class JournalDao extends BaseDao<JournalEntryModel> {
  @override
  String get tableName => DatabaseConfig.tableJournalEntries;

  @override
  JournalEntryModel fromMap(Map<String, dynamic> map) {
    final mutableMap = Map<String, dynamic>.from(map);
    
    // Map DB columns to Model properties
    // DB: mood_score (REAL) -> Model: rating (int)
    if (mutableMap['mood_score'] != null) {
      mutableMap['rating'] = (mutableMap['mood_score'] as num).toInt();
    }
    // DB: mood_label (TEXT) -> Model: mood (String)
    if (mutableMap['mood_label'] != null) {
      mutableMap['mood'] = mutableMap['mood_label'];
    }
    // DB: tags (TEXT) -> Model: tags (List<String>)
    if (mutableMap['tags'] is String) {
      final str = mutableMap['tags'] as String;
      mutableMap['tags'] = str.isNotEmpty ? str.split(',') : <String>[];
    }
    // DB: is_private (INTEGER) -> Model: isPrivate (bool)
    if (mutableMap['is_private'] != null) {
      mutableMap['is_private'] = (mutableMap['is_private'] as int) == 1;
    }
    
    // Handle attachments if we ever add them (not in DB yet, model has empty list)
    mutableMap['attachments'] = <String>[];

    return JournalEntryModel.fromJson(mutableMap);
  }

  @override
  Map<String, dynamic> toMap(JournalEntryModel item) {
    return {
      'id': item.id,
      'user_id': item.userId,
      'title': item.title,
      'content': item.content,
      'mood_score': item.rating,
      'mood_label': item.mood,
      'tags': item.tags.join(','),
      'is_private': item.isPrivate ? 1 : 0,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };
  }

  Future<List<JournalEntryModel>> getEntriesForUser(String userId) async {
    final db = database;
    final maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
  
  Future<List<JournalEntryModel>> searchEntries(String userId, String query) async {
    final db = database;
    final maps = await db.query(
      tableName,
      where: 'user_id = ? AND (title LIKE ? OR content LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
}
