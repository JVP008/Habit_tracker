import 'package:flutter/material.dart';

void main() {
  runApp(const ZenFlowVintageApp());
}

class ZenFlowVintageApp extends StatelessWidget {
  const ZenFlowVintageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Vintage paper theme
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3E2723), // Dark brown
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Beige paper
        cardColor: const Color(0xFFFAF7F2), // Light cream
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFF2C1810), // Dark brown
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF3E2723), // Dark brown
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF5D4037), // Medium brown
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D6E63), // Light brown
            foregroundColor: const Color(0xFF2C1810), // Dark brown text
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFAF7F2), // Paper color
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: const Color(0xFFD7CCC8).withValues(alpha: 0.5),
            ), // Light border
          ),
        ),
      ),
      home: const ZenFlowVintageMainScreen(),
    );
  }
}

class ZenFlowVintageMainScreen extends StatefulWidget {
  const ZenFlowVintageMainScreen({super.key});

  @override
  State<ZenFlowVintageMainScreen> createState() =>
      _ZenFlowVintageMainScreenState();
}

class _ZenFlowVintageMainScreenState extends State<ZenFlowVintageMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const VintageDashboardScreen(),
    const VintageHabitsScreen(),
    const VintageChallengesScreen(),
    const VintageJournalScreen(),
    const VintageWellbeingScreen(),
    const VintageProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF7F2), // Paper color
          border: Border(
            top: BorderSide(
              color: const Color(0xFFD7CCC8).withValues(alpha: 0.5),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildVintageNavItem(Icons.dashboard, 'Dashboard', 0),
            _buildVintageNavItem(Icons.check_circle, 'Habits', 1),
            _buildVintageNavItem(Icons.emoji_events, 'Challenges', 2),
            _buildVintageNavItem(Icons.book, 'Journal', 3),
            _buildVintageNavItem(Icons.favorite, 'Wellbeing', 4),
            _buildVintageNavItem(Icons.person, 'Profile', 5),
          ],
        ),
      ),
    );
  }

  Widget _buildVintageNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8D6E63) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFFAF7F2)
                  : const Color(0xFF5D4037),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFFFAF7F2)
                    : const Color(0xFF5D4037),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VintageDashboardScreen extends StatelessWidget {
  const VintageDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF3E2723), // Dark brown
        foregroundColor: const Color(0xFFFAF7F2), // Paper color
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card
            VintagePaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back, good sir!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1810),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVintageStatCard('Current Streak', '7 days', '🔥'),
                  const SizedBox(height: 12),
                  _buildVintageStatCard('Habits Today', '3 of 5', '✅'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Today\'s Duties',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 16),

            // Habit cards
            _buildVintageHabitCard('Morning Meditation', true),
            _buildVintageHabitCard('Drink Water', true),
            _buildVintageHabitCard('Exercise', false),
            _buildVintageHabitCard('Read Book', false),
            _buildVintageHabitCard('Gratitude Journal', false),
          ],
        ),
      ),
    );
  }

  Widget _buildVintageStatCard(String label, String value, String emoji) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8D6E63).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD7CCC8).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1810),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVintageHabitCard(String title, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD7CCC8).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFD7CCC8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                completed ? '✓' : '',
                style: const TextStyle(
                  color: Color(0xFFFAF7F2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF3E2723),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            completed ? 'Done' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              color: completed
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF8D6E63),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class VintageHabitsScreen extends StatelessWidget {
  const VintageHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFFAF7F2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFFAF7F2)),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            VintagePaperCard(
              child: Column(
                children: [
                  const Text(
                    'Active Habits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1810),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8D6E63).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFD7CCC8).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      '12',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Your Habits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1810),
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(
              6,
              (index) => _buildVintageHabitItem(
                [
                  'Morning Meditation',
                  'Exercise',
                  'Read for 30 mins',
                  'Drink 8 glasses',
                  'Journal',
                  'No social media',
                ][index],
                ['Daily', 'Daily', 'Daily', 'Daily', 'Daily', 'Daily'][index],
                [
                  '7 day streak',
                  '3 day streak',
                  '14 day streak',
                  '21 day streak',
                  '2 day streak',
                  '5 day streak',
                ][index],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVintageHabitItem(String title, String frequency, String streak) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD7CCC8).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD7CCC8)),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF8D6E63),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C1810),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$frequency • $streak',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF8D6E63),
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        title: const Text(
          'Add New Habit',
          style: TextStyle(color: Color(0xFF2C1810)),
        ),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter habit name...',
            hintStyle: TextStyle(color: Color(0xFF8D6E63)),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD7CCC8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8D6E63)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8D6E63)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D6E63),
              foregroundColor: const Color(0xFFFAF7F2),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class VintagePaperCard extends StatelessWidget {
  final Widget child;

  const VintagePaperCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD7CCC8).withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Placeholder screens for other tabs
class VintageChallengesScreen extends StatelessWidget {
  const VintageChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFFAF7F2),
      ),
      body: const Center(
        child: Text(
          'Challenges Screen',
          style: TextStyle(color: Color(0xFF3E2723)),
        ),
      ),
    );
  }
}

class VintageJournalScreen extends StatelessWidget {
  const VintageJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFFAF7F2),
      ),
      body: const Center(
        child: Text(
          'Journal Screen',
          style: TextStyle(color: Color(0xFF3E2723)),
        ),
      ),
    );
  }
}

class VintageWellbeingScreen extends StatelessWidget {
  const VintageWellbeingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFFAF7F2),
      ),
      body: const Center(
        child: Text(
          'Wellbeing Screen',
          style: TextStyle(color: Color(0xFF3E2723)),
        ),
      ),
    );
  }
}

class VintageProfileScreen extends StatelessWidget {
  const VintageProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: const Color(0xFFFAF7F2),
      ),
      body: const Center(
        child: Text(
          'Profile Screen',
          style: TextStyle(color: Color(0xFF3E2723)),
        ),
      ),
    );
  }
}
