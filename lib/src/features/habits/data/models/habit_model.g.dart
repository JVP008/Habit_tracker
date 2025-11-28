// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HabitModel _$HabitModelFromJson(Map<String, dynamic> json) => HabitModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      frequency: json['frequency'] as String,
      targetDays: (json['targetDays'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      reminderTime:
          HabitTimeOfDay.fromJson(json['reminderTime'] as Map<String, dynamic>),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      totalCompletions: (json['totalCompletions'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastCompletedAt: json['lastCompletedAt'] == null
          ? null
          : DateTime.parse(json['lastCompletedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      targetCount: (json['targetCount'] as num?)?.toInt(),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$HabitModelToJson(HabitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'frequency': instance.frequency,
      'targetDays': instance.targetDays,
      'reminderTime': instance.reminderTime,
      'tags': instance.tags,
      'streakDays': instance.streakDays,
      'totalCompletions': instance.totalCompletions,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastCompletedAt': instance.lastCompletedAt?.toIso8601String(),
      'isActive': instance.isActive,
      'targetCount': instance.targetCount,
      'unit': instance.unit,
    };

HabitTimeOfDay _$HabitTimeOfDayFromJson(Map<String, dynamic> json) =>
    HabitTimeOfDay(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$HabitTimeOfDayToJson(HabitTimeOfDay instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };
