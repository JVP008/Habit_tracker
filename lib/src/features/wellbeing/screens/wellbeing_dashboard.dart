import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lottie/lottie.dart';

import '../../../../src/core/utils/animations.dart';
import '../../journal/providers/journal_provider.dart';
import '../../../core/providers/task_provider.dart';
import '../widgets/wellbeing_insight_card.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/habit_streak_widget.dart';

class WellbeingDashboard extends StatefulWidget {
  const WellbeingDashboard({super.key});

  @override
  WellbeingDashboardState createState() => WellbeingDashboardState();
}

class WellbeingDashboardState extends State<WellbeingDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      Provider.of<JournalProvider>(context, listen: false).loadEntries(),
      Provider.of<TaskProvider>(context, listen: false).loadData(),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: AppAnimations.fadeIn(child: const Text('My Wellbeing')),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.9),
                      theme.colorScheme.secondary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Lottie.asset(
                  'assets/animations/wellbeing_wave.json',
                  controller: _animationController,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Main content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting with time-based message
                  _buildGreeting(theme),
                  const SizedBox(height: 24),

                  // Mood & Stats Overview
                  _buildMoodOverview(theme),
                  const SizedBox(height: 24),

                  // Habit Streaks
                  _buildHabitStreaks(theme),
                  const SizedBox(height: 24),

                  // Weekly Insights
                  _buildWeeklyInsights(theme),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          'How are you feeling today?',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodOverview(ThemeData theme) {
    return Consumer<JournalProvider>(
      builder: (context, journalProvider, _) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: journalProvider.getMoodHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Error loading mood history');
            }
            final List<Map<String, dynamic>> moodHistory = snapshot.data ?? <Map<String, dynamic>>[];
            return FutureBuilder<Map<String, dynamic>>(
              future: journalProvider.getInsights(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Text('Error loading insights');
                }
                final insights = snapshot.data ?? {};
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mood Overview',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to mood history screen
                              },
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: MoodTrendChart(moodData: moodHistory.map((e) => e['mood'] as double).toList()),
                        ),
                        if (insights.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          WellbeingInsightCard(
                            title: 'Your Mood is ${insights['trend']?.toString() ?? 'Unknown'}' ,
                            message: (insights['recommendations'] as List<dynamic>?)?.first?.toString() ?? '',
                            icon: _getTrendIcon(insights['trend']),
                            color: _getTrendColor(insights['trend'], theme),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHabitStreaks(ThemeData theme) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final completedTasks = taskProvider.tasks
            .where((t) => t.isCompleted)
            .length;
        final totalTasks = taskProvider.tasks.length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Habit Streaks',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: HabitStreakWidget(
                        title: 'Current Streak',
                        days: 7,
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: HabitStreakWidget(
                        title: 'Tasks Completed',
                        days: completedTasks,
                        total: totalTasks,
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyInsights(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Insights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildInsightPage(index, theme);
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightPage(int index, ThemeData theme) {
    final insights = [
      {
        'title': 'Mindful Minutes',
        'value': '42',
        'unit': 'min',
        'trend': '↑ 12% from last week',
        'icon': Icons.self_improvement,
        'color': Colors.purple,
      },
      {
        'title': 'Productivity',
        'value': '78',
        'unit': '%',
        'trend': '↑ 5% from last week',
        'icon': Icons.rocket_launch,
        'color': Colors.blue,
      },
      {
        'title': 'Sleep Quality',
        'value': '6.8',
        'unit': '/10',
        'trend': '↓ 0.5 from last week',
        'icon': Icons.nightlight_round,
        'color': Colors.indigo,
      },
    ][index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (insights['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            insights['icon'] as IconData,
            size: 40,
            color: insights['color'] as Color,
          ),
          const SizedBox(height: 16),
          Text(
            insights['title'] as String,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                insights['value'] as String,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: insights['color'] as Color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                insights['unit'] as String,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: (insights['color'] as Color).withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insights['trend']?.toString() ?? 'N/A',
            style: theme.textTheme.bodySmall?.copyWith(
              color: (insights['trend']?.toString() ?? '').startsWith('↑')
                  ? Colors.green
                  : (insights['trend']?.toString() ?? '').startsWith('↓')
                  ? Colors.red
                  : theme.textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    final actions = [
      {
        'title': 'Quick Journal',
        'icon': Icons.edit_note_rounded,
        'color': Colors.purple,
        'route': '/journal/new',
      },
      {
        'title': 'Meditate',
        'icon': Icons.self_improvement,
        'color': Colors.teal,
        'route': '/mindfulness',
      },
      {
        'title': 'Add Task',
        'icon': Icons.add_task,
        'color': Colors.blue,
        'route': '/tasks/new',
      },
      {
        'title': 'Sleep Sounds',
        'icon': Icons.nights_stay,
        'color': Colors.indigo,
        'route': '/sleep/sounds',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return AppAnimations.bounce(
              onTap: () {
                // Navigate to the corresponding screen
                // Navigator.pushNamed(context, action['route']);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (action['color'] as Color).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      size: 32,
                      color: action['color'] as Color,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: action['color'] as Color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getTrendIcon(String? trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String? trend, ThemeData theme) {
    switch (trend) {
      case 'improving':
        return Colors.green;
      case 'declining':
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }
}
