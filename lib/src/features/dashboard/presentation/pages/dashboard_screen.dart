import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../features/habits/providers/habit_provider.dart';
import '../../../../data/models/task_model.dart';
import '../../../../features/habits/data/models/habit_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh data when dashboard is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        Provider.of<TaskProvider>(context, listen: false).setUserId(user.id);
        Provider.of<HabitProvider>(context, listen: false).setUserId(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = Provider.of<AuthProvider>(context, listen: false).user;
              if (user != null) {
                Provider.of<TaskProvider>(context, listen: false).loadData();
                Provider.of<HabitProvider>(context, listen: false).loadHabits();
              }
            },
          ),
        ],
      ),
      body: Consumer3<AuthProvider, TaskProvider, HabitProvider>(
        builder: (context, authProvider, taskProvider, habitProvider, _) {
          final user = authProvider.user;
          
          // Task Stats
          final allTodayTasks = taskProvider.getTasksForDay(DateTime.now());
          final tasksCompleted = allTodayTasks.where((t) => t.isCompleted).length;
          final tasksTotal = allTodayTasks.length;
          
          // Habit Stats
          final activeHabits = habitProvider.habits.where((h) => h.isActive).toList();
          final habitsCompleted = activeHabits.where((h) => h.isCompletedToday).length;
          final habitsTotal = activeHabits.length;

          return RefreshIndicator(
            onRefresh: () async {
              if (user != null) {
                await taskProvider.loadData();
                await habitProvider.loadHabits();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user?.shortName ?? 'User'}! 👋',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stats Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Streak',
                          value: '${user?.streakDays ?? 0} days',
                          icon: Icons.local_fire_department,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Tasks',
                          value: '$tasksCompleted/$tasksTotal',
                          icon: Icons.check_circle_outline,
                          color: Colors.blue,
                          progress: tasksTotal > 0 ? tasksCompleted / tasksTotal : 0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          title: 'Habits',
                          value: '$habitsCompleted/$habitsTotal',
                          icon: Icons.repeat,
                          color: Colors.purple,
                          progress: habitsTotal > 0 ? habitsCompleted / habitsTotal : 0,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's Tasks Section
                  _buildSectionHeader(context, 'Tasks for Today', () => context.go('/tasks')),
                  const SizedBox(height: 8),
                  if (allTodayTasks.isEmpty)
                    _buildEmptyState(context, 'No tasks scheduled for today')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allTodayTasks.length,
                      itemBuilder: (context, index) {
                        final task = allTodayTasks[index];
                        return _buildTaskCard(context, task, taskProvider);
                      },
                    ),

                  const SizedBox(height: 24),

                  // Today's Habits Section
                  _buildSectionHeader(context, 'Habits', () {}), // Habits tab is usually handled by navigation bar
                  const SizedBox(height: 8),
                  if (activeHabits.isEmpty)
                    _buildEmptyState(context, 'No active habits. Start one!')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeHabits.length,
                      itemBuilder: (context, index) {
                        final habit = activeHabits[index];
                        return _buildHabitCard(context, habit, habitProvider);
                      },
                    ),
                    
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withAlpha(25),
              color: color,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onTap,
          child: const Text('See All'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, TaskProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.withAlpha(51)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        trailing: Transform.scale(
          scale: 0.9,
          child: Checkbox(
            value: task.isCompleted,
            onChanged: (_) => provider.toggleTaskStatus(task.id),
            activeColor: Colors.blue,
            shape: const CircleBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(BuildContext context, HabitModel habit, HabitProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.withAlpha(51)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.repeat, color: Colors.purple, size: 20),
        ),
        title: Text(
          habit.title,
          style: TextStyle(
            decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
            color: habit.isCompletedToday ? Colors.grey : null,
          ),
        ),
        subtitle: Text('${habit.streakDays} day streak'),
        trailing: Transform.scale(
          scale: 0.9,
          child: Checkbox(
            value: habit.isCompletedToday,
            onChanged: (_) => provider.toggleHabitCompletion(habit.id!),
            activeColor: Colors.purple,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ),
    );
  }
}