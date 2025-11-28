import 'package:flutter/foundation.dart';
import 'package:habit_tracker/src/features/habits/data/models/habit_model.dart';
import 'package:habit_tracker/src/core/database/daos/habit_dao.dart';

class HabitProvider with ChangeNotifier {
  final HabitDao _habitDao = HabitDao();
  String? _userId;
  List<HabitModel> _habits = [];
  bool _isLoading = false;
  String? _error;

  List<HabitModel> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUserId(String? userId) {
    _userId = userId;
    if (_userId != null) {
      loadHabits();
    } else {
      _habits = [];
      notifyListeners();
    }
  }

  Future<void> loadHabits() async {
    if (_userId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _habitDao.getHabitsForUser(_userId!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(HabitModel habit) async {
    if (_userId == null) return;
    
    // Ensure userId is set
    final newHabit = habit.copyWith(userId: _userId);
    
    _habits.add(newHabit);
    notifyListeners();

    try {
      await _habitDao.insert(newHabit);
    } catch (e) {
      _habits.remove(newHabit);
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String id) async {
    final habit = _habits.firstWhere((h) => h.id == id);
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();

    try {
      await _habitDao.delete(id);
    } catch (e) {
      _habits.add(habit);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> toggleHabitCompletion(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final updatedHabit = habit.isCompletedToday 
          ? habit.copyWith(
              lastCompletedAt: DateTime.now().subtract(const Duration(days: 1)), // naive undo
              // real undo needs history table, for now simpler logic
              totalCompletions: habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0,
            )
          : habit.markCompleted();
          
      _habits[index] = updatedHabit;
      notifyListeners();
      
      try {
        await _habitDao.update(updatedHabit, habitId);
      } catch (e) {
        _error = e.toString();
        // revert
        notifyListeners();
      }
    }
  }
}
