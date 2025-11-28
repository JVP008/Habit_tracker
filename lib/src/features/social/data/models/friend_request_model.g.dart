// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequestModel _$FriendRequestModelFromJson(Map<String, dynamic> json) =>
    FriendRequestModel(
      id: json['id'] as String?,
      requesterId: json['requesterId'] as String,
      recipientId: json['recipientId'] as String,
      status:
          $enumDecodeNullable(_$FriendRequestStatusEnumMap, json['status']) ??
              FriendRequestStatus.pending,
      message: json['message'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] == null
          ? null
          : DateTime.parse(json['respondedAt'] as String),
    );

Map<String, dynamic> _$FriendRequestModelToJson(FriendRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requesterId': instance.requesterId,
      'recipientId': instance.recipientId,
      'status': _$FriendRequestStatusEnumMap[instance.status]!,
      'message': instance.message,
      'createdAt': instance.createdAt.toIso8601String(),
      'respondedAt': instance.respondedAt?.toIso8601String(),
    };

const _$FriendRequestStatusEnumMap = {
  FriendRequestStatus.pending: 'pending',
  FriendRequestStatus.accepted: 'accepted',
  FriendRequestStatus.rejected: 'rejected',
  FriendRequestStatus.cancelled: 'cancelled',
};

FriendModel _$FriendModelFromJson(Map<String, dynamic> json) => FriendModel(
      id: json['id'] as String?,
      userId1: json['userId1'] as String,
      userId2: json['userId2'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastInteractionAt: json['lastInteractionAt'] == null
          ? null
          : DateTime.parse(json['lastInteractionAt'] as String),
    );

Map<String, dynamic> _$FriendModelToJson(FriendModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId1': instance.userId1,
      'userId2': instance.userId2,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastInteractionAt': instance.lastInteractionAt?.toIso8601String(),
    };
