import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitItem {
  HabitItem({
    required this.title,
    required this.frequency,
    required this.streakLabel,
    required this.accentHex,
    this.completed = false,
  });

  final String title;
  final String frequency;
  final String streakLabel;
  final int accentHex;
  bool completed;

  Map<String, dynamic> toJson() => {
    'title': title,
    'frequency': frequency,
    'streak': streakLabel,
    'accent': accentHex,
    'completed': completed,
  };

  static HabitItem fromJson(Map<String, dynamic> json) => HabitItem(
    title: json['title'] as String,
    frequency: json['frequency'] as String,
    streakLabel: json['streak'] as String,
    accentHex: json['accent'] as int,
    completed: json['completed'] as bool? ?? false,
  );
}

class ZenFlowAppState extends ChangeNotifier {
  ZenFlowAppState() {
    _load();
  }

  final List<HabitItem> _habits = [];
  List<HabitItem> get habits => List.unmodifiable(_habits);

  Future<void> toggleHabit(int index) async {
    _habits[index].completed = !_habits[index].completed;
    notifyListeners();
    await _save();
  }

  Future<void> addHabit(String title, String frequency, int accentHex) async {
    _habits.add(
      HabitItem(
        title: title,
        frequency: frequency,
        streakLabel: 'new habit',
        accentHex: accentHex,
      ),
    );
    notifyListeners();
    await _save();
  }

  Future<void> editHabit(
    int index, {
    String? title,
    String? frequency,
    int? accentHex,
  }) async {
    final h = _habits[index];
    _habits[index] = HabitItem(
      title: title ?? h.title,
      frequency: frequency ?? h.frequency,
      streakLabel: h.streakLabel,
      accentHex: accentHex ?? h.accentHex,
      completed: h.completed,
    );
    notifyListeners();
    await _save();
  }

  Future<void> deleteHabit(int index) async {
    _habits.removeAt(index);
    notifyListeners();
    await _save();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('habits');
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _habits
        ..clear()
        ..addAll(list.map(HabitItem.fromJson));
      notifyListeners();
    }
    await _seedDefaultsIfEmpty();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', raw);
  }

  Future<void> _seedDefaultsIfEmpty() async {
    if (_habits.isEmpty) {
      _habits.addAll([
        HabitItem(
          title: 'morning meditation',
          frequency: 'daily',
          streakLabel: '7 day streak',
          accentHex: 0xFF4CAF50, // Vibrant green - VISIBLE!
          completed: false,
        ),
        HabitItem(
          title: 'hydrate (8 glasses)',
          frequency: 'daily',
          streakLabel: '3 day streak',
          accentHex:
              0xFFFF9800, // Vibrant orange (NOT invisible yellow!) - VISIBLE!
          completed: false,
        ),
        HabitItem(
          title: 'evening journal',
          frequency: 'daily',
          streakLabel: '5 day streak',
          accentHex: 0xFFF44336, // Vibrant red - VISIBLE!
          completed: false,
        ),
      ]);
      notifyListeners();
      await _save();
    }
  }
}

class AuthState extends ChangeNotifier {
  AuthState() {
    _load();
  }

  String? _displayName;
  String? _email;
  String? _userId;

  String? get displayName => _displayName;
  String? get email => _email;
  String? get userId => _userId;
  bool get isRegistered =>
      (_displayName != null && _displayName!.isNotEmpty) ||
      (_userId != null && _userId!.isNotEmpty);

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('auth_user');
    if (raw != null) {
      final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
      _displayName = map['name'] as String?;
      _email = map['email'] as String?;
      _userId = map['id'] as String?;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    String? id,
  }) async {
    _displayName = name;
    _email = email;
    _userId = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'auth_user',
      jsonEncode({'id': id, 'name': name, 'email': email}),
    );
  }

  Future<void> logout() async {
    _displayName = null;
    _email = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
  }
}
