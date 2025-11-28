import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:habit_tracker/src/core/data/models/base_model.dart';

part 'challenge_model.g.dart';

@JsonSerializable()
class ChallengeModel extends BaseModel<ChallengeModel> with EquatableMixin {
  @override
  final String? id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime startDate;
  final DateTime endDate;
  final String goalType;
  final int goalTarget;
  final String goalUnit;
  final String? imageUrl;
  final bool isPublic;
  final bool isActive;
  final int? maxParticipants;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChallengeModel({
    this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.startDate,
    required this.endDate,
    required this.goalType,
    required this.goalTarget,
    required this.goalUnit,
    this.imageUrl,
    this.isPublic = true,
    this.isActive = true,
    this.maxParticipants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ChallengeModel.fromJson(Map<String, dynamic> json) =>
      _$ChallengeModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChallengeModelToJson(this);

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    DateTime? startDate,
    DateTime? endDate,
    String? goalType,
    int? goalTarget,
    String? goalUnit,
    String? imageUrl,
    bool? isPublic,
    bool? isActive,
    int? maxParticipants,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goalType: goalType ?? this.goalType,
      goalTarget: goalTarget ?? this.goalTarget,
      goalUnit: goalUnit ?? this.goalUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      isActive: isActive ?? this.isActive,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  ChallengeModel copyWithJson(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      goalType: json['goal_type'] as String?,
      goalTarget: json['goal_target'] as int?,
      goalUnit: json['goal_unit'] as String?,
      imageUrl: json['image_url'] as String?,
      isPublic: json['is_public'] as bool?,
      isActive: json['is_active'] as bool?,
      maxParticipants: json['max_participants'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    createdBy,
    startDate,
    endDate,
    goalType,
    goalTarget,
    goalUnit,
    imageUrl,
    isPublic,
    isActive,
    maxParticipants,
    createdAt,
    updatedAt,
  ];

  bool get isEmpty => id?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;

  Duration get duration => endDate.difference(startDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isActiveNow => !isExpired && !isUpcoming && isActive;

  ChallengeModel activate() =>
      copyWith(isActive: true, updatedAt: DateTime.now());
  ChallengeModel deactivate() =>
      copyWith(isActive: false, updatedAt: DateTime.now());
}
