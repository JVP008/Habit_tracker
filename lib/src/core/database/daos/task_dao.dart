import '../../../data/models/task_model.dart';
import '../../database/base_dao.dart';
import '../../database/database_config.dart';

class TaskDao extends BaseDao<Task> {
  @override
  String get tableName => DatabaseConfig.tableTasks;

  @override
  Task fromMap(Map<String, dynamic> map) => Task.fromMap(map);

  @override
  Map<String, dynamic> toMap(Task item) => item.toMap();

  /// Gets all tasks for a specific user
  Future<List<Task>> getTasksForUser(String userId) async {
    final db = database;
    final maps = await db.query(
      tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Gets tasks for a specific user and date
  Future<List<Task>> getTasksForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;

    final db = database;
    final maps = await db.query(
      tableName,
      where: 'user_id = ? AND due_date >= ? AND due_date <= ?',
      whereArgs: [userId, startOfDay, endOfDay],
      orderBy: 'priority DESC, created_at ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Gets incomplete tasks for a user
  Future<List<Task>> getPendingTasks(String userId) async {
    final db = database;
    final maps = await db.query(
      tableName,
      where: 'user_id = ? AND is_completed = 0',
      whereArgs: [userId],
      orderBy: 'due_date ASC',
    );
    return List.generate(maps.length, (i) => fromMap(maps[i]));
  }

  /// Toggles task completion status
  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    final db = database;
    await db.update(
      tableName,
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }
}
