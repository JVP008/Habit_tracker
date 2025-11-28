import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

enum TaskStatus { todo, inProgress, completed }

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  Task({
    String? id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate.millisecondsSinceEpoch,
      'priority': priority.index,
      'is_completed': status == TaskStatus.completed ? 1 : 0,
      'category': category,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      // We don't store completedAt in DB explicitly in this schema version based on migration, 
      // but we can infer it or ignore it. Ideally schema should have it.
      // For now, let's strictly follow the migration schema I just added:
      // id, user_id, title, description, due_date, is_completed, priority, category, created_at, updated_at
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final isCompleted = (map['is_completed'] as int) == 1;
    return Task(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date']),
      priority: TaskPriority.values[map['priority']],
      status: isCompleted ? TaskStatus.completed : TaskStatus.todo,
      category: map['category'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      completedAt: isCompleted ? DateTime.fromMillisecondsSinceEpoch(map['updated_at']) : null, 
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  bool get isCompleted => status == TaskStatus.completed;
}