import 'package:flutter/foundation.dart';
import 'package:habit_tracker/src/features/journal/data/models/journal_entry_model.dart';
import 'package:habit_tracker/src/core/database/daos/journal_dao.dart';

class JournalProvider with ChangeNotifier {
  final JournalDao _journalDao = JournalDao();
  String? _userId;
  List<JournalEntryModel> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<JournalEntryModel> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUserId(String? userId) {
    _userId = userId;
    if (_userId != null) {
      loadEntries();
    } else {
      _entries = [];
      notifyListeners();
    }
  }

  Future<void> loadEntries() async {
    if (_userId == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _journalDao.getEntriesForUser(_userId!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(JournalEntryModel entry) async {
    if (_userId == null) return;
    
    final newEntry = entry.copyWith(userId: _userId);
    _entries.insert(0, newEntry);
    notifyListeners();

    try {
      await _journalDao.insert(newEntry);
    } catch (e) {
      _entries.remove(newEntry);
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
    
    try {
      await _journalDao.delete(id);
    } catch (e) {
      _error = e.toString();
      loadEntries(); // Reload to restore state
    }
  }

  // Stub methods for analytics
  Future<List<Map<String, dynamic>>> getMoodHistory() async {
    // This would typically come from a MoodDao or similar
    return [];
  }

  Future<Map<String, dynamic>> getInsights() async {
    // This would calculate insights from journal entries
    return {};
  }
}