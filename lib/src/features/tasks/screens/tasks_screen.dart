import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:habit_tracker/src/core/providers/task_provider.dart';
import 'package:habit_tracker/src/data/models/task_model.dart';
import 'package:habit_tracker/src/core/widgets/loading_indicator.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Today', 'Upcoming', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: Theme.of(context).colorScheme.primary,
          indicatorColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children:
            [_buildTaskList(context, TaskFilter.today), _buildTaskList(context, TaskFilter.upcoming), _buildTaskList(context, TaskFilter.completed)],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, TaskFilter filter) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        if (taskProvider.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        List<Task> tasks = [];
        switch (filter) {
          case TaskFilter.today:
            tasks = taskProvider.todayTasks;
            break;
          case TaskFilter.upcoming:
            tasks = taskProvider
                .getTasksByStatus(TaskStatus.todo)
                .where((task) => task.dueDate.isAfter(DateTime.now()))
                .toList();
            break;
          case TaskFilter.completed:
            tasks = taskProvider.getTasksByStatus(TaskStatus.completed);
            break;
        }

        if (tasks.isEmpty) {
          return _buildEmptyState(filter);
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _TaskItem(
              task: task,
              onToggle: () => _onTaskToggled(task, taskProvider),
              onTap: () => _showTaskDetails(context, task, taskProvider),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(TaskFilter filter) {
    final Map<TaskFilter, Map<String, dynamic>> emptyStates = {
      TaskFilter.today: {
        'icon': Icons.check_circle_outline,
        'title': 'No tasks for today',
        'subtitle': 'You\'re all caught up!',
      },
      TaskFilter.upcoming: {
        'icon': Icons.calendar_today_outlined,
        'title': 'No upcoming tasks',
        'subtitle': 'Add a task to see it here',
      },
      TaskFilter.completed: {
        'icon': Icons.check_circle,
        'title': 'No completed tasks',
        'subtitle': 'Complete some tasks to see them here',
      },
    };

    final state = emptyStates[filter]!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              [
            Icon(state['icon'] as IconData, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              state['title'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state['subtitle'] as String,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            if (filter == TaskFilter.today) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    _tabController.animateTo(1), // Switch to upcoming tab
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Upcoming Tasks'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onTaskToggled(Task task, TaskProvider taskProvider) {
    taskProvider.toggleTaskStatus(task.id);
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? dueDate = DateTime.now();
    TaskPriority priority = TaskPriority.medium;
    String? category;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  [
                const Text(
                  'Add New Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(dueDate!)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => dueDate = date);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Priority'),
                  trailing: DropdownButton<TaskPriority>(
                    value: priority,
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem<TaskPriority>(
                        value: p,
                        child: Text(
                          p.toString().split('.').last,
                          style: TextStyle(
                            color: _getPriorityColor(p),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => priority = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isNotEmpty) {
                      Navigator.pop(context, {
                        'title': titleController.text.trim(),
                        'description': descriptionController.text.trim(),
                        'dueDate': dueDate,
                        'priority': priority,
                        'category': category,
                      });
                    }
                  },
                  child: const Text('Add Task'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      if (!context.mounted) return;
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      // NOTE: The error "missing required argument userId" in tasks_screen.dart line 285 comes from here
      // Task constructor requires userId.
      // We need to get the current user ID from AuthProvider or assume TaskProvider handles it if we pass a dummy or let the provider override it.
      // However, the `addTask` method in `TaskProvider` (updated in previous turn) expects `Task` object.
      // And it overrides `userId` inside `addTask` using `_userId` from provider state.
      // So we can pass an empty string for userId here, and it will be overwritten.

      final task = Task(
        userId: '', // Will be overwritten by TaskProvider
        title: result['title'] as String,
        description: result['description'] as String?,
        dueDate: result['dueDate'] as DateTime,
        priority: result['priority'] as TaskPriority,
        category: result['category'] as String?,
      );
      await taskProvider.addTask(task);
    }
  }

  Future<void> _showTaskDetails(
    BuildContext context,
    Task task,
    TaskProvider taskProvider,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                [
              Row(
                children:
                    [
                  Checkbox(
                    value: task.status == TaskStatus.completed,
                    onChanged: (value) {
                      taskProvider.toggleTaskStatus(task.id);
                      Navigator.pop(context);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      taskProvider.deleteTask(task.id);
                      Navigator.pop(context);
                    },
                    color: Colors.red,
                  ),
                ],
              ),
              if (task.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                Text(
                  task.description!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                icon: Icons.calendar_today,
                label: 'Due Date',
                value: DateFormat('MMM d, yyyy').format(task.dueDate),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                icon: Icons.flag_outlined,
                label: 'Priority',
                value: task.priority.toString().split('.').last,
                valueColor: _getPriorityColor(task.priority),
              ),
              if (task.category != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  icon: Icons.label_outline,
                  label: 'Category',
                  value: task.category!,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Edit task
                  Navigator.pop(context);
                  _showEditTaskDialog(context, task, taskProvider);
                },
                child: const Text('Edit Task'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    Task task,
    TaskProvider taskProvider,
  ) async {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    DateTime dueDate = task.dueDate;
    TaskPriority priority = task.priority;
    String? category = task.category;

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  [
                const Text(
                  'Edit Task',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(dueDate)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => dueDate = date);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Priority'),
                  trailing: DropdownButton<TaskPriority>(
                    value: priority,
                    items: TaskPriority.values.map((p) {
                      return DropdownMenuItem<TaskPriority>(
                        value: p,
                        child: Text(
                          p.toString().split('.').last,
                          style: TextStyle(
                            color: _getPriorityColor(p),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => priority = value);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children:
                      [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isNotEmpty) {
                            Navigator.pop(context, {
                              'title': titleController.text.trim(),
                              'description':
                                  descriptionController.text.trim().isNotEmpty
                                      ? descriptionController.text.trim()
                                      : null,
                              'dueDate': dueDate,
                              'priority': priority,
                              'category': category,
                            });
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      final updatedTask = task.copyWith(
        title: result['title'] as String,
        description: result['description'] as String?,
        dueDate: result['dueDate'] as DateTime,
        priority: result['priority'] as TaskPriority,
        category: result['category'] as String?,
      );
      await taskProvider.updateTask(updatedTask);
    }
  }

  Widget _buildDetailRow(
    BuildContext context,
    {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children:
          [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }
}

enum TaskFilter { today, upcoming, completed }

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children:
                [
              Checkbox(
                value: isCompleted,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted ? Colors.grey : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children:
                          [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, hh:mm a').format(task.dueDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(
                                  task.priority,
                                ).withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _getPriorityColor(
                                    task.priority,
                                  ).withAlpha((0.3 * 255).toInt()),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            task.priority.toString().split('.').last,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getPriorityColor(task.priority),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }
}