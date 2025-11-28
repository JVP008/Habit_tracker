import 'package:flutter/material.dart';
import 'package:habit_tracker/src/core/ui/widgets/glass_container.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassContainer.clearGlass(
              height: 60,
              borderRadius: BorderRadius.circular(16),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Discover'),
                  Tab(text: 'My Challenges'),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ActiveChallengesTab(),
                DiscoverChallengesTab(),
                MyChallengesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActiveChallengesTab extends StatelessWidget {
  const ActiveChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Challenge Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: GlassContainer.clearGlass(
                  height: 140,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getChallengeColor(index).withAlpha((0.3 * 255).round()),
                              ),
                              child: Icon(
                                _getChallengeIcon(index),
                                color: _getChallengeColor(index),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getChallengeTitle(index),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${_getChallengeParticipants(index)} participants',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_getChallengeDaysLeft(index)}d left',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getChallengeDescription(index),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _getChallengeProgress(index),
                          backgroundColor: Colors.white30,
                          valueColor: AlwaysStoppedAnimation<Color>(_getChallengeColor(index)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_getChallengeProgress(index) * 100).toInt()}% complete',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  String _getChallengeTitle(int index) {
    final titles = [
      '30-Day Meditation Challenge',
      '10K Steps Daily',
      'Read 20 Books',
      'No Sugar Challenge',
      'Yoga Every Day',
    ];
    return titles[index % titles.length];
  }
  
  String _getChallengeDescription(int index) {
    final descriptions = [
      'Meditate for at least 10 minutes every day for 30 days',
      'Walk 10,000 steps every day for a month',
      'Read and finish 20 books in 3 months',
      'No added sugar for 21 days straight',
      'Practice yoga for 15 minutes daily',
    ];
    return descriptions[index % descriptions.length];
  }
  
  IconData _getChallengeIcon(int index) {
    final icons = [
      Icons.self_improvement,
      Icons.directions_walk,
      Icons.menu_book,
      Icons.no_food,
      Icons.sports_gymnastics,
    ];
    return icons[index % icons.length];
  }
  
  Color _getChallengeColor(int index) {
    final colors = [
      Colors.purple.shade300,
      Colors.green.shade300,
      Colors.blue.shade300,
      Colors.red.shade300,
      Colors.orange.shade300,
    ];
    return colors[index % colors.length];
  }
  
  int _getChallengeParticipants(int index) {
    return [1234, 892, 567, 445, 321][index % 5];
  }
  
  int _getChallengeDaysLeft(int index) {
    return [15, 8, 45, 12, 20][index % 5];
  }
  
  double _getChallengeProgress(int index) {
    return [0.6, 0.3, 0.8, 0.4, 0.7][index % 5];
  }
}

class DiscoverChallengesTab extends StatelessWidget {
  const DiscoverChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          GlassContainer.clearGlass(
            height: 50,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search challenges...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Categories
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: GlassContainer.clearGlass(
                    width: 100,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(index),
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getCategoryName(index),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Featured Challenges
          Text(
            'Featured Challenges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassContainer.clearGlass(
                  height: 100,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _getFeaturedColor(index).withAlpha((0.3 * 255).round()),
                          ),
                          child: Icon(
                            _getFeaturedIcon(index),
                            color: _getFeaturedColor(index),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFeaturedTitle(index),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getFeaturedDescription(index),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_getFeaturedParticipants(index)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withAlpha((0.2 * 255).round()),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                    ),
                                    child: const Text('Join'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(int index) {
    final icons = [
      Icons.fitness_center,
      Icons.self_improvement,
      Icons.menu_book,
      Icons.brush, // Replaced Icons.creativity
      Icons.health_and_safety,
      Icons.social_distance,
    ];
    return icons[index % icons.length];
  }
  
  String _getCategoryName(int index) {
    final names = [
      'Fitness',
      'Mindfulness',
      'Learning',
      'Creative',
      'Health',
      'Social',
    ];
    return names[index % names.length];
  }
  
  IconData _getFeaturedIcon(int index) {
    final icons = [
      Icons.directions_run,
      Icons.psychology,
      Icons.code,
      Icons.music_note,
      Icons.pets,
      Icons.volunteer_activism,
      Icons.camera_alt,
      Icons.local_florist, // Replaced Icons.garden
    ];
    return icons[index % icons.length];
  }
  
  Color _getFeaturedColor(int index) {
    final colors = [
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.green.shade300,
      Colors.pink.shade300,
      Colors.orange.shade300,
      Colors.red.shade300,
      Colors.indigo.shade300,
      Colors.teal.shade300,
    ];
    return colors[index % colors.length];
  }
  
  String _getFeaturedTitle(int index) {
    final titles = [
      'Marathon Training',
      'Mindful Month',
      'Code Every Day',
      'Music Practice',
      'Pet Care Challenge',
      'Random Acts of Kindness',
      'Photo a Day',
      'Garden Growth',
    ];
    return titles[index % titles.length];
  }
  
  String _getFeaturedDescription(int index) {
    final descriptions = [
      'Build up to running a full marathon',
      'Practice mindfulness daily',
      'Code for at least 30 minutes',
      'Practice instrument daily',
      'Daily pet care routine',
      'Help others every day',
      'Take one photo daily',
      'Grow plants from seeds',
    ];
    return descriptions[index % descriptions.length];
  }
  
  int _getFeaturedParticipants(int index) {
    return [2341, 1876, 1234, 987, 654, 543, 432, 321][index % 8];
  }
}

class MyChallengesTab extends StatelessWidget {
  const MyChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Create Challenge Button
          GlassContainer.clearGlass(
            width: double.infinity,
            height: 60,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Create Challenge',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // My Created Challenges
          Text(
            'My Created Challenges',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassContainer.clearGlass(
                  height: 120,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'My Challenge ${index + 1}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Description of my challenge ${index + 1}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(index + 1) * 12} participants',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Manage',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
