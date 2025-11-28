import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:habit_tracker/src/core/data/models/base_model.dart';

part 'habit_model.g.dart';

@JsonSerializable()
class HabitModel extends BaseModel<HabitModel> with EquatableMixin {
  @override
  final String? id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String frequency; // daily, weekly, monthly
  final List<int> targetDays; // Days of week (1-7, Monday=1)
  final HabitTimeOfDay reminderTime;
  final List<String> tags;
  final int streakDays;
  final int totalCompletions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastCompletedAt;
  final bool isActive;
  final int? targetCount;
  final String? unit;

  HabitModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.frequency,
    required this.targetDays,
    required this.reminderTime,
    this.tags = const [],
    this.streakDays = 0,
    this.totalCompletions = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastCompletedAt,
    this.isActive = true,
    this.targetCount,
    this.unit,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      _$HabitModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HabitModelToJson(this);

  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? frequency,
    List<int>? targetDays,
    HabitTimeOfDay? reminderTime,
    List<String>? tags,
    int? streakDays,
    int? totalCompletions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastCompletedAt,
    bool? isActive,
    int? targetCount,
    String? unit,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      reminderTime: reminderTime ?? this.reminderTime,
      tags: tags ?? this.tags,
      streakDays: streakDays ?? this.streakDays,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      isActive: isActive ?? this.isActive,
      targetCount: targetCount ?? this.targetCount,
      unit: unit ?? this.unit,
    );
  }

  @override
  HabitModel copyWithJson(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      frequency: json['frequency'] as String?,
      targetDays: (json['target_days'] as List?)?.cast<int>(),
      reminderTime: json['reminder_time'] != null
          ? HabitTimeOfDay.fromDateTime(
              DateTime.parse(json['reminder_time'] as String),
            )
          : null,
      tags: (json['tags'] as List?)?.cast<String>(),
      streakDays: json['streak_days'] as int?,
      totalCompletions: json['total_completions'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastCompletedAt: json['last_completed_at'] != null
          ? DateTime.parse(json['last_completed_at'] as String)
          : null,
      isActive: json['is_active'] as bool?,
      targetCount: json['target_count'] as int?,
      unit: json['unit'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    category,
    frequency,
    targetDays,
    reminderTime,
    tags,
    streakDays,
    totalCompletions,
    createdAt,
    updatedAt,
    lastCompletedAt,
    isActive,
    targetCount,
    unit,
  ];

  bool get isEmpty => id?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;

  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      lastCompletedAt!.year,
      lastCompletedAt!.month,
      lastCompletedAt!.day,
    );
    return lastCompleted.isAtSameMomentAs(today);
  }

  HabitModel markCompleted() {
    final now = DateTime.now();
    return copyWith(
      lastCompletedAt: now,
      totalCompletions: totalCompletions + 1,
      streakDays: isCompletedToday ? streakDays : streakDays + 1,
      updatedAt: now,
    );
  }

  HabitModel resetStreak() {
    return copyWith(streakDays: 0, updatedAt: DateTime.now());
  }

  HabitModel activate() => copyWith(isActive: true, updatedAt: DateTime.now());
  HabitModel deactivate() =>
      copyWith(isActive: false, updatedAt: DateTime.now());
}

@JsonSerializable()
class HabitTimeOfDay with EquatableMixin {
  final int hour;
  final int minute;

  const HabitTimeOfDay({required this.hour, required this.minute});

  factory HabitTimeOfDay.fromDateTime(DateTime dateTime) {
    return HabitTimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  factory HabitTimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$HabitTimeOfDayFromJson(json);

  Map<String, dynamic> toJson() => _$HabitTimeOfDayToJson(this);

  DateTime toDateTime([DateTime? date]) {
    final baseDate = date ?? DateTime.now();
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  String get formatted =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [hour, minute];
}
