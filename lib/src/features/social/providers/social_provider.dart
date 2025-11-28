import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class SocialProvider with ChangeNotifier {
  SocialUser? _currentUser;
  List<SocialUser> _friends = [];
  List<FriendRequest> _friendRequests = [];
  List<Challenge> _challenges = [];
  bool _isLoading = false;
  String? _error;

  SocialUser? get currentUser => _currentUser;
  List<SocialUser> get friends => List.unmodifiable(_friends);
  List<FriendRequest> get friendRequests => List.unmodifiable(_friendRequests);
  List<Challenge> get challenges => List.unmodifiable(_challenges);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _currentUser = SocialUser(
        id: 'current_user_id',
        displayName: 'John Doe',
        lastActive: DateTime.now(),
        streakDays: 5,
        completedChallenges: 12,
      );

      _friends = [
        SocialUser(
          id: 'friend_1',
          displayName: 'Jane Smith',
          lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
          streakDays: 10,
          completedChallenges: 25,
        ),
        SocialUser(
          id: 'friend_2',
          displayName: 'Mike Johnson',
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
          streakDays: 3,
          completedChallenges: 8,
        ),
      ];

      _friendRequests = [
        FriendRequest(
          id: 'req_1',
          fromUserId: 'user_3',
          toUserId: 'current_user_id',
          fromUserName: 'Alice Williams',
          sentAt: DateTime.now().subtract(const Duration(days: 1)),
          message: 'Hey! Let\'s challenge each other.',
        ),
      ];

      _challenges = [
        Challenge(
          id: 'ch_1',
          title: '30 Days of Meditation',
          description: 'Meditate for 10 minutes every day',
          createdBy: 'current_user_id',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          goal: {'type': 'duration', 'value': 10},
          participants: ['current_user_id', 'friend_1'],
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<SocialUser>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    // Simulate API search
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock results excluding current user and existing friends
    return [
          SocialUser(
            id: 'user_4',
            displayName: 'Sarah Connor',
            lastActive: DateTime.now(),
            streakDays: 15,
            completedChallenges: 30,
          ),
          SocialUser(
            id: 'user_5',
            displayName: 'Kyle Reese',
            lastActive: DateTime.now(),
            streakDays: 2,
            completedChallenges: 5,
          ),
        ]
        .where(
          (user) =>
              user.displayName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<void> sendFriendRequest(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    notifyListeners();
  }

  Future<void> respondToFriendRequest(String requestId, bool accept) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    _friendRequests.removeWhere((req) => req.id == requestId);

    if (accept) {
      // Add to friends (mock logic)
      // In a real app, we would fetch the user details
    }

    notifyListeners();
  }
}
