import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'database_config.dart';

class DatabaseOptimization {
  /// Applies all database optimizations
  static Future<void> optimizeDatabase(Database db) async {
    try {
      debugPrint('💡 ⚙️ Configuring database for optimal performance');
      
      // 1. Enable WAL mode for better concurrency
      await db.rawQuery('PRAGMA journal_mode=WAL');

      // 2. Set synchronous to NORMAL for better performance (safe with WAL)
      await db.execute('PRAGMA synchronous=NORMAL');

      // 3. Increase cache size (in pages, 1 page = ~4KB with default page_size)
      await db.execute('PRAGMA cache_size=-20000'); // ~80MB cache

      // 4. Set page size to match OS (typically 4KB)
      await db.execute('PRAGMA page_size=4096');

      // 5. Enable memory-mapped I/O
      await db.execute('PRAGMA mmap_size=268435456'); // 256MB

      // 6. Set busy timeout to 5 seconds
      await db.execute('PRAGMA busy_timeout=5000');

      // 7. Set temp_store to MEMORY for temporary tables and indices
      await db.execute('PRAGMA temp_store=MEMORY');

      // 8. Set journal size limit
      await db.rawQuery('PRAGMA journal_size_limit=1048576'); // 1MB

      // 9. Optimize the database (optional, run occasionally)
      await db.execute('PRAGMA optimize');

      debugPrint('✅ Performance optimizations applied successfully');
    } catch (e) {
      debugPrint(
        '⛔ ! Could not apply all performance optimizations: $e',
      );
    }
  }

  /// Public alias for creating indexes (used by migrations)
  static Future<void> createIndexes(Database db) => _createIndexes(db);

  /// Creates necessary indexes for optimal query performance
  static Future<void> _createIndexes(Database db) async {
    // Users table indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_users_email 
      ON ${DatabaseConfig.tableUsers}(email)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_users_created_at 
      ON ${DatabaseConfig.tableUsers}(created_at)
    ''');

    // Challenges table indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_challenges_created_by 
      ON ${DatabaseConfig.tableChallenges}(created_by)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_challenges_dates 
      ON ${DatabaseConfig.tableChallenges}(start_date, end_date)
    ''');

    // Challenge Participants indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_participants_challenge 
      ON ${DatabaseConfig.tableChallengeParticipants}(challenge_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_participants_user 
      ON ${DatabaseConfig.tableChallengeParticipants}(user_id)
    ''');

    // Challenge Progress indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_progress_challenge_user 
      ON ${DatabaseConfig.tableChallengeProgress}(challenge_id, user_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_progress_date 
      ON ${DatabaseConfig.tableChallengeProgress}(date)
    ''');

    // Friend Requests indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_friend_requests_sender 
      ON ${DatabaseConfig.tableFriendRequests}(from_user_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_friend_requests_receiver 
      ON ${DatabaseConfig.tableFriendRequests}(to_user_id)
    ''');

    // Journal Entries indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_journal_user_date 
      ON ${DatabaseConfig.tableJournalEntries}(user_id, created_at)
    ''');

    // Mood Entries indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_mood_user_date 
      ON ${DatabaseConfig.tableMoodEntries}(user_id, created_at)
    ''');

    // Habits indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_habits_user 
      ON ${DatabaseConfig.tableHabits}(user_id)
    ''');

    // Habit Completions indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_habit_completions 
      ON ${DatabaseConfig.tableHabitCompletions}(habit_id, date)
    ''');
  }

  /// Analyzes the database to optimize query plans
  static Future<void> analyzeDatabase(Database db) async {
    try {
      await db.execute('ANALYZE');
      debugPrint('✅ Database analysis completed');
    } catch (e) {
      debugPrint('⚠️ Could not analyze database: $e');
    }
  }

  /// Rebuilds all indexes for better performance
  static Future<void> rebuildIndexes(Database db) async {
    try {
      await db.execute('REINDEX');
      debugPrint('✅ Database indexes rebuilt');
    } catch (e) {
      debugPrint('⚠️ Could not rebuild indexes: $e');
    }
  }

  /// Compacts the database file
  static Future<void> compactDatabase(Database db) async {
    try {
      await db.execute('VACUUM');
      debugPrint('✅ Database compaction completed');
    } catch (e) {
      debugPrint('⚠️ Could not compact database: $e');
    }
  }

  /// Gets database statistics
  static Future<Map<String, dynamic>> getDatabaseStats(Database db) async {
    final stats = <String, dynamic>{};

    try {
      // Get table row counts
      final tables = [
        DatabaseConfig.tableUsers,
        DatabaseConfig.tableChallenges,
        DatabaseConfig.tableChallengeParticipants,
        DatabaseConfig.tableChallengeProgress,
        DatabaseConfig.tableFriendRequests,
        DatabaseConfig.tableFriends,
        DatabaseConfig.tableJournalEntries,
        DatabaseConfig.tableMoodEntries,
        DatabaseConfig.tableHabits,
        DatabaseConfig.tableHabitCompletions,
      ];

      for (final table in tables) {
        try {
          final result = await db.rawQuery(
            'SELECT COUNT(*) as count FROM $table',
          );
          stats[table] = result.first['count'];
        } catch (_) {
          stats[table] = 'Not available';
        }
      }

      // Get database size (best-effort)
      try {
        final dynamic dynDb = db;
        final String? path = dynDb.path;
        if (path != null && path.isNotEmpty) {
          final file = File(path);
          if (await file.exists()) {
            stats['database_size'] = await file.length();
          }
        }
      } catch (_) {
        // ignore if path is unavailable in this platform/context
      }

      // Get index information
      final indexes = await db.rawQuery('''
        SELECT name, sql FROM sqlite_master 
        WHERE type = 'index' AND name NOT LIKE 'sqlite_%'
      ''');
      stats['indexes'] = indexes;

      // Get table information
      final tablesInfo = await db.rawQuery('''
        SELECT name, sql FROM sqlite_master 
        WHERE type = 'table' AND name NOT LIKE 'sqlite_%'
      ''');
      stats['tables'] = tablesInfo;

      return stats;
    } catch (e) {
      debugPrint('⚠️ Could not get database stats: $e');
      return {'error': e.toString()};
    }
  }
}
