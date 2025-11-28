import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/src/core/ui/widgets/glass_container.dart';
import 'package:habit_tracker/src/core/providers/auth_provider.dart';
import 'package:habit_tracker/src/features/auth/data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (_authProvider.user != null) {
      setState(() {
        _user = _authProvider.user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            GlassContainer.clearGlass(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(51),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _user?.photoUrl != null
                          ? ClipOval(
                              child: Image.network(
                                _user!.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 40,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _user?.displayName ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Stats Overview
            Row(
              children: [
                Expanded(
                  child: GlassContainer.clearGlass(
                    height: 100,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.green.shade300,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_getDaysSinceJoin()}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Days Active',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Menu Items
            GlassContainer.clearGlass(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  _buildMenuItem(
                    'Edit Profile',
                    Icons.edit,
                    () => _showEditProfileDialog(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    'Settings',
                    Icons.settings,
                    () => _showSettings(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    'Achievements',
                    Icons.emoji_events,
                    () => _showAchievements(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    'Help & Support',
                    Icons.help,
                    () => _showHelp(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    'About',
                    Icons.info,
                    () => _showAbout(context),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    'Sign Out',
                    Icons.logout,
                    () => _signOut(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // App Version
            Text(
              'ZenFlow v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  int _getDaysSinceJoin() {
    if (_user?.createdAt == null) return 0;
    return DateTime.now().difference(_user!.createdAt).inDays;
  }
  
  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red.shade300 : Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red.shade300 : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDestructive ? Colors.red.shade300 : Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 1,
        color: Colors.white.withAlpha(51),
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context) {
    final displayNameController = TextEditingController(text: _user?.displayName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update profile logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
  
  void _showAchievements(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
    );
  }
  
  void _showHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }
  
  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ZenFlow',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.self_improvement, size: 48),
      children: [
        const Text('A mindfulness and habit tracking app to help you achieve your wellness goals.'),
      ],
    );
  }
  
  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _authProvider.logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// Placeholder screens
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings screen - Coming soon!'),
      ),
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: const Center(
        child: Text('Achievements screen - Coming soon!'),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: const Center(
        child: Text('Help screen - Coming soon!'),
      ),
    );
  }
}
