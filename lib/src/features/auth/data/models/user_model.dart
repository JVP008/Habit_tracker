import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:habit_tracker/src/core/data/models/base_model.dart';

part 'user_model.g.dart';

/// Represents a user in the application
@JsonSerializable()
class UserModel extends BaseModel<UserModel> with EquatableMixin {
  /// The unique identifier for the user
  @override
  final String? id;

  /// The user's display name
  final String displayName;

  /// The user's email address
  final String email;

  /// URL to the user's profile picture
  final String? photoUrl;

  /// The user's bio/description
  final String? bio;

  /// The user's current streak in days
  @JsonKey(defaultValue: 0)
  final int streakDays;

  /// Number of challenges completed by the user
  @JsonKey(defaultValue: 0)
  final int completedChallenges;

  /// Timestamp when the user was created
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// Timestamp when the user was last updated
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Timestamp when the user was last active
  @JsonKey(name: 'last_active')
  final DateTime? lastActive;

  /// User preferences as a JSON string
  final Map<String, dynamic>? settings;

  /// Whether the user has a premium subscription
  @JsonKey(defaultValue: false)
  final bool isPremium;

  /// When the user's premium subscription expires (if any)
  @JsonKey(name: 'subscription_expiry')
  final DateTime? subscriptionExpiry;

  UserModel({
    this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.streakDays = 0,
    this.completedChallenges = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastActive,
    this.settings,
    this.isPremium = false,
    this.subscriptionExpiry,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Creates a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts the UserModel to JSON
  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Creates a copy of the user with the given fields replaced
  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    String? bio,
    int? streakDays,
    int? completedChallenges,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    Map<String, dynamic>? settings,
    bool? isPremium,
    DateTime? subscriptionExpiry,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      streakDays: streakDays ?? this.streakDays,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      settings: settings ?? this.settings,
      isPremium: isPremium ?? this.isPremium,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
    );
  }

  /// Creates a copy of the user with the given fields replaced from a JSON map
  @override
  UserModel copyWithJson(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] as String?,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      bio: json['bio'] as String?,
      streakDays: json['streak_days'] as int?,
      completedChallenges: json['completed_challenges'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
      isPremium: json['is_premium'] as bool?,
      subscriptionExpiry: json['subscription_expiry'] != null
          ? DateTime.parse(json['subscription_expiry'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    bio,
    streakDays,
    completedChallenges,
    createdAt,
    updatedAt,
    lastActive,
    isPremium,
    subscriptionExpiry,
  ];

  /// Creates a default/empty user
  factory UserModel.empty() => UserModel(id: '', displayName: '', email: '');

  /// Whether the user is empty (not saved to the database)
  bool get isEmpty => id?.isEmpty ?? true;

  /// Whether the user is not empty (saved to the database)
  bool get isNotEmpty => !isEmpty;

  /// Gets the short name (first name only)
  String get shortName {
    if (displayName.isEmpty) return 'User';
    return displayName.split(' ').first;
  }

  /// Whether the user has an active premium subscription
  bool get hasActiveSubscription =>
      isPremium &&
      subscriptionExpiry != null &&
      subscriptionExpiry!.isAfter(DateTime.now());

  /// Updates the last active timestamp to now
  UserModel updateLastActive() {
    return copyWith(lastActive: DateTime.now());
  }

  /// Increments the user's streak
  UserModel incrementStreak() {
    return copyWith(streakDays: streakDays + 1, updatedAt: DateTime.now());
  }

  /// Resets the user's streak to 0
  UserModel resetStreak() {
    return copyWith(streakDays: 0, updatedAt: DateTime.now());
  }

  /// Increments the number of completed challenges
  UserModel incrementCompletedChallenges() {
    return copyWith(
      completedChallenges: completedChallenges + 1,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the user's profile information
  UserModel updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
  }) {
    return copyWith(
      displayName: displayName,
      photoUrl: photoUrl,
      bio: bio,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates the user's settings
  UserModel updateSettings(Map<String, dynamic> newSettings) {
    return copyWith(
      settings: {...(settings ?? {}), ...newSettings},
      updatedAt: DateTime.now(),
    );
  }

  /// Upgrades the user to premium
  UserModel upgradeToPremium(Duration duration) {
    final now = DateTime.now();
    final expiry = now.add(duration);

    return copyWith(
      isPremium: true,
      subscriptionExpiry: expiry,
      updatedAt: now,
    );
  }

  /// Downgrades the user from premium
  UserModel downgradeFromPremium() {
    return copyWith(
      isPremium: false,
      subscriptionExpiry: null,
      updatedAt: DateTime.now(),
    );
  }
}

/// Extension methods for UserModel
extension UserModelExtension on UserModel {
  /// Gets the short name (first name only)
  String get shortName {
    if (displayName.isEmpty) return 'User';
    return displayName.split(' ').first;
  }

  /// Gets user initials
  String get initials {
    if (displayName.isEmpty) return 'U';
    final names = displayName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }

  /// Converts to Firestore data format
  Map<String, dynamic> toFirestoreData() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'photo_url': photoUrl,
      'bio': bio,
      'streak_days': streakDays,
      'completed_challenges': completedChallenges,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
      'settings': settings,
      'is_premium': isPremium,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
    }..removeWhere((key, value) => value == null);
  }

  /// Creates from Firestore data
  static UserModel fromFirestoreData(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String?,
      displayName: data['display_name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photo_url'] as String?,
      bio: data['bio'] as String?,
      streakDays: data['streak_days'] as int? ?? 0,
      completedChallenges: data['completed_challenges'] as int? ?? 0,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : DateTime.now(),
      lastActive: data['last_active'] != null
          ? DateTime.parse(data['last_active'] as String)
          : null,
      settings: data['settings'] as Map<String, dynamic>?,
      isPremium: data['is_premium'] as bool? ?? false,
      subscriptionExpiry: data['subscription_expiry'] != null
          ? DateTime.parse(data['subscription_expiry'] as String)
          : null,
    );
  }
}
