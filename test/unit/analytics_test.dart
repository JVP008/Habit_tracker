import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:habit_tracker/src/core/analytics/analytics_service.dart';
import 'package:habit_tracker/src/core/database/database_service.dart';

@GenerateMocks([DatabaseService, Database])
import 'analytics_test.mocks.dart';

void main() {
  late MockDatabaseService mockDbService;
  late MockDatabase mockDb;
  late AnalyticsService analyticsService;

  setUp(() {
    mockDbService = MockDatabaseService();
    mockDb = MockDatabase();
    
    // Setup default DB behavior
    when(mockDbService.db).thenReturn(mockDb);
    when(mockDb.path).thenReturn('test.db');
    
    analyticsService = AnalyticsService(dbService: mockDbService);
  });

  group('AnalyticsService Tests', () {
    const userId = 'test_user_123';

    test('getUserAnalytics returns empty analytics when no data exists', () async {
      // Mock empty responses for all queries
      when(mockDb.query('habits')).thenAnswer((_) async => []);
      
      // Note: specific mocks for where clauses are needed if the service uses them
      when(mockDb.query(
        'habits', 
        where: anyNamed('where'), 
        whereArgs: anyNamed('whereArgs')
      )).thenAnswer((_) async => []);

      when(mockDb.query(
        'habit_completions', 
        where: anyNamed('where'), 
        whereArgs: anyNamed('whereArgs')
      )).thenAnswer((_) async => []);

      when(mockDb.query(
        'challenge_participants', 
        where: anyNamed('where'), 
        whereArgs: anyNamed('whereArgs')
      )).thenAnswer((_) async => []);

      when(mockDb.query(
        'challenge_progress', 
        where: anyNamed('where'), 
        whereArgs: anyNamed('whereArgs')
      )).thenAnswer((_) async => []);

      when(mockDb.query(
        'journal_entries', 
        where: anyNamed('where'), 
        whereArgs: anyNamed('whereArgs'), 
        orderBy: anyNamed('orderBy')
      )).thenAnswer((_) async => []);

      when(mockDb.query(
        'mood_entries', 
        where: anyNamed('where'), 
        whereArgs: anyNamed('whereArgs'), 
        orderBy: anyNamed('orderBy')
      )).thenAnswer((_) async => []);

      when(mockDb.query(
        'users', 
        where: anyNamed('where'), 
        whereArgs: anyNamed('whereArgs'), 
        limit: anyNamed('limit')
      )).thenAnswer((_) async => []);

      // Act
      final result = await analyticsService.getUserAnalytics(userId, testDb: mockDb);

      // Assert
      expect(result.userId, userId);
      expect(result.habitAnalytics.totalHabits, 0);
      expect(result.challengeAnalytics.totalChallenges, 0);
      expect(result.journalAnalytics.totalEntries, 0);
      expect(result.moodAnalytics.totalEntries, 0);
      expect(result.streakAnalytics.currentStreak, 0);
      expect(result.insights, isEmpty);
    });
  });
}
