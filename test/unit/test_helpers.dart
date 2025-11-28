
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:habit_tracker/src/core/di/injection.dart';
import 'package:habit_tracker/src/features/auth/data/models/user_model.dart';
import 'package:habit_tracker/src/features/habits/data/models/habit_model.dart' as habit_tracker;
import 'package:habit_tracker/src/features/challenges/data/models/challenge_model.dart';

/// Test helper utilities
class TestHelpers {
  static Database? _testDatabase;
  static bool _isInitialized = false;

  /// Initialize test environment
  static Future<void> setupTestEnvironment() async {
    if (_isInitialized) return;

    // Ensure bindings are initialized
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      },
    );

    // Initialize FFI
    sqfliteFfiInit();
    
    // Set database factory to FFI
    databaseFactory = databaseFactoryFfi;

    // Close any existing database connection
    if (_testDatabase != null && _testDatabase!.isOpen) {
      await _testDatabase!.close();
    }

    // Initialize test database with a unique name to prevent locks across test groups
    // if running in parallel, though dart test runs files in isolation usually.
    // Using singleInstance: false for in-memory might help if we were using named in-memory.
    // But here we use :memory: which is private.
    _testDatabase = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Create test tables
        await _createTestTables(db);
      },
    );

    // Initialize dependency injection for testing
    await getIt.reset();
    await configureDependencies();

    _isInitialized = true;
  }

  /// Create test database tables
  static Future<void> _createTestTables(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        email TEXT,
        photo_url TEXT,
        bio TEXT,
        streak_days INTEGER DEFAULT 0,
        completed_challenges INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_active INTEGER,
        settings TEXT,
        is_premium INTEGER DEFAULT 0,
        subscription_expiry INTEGER
      )
    ''');

    // Challenges table
    await db.execute('''
      CREATE TABLE challenges (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        created_by TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        goal_type TEXT NOT NULL,
        goal_target INTEGER NOT NULL,
        goal_unit TEXT NOT NULL,
        image_url TEXT,
        is_public INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        max_participants INTEGER,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Challenge Participants table
    await db.execute('''
      CREATE TABLE challenge_participants (
        challenge_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        joined_at INTEGER NOT NULL,
        PRIMARY KEY (challenge_id, user_id),
        FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Challenge Progress table
    await db.execute('''
      CREATE TABLE challenge_progress (
        id TEXT PRIMARY KEY,
        challenge_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        value REAL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (challenge_id) REFERENCES challenges(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(challenge_id, user_id, date)
      )
    ''');

    // Friend Requests table
    await db.execute('''
      CREATE TABLE friend_requests (
        id TEXT PRIMARY KEY,
        from_user_id TEXT NOT NULL,
        to_user_id TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(from_user_id, to_user_id)
      )
    ''');

    // Friends table
    await db.execute('''
      CREATE TABLE friends (
        user_id TEXT NOT NULL,
        friend_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        PRIMARY KEY (user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (friend_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Journal Entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood_score REAL,
        mood_label TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        tags TEXT,
        is_private INTEGER DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Mood Entries table
    await db.execute('''
      CREATE TABLE mood_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        mood_score REAL NOT NULL,
        mood_label TEXT,
        notes TEXT,
        energy INTEGER,
        stress INTEGER,
        sleep INTEGER,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT,
        frequency TEXT,
        target_days TEXT,
        reminder_time TEXT,
        tags TEXT,
        streak_days INTEGER DEFAULT 0,
        total_completions INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        last_completed_at INTEGER,
        is_active INTEGER DEFAULT 1,
        target_count INTEGER DEFAULT 1,
        unit TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Habit Completions table
    await db.execute('''
      CREATE TABLE habit_completions (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        date TEXT NOT NULL,
        value REAL NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        UNIQUE(habit_id, user_id, date)
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 1,
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_habits_user_id ON habits(user_id)');
    await db.execute('CREATE INDEX idx_challenges_created_by ON challenges(created_by)');
  }

  /// Get test database
  static Database get testDatabase {
    if (_testDatabase == null) {
      throw Exception('Test database not initialized. Call setupTestEnvironment() first.');
    }
    return _testDatabase!;
  }

  /// Clean up test environment
  static Future<void> cleanupTestEnvironment() async {
    if (_testDatabase != null) {
      if (_testDatabase!.isOpen) {
        await _testDatabase!.close();
      }
      _testDatabase = null;
    }
    // Reset getIt to avoid pollution
    await getIt.reset();
    
    // We allow re-initialization
    _isInitialized = false;
  }

  /// Create test user
  static UserModel createTestUser({
    String? id,
    String displayName = 'Test User',
    String email = 'test@example.com',
    String? photoUrl,
    String? bio,
    int streakDays = 0,
    int completedChallenges = 0,
    bool isPremium = false,
  }) {
    return UserModel(
      id: id ?? 'test_user_${DateTime.now().millisecondsSinceEpoch}',
      displayName: displayName,
      email: email,
      photoUrl: photoUrl,
      bio: bio,
      streakDays: streakDays,
      completedChallenges: completedChallenges,
      isPremium: isPremium,
    );
  }

  static int _habitIdCounter = 0;
  /// Create test habit
  static habit_tracker.HabitModel createTestHabit({
    String? id,
    String userId = 'test_user',
    String title = 'Test Habit',
    String description = '',
    String category = 'Health',
    String frequency = 'daily',
    List<int> targetDays = const [1, 2, 3, 4, 5, 6, 7],
    habit_tracker.HabitTimeOfDay reminderTime = const habit_tracker.HabitTimeOfDay(hour: 8, minute: 0),
    List<String> tags = const [],
    int streakDays = 0,
    int totalCompletions = 0,
    bool isActive = true,
    int? targetCount,
    String? unit,
  }) {
    return habit_tracker.HabitModel(
      id: id ?? 'test_habit_${_habitIdCounter++}',
      userId: userId,
      title: title,
      description: description,
      category: category,
      frequency: frequency,
      targetDays: targetDays,
      reminderTime: reminderTime,
      tags: tags,
      streakDays: streakDays,
      totalCompletions: totalCompletions,
      isActive: isActive,
      targetCount: targetCount,
      unit: unit,
    );
  }

  static int _challengeIdCounter = 0;
  /// Create test challenge
  static ChallengeModel createTestChallenge({
    String? id,
    String title = 'Test Challenge',
    String description = '',
    String createdBy = 'test_user',
    DateTime? startDate,
    DateTime? endDate,
    String goalType = 'duration',
    int goalTarget = 30,
    String goalUnit = 'days',
    String? imageUrl,
    bool isPublic = true,
    bool isActive = true,
    int? maxParticipants,
  }) {
    final now = DateTime.now();
    return ChallengeModel(
      id: id ?? 'test_challenge_${_challengeIdCounter++}',
      title: title,
      description: description,
      createdBy: createdBy,
      startDate: startDate ?? now,
      endDate: endDate ?? now.add(const Duration(days: 30)),
      goalType: goalType,
      goalTarget: goalTarget,
      goalUnit: goalUnit,
      imageUrl: imageUrl,
      isPublic: isPublic,
      isActive: isActive,
      maxParticipants: maxParticipants,
    );
  }

  /// Insert test data into database
  static Future<void> insertTestData({
    List<UserModel>? users,
    List<habit_tracker.HabitModel>? habits,
    List<ChallengeModel>? challenges,
  }) async {
    final db = testDatabase;

    // Insert users
    if (users != null) {
      for (final user in users) {
        await db.insert('users', {
          'id': user.id,
          'display_name': user.displayName,
          'email': user.email,
          'photo_url': user.photoUrl,
          'bio': user.bio,
          'streak_days': user.streakDays,
          'completed_challenges': user.completedChallenges,
          'created_at': user.createdAt.millisecondsSinceEpoch,
          'updated_at': user.updatedAt.millisecondsSinceEpoch,
          'last_active': user.lastActive?.millisecondsSinceEpoch,
          'settings': user.settings?.toString(),
          'is_premium': user.isPremium ? 1 : 0,
          'subscription_expiry': user.subscriptionExpiry?.millisecondsSinceEpoch,
        });
      }
    }

    // Insert habits
    if (habits != null) {
      for (final habit in habits) {
        await db.insert('habits', {
          'id': habit.id,
          'user_id': habit.userId,
          'title': habit.title,
          'description': habit.description,
          'category': habit.category,
          'frequency': habit.frequency,
          'target_days': habit.targetDays.join(','),
          'reminder_time': habit.reminderTime.formatted,
          'tags': habit.tags.join(','),
          'streak_days': habit.streakDays,
          'total_completions': habit.totalCompletions,
          'created_at': habit.createdAt.millisecondsSinceEpoch,
          'updated_at': habit.updatedAt.millisecondsSinceEpoch,
          'last_completed_at': habit.lastCompletedAt?.millisecondsSinceEpoch,
          'is_active': habit.isActive ? 1 : 0,
          'target_count': habit.targetCount,
          'unit': habit.unit,
        });
      }
    }

    // Insert challenges
    if (challenges != null) {
      for (final challenge in challenges) {
        await db.insert('challenges', {
          'id': challenge.id,
          'title': challenge.title,
          'description': challenge.description,
          'created_by': challenge.createdBy,
          'start_date': challenge.startDate.millisecondsSinceEpoch,
          'end_date': challenge.endDate.millisecondsSinceEpoch,
          'goal_type': challenge.goalType,
          'goal_target': challenge.goalTarget,
          'goal_unit': challenge.goalUnit,
          'image_url': challenge.imageUrl,
          'is_public': challenge.isPublic ? 1 : 0,
          'is_active': challenge.isActive ? 1 : 0,
          'max_participants': challenge.maxParticipants,
          'created_at': challenge.createdAt.millisecondsSinceEpoch,
          'updated_at': challenge.updatedAt.millisecondsSinceEpoch,
        });
      }
    }
  }

  /// Clear all test data
  static Future<void> clearTestData() async {
    final db = testDatabase;
    
    await db.delete('habits');
    await db.delete('challenges');
    await db.delete('users');
  }

  /// Assert database contains expected data
  static Future<void> assertDatabaseContains({
    int? userCount,
    int? habitCount,
    int? challengeCount,
  }) async {
    final db = testDatabase;

    if (userCount != null) {
      final users = await db.query('users');
      assert(users.length == userCount, 'Expected $userCount users, found ${users.length}');
    }

    if (habitCount != null) {
      final habits = await db.query('habits');
      assert(habits.length == habitCount, 'Expected $habitCount habits, found ${habits.length}');
    }
  }

  /// Wait for async operations
  static Future<void> waitForAsync([int milliseconds = 100]) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Generate random test data
  static List<UserModel> generateTestUsers(int count) {
    return List.generate(count, (index) => createTestUser(
      id: 'test_user_$index',
      displayName: 'Test User $index',
      email: 'test$index@example.com',
      streakDays: index * 2,
      completedChallenges: index,
    ));
  }

  static List<habit_tracker.HabitModel> generateTestHabits(int count, {String userId = 'test_user', int startIndex = 0}) {
    final categories = ['Health', 'Fitness', 'Learning', 'Productivity', 'Mindfulness'];
    final frequencies = ['daily', 'weekly', 'monthly'];
    
    return List.generate(count, (index) => createTestHabit(
      id: 'test_habit_${startIndex + index}',
      userId: userId,
      title: 'Test Habit ${startIndex + index}',
      category: categories[(startIndex + index) % categories.length],
      frequency: frequencies[(startIndex + index) % frequencies.length],
      streakDays: index,
      totalCompletions: index * 3,
    ));
  }

  static List<ChallengeModel> generateTestChallenges(int count, {String createdBy = 'test_user'}) {
    final goalTypes = ['duration', 'frequency', 'distance', 'points'];
    
    return List.generate(count, (index) => createTestChallenge(
      id: 'test_challenge_$index',
      title: 'Test Challenge $index',
      createdBy: createdBy,
      goalType: goalTypes[index % goalTypes.length],
      goalTarget: (index + 1) * 10,
    ));
  }
}

/// Custom test exception
class TestException implements Exception {
  final String message;
  
  const TestException(this.message);
  
  @override
  String toString() => 'TestException: $message';
}
