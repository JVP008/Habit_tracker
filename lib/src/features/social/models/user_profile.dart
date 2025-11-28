class SocialUser {
  final String id;
  final String displayName;
  final String? photoUrl;
  final int streakDays;
  final int completedChallenges;
  final DateTime lastActive;
  final List<String> friends;
  final List<String> pendingRequests;
  final Map<String, dynamic> stats;

  SocialUser({
    required this.id,
    required this.displayName,
    this.photoUrl,
    this.streakDays = 0,
    this.completedChallenges = 0,
    required this.lastActive,
    List<String>? friends,
    List<String>? pendingRequests,
    Map<String, dynamic>? stats,
  }) : friends = friends ?? [],
       pendingRequests = pendingRequests ?? [],
       stats = stats ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'streakDays': streakDays,
      'completedChallenges': completedChallenges,
      'lastActive': lastActive.toIso8601String(),
      'friends': friends,
      'pendingRequests': pendingRequests,
      'stats': stats,
    };
  }

  factory SocialUser.fromMap(Map<String, dynamic> map) {
    return SocialUser(
      id: map['id'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      streakDays: map['streakDays'] ?? 0,
      completedChallenges: map['completedChallenges'] ?? 0,
      lastActive: DateTime.parse(map['lastActive']),
      friends: List<String>.from(map['friends'] ?? []),
      pendingRequests: List<String>.from(map['pendingRequests'] ?? []),
      stats: Map<String, dynamic>.from(map['stats'] ?? {}),
    );
  }

  SocialUser copyWith({
    String? id,
    String? displayName,
    String? photoUrl,
    int? streakDays,
    int? completedChallenges,
    DateTime? lastActive,
    List<String>? friends,
    List<String>? pendingRequests,
    Map<String, dynamic>? stats,
  }) {
    return SocialUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      streakDays: streakDays ?? this.streakDays,
      completedChallenges: completedChallenges ?? this.completedChallenges,
      lastActive: lastActive ?? this.lastActive,
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      stats: stats ?? this.stats,
    );
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> goal;
  final List<String> participants;
  final Map<String, dynamic> progress;
  final bool isPublic;
  final String? imageUrl;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.startDate,
    required this.endDate,
    required this.goal,
    List<String>? participants,
    Map<String, dynamic>? progress,
    this.isPublic = true,
    this.imageUrl,
  }) : participants = participants ?? [],
       progress = progress ?? {};

  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isCompleted => DateTime.now().isAfter(endDate);

  double get completionPercentage {
    if (progress.isEmpty) return 0.0;
    final total = progress.values.fold<int>(
      0,
      (sum, p) => sum + (p['completed'] ? 1 : 0),
    );
    return total / participants.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'goal': goal,
      'participants': participants,
      'progress': progress,
      'isPublic': isPublic,
      'imageUrl': imageUrl,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdBy: map['createdBy'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      goal: Map<String, dynamic>.from(map['goal']),
      participants: List<String>.from(map['participants'] ?? []),
      progress: Map<String, dynamic>.from(map['progress'] ?? {}),
      isPublic: map['isPublic'] ?? true,
      imageUrl: map['imageUrl'],
    );
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, dynamic>? goal,
    List<String>? participants,
    Map<String, dynamic>? progress,
    bool? isPublic,
    String? imageUrl,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goal: goal ?? this.goal,
      participants: participants ?? this.participants,
      progress: progress ?? this.progress,
      isPublic: isPublic ?? this.isPublic,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String? fromUserPhotoUrl;
  final DateTime sentAt;
  final String? message;

  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserName,
    this.fromUserPhotoUrl,
    required this.sentAt,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'sentAt': sentAt.toIso8601String(),
      'message': message,
    };
  }

  factory FriendRequest.fromMap(Map<String, dynamic> map) {
    return FriendRequest(
      id: map['id'],
      fromUserId: map['fromUserId'],
      toUserId: map['toUserId'] ?? '',
      fromUserName: map['fromUserName'],
      fromUserPhotoUrl: map['fromUserPhotoUrl'],
      sentAt: DateTime.parse(map['sentAt']),
      message: map['message'],
    );
  }
}
