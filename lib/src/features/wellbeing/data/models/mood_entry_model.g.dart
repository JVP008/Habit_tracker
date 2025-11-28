// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodEntryModel _$MoodEntryModelFromJson(Map<String, dynamic> json) =>
    MoodEntryModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      mood: json['mood'] as String,
      energy: (json['energy'] as num).toInt(),
      stress: (json['stress'] as num).toInt(),
      sleep: (json['sleep'] as num).toInt(),
      note: json['note'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      triggers: (json['triggers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      activities: (json['activities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MoodEntryModelToJson(MoodEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mood': instance.mood,
      'energy': instance.energy,
      'stress': instance.stress,
      'sleep': instance.sleep,
      'note': instance.note,
      'tags': instance.tags,
      'triggers': instance.triggers,
      'activities': instance.activities,
      'recordedAt': instance.recordedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
