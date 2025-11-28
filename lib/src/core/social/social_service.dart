import 'dart:async';
import 'package:logger/logger.dart';
import 'package:habit_tracker/src/core/database/database_service.dart';
import 'package:habit_tracker/src/features/social/data/models/friend_request_model.dart';
import 'package:habit_tracker/src/features/auth/data/models/user_model.dart';
import 'package:habit_tracker/src/features/habits/data/models/habit_model.dart';
import 'package:habit_tracker/src/features/challenges/data/models/challenge_model.dart';

class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  final Logger _logger = Logger();
  final DatabaseService _dbService = DatabaseService();

  /// Send friend request
  Future<bool> sendFriendRequest(String requesterId, String recipientId, {String? message}) async {
    try {
      final db = _dbService.db;
      
      // Check if already friends
      final existingFriendship = await db.query(
        'friends',
        where: '(user_id1 = ? AND user_id2 = ?) OR (user_id1 = ? AND user_id2 = ?)',
        whereArgs: [requesterId, recipientId, recipientId, requesterId],
      );

      if (existingFriendship.isNotEmpty) {
        _logger.w('Users are already friends');
        return false;
      }

      // Check for existing pending request
      final existingRequest = await db.query(
        'friend_requests',
        where: '(requester_id = ? AND recipient_id = ?) OR (requester_id = ? AND recipient_id = ?)',
        whereArgs: [requesterId, recipientId, recipientId, requesterId],
      );

      if (existingRequest.isNotEmpty) {
        _logger.w('Friend request already exists');
        return false;
      }

      // Create friend request
      await db.insert('friend_requests', {
        'requester_id': requesterId,
        'recipient_id': recipientId,
        'status': 'pending',
        'message': message,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      _logger.i('Friend request sent from $requesterId to $recipientId');
      
      // Send notification to recipient (would integrate with notification service)
      await _notifyFriendRequest(recipientId, requesterId);
      
      return true;
    } catch (e) {
      _logger.e('Failed to send friend request: $e');
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      final db = _dbService.db;
      
      // Get the request
      final requests = await db.query(
        'friend_requests',
        where: 'id = ?',
        whereArgs: [requestId],
      );

      if (requests.isEmpty) {
        _logger.w('Friend request not found');
        return false;
      }

      final request = requests.first;
      final requesterId = request['requester_id'] as String;
      final recipientId = request['recipient_id'] as String;

      // Update request status
      await db.update(
        'friend_requests',
        {
          'status': 'accepted',
          'responded_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [requestId],
      );

      // Create friendship
      await db.insert('friends', {
        'user_id1': requesterId,
        'user_id2': recipientId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      _logger.i('Friend request accepted: $requestId');
      
      // Send notification to requester
      await _notifyFriendRequestAccepted(requesterId, recipientId);
      
      return true;
    } catch (e) {
      _logger.e('Failed to accept friend request: $e');
      return false;
    }
  }

  /// Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      final db = _dbService.db;
      
      await db.update(
        'friend_requests',
        {
          'status': 'rejected',
          'responded_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [requestId],
      );

      _logger.i('Friend request rejected: $requestId');
      return true;
    } catch (e) {
      _logger.e('Failed to reject friend request: $e');
      return false;
    }
  }

  /// Get pending friend requests for user
  Future<List<FriendRequestModel>> getPendingFriendRequests(String userId) async {
    try {
      final db = _dbService.db;
      
      final requests = await db.query(
        'friend_requests',
        where: 'recipient_id = ? AND status = ?',
        whereArgs: [userId, 'pending'],
        orderBy: 'created_at DESC',
      );

      return requests.map((request) => FriendRequestModel.fromJson({
        'id': request['id'] as String,
        'requester_id': request['requester_id'] as String,
        'recipient_id': request['recipient_id'] as String,
        'status': request['status'] as String,
        'message': request['message'] as String?,
        'created_at': DateTime.fromMillisecondsSinceEpoch(request['created_at'] as int).toIso8601String(),
        'responded_at': request['responded_at'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(request['responded_at'] as int).toIso8601String()
            : null,
      })).toList();
    } catch (e) {
      _logger.e('Failed to get pending friend requests: $e');
      return [];
    }
  }

  /// Get user's friends
  Future<List<UserModel>> getUserFriends(String userId) async {
    try {
      final db = _dbService.db;
      
      final friendships = await db.query(
        'friends',
        where: 'user_id1 = ? OR user_id2 = ?',
        whereArgs: [userId, userId],
      );

      final friendIds = <String>[];
      for (final friendship in friendships) {
        final userId1 = friendship['user_id1'] as String;
        final userId2 = friendship['user_id2'] as String;
        
        if (userId1 == userId) {
          friendIds.add(userId2);
        } else {
          friendIds.add(userId1);
        }
      }

      if (friendIds.isEmpty) return [];

      // Get user data for friends
      final placeholders = List.filled(friendIds.length, '?').join(',');
      final users = await db.query(
        'users',
        where: 'id IN ($placeholders)',
        whereArgs: friendIds,
      );

      return users.map((user) => UserModel.fromJson({
        'id': user['id'] as String,
        'display_name': user['display_name'] as String,
        'email': user['email'] as String,
        'photo_url': user['photo_url'] as String?,
        'bio': user['bio'] as String?,
        'streak_days': user['streak_days'] as int? ?? 0,
        'completed_challenges': user['completed_challenges'] as int? ?? 0,
        'created_at': DateTime.fromMillisecondsSinceEpoch(user['created_at'] as int).toIso8601String(),
        'updated_at': DateTime.fromMillisecondsSinceEpoch(user['updated_at'] as int).toIso8601String(),
        'last_active': user['last_active'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(user['last_active'] as int).toIso8601String()
            : null,
        'settings': user['settings'] as Map<String, dynamic>?,
        'is_premium': user['is_premium'] as bool? ?? false,
        'subscription_expiry': user['subscription_expiry'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(user['subscription_expiry'] as int).toIso8601String()
            : null,
      })).toList();
    } catch (e) {
      _logger.e('Failed to get user friends: $e');
      return [];
    }
  }

  /// Share habit with friends
  Future<bool> shareHabitWithFriends(String habitId, List<String> friendIds) async {
    try {
      final db = _dbService.db;
      
      for (final friendId in friendIds) {
        await db.insert('shared_habits', {
          'habit_id': habitId,
          'shared_with': friendId,
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      _logger.i('Shared habit $habitId with ${friendIds.length} friends');
      return true;
    } catch (e) {
      _logger.e('Failed to share habit: $e');
      return false;
    }
  }

  /// Get shared habits from friends
  Future<List<HabitModel>> getSharedHabits(String userId) async {
    try {
      final db = _dbService.db;
      
      final sharedHabits = await db.rawQuery('''
        SELECT h.* FROM habits h
        INNER JOIN shared_habits sh ON h.id = sh.habit_id
        WHERE sh.shared_with = ?
        ORDER BY sh.shared_at DESC
      ''', [userId]);

      return sharedHabits.map((habit) => HabitModel.fromJson({
        'id': habit['id'] as String,
        'user_id': habit['user_id'] as String,
        'title': habit['title'] as String,
        'description': habit['description'] as String?,
        'category': habit['category'] as String,
        'frequency': habit['frequency'] as String,
        'target_days': habit['target_days'] as int? ?? 7,
        'reminder_time': habit['reminder_time'] as String?,
        'tags': (habit['tags'] as String?)?.split(',') ?? [],
        'streak_days': habit['streak_days'] as int? ?? 0,
        'total_completions': habit['total_completions'] as int? ?? 0,
        'created_at': DateTime.fromMillisecondsSinceEpoch(habit['created_at'] as int).toIso8601String(),
        'updated_at': DateTime.fromMillisecondsSinceEpoch(habit['updated_at'] as int).toIso8601String(),
        'last_completed_at': habit['last_completed_at'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(habit['last_completed_at'] as int).toIso8601String()
            : null,
        'is_active': habit['is_active'] as int? ?? 1 == 1,
        'target_count': habit['target_count'] as int? ?? 1,
        'unit': habit['unit'] as String?,
      })).toList();
    } catch (e) {
      _logger.e('Failed to get shared habits: $e');
      return [];
    }
  }

  /// Invite friend to challenge
  Future<bool> inviteFriendToChallenge(String challengeId, String friendId) async {
    try {
      final db = _dbService.db;
      
      await db.insert('challenge_invitations', {
        'challenge_id': challengeId,
        'invited_user': friendId,
        'status': 'pending',
        'invited_at': DateTime.now().millisecondsSinceEpoch,
      });

      _logger.i('Invited friend $friendId to challenge $challengeId');
      
      // Send notification
      await _notifyChallengeInvitation(friendId, challengeId);
      
      return true;
    } catch (e) {
      _logger.e('Failed to invite friend to challenge: $e');
      return false;
    }
  }

  /// Get community challenges
  Future<List<ChallengeModel>> getCommunityChallenges({int limit = 20}) async {
    try {
      final db = _dbService.db;
      
      final challenges = await db.query(
        'challenges',
        where: 'is_public = ? AND is_active = ?',
        whereArgs: [1, 1],
        orderBy: 'created_at DESC',
        limit: limit,
      );

      return challenges.map((challenge) => ChallengeModel.fromJson({
        'id': challenge['id'] as String,
        'title': challenge['title'] as String,
        'description': challenge['description'] as String?,
        'created_by': challenge['created_by'] as String,
        'start_date': DateTime.fromMillisecondsSinceEpoch(challenge['start_date'] as int).toIso8601String(),
        'end_date': DateTime.fromMillisecondsSinceEpoch(challenge['end_date'] as int).toIso8601String(),
        'goal_type': challenge['goal_type'] as String,
        'goal_target': challenge['goal_target'] as int,
        'goal_unit': challenge['goal_unit'] as String?,
        'image_url': challenge['image_url'] as String?,
        'is_public': challenge['is_public'] as int? ?? 1 == 1,
        'is_active': challenge['is_active'] as int? ?? 1 == 1,
        'max_participants': challenge['max_participants'] as int?,
        'created_at': DateTime.fromMillisecondsSinceEpoch(challenge['created_at'] as int).toIso8601String(),
        'updated_at': DateTime.fromMillisecondsSinceEpoch(challenge['updated_at'] as int).toIso8601String(),
      })).toList();
    } catch (e) {
      _logger.e('Failed to get community challenges: $e');
      return [];
    }
  }

  /// Join community challenge
  Future<bool> joinCommunityChallenge(String challengeId, String userId) async {
    try {
      final db = _dbService.db;
      
      // Check if already participating
      final existing = await db.query(
        'challenge_participants',
        where: 'challenge_id = ? AND user_id = ?',
        whereArgs: [challengeId, userId],
      );

      if (existing.isNotEmpty) {
        _logger.w('User already participating in challenge');
        return false;
      }

      // Check if challenge is full
      final challenge = await db.query(
        'challenges',
        where: 'id = ?',
        whereArgs: [challengeId],
        limit: 1,
      );

      if (challenge.isNotEmpty) {
        final maxParticipants = challenge.first['max_participants'] as int?;
        if (maxParticipants != null) {
          final currentParticipants = await db.query(
            'challenge_participants',
            where: 'challenge_id = ?',
            whereArgs: [challengeId],
          );

          if (currentParticipants.length >= maxParticipants) {
            _logger.w('Challenge is full');
            return false;
          }
        }
      }

      // Join challenge
      await db.insert('challenge_participants', {
        'challenge_id': challengeId,
        'user_id': userId,
        'status': 'active',
        'joined_at': DateTime.now().millisecondsSinceEpoch,
      });

      _logger.i('User $userId joined challenge $challengeId');
      return true;
    } catch (e) {
      _logger.e('Failed to join community challenge: $e');
      return false;
    }
  }

  /// Get social feed
  Future<List<SocialFeedItem>> getSocialFeed(String userId, {int limit = 20}) async {
    try {
      final db = _dbService.db;
      
      // Get friends' recent activities
      final friends = await getUserFriends(userId);
      final friendIds = friends.map((f) => f.id!).toList();
      
      if (friendIds.isEmpty) return [];

      final placeholders = List.filled(friendIds.length, '?').join(',');
      
      // Get recent habit completions
      final habitCompletions = await db.rawQuery('''
        SELECT hc.*, h.title as habit_title, u.display_name as user_name, u.photo_url as user_photo
        FROM habit_completions hc
        INNER JOIN habits h ON hc.habit_id = h.id
        INNER JOIN users u ON h.user_id = u.id
        WHERE h.user_id IN ($placeholders)
        ORDER BY hc.completed_at DESC
        LIMIT ?
      ''', [...friendIds, limit]);

      // Get challenge participations
      final challengeParticipations = await db.rawQuery('''
        SELECT cp.*, c.title as challenge_title, u.display_name as user_name, u.photo_url as user_photo
        FROM challenge_participants cp
        INNER JOIN challenges c ON cp.challenge_id = c.id
        INNER JOIN users u ON cp.user_id = u.id
        WHERE cp.user_id IN ($placeholders)
        ORDER BY cp.joined_at DESC
        LIMIT ?
      ''', [...friendIds, limit]);

      final feedItems = <SocialFeedItem>[];

      // Process habit completions
      for (final completion in habitCompletions) {
        feedItems.add(SocialFeedItem(
          id: completion['id'] as String,
          type: SocialFeedType.habitCompletion,
          userId: completion['user_id'] as String,
          userName: completion['user_name'] as String,
          userPhotoUrl: completion['user_photo'] as String?,
          title: 'Completed habit',
          description: completion['habit_title'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(completion['completed_at'] as int),
        ));
      }

      // Process challenge participations
      for (final participation in challengeParticipations) {
        feedItems.add(SocialFeedItem(
          id: participation['id'] as String,
          type: SocialFeedType.challengeJoined,
          userId: participation['user_id'] as String,
          userName: participation['user_name'] as String,
          userPhotoUrl: participation['user_photo'] as String?,
          title: 'Joined challenge',
          description: participation['challenge_title'] as String,
          timestamp: DateTime.fromMillisecondsSinceEpoch(participation['joined_at'] as int),
        ));
      }

      // Sort by timestamp
      feedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return feedItems.take(limit).toList();
    } catch (e) {
      _logger.e('Failed to get social feed: $e');
      return [];
    }
  }

  /// Post to social feed
  Future<bool> postToSocialFeed(String userId, String content, {String? imageUrl}) async {
    try {
      final db = _dbService.db;
      
      await db.insert('social_posts', {
        'user_id': userId,
        'content': content,
        'image_url': imageUrl,
        'likes': 0,
        'comments': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      _logger.i('User $userId posted to social feed');
      return true;
    } catch (e) {
      _logger.e('Failed to post to social feed: $e');
      return false;
    }
  }

  /// Like social post
  Future<bool> likeSocialPost(String postId, String userId) async {
    try {
      final db = _dbService.db;
      
      // Check if already liked
      final existingLike = await db.query(
        'social_post_likes',
        where: 'post_id = ? AND user_id = ?',
        whereArgs: [postId, userId],
      );

      if (existingLike.isNotEmpty) {
        // Unlike
        await db.delete(
          'social_post_likes',
          where: 'post_id = ? AND user_id = ?',
          whereArgs: [postId, userId],
        );
        
        await db.rawUpdate(
          'UPDATE social_posts SET likes = likes - 1 WHERE id = ?',
          [postId],
        );
      } else {
        // Like
        await db.insert('social_post_likes', {
          'post_id': postId,
          'user_id': userId,
          'liked_at': DateTime.now().millisecondsSinceEpoch,
        });
        
        await db.rawUpdate(
          'UPDATE social_posts SET likes = likes + 1 WHERE id = ?',
          [postId],
        );
      }

      return true;
    } catch (e) {
      _logger.e('Failed to like social post: $e');
      return false;
    }
  }

  // Private notification methods
  Future<void> _notifyFriendRequest(String recipientId, String requesterId) async {
    // Would integrate with notification service
    _logger.i('Notifying user $recipientId about friend request from $requesterId');
  }

  Future<void> _notifyFriendRequestAccepted(String requesterId, String recipientId) async {
    // Would integrate with notification service
    _logger.i('Notifying user $requesterId that friend request was accepted by $recipientId');
  }

  Future<void> _notifyChallengeInvitation(String friendId, String challengeId) async {
    // Would integrate with notification service
    _logger.i('Notifying user $friendId about challenge invitation $challengeId');
  }
}

// Social feed data models
class SocialFeedItem {
  final String id;
  final SocialFeedType type;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String title;
  final String description;
  final DateTime timestamp;

  const SocialFeedItem({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}

enum SocialFeedType {
  habitCompletion,
  challengeJoined,
  challengeCompleted,
  milestone,
  post,
}
