import 'package:flutter/material.dart';
import 'package:habit_tracker/src/core/di/injection.dart';
import 'package:habit_tracker/src/features/auth/data/models/user_model.dart';
import 'package:habit_tracker/src/features/auth/data/repositories/user_repository.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserRepository _userRepository = getIt.userRepository;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _userRepository.getUser(widget.userId);

    setState(() {
      _isLoading = false;
      result.fold(
        (failure) => _errorMessage = failure.message,
        (user) => _user = user,
      );
    });
  }

  Future<void> _updateProfile() async {
    if (_user == null) return;

    final result = await _userRepository.updateProfile(
      userId: _user!.id!,
      displayName: 'Updated Name',
      bio: 'Updated bio',
    );

    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}'))),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        _loadUser(); // Reload to show updated data
      },
    );
  }

  Future<void> _incrementStreak() async {
    if (_user == null) return;

    final result = await _userRepository.incrementStreak(_user!.id!);

    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${failure.message}'))),
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Streak incremented!')));
        _loadUser(); // Reload to show updated data
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUser,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _user!.photoUrl != null
                        ? NetworkImage(_user!.photoUrl!)
                        : null,
                    child: _user!.photoUrl == null
                        ? Text(_user!.initials)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user!.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    _user!.email,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (_user!.bio != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _user!.bio!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${_user!.streakDays}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const Text('Day Streak'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '${_user!.completedChallenges}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const Text('Completed'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_user!.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          child: const Text('Update Profile'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _incrementStreak,
                          child: const Text('Increment Streak'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: Text('User not found')),
    );
  }
}
