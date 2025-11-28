import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:habit_tracker/src/core/data/models/base_model.dart';

part 'friend_request_model.g.dart';

enum FriendRequestStatus { pending, accepted, rejected, cancelled }

@JsonSerializable()
class FriendRequestModel extends BaseModel<FriendRequestModel>
    with EquatableMixin {
  @override
  final String? id;
  final String requesterId;
  final String recipientId;
  final FriendRequestStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequestModel({
    this.id,
    required this.requesterId,
    required this.recipientId,
    this.status = FriendRequestStatus.pending,
    this.message,
    DateTime? createdAt,
    this.respondedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FriendRequestModelToJson(this);

  FriendRequestModel copyWith({
    String? id,
    String? requesterId,
    String? recipientId,
    FriendRequestStatus? status,
    String? message,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      recipientId: recipientId ?? this.recipientId,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  FriendRequestModel copyWithJson(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] as String?,
      requesterId: json['requester_id'] as String?,
      recipientId: json['recipient_id'] as String?,
      status: json['status'] != null
          ? FriendRequestStatus.values.firstWhere(
              (e) => e.toString() == 'FriendRequestStatus.${json['status']}',
            )
          : null,
      message: json['message'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    requesterId,
    recipientId,
    status,
    message,
    createdAt,
    respondedAt,
  ];

  bool get isEmpty => id?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;
  bool get isPending => status == FriendRequestStatus.pending;
  bool get isAccepted => status == FriendRequestStatus.accepted;
  bool get isRejected => status == FriendRequestStatus.rejected;
  bool get isCancelled => status == FriendRequestStatus.cancelled;

  FriendRequestModel accept() {
    return copyWith(
      status: FriendRequestStatus.accepted,
      respondedAt: DateTime.now(),
    );
  }

  FriendRequestModel reject() {
    return copyWith(
      status: FriendRequestStatus.rejected,
      respondedAt: DateTime.now(),
    );
  }

  FriendRequestModel cancel() {
    return copyWith(
      status: FriendRequestStatus.cancelled,
      respondedAt: DateTime.now(),
    );
  }
}

@JsonSerializable()
class FriendModel extends BaseModel<FriendModel> with EquatableMixin {
  @override
  final String? id;
  final String userId1;
  final String userId2;
  final DateTime createdAt;
  final DateTime? lastInteractionAt;

  FriendModel({
    this.id,
    required this.userId1,
    required this.userId2,
    DateTime? createdAt,
    this.lastInteractionAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FriendModel.fromJson(Map<String, dynamic> json) =>
      _$FriendModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FriendModelToJson(this);

  FriendModel copyWith({
    String? id,
    String? userId1,
    String? userId2,
    DateTime? createdAt,
    DateTime? lastInteractionAt,
  }) {
    return FriendModel(
      id: id ?? this.id,
      userId1: userId1 ?? this.userId1,
      userId2: userId2 ?? this.userId2,
      createdAt: createdAt ?? this.createdAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
    );
  }

  @override
  FriendModel copyWithJson(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] as String?,
      userId1: json['user_id1'] as String?,
      userId2: json['user_id2'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      lastInteractionAt: json['last_interaction_at'] != null
          ? DateTime.parse(json['last_interaction_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId1,
    userId2,
    createdAt,
    lastInteractionAt,
  ];

  bool get isEmpty => id?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;

  FriendModel updateInteraction() {
    return copyWith(lastInteractionAt: DateTime.now());
  }

  bool isFriendWith(String userId) {
    return userId1 == userId || userId2 == userId;
  }
}
