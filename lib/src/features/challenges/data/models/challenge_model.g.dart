// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChallengeModel _$ChallengeModelFromJson(Map<String, dynamic> json) =>
    ChallengeModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      createdBy: json['createdBy'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      goalType: json['goalType'] as String,
      goalTarget: (json['goalTarget'] as num).toInt(),
      goalUnit: json['goalUnit'] as String,
      imageUrl: json['imageUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      isActive: json['isActive'] as bool? ?? true,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChallengeModelToJson(ChallengeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'createdBy': instance.createdBy,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'goalType': instance.goalType,
      'goalTarget': instance.goalTarget,
      'goalUnit': instance.goalUnit,
      'imageUrl': instance.imageUrl,
      'isPublic': instance.isPublic,
      'isActive': instance.isActive,
      'maxParticipants': instance.maxParticipants,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
