import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> with SingleTickerProviderStateMixin {
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
                  Tab(text: 'Mood'),
                  Tab(text: 'Stats'),
                  Tab(text: 'Insights'),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MoodTab(),
                StatsTab(),
                InsightsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MoodTab extends StatefulWidget {
  const MoodTab({super.key});

  @override
  State<MoodTab> createState() => _MoodTabState();
}

class _MoodTabState extends State<MoodTab> {
  int _energy = 5;
  int _stress = 5;
  int _sleep = 5;
  String _selectedMood = '😊';
  final List<String> _triggers = [];
  final List<String> _activities = [];
  final _noteController = TextEditingController();

  final List<String> _moods = ['😊', '😌', '😔', '🤔', '😴', '😤', '🎉', '😇'];
  final List<String> _availableTriggers = [
    'Work', 'Family', 'Friends', 'Exercise', 'Food', 'Sleep',
    'Weather', 'News', 'Social Media', 'Health', 'Finance', 'Relationships',
  ];
  final List<String> _availableActivities = [
    'Meditation', 'Exercise', 'Reading', 'Music', 'Nature', 'Social',
    'Creative', 'Learning', 'Rest', 'Play', 'Work', 'Travel',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Mood Selector
          GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling right now?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _moods.length,
                      itemBuilder: (context, index) {
                        final mood = _moods[index];
                        final isSelected = mood == _selectedMood;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedMood = mood),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? Colors.white.withAlpha((0.3 * 255).toInt())
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.white.withAlpha((0.3 * 255).toInt()),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              mood,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Energy, Stress, Sleep Sliders
          GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate your levels',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Energy
                  _buildSlider(
                    'Energy',
                    _energy,
                    Icons.bolt,
                    Colors.yellow,
                    (value) => setState(() => _energy = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Stress
                  _buildSlider(
                    'Stress',
                    _stress,
                    Icons.psychology,
                    Colors.red,
                    (value) => setState(() => _stress = value),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Sleep
                  _buildSlider(
                    'Sleep',
                    _sleep,
                    Icons.bedtime,
                    Colors.indigo,
                    (value) => setState(() => _sleep = value),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Triggers
          GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What triggered this mood?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableTriggers.map((trigger) {
                      final isSelected = _triggers.contains(trigger);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _triggers.remove(trigger);
                            } else {
                              _triggers.add(trigger);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withAlpha((0.3 * 255).toInt())
                                : Colors.white.withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white30,
                            ),
                          ),
                          child: Text(
                            trigger,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Activities
          GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What activities did you do?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableActivities.map((activity) {
                      final isSelected = _activities.contains(activity);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _activities.remove(activity);
                            } else {
                              _activities.add(activity);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withAlpha((0.3 * 255).toInt())
                                : Colors.white.withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white30,
                            ),
                          ),
                          child: Text(
                            activity,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Note
          GlassContainer.clearGlass(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a note (optional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Any additional thoughts...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Save Button
          GlassContainer.clearGlass(
            width: double.infinity,
            height: 50,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                // Save mood entry
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mood entry saved!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Center(
                child: Text(
                  'Save Mood Entry',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSlider(
    String label,
    int value,
    IconData icon,
    Color color,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '$value/10',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            overlayColor: color.withAlpha((0.2 * 255).toInt()),
            valueIndicatorColor: color,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
      ],
    );
  }
}

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Weekly Overview
          GlassContainer.clearGlass(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        _buildStatCard('Avg Mood', '😊', '7.5', Colors.green),
                        const SizedBox(width: 12),
                        _buildStatCard('Energy', '⚡', '6.8', Colors.yellow),
                        const SizedBox(width: 12),
                        _buildStatCard('Stress', '🧘', '4.2', Colors.red),
                        const SizedBox(width: 12),
                        _buildStatCard('Sleep', '😴', '7.1', Colors.indigo),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Mood Trends
          GlassContainer.clearGlass(
            width: double.infinity,
            height: 250,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Trends',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildMoodChart(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Insights
          GlassContainer.clearGlass(
            width: double.infinity,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInsightItem(
                    'Your mood improves after exercise',
                    Icons.trending_up,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    'Stress levels peak on Wednesdays',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    'Better sleep correlates with positive mood',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String emoji, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha((0.2 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMoodChart() {
    // Simple placeholder for mood chart
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'Mood Chart\n(Implementation needed)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
  
  Widget _buildInsightItem(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Monthly Summary
          GlassContainer.clearGlass(
            width: double.infinity,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem(
                    'Best Day',
                    'Monday, Nov 18',
                    'You felt most energetic and positive',
                    Icons.star,
                    Colors.yellow,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Most Common Mood',
                    '😊 Happy',
                    'You felt happy 60% of the time',
                    Icons.sentiment_satisfied,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryItem(
                    'Total Entries',
                    '24',
                    'Great job tracking your mood!',
                    Icons.edit,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Patterns
          GlassContainer.clearGlass(
            width: double.infinity,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patterns & Correlations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPatternItem(
                    'Morning Exercise',
                    'Leads to 30% better mood throughout the day',
                    Icons.fitness_center,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildPatternItem(
                    'Less than 7 hours sleep',
                    'Correlates with higher stress levels',
                    Icons.bedtime,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildPatternItem(
                    'Social Activities',
                    'Improve mood and reduce stress',
                    Icons.people,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Recommendations
          GlassContainer.clearGlass(
            width: double.infinity,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationItem(
                    'Try morning meditation',
                    'Could help reduce stress levels',
                    Icons.self_improvement,
                    Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationItem(
                    'Maintain consistent sleep schedule',
                    'Improves overall mood and energy',
                    Icons.schedule,
                    Colors.teal,
                  ),
                  const SizedBox(height: 12),
                  _buildRecommendationItem(
                    'Take regular breaks during work',
                    'Helps maintain energy levels',
                    Icons.coffee,
                    Colors.brown,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha((0.2 * 255).toInt()),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPatternItem(
    String pattern,
    String correlation,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pattern,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                correlation,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecommendationItem(
    String recommendation,
    String benefit,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recommendation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                benefit,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
