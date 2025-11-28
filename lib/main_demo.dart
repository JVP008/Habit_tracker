import 'package:flutter/material.dart';

void main() {
  runApp(const ZenFlowDemoApp());
}

class ZenFlowDemoApp extends StatelessWidget {
  const ZenFlowDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ZenFlowMainScreen(),
    );
  }
}

class ZenFlowMainScreen extends StatefulWidget {
  const ZenFlowMainScreen({super.key});

  @override
  State<ZenFlowMainScreen> createState() => _ZenFlowMainScreenState();
}

class _ZenFlowMainScreenState extends State<ZenFlowMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HabitsScreen(),
    const ChallengesScreen(),
    const JournalScreen(),
    const WellbeingScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wellbeing',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back! 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Streak',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '7 days 🔥',
                        style: TextStyle(color: Colors.orange, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Habits Today'),
                      Text(
                        '3/5 completed',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Today\'s Habits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildHabitCard('Morning Meditation', '✅ Completed'),
                  _buildHabitCard('Drink Water', '✅ Completed'),
                  _buildHabitCard('Exercise', '⏳ Pending'),
                  _buildHabitCard('Read Book', '⏳ Pending'),
                  _buildHabitCard('Gratitude Journal', '⏳ Pending'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(String title, String status) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text(status),
        leading: CircleAvatar(
          backgroundColor: status.contains('✅') ? Colors.green : Colors.grey,
          child: Icon(
            status.contains('✅') ? Icons.check : Icons.schedule,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Habits',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '12',
                    style: TextStyle(color: Colors.green, fontSize: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildHabitItem(
                    'Morning Meditation',
                    'Daily',
                    '7 day streak',
                  ),
                  _buildHabitItem('Exercise', 'Daily', '3 day streak'),
                  _buildHabitItem('Read for 30 mins', 'Daily', '14 day streak'),
                  _buildHabitItem('Drink 8 glasses', 'Daily', '21 day streak'),
                  _buildHabitItem('Journal', 'Daily', '2 day streak'),
                  _buildHabitItem('No social media', 'Daily', '5 day streak'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(String title, String frequency, String streak) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$frequency • $streak'),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.2),
          child: const Icon(Icons.check_circle, color: Colors.blue),
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Habit'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter habit name...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Challenges',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '3',
                        style: TextStyle(color: Colors.purple, fontSize: 24),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Completed'),
                      Text('8', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available Challenges',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildChallengeCard(
                    '30-Day Meditation',
                    'Mindfulness',
                    '12 participants',
                  ),
                  _buildChallengeCard(
                    'Fitness Marathon',
                    'Health',
                    '45 participants',
                  ),
                  _buildChallengeCard(
                    'Reading Challenge',
                    'Learning',
                    '28 participants',
                  ),
                  _buildChallengeCard(
                    'No Sugar Challenge',
                    'Wellness',
                    '67 participants',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(
    String title,
    String category,
    String participants,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$category • $participants'),
        trailing: ElevatedButton(onPressed: () {}, child: const Text('Join')),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withValues(alpha: 0.2),
          child: const Icon(Icons.emoji_events, color: Colors.purple),
        ),
      ),
    );
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEntryDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Entries',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '47',
                    style: TextStyle(color: Colors.teal, fontSize: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Entries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildJournalEntry(
                    'Today was productive...',
                    'Today, 10:30 AM',
                  ),
                  _buildJournalEntry(
                    'Feeling grateful for...',
                    'Yesterday, 9:15 PM',
                  ),
                  _buildJournalEntry(
                    'Meditation helped me...',
                    'Dec 20, 8:00 AM',
                  ),
                  _buildJournalEntry(
                    'New insights about...',
                    'Dec 19, 7:45 PM',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalEntry(String preview, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(date),
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withValues(alpha: 0.2),
          child: const Icon(Icons.book, color: Colors.teal),
        ),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Journal Entry'),
        content: const TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Write your thoughts...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class WellbeingScreen extends StatelessWidget {
  const WellbeingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text(
                    'How are you feeling today?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('😢', style: TextStyle(fontSize: 30)),
                      Text('😔', style: TextStyle(fontSize: 30)),
                      Text('😐', style: TextStyle(fontSize: 30)),
                      Text('🙂', style: TextStyle(fontSize: 30)),
                      Text('😊', style: TextStyle(fontSize: 30)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Wellbeing Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildMetricCard('Mood', '😊 Good', Colors.green),
                  _buildMetricCard('Energy', '⚡ High', Colors.orange),
                  _buildMetricCard('Stress', '😌 Low', Colors.blue),
                  _buildMetricCard('Sleep', '😴 Good', Colors.purple),
                  _buildMetricCard('Focus', '🎯 High', Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String metric, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          metric,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.favorite, color: color),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ZenFlow User',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text('user@zenflow.app'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⭐ PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileItem('Settings', Icons.settings),
                  _buildProfileItem('Achievements', Icons.emoji_events),
                  _buildProfileItem('Statistics', Icons.bar_chart),
                  _buildProfileItem('Friends', Icons.people),
                  _buildProfileItem('Help & Support', Icons.help),
                  _buildProfileItem('About', Icons.info),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.2),
          child: Icon(icon, color: Colors.blue),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
