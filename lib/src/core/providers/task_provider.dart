import 'package:flutter/foundation.dart';

import '../../../src/data/models/task_model.dart';
import '../../../src/data/models/mood_model.dart';
import '../database/daos/task_dao.dart';
import '../database/daos/mood_dao.dart';

class TaskProvider with ChangeNotifier {
  final TaskDao _taskDao = TaskDao();
  final MoodDao _moodDao = MoodDao();
  
  String? _userId;
  List<Task> _tasks = [];
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider() {
    // Empty constructor
  }
  
  // Set the user ID and load data
  void setUserId(String? userId) {
    _userId = userId;
    if (_userId != null) {
      loadData();
    } else {
      clearData();
    }
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<MoodEntry> get moodEntries => List.unmodifiable(_moodEntries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get tasks for a specific day
  List<Task> getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      return task.dueDate.year == day.year &&
          task.dueDate.month == day.month &&
          task.dueDate.day == day.day;
    }).toList();
  }

  // Get today's tasks
  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _tasks.where((task) {
      return task.dueDate.isAfter(today) &&
          task.dueDate.isBefore(tomorrow) &&
          !task.isCompleted;
    }).toList();
  }

  // Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Toggle task status
  Future<void> toggleTaskStatus(String taskId) async {
    if (_userId == null) return;

    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final isCompleted = !task.isCompleted;
      
      final updatedTask = task.copyWith(
        status: isCompleted ? TaskStatus.completed : TaskStatus.todo,
        completedAt: isCompleted ? DateTime.now() : null, // Update local model too
      );
      
      // Update local list optimistically
      _tasks[index] = updatedTask;
      notifyListeners();

      try {
        await _taskDao.toggleTaskStatus(taskId, isCompleted);
      } catch (e) {
        _error = e.toString();
        // Revert on error? 
        notifyListeners();
      }
    }
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    if (_userId == null) return;

    // Ensure task has userId
    final taskWithUser = task.copyWith(userId: _userId);
    
    _tasks.add(taskWithUser);
    notifyListeners();

    try {
      await _taskDao.insert(taskWithUser);
    } catch (e) {
      _error = e.toString();
      _tasks.remove(taskWithUser);
      notifyListeners();
    }
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    if (_userId == null) return;

    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();

      try {
        await _taskDao.update(updatedTask, updatedTask.id);
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) return;

    final task = _tasks.firstWhere((t) => t.id == taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    try {
      await _taskDao.delete(taskId);
    } catch (e) {
      _error = e.toString();
      _tasks.add(task); // Revert
      notifyListeners();
    }
  }

  // Get mood entries for a specific day
  MoodEntry? getMoodForDay(DateTime day) {
    try {
      return _moodEntries.firstWhere(
        (entry) =>
            entry.date.year == day.year &&
            entry.date.month == day.month &&
            entry.date.day == day.day,
      );
    } catch (e) {
      return null;
    }
  }

  // Get today's mood
  MoodEntry? get todayMood {
    return getMoodForDay(DateTime.now());
  }

  // Load data from DB
  Future<void> loadData() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Load tasks
      _tasks = await _taskDao.getTasksForUser(_userId!);

      // Load mood entries
      _moodEntries = await _moodDao.getMoodsForUser(_userId!);
    } catch (e) {
      _error = 'Failed to load data: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mood tracking operations
  Future<void> addMoodEntry(MoodEntry entry) async {
    if (_userId == null) return;

    // Remove any existing entry for the same day locally
    _moodEntries.removeWhere(
      (e) =>
          e.date.year == entry.date.year &&
          e.date.month == entry.date.month &&
          e.date.day == entry.date.day,
    );

    _moodEntries.add(entry);
    notifyListeners();
    
    try {
       await _moodDao.insertMood(entry, _userId!);
    } catch (e) {
       _error = e.toString();
       notifyListeners();
    }
  }

  // Get mood statistics
  Map<MoodLevel, int> getMoodStatistics({int daysBack = 7}) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysBack));

    final recentEntries = _moodEntries.where(
      (entry) => entry.date.isAfter(startDate),
    );

    final stats = <MoodLevel, int>{};
    for (var level in MoodLevel.values) {
      stats[level] = recentEntries.where((e) => e.moodLevel == level).length;
    }

    return stats;
  }

  // Clear data (used during logout)
  void clearData() {
    _tasks.clear();
    _moodEntries.clear();
    _userId = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}