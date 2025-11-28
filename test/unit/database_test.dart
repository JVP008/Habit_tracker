import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/src/core/database/database_service.dart';
import 'package:habit_tracker/src/features/habits/data/models/habit_model.dart' as habit_tracker;
import './test_helpers.dart';

void main() {
  group('Database Tests', () {
    late DatabaseService databaseService;

    setUpAll(() async {
      // Initialize test environment
      await TestHelpers.setupTestEnvironment();
    });

    tearDownAll(() async {
      // Clean up test environment
      await TestHelpers.cleanupTestEnvironment();
    });

    setUp(() async {
      // Clear test data before each test
      await TestHelpers.clearTestData();
      
      // Create new database service instance
      databaseService = DatabaseService();
      // Override the database with test database
      databaseService.db = TestHelpers.testDatabase;
    });

    group('User Operations', () {
      test('should create and retrieve user', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser(
          displayName: 'John Doe',
          email: 'john@example.com',
        );

        // Act
        await databaseService.db.insert('users', {
          'id': testUser.id,
          'display_name': testUser.displayName,
          'email': testUser.email,
          'streak_days': testUser.streakDays,
          'completed_challenges': testUser.completedChallenges,
          'created_at': testUser.createdAt.millisecondsSinceEpoch,
          'updated_at': testUser.updatedAt.millisecondsSinceEpoch,
        });

        final result = await databaseService.db.query(
          'users',
          where: 'id = ?',
          whereArgs: [testUser.id],
        );

        // Assert
        expect(result.length, 1);
        expect(result.first['display_name'], 'John Doe');
        expect(result.first['email'], 'john@example.com');
      });

      test('should update user information', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();
        await TestHelpers.insertTestData(users: [testUser]);

        // Act
        await databaseService.db.update(
          'users',
          {
            'display_name': 'Jane Doe',
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [testUser.id],
        );

        final result = await databaseService.db.query(
          'users',
          where: 'id = ?',
          whereArgs: [testUser.id],
        );

        // Assert
        expect(result.length, 1);
        expect(result.first['display_name'], 'Jane Doe');
      });

      test('should delete user', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();
        await TestHelpers.insertTestData(users: [testUser]);

        // Act
        await databaseService.db.delete(
          'users',
          where: 'id = ?',
          whereArgs: [testUser.id],
        );

        final result = await databaseService.db.query(
          'users',
          where: 'id = ?',
          whereArgs: [testUser.id],
        );

        // Assert
        expect(result.length, 0);
      });

      test('should enforce unique email constraint', () async {
        // Arrange
        final user1 = TestHelpers.createTestUser(id: 'unique_user_1', email: 'test@example.com');
        final user2 = TestHelpers.createTestUser(id: 'unique_user_2', email: 'test@example.com');
        
        await TestHelpers.insertTestData(users: [user1]);

        // Act & Assert
        try {
          await TestHelpers.insertTestData(users: [user2]);
          fail('Should have thrown exception due to duplicate email');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });
    });

    group('Habit Operations', () {
      test('should create and retrieve habit', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();
        final testHabit = TestHelpers.createTestHabit(
          userId: testUser.id!,
          title: 'Morning Meditation',
          category: 'Mindfulness',
        );

        await TestHelpers.insertTestData(users: [testUser]);

        // Act
        await databaseService.db.insert('habits', {
          'id': testHabit.id,
          'user_id': testHabit.userId,
          'title': testHabit.title,
          'category': testHabit.category,
          'frequency': testHabit.frequency,
          'target_days': testHabit.targetDays.join(','),
          'streak_days': testHabit.streakDays,
          'total_completions': testHabit.totalCompletions,
          'created_at': testHabit.createdAt.millisecondsSinceEpoch,
          'updated_at': testHabit.updatedAt.millisecondsSinceEpoch,
          'is_active': testHabit.isActive ? 1 : 0,
        });

        final result = await databaseService.db.query(
          'habits',
          where: 'id = ?',
          whereArgs: [testHabit.id],
        );

        // Assert
        expect(result.length, 1);
        expect(result.first['title'], 'Morning Meditation');
        expect(result.first['category'], 'Mindfulness');
        expect(result.first['user_id'], testUser.id);
      });

      test('should update habit streak', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();
        final testHabit = TestHelpers.createTestHabit(
          userId: testUser.id!,
          streakDays: 5,
        );

        await TestHelpers.insertTestData(users: [testUser]);
        await TestHelpers.insertTestData(habits: [testHabit]);

        // Act
        await databaseService.db.update(
          'habits',
          {
            'streak_days': 6,
            'total_completions': 25,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [testHabit.id],
        );

        final result = await databaseService.db.query(
          'habits',
          where: 'id = ?',
          whereArgs: [testHabit.id],
        );

        // Assert
        expect(result.length, 1);
        expect(result.first['streak_days'], 6);
        expect(result.first['total_completions'], 25);
      });

      test('should filter habits by user', () async {
        // Arrange
        final user1 = TestHelpers.createTestUser(id: 'user1');
        final user2 = TestHelpers.createTestUser(id: 'user2');
        final habit1 = TestHelpers.createTestHabit(id: 'h1', userId: 'user1', title: 'Habit 1');
        final habit2 = TestHelpers.createTestHabit(id: 'h2', userId: 'user1', title: 'Habit 2');
        final habit3 = TestHelpers.createTestHabit(id: 'h3', userId: 'user2', title: 'Habit 3');

        await TestHelpers.insertTestData(users: [user1, user2]);
        await TestHelpers.insertTestData(habits: [habit1, habit2, habit3]);

        // Act
        final user1Habits = await databaseService.db.query(
          'habits',
          where: 'user_id = ?',
          whereArgs: ['user1'],
        );

        final user2Habits = await databaseService.db.query(
          'habits',
          where: 'user_id = ?',
          whereArgs: ['user2'],
        );

        // Assert
        expect(user1Habits.length, 2);
        expect(user2Habits.length, 1);
        expect(user1Habits.map((h) => h['title']).contains('Habit 1'), isTrue);
        expect(user1Habits.map((h) => h['title']).contains('Habit 2'), isTrue);
        expect(user2Habits.map((h) => h['title']).contains('Habit 3'), isTrue);
      });
    });

    group('Challenge Operations', () {
      test('should create and retrieve challenge', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();
        final testChallenge = TestHelpers.createTestChallenge(
          createdBy: testUser.id!,
          title: '30-Day Meditation',
          goalTarget: 30,
        );

        await TestHelpers.insertTestData(users: [testUser]);

        // Act
        await databaseService.db.insert('challenges', {
          'id': testChallenge.id,
          'title': testChallenge.title,
          'created_by': testChallenge.createdBy,
          'start_date': testChallenge.startDate.millisecondsSinceEpoch,
          'end_date': testChallenge.endDate.millisecondsSinceEpoch,
          'goal_type': testChallenge.goalType,
          'goal_target': testChallenge.goalTarget,
          'goal_unit': testChallenge.goalUnit,
          'is_public': testChallenge.isPublic ? 1 : 0,
          'is_active': testChallenge.isActive ? 1 : 0,
          'created_at': testChallenge.createdAt.millisecondsSinceEpoch,
          'updated_at': testChallenge.updatedAt.millisecondsSinceEpoch,
        });

        final result = await databaseService.db.query(
          'challenges',
          where: 'id = ?',
          whereArgs: [testChallenge.id],
        );

        // Assert
        expect(result.length, 1);
        expect(result.first['title'], '30-Day Meditation');
        expect(result.first['goal_target'], 30);
        expect(result.first['created_by'], testUser.id);
      });

      test('should filter public challenges', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();
        final publicChallenge = TestHelpers.createTestChallenge(
          createdBy: testUser.id!,
          title: 'Public Challenge',
          isPublic: true,
        );
        final privateChallenge = TestHelpers.createTestChallenge(
          createdBy: testUser.id!,
          title: 'Private Challenge',
          isPublic: false,
        );

        await TestHelpers.insertTestData(users: [testUser]);
        await TestHelpers.insertTestData(challenges: [publicChallenge, privateChallenge]);

        // Act
        final publicChallenges = await databaseService.db.query(
          'challenges',
          where: 'is_public = ?',
          whereArgs: [1],
        );

        final privateChallenges = await databaseService.db.query(
          'challenges',
          where: 'is_public = ?',
          whereArgs: [0],
        );

        // Assert
        expect(publicChallenges.length, 1);
        expect(privateChallenges.length, 1);
        expect(publicChallenges.first['title'], 'Public Challenge');
        expect(privateChallenges.first['title'], 'Private Challenge');
      });
    });

    group('Database Constraints', () {
      test('should enforce foreign key constraints', () async {
        // Act & Assert
        expect(
          () async => await databaseService.db.insert('habits', {
            'id': 'orphan_habit',
            'user_id': 'nonexistent_user',
            'title': 'Orphan Habit',
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          }),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle database transactions', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();
        final testHabit = TestHelpers.createTestHabit(userId: testUser.id!);

        // Act
        await databaseService.db.transaction((txn) async {
          await txn.insert('users', {
            'id': testUser.id,
            'display_name': testUser.displayName,
            'email': testUser.email,
            'created_at': testUser.createdAt.millisecondsSinceEpoch,
            'updated_at': testUser.updatedAt.millisecondsSinceEpoch,
          });

          await txn.insert('habits', {
            'id': testHabit.id,
            'user_id': testHabit.userId,
            'title': testHabit.title,
            'created_at': testHabit.createdAt.millisecondsSinceEpoch,
            'updated_at': testHabit.updatedAt.millisecondsSinceEpoch,
          });
        });

        // Assert
        await TestHelpers.assertDatabaseContains(userCount: 1, habitCount: 1);
      });

      test('should rollback transaction on error', () async {
        // Arrange
        final testUser = TestHelpers.createTestUser();

        // Act & Assert
        expect(
          () async => await databaseService.db.transaction((txn) async {
            await txn.insert('users', {
              'id': testUser.id,
              'display_name': testUser.displayName,
              'email': testUser.email,
              'created_at': testUser.createdAt.millisecondsSinceEpoch,
              'updated_at': testUser.updatedAt.millisecondsSinceEpoch,
            });

            // This should cause an error
            await txn.insert('users', {
              'id': testUser.id, // Duplicate ID
              'display_name': 'Duplicate',
              'email': 'duplicate@example.com',
              'created_at': DateTime.now().millisecondsSinceEpoch,
              'updated_at': DateTime.now().millisecondsSinceEpoch,
            });
          }),
          throwsA(isA<Exception>()),
        );

        // Assert - transaction should be rolled back
        await TestHelpers.assertDatabaseContains(userCount: 0);
      });
    });

    group('Performance Tests', () {
      test('should handle bulk insert operations efficiently', () async {
        // Arrange
        final users = TestHelpers.generateTestUsers(100);
        final habits = <habit_tracker.HabitModel>[];
        final challenges = TestHelpers.generateTestChallenges(50, createdBy: users.first.id!); // Ensure createdBy exists

        // Distribute habits among users
        for (int i = 0; i < users.length; i++) {
          habits.addAll(TestHelpers.generateTestHabits(5, userId: users[i].id!, startIndex: i * 5));
        }

        final stopwatch = Stopwatch()..start();

        // Act
        await TestHelpers.insertTestData(
          users: users,
          habits: habits,
          challenges: challenges,
        );

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete in under 5 seconds
        await TestHelpers.assertDatabaseContains(
          userCount: 100,
          habitCount: 500,
          challengeCount: 50,
        );
      });

      test('should handle complex queries efficiently', () async {
        // Arrange
        final users = TestHelpers.generateTestUsers(50);
        final habits = <habit_tracker.HabitModel>[];
        
        // Create habits linked to users
        for (int i = 0; i < users.length; i++) {
          habits.addAll(TestHelpers.generateTestHabits(4, userId: users[i].id!, startIndex: i * 4));
        }
        
        await TestHelpers.insertTestData(users: users, habits: habits);

        final stopwatch = Stopwatch()..start();

        // Act
        final results = await databaseService.db.rawQuery('''
          SELECT u.display_name, COUNT(h.id) as habit_count
          FROM users u
          LEFT JOIN habits h ON u.id = h.user_id
          WHERE h.is_active = 1
          GROUP BY u.id
          ORDER BY habit_count DESC
          LIMIT 10
        ''');

        stopwatch.stop();

        // Assert
        expect(results.length, 10);
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should complete in under 1 second
      });
    });
  });
}
