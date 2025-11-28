import '../../../features/habits/data/models/habit_model.dart';
import '../../database/base_dao.dart';
import '../../database/database_config.dart';

class HabitDao extends BaseDao<HabitModel> {
  @override
  String get tableName => DatabaseConfig.tableHabits;

  @override
  Map<String, dynamic> toMap(HabitModel item) {
    final json = item.toJson();
    // Manually handle list conversions for SQLite
    if (json['target_days'] is List) {
      json['target_days'] = (json['target_days'] as List).join(',');
    }
    if (json['tags'] is List) {
      json['tags'] = (json['tags'] as List).join(',');
    }
    // Handle TimeOfDay serialization if needed
    // Assuming json['reminder_time'] returns a String from the model's toJson
    return json;
  }
  
  // Override fromMap to handle the string-to-list conversion
  @override
  HabitModel fromMap(Map<String, dynamic> map) {
    final mutableMap = Map<String, dynamic>.from(map);
    
    if (mutableMap['target_days'] is String) {
      final str = mutableMap['target_days'] as String;
      if (str.isNotEmpty) {
        try {
          mutableMap['target_days'] = str.split(',').map((e) => int.parse(e)).toList();
        } catch (e) {
          mutableMap['target_days'] = <int>[];
        }
      } else {
        mutableMap['target_days'] = <int>[];
      }
    }
    
    if (mutableMap['tags'] is String) {
      final str = mutableMap['tags'] as String;
      if (str.isNotEmpty) {
        mutableMap['tags'] = str.split(',').toList();
      } else {
        mutableMap['tags'] = <String>[];
      }
    }
    
    return HabitModel.fromJson(mutableMap);
  }

  Future<List<HabitModel>> getHabitsForUser(String userId) async {
    final db = database;
    final maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }
  
  Future<void> updateStreak(String habitId, int streak) async {
    final db = database;
    await db.update(
      tableName,
      {'streak_days': streak},
      where: 'id = ?',
      whereArgs: [habitId],
    );
  }
}