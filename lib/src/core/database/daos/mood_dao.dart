import '../../../data/models/mood_model.dart';
import '../../database/base_dao.dart';
import '../../database/database_config.dart';

class MoodDao extends BaseDao<MoodEntry> {
  @override
  String get tableName => DatabaseConfig.tableMoodEntries;

  @override
  MoodEntry fromMap(Map<String, dynamic> map) {
    // Map DB columns to Model
    // DB: mood_score (REAL), mood_label (TEXT), notes (TEXT), created_at (INTEGER)
    // Model uses MoodLevel enum. We assume mood_score maps to index or we infer it.
    // Let's use mood_score as index.
    final score = (map['mood_score'] as num).toInt();
    final moodLevel = MoodLevel.values.length > score ? MoodLevel.values[score] : MoodLevel.neutral;
    
    return MoodEntry(
      id: map['id'],
      moodLevel: moodLevel,
      note: map['notes'],
      date: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  @override
  Map<String, dynamic> toMap(MoodEntry item) {
    return {
      'id': item.id,
      // We need user_id here, but model doesn't have it. 
      // It will be handled by the Provider or we need to update Model. 
      // For now, I will assume the map passed IN has user_id if needed, 
      // OR I will update the model. 
      // Actually, BaseDao's toMap signature takes T item. 
      // I should update MoodEntry to have userId.
      'mood_score': item.moodLevel.index,
      'mood_label': item.moodLevel.label,
      'notes': item.note,
      'created_at': item.date.millisecondsSinceEpoch,
    };
  }
  
  // Method to insert with userId explicitly if model doesn't have it
  Future<void> insertMood(MoodEntry entry, String userId) async {
    final db = database;
    final data = toMap(entry);
    data['user_id'] = userId;
    await db.insert(tableName, data);
  }

  Future<List<MoodEntry>> getMoodsForUser(String userId) async {
    final db = database;
    final maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
  
  Future<void> deleteMood(String id) async {
     await delete(id);
  }
}
