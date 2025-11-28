import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/src/core/ui/widgets/glass_container.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../data/models/habit_model.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  Tab(text: 'Today'),
                  Tab(text: 'All Habits'),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Consumer<HabitProvider>(
              builder: (context, habitProvider, _) {
                if (habitProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                return TabBarView(
                  controller: _tabController,
                  children: [
                    TodayHabitsTab(habits: habitProvider.habits),
                    AllHabitsTab(habits: habitProvider.habits),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TodayHabitsTab extends StatelessWidget {
  final List<HabitModel> habits;
  const TodayHabitsTab({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // In a real app, we would filter based on `targetDays` vs today's weekday
    // For now, we show all active habits
    final activeHabits = habits.where((h) => h.isActive).toList();
    final completedCount = activeHabits.where((h) => h.isCompletedToday).length;
    final totalCount = activeHabits.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress Overview
          GlassContainer.clearGlass(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Progress',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade300),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedCount of $totalCount habits completed',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Today's Habits List
          activeHabits.isEmpty 
            ? const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No habits for today!", style: TextStyle(color: Colors.white70)),
              ))
            : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeHabits.length,
            itemBuilder: (context, index) {
              final habit = activeHabits[index];
              final isCompleted = habit.isCompletedToday;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassContainer.clearGlass(
                  height: 80,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Provider.of<HabitProvider>(context, listen: false).toggleHabitCompletion(habit.id!);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted 
                                  ? Colors.green.shade300 
                                  : Colors.white30,
                              border: isCompleted 
                                  ? null 
                                  : Border.all(color: Colors.white54),
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.title,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  decoration: isCompleted 
                                      ? TextDecoration.lineThrough 
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                habit.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _getCategoryIcon(habit.category),
                          color: Colors.white70,
                          size: 24,
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
  
  IconData _getCategoryIcon(String category) {
    switch(category.toLowerCase()) {
      case 'mindfulness': return Icons.self_improvement;
      case 'fitness': return Icons.fitness_center;
      case 'learning': return Icons.menu_book;
      case 'productivity': return Icons.work;
      case 'social': return Icons.social_distance;
      case 'health': return Icons.health_and_safety;
      default: return Icons.star;
    }
  }
}

class AllHabitsTab extends StatelessWidget {
  final List<HabitModel> habits;
  const AllHabitsTab({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Add Habit Button
          InkWell(
            onTap: () => _showAddHabitDialog(context),
            child: GlassContainer.clearGlass(
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
                    'Add New Habit',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Habits List (Grid might be too cramped for details)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassContainer.clearGlass(
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    leading: Icon(_getCategoryIcon(habit.category), color: Colors.white70),
                    title: Text(habit.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text('${habit.streakDays} day streak', style: const TextStyle(color: Colors.white54)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white54),
                      onPressed: () {
                        Provider.of<HabitProvider>(context, listen: false).deleteHabit(habit.id!);
                      },
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

  IconData _getCategoryIcon(String category) {
    // Simplified mapping
    return Icons.star_border; 
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Habit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final user = Provider.of<AuthProvider>(context, listen: false).user;
                if (user != null) {
                  final habit = HabitModel(
                    userId: user.id!,
                    title: titleController.text,
                    description: descriptionController.text,
                    category: 'General',
                    frequency: 'Daily',
                    targetDays: [1,2,3,4,5,6,7],
                    reminderTime: const HabitTimeOfDay(hour: 9, minute: 0),
                  );
                  Provider.of<HabitProvider>(context, listen: false).addHabit(habit);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
