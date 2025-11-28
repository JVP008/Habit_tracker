import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:habit_tracker/src/core/data/models/base_model.dart';

part 'mood_entry_model.g.dart';

@JsonSerializable()
class MoodEntryModel extends BaseModel<MoodEntryModel> with EquatableMixin {
  @override
  final String? id;
  final String userId;
  final String mood;
  final int energy; // 1-10 scale
  final int stress; // 1-10 scale
  final int sleep; // 1-10 scale
  final String? note;
  final List<String> tags;
  final List<String> triggers;
  final List<String> activities;
  final DateTime recordedAt;
  final DateTime createdAt;

  MoodEntryModel({
    this.id,
    required this.userId,
    required this.mood,
    required this.energy,
    required this.stress,
    required this.sleep,
    this.note,
    this.tags = const [],
    this.triggers = const [],
    this.activities = const [],
    required this.recordedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) =>
      _$MoodEntryModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MoodEntryModelToJson(this);

  MoodEntryModel copyWith({
    String? id,
    String? userId,
    String? mood,
    int? energy,
    int? stress,
    int? sleep,
    String? note,
    List<String>? tags,
    List<String>? triggers,
    List<String>? activities,
    DateTime? recordedAt,
    DateTime? createdAt,
  }) {
    return MoodEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      sleep: sleep ?? this.sleep,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      triggers: triggers ?? this.triggers,
      activities: activities ?? this.activities,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  MoodEntryModel copyWithJson(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      mood: json['mood'] as String?,
      energy: json['energy'] as int?,
      stress: json['stress'] as int?,
      sleep: json['sleep'] as int?,
      note: json['note'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
      triggers: (json['triggers'] as List?)?.cast<String>(),
      activities: (json['activities'] as List?)?.cast<String>(),
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    mood,
    energy,
    stress,
    sleep,
    note,
    tags,
    triggers,
    activities,
    recordedAt,
    createdAt,
  ];

  bool get isEmpty => id?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;

  double get averageScore => (energy + (11 - stress) + sleep) / 3;

  MoodEntryModel updateMood(String newMood) {
    return copyWith(mood: newMood, recordedAt: DateTime.now());
  }

  MoodEntryModel updateScores({int? energy, int? stress, int? sleep}) {
    return copyWith(
      energy: energy ?? this.energy,
      stress: stress ?? this.stress,
      sleep: sleep ?? this.sleep,
      recordedAt: DateTime.now(),
    );
  }

  MoodEntryModel addTrigger(String trigger) {
    final newTriggers = List<String>.from(triggers);
    if (!newTriggers.contains(trigger)) {
      newTriggers.add(trigger);
    }
    return copyWith(triggers: newTriggers, recordedAt: DateTime.now());
  }

  MoodEntryModel addActivity(String activity) {
    final newActivities = List<String>.from(activities);
    if (!newActivities.contains(activity)) {
      newActivities.add(activity);
    }
    return copyWith(activities: newActivities, recordedAt: DateTime.now());
  }
}
