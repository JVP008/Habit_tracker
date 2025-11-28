// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String?,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      completedChallenges: (json['completedChallenges'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      lastActive: json['last_active'] == null
          ? null
          : DateTime.parse(json['last_active'] as String),
      settings: json['settings'] as Map<String, dynamic>?,
      isPremium: json['isPremium'] as bool? ?? false,
      subscriptionExpiry: json['subscription_expiry'] == null
          ? null
          : DateTime.parse(json['subscription_expiry'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'bio': instance.bio,
      'streakDays': instance.streakDays,
      'completedChallenges': instance.completedChallenges,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_active': instance.lastActive?.toIso8601String(),
      'settings': instance.settings,
      'isPremium': instance.isPremium,
      'subscription_expiry': instance.subscriptionExpiry?.toIso8601String(),
    };
