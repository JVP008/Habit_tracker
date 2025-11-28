// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalEntryModel _$JournalEntryModelFromJson(Map<String, dynamic> json) =>
    JournalEntryModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      mood: json['mood'] as String,
      rating: (json['rating'] as num?)?.toInt() ?? 3,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isPrivate: json['isPrivate'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$JournalEntryModelToJson(JournalEntryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'tags': instance.tags,
      'mood': instance.mood,
      'rating': instance.rating,
      'attachments': instance.attachments,
      'isPrivate': instance.isPrivate,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
