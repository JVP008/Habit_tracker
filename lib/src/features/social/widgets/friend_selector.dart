import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/social_provider.dart';
import '../models/user_profile.dart';

class FriendSelector extends StatefulWidget {
  final List<String> selectedFriends;
  final Function(List<String>) onFriendsSelected;

  const FriendSelector({
    super.key,
    required this.selectedFriends,
    required this.onFriendsSelected,
  });

  @override
  State<FriendSelector> createState() => _FriendSelectorState();
}

class _FriendSelectorState extends State<FriendSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<SocialUser> _filteredFriends = [];
  List<String> _selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _selectedFriends = List.from(widget.selectedFriends);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant FriendSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFriends != widget.selectedFriends) {
      setState(() {
        _selectedFriends = List.from(widget.selectedFriends);
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);

    if (query.isEmpty) {
      setState(() {
        _filteredFriends = [];
      });
      return;
    }

    setState(() {
      _filteredFriends = socialProvider.friends.where((friend) {
        return friend.displayName.toLowerCase().contains(query) ||
            friend.id.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleFriendSelection(String friendId) {
    setState(() {
      if (_selectedFriends.contains(friendId)) {
        _selectedFriends.remove(friendId);
      } else {
        _selectedFriends.add(friendId);
      }
      widget.onFriendsSelected(_selectedFriends);
    });
  }

  void _showAllFriends() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withAlpha((0.1 * 255).toInt()),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select Friends',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onFriendsSelected(_selectedFriends);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search friends...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Friends List
            Expanded(
              child: Consumer<SocialProvider>(
                builder: (context, socialProvider, _) {
                  final friends = _searchController.text.isEmpty
                      ? socialProvider.friends
                      : _filteredFriends;

                  if (friends.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 64,
                            color: Theme.of(
                              context,
                            ).hintColor.withAlpha((0.5 * 255).toInt()),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No friends found'
                                : 'No matching friends',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                          if (_searchController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filteredFriends = [];
                                });
                              },
                              child: const Text('Clear search'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final isSelected = _selectedFriends.contains(friend.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => _toggleFriendSelection(friend.id),
                        title: Text(friend.displayName),
                        subtitle: Text(
                          '${friend.streakDays} day streak • ${friend.completedChallenges} challenges',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          backgroundImage: friend.photoUrl != null
                              ? NetworkImage(friend.photoUrl!)
                              : null,
                          child: friend.photoUrl == null
                              ? Text(friend.displayName[0].toUpperCase())
                              : null,
                        ),
                        controlAffinity: ListTileControlAffinity.trailing,
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Selected Friends Preview
            if (_selectedFriends.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest
                      .withAlpha((0.5 * 255).toInt()),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_selectedFriends.length} selected',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedFriends.length,
                        itemBuilder: (context, index) {
                          final friendId = _selectedFriends[index];
                          final friend =
                              Provider.of<SocialProvider>(
                                context,
                                listen: false,
                              ).friends.firstWhere(
                                (f) => f.id == friendId,
                                orElse: () => SocialUser(
                                  id: friendId,
                                  displayName: 'Unknown',
                                  lastActive: DateTime.now(),
                                  streakDays: 0,
                                  completedChallenges: 0,
                                ),
                              );

                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha((0.1 * 255).toInt()),
                                  backgroundImage: friend.photoUrl != null
                                      ? NetworkImage(friend.photoUrl!)
                                      : null,
                                  child: friend.photoUrl == null
                                      ? Text(
                                          friend.displayName[0].toUpperCase(),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _toggleFriendSelection(friendId),
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _showAllFriends,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(
            (0.3 * 255).toInt(),
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha((0.2 * 255).toInt()),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedFriends.isEmpty
                    ? 'Invite friends to this challenge'
                    : '${_selectedFriends.length} ${_selectedFriends.length == 1 ? 'friend' : 'friends'} selected',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _selectedFriends.isEmpty
                      ? theme.hintColor
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.hintColor,
            ),
          ],
        ),
      ),
    );
  }
}
