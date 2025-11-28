import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../src/core/utils/animations.dart';
import '../../../core/providers/task_provider.dart';
import '../models/user_profile.dart';
import '../providers/social_provider.dart';
import '../widgets/challenge_card.dart';

class SocialDashboardScreen extends StatefulWidget {
  const SocialDashboardScreen({super.key});

  @override
  State<SocialDashboardScreen> createState() => _SocialDashboardScreenState();
}

class _SocialDashboardScreenState extends State<SocialDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      Provider.of<SocialProvider>(context, listen: false).loadUserData(),
      Provider.of<TaskProvider>(context, listen: false).loadData(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<void> _searchUsers(String query) async { // Unused method
  //   if (query.isEmpty) {
  //     setState(() {
  //       _isSearching = false;
  //       _searchResults = [];
  //     });
  //     return;
  //   }

  //   setState(() => _isSearching = true);

  //   try {
  //     final socialProvider = Provider.of<SocialProvider>(
  //       context,
  //       listen: false,
  //     );
  //     final results = await socialProvider.searchUsers(query);

  //     setState(() {
  //       _searchResults = results;
  //     });
  //   } catch (e) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Error searching users: $e')));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final socialProvider = Provider.of<SocialProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: AppAnimations.fadeIn(child: const Text('Community')),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withAlpha(
                          (0.9 * 255).toInt(),
                        ),
                        theme.colorScheme.secondary.withAlpha(
                          (0.8 * 255).toInt(),
                        ),
                      ],
                    ),
                  ),
                  child: Lottie.asset(
                    'assets/loading.json/community.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: UserSearchDelegate(
                        socialProvider: socialProvider,
                        currentUserId: socialProvider.currentUser?.id ?? '',
                      ),
                    );
                  },
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () {
                        // Navigate to notifications
                      },
                    ),
                    if (socialProvider.friendRequests.isNotEmpty)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${socialProvider.friendRequests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.emoji_events_rounded),
                    text: 'Challenges',
                  ),
                  Tab(icon: Icon(Icons.people_alt_rounded), text: 'Friends'),
                  Tab(
                    icon: Icon(Icons.leaderboard_rounded),
                    text: 'Leaderboard',
                  ),
                ],
                labelColor: theme.colorScheme.onPrimary,
                indicatorColor: theme.colorScheme.onPrimary,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Challenges Tab
            _buildChallengesTab(context, socialProvider, taskProvider, theme),

            // Friends Tab
            _buildFriendsTab(context, socialProvider, theme),

            // Leaderboard Tab
            _buildLeaderboardTab(context, socialProvider, theme),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const CreateChallengeScreen(),
                //   ),
                // );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create Challenge coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Challenge'),
            )
          : null,
    );
  }

  Widget _buildChallengesTab(
    BuildContext context,
    SocialProvider socialProvider,
    TaskProvider taskProvider,
    ThemeData theme,
  ) {
    if (socialProvider.isLoading && socialProvider.challenges.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (socialProvider.challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/loading.json/no_challenges.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            Text('No challenges yet!', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Create a challenge to get started',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const CreateChallengeScreen(),
                //   ),
                // );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create Challenge coming soon!'),
                  ),
                );
              },
              child: const Text('Create Challenge'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: socialProvider.challenges.length,
        itemBuilder: (context, index) {
          final challenge = socialProvider.challenges[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ChallengeCard(
              challenge: challenge,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         ChallengeDetailScreen(challenge: challenge),
                //   ),
                // );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challenge Details coming soon!'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsTab(
    BuildContext context,
    SocialProvider socialProvider,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // Friend Requests Section
        if (socialProvider.friendRequests.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'Friend Requests (${socialProvider.friendRequests.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: socialProvider.friendRequests.length,
              itemBuilder: (context, index) {
                final request = socialProvider.friendRequests[index];
                return FriendRequestCard(
                  request: request,
                  onAccept: () =>
                      socialProvider.respondToFriendRequest(request.id, true),
                  onReject: () =>
                      socialProvider.respondToFriendRequest(request.id, false),
                );
              },
            ),
          ),
          const Divider(),
        ],

        // Friends List
        Expanded(
          child: socialProvider.friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/loading.json/no_friends.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No friends yet!',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add friends to see their activity',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: UserSearchDelegate(
                              socialProvider: socialProvider,
                              currentUserId:
                                  socialProvider.currentUser?.id ?? '',
                            ),
                          );
                        },
                        child: const Text('Find Friends'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: socialProvider.friends.length,
                  itemBuilder: (context, index) {
                    final friend = socialProvider.friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: friend.photoUrl != null
                            ? CachedNetworkImageProvider(friend.photoUrl!)
                            : null,
                        child: friend.photoUrl == null
                            ? Text(friend.displayName[0].toUpperCase())
                            : null,
                      ),
                      title: Text(friend.displayName),
                      subtitle: Text(
                        '${friend.streakDays} day streak • ${friend.completedChallenges} challenges',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        // Navigate to friend's profile
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab(
    BuildContext context,
    SocialProvider socialProvider,
    ThemeData theme,
  ) {
    // Sort friends by streak and completed challenges
    final sortedFriends = List<SocialUser>.from(socialProvider.friends)
      ..sort((a, b) {
        if (a.streakDays != b.streakDays) {
          return b.streakDays.compareTo(a.streakDays);
        }
        return b.completedChallenges.compareTo(a.completedChallenges);
      });

    // Add current user to the leaderboard if not already in friends
    final leaderboard = <SocialUser>[];
    if (socialProvider.currentUser != null) {
      leaderboard.add(socialProvider.currentUser!);
    }
    leaderboard.addAll(sortedFriends);

    return leaderboard.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/loading.json/leaderboard.json',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 16),
                Text(
                  'No leaderboard data yet',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete challenges to climb the ranks!',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final isCurrentUser = user.id == socialProvider.currentUser?.id;

              return Card(
                color: isCurrentUser
                    ? theme.colorScheme.primary.withAlpha((0.1 * 255).toInt())
                    : null,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: isCurrentUser
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrentUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (index < 3) ...[
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              ['🥇', '🥈', '🥉'][index],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  title: Text(
                    isCurrentUser ? 'You' : user.displayName,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : null,
                    ),
                  ),
                  subtitle: Text(
                    '${user.streakDays} day streak • ${user.completedChallenges} challenges',
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class FriendRequestCard extends StatelessWidget {
  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const FriendRequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: request.fromUserPhotoUrl != null
                    ? CachedNetworkImageProvider(request.fromUserPhotoUrl!)
                    : null,
                child: request.fromUserPhotoUrl == null
                    ? Text(request.fromUserName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  request.fromUserName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.message!,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onAccept,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                  child: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onReject,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  final SocialProvider socialProvider;
  final String currentUserId;

  UserSearchDelegate({
    required this.socialProvider,
    required this.currentUserId,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear_rounded),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for friends by name or email'));
    }

    return FutureBuilder<List<SocialUser>>(
      future: socialProvider.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final user = results[index];
            final isFriend = socialProvider.friends.any((f) => f.id == user.id);
            final hasPendingRequest = socialProvider.friendRequests.any(
              (r) => r.fromUserId == user.id || r.toUserId == user.id,
            );

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: user.photoUrl != null
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: user.photoUrl == null
                    ? Text(user.displayName[0].toUpperCase())
                    : null,
              ),
              title: Text(user.displayName),
              subtitle: Text(
                '${user.streakDays} day streak • ${user.completedChallenges} challenges',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: user.id == currentUserId
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'You',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  : isFriend
                  ? OutlinedButton(
                      onPressed: null,
                      child: Text(
                        'Friends',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  : hasPendingRequest
                  ? OutlinedButton(
                      onPressed: null,
                      child: Text(
                        'Request Sent',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        socialProvider.sendFriendRequest(user.id);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Friend request sent!')),
                        );
                      },
                      child: const Text('Add Friend'),
                    ),
            );
          },
        );
      },
    );
  }
}
