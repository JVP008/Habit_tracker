import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'database_config.dart';
import 'database_optimization.dart';
import 'migration.dart';

class DatabaseMigrations {
  /// Gets all database migrations
  static List<Migration> getMigrations() {
    return [
      // Initial database schema (v1)
      Migration(1, 1, (Database db, int fromVersion, int toVersion) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableUsers} (
            id TEXT PRIMARY KEY,
            display_name TEXT NOT NULL,
            email TEXT,
            photo_url TEXT,
            bio TEXT,
            streak_days INTEGER DEFAULT 0,
            completed_challenges INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableChallenges} (
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
            FOREIGN KEY (created_by) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableChallengeParticipants} (
            challenge_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            joined_at INTEGER NOT NULL,
            PRIMARY KEY (challenge_id, user_id),
            FOREIGN KEY (challenge_id) REFERENCES ${DatabaseConfig.tableChallenges}(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableChallengeProgress} (
            id TEXT PRIMARY KEY,
            challenge_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            date TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            value REAL,
            notes TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (challenge_id) REFERENCES ${DatabaseConfig.tableChallenges}(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE,
            UNIQUE(challenge_id, user_id, date)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableFriendRequests} (
            id TEXT PRIMARY KEY,
            from_user_id TEXT NOT NULL,
            to_user_id TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (from_user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE,
            FOREIGN KEY (to_user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE,
            UNIQUE(from_user_id, to_user_id)
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableFriends} (
            user_id TEXT NOT NULL,
            friend_id TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            PRIMARY KEY (user_id, friend_id),
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE,
            FOREIGN KEY (friend_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableJournalEntries} (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            mood_score REAL,
            mood_label TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableMoodEntries} (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            mood_score REAL NOT NULL,
            mood_label TEXT,
            notes TEXT,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableHabits} (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            color INTEGER NOT NULL,
            icon_code_point INTEGER NOT NULL,
            frequency TEXT NOT NULL,
            goal_value INTEGER NOT NULL,
            goal_unit TEXT NOT NULL,
            is_archived INTEGER NOT NULL DEFAULT 0,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableHabitCompletions} (
            id TEXT PRIMARY KEY,
            habit_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            date TEXT NOT NULL,
            value REAL NOT NULL,
            notes TEXT,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (habit_id) REFERENCES ${DatabaseConfig.tableHabits}(id) ON DELETE CASCADE,
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE,
            UNIQUE(habit_id, user_id, date)
          )
        ''');

        // Create indexes for better performance
        await DatabaseOptimization.createIndexes(db);
      }),
      // Migration from v1 to v2: Adding new columns to tableUsers and tableChallenges
      Migration(1, 2, (Database db, int fromVersion, int toVersion) async {
        await db.execute('''
            ALTER TABLE ${DatabaseConfig.tableUsers} ADD COLUMN last_active INTEGER;
          ''');
        await db.execute('''
            ALTER TABLE ${DatabaseConfig.tableUsers} ADD COLUMN settings TEXT;
          ''');
        await db.execute('''
            ALTER TABLE ${DatabaseConfig.tableUsers} ADD COLUMN is_premium INTEGER DEFAULT 0;
          ''');
        await db.execute('''
            ALTER TABLE ${DatabaseConfig.tableUsers} ADD COLUMN subscription_expiry INTEGER;
          ''');
        await db.execute('''
            ALTER TABLE ${DatabaseConfig.tableChallenges} ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;
          ''');
        await db.execute('''
            ALTER TABLE ${DatabaseConfig.tableChallenges} ADD COLUMN max_participants INTEGER;
          ''');
      }),
      // Migration from v2 to v3: Add tasks table
      Migration(2, 3, (Database db, int fromVersion, int toVersion) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS ${DatabaseConfig.tableTasks} (
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
            FOREIGN KEY (user_id) REFERENCES ${DatabaseConfig.tableUsers}(id) ON DELETE CASCADE
          )
        ''');
        // Add index for faster queries
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON ${DatabaseConfig.tableTasks}(user_id)',
        );
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON ${DatabaseConfig.tableTasks}(due_date)',
        );
      }),
      // Migration from v3 to v4: Add tags and is_private to journal_entries
      Migration(3, 4, (Database db, int fromVersion, int toVersion) async {
        await db.execute('''
          ALTER TABLE ${DatabaseConfig.tableJournalEntries} ADD COLUMN tags TEXT;
        ''');
        await db.execute('''
          ALTER TABLE ${DatabaseConfig.tableJournalEntries} ADD COLUMN is_private INTEGER DEFAULT 1;
        ''');
      }),
    ];
  }

  /// Runs all pending migrations
  static Future<void> runMigrations(Database db, int currentVersion) async {
    final migrations = getMigrations();

    for (final migration in migrations) {
      if (migration.startVersion >= currentVersion) {
        try {
          await migration.migrate(
            db,
            migration.startVersion,
            migration.endVersion,
          );
          debugPrint(
            '✅ Applied migration from v${migration.startVersion} to v${migration.endVersion}',
          );
        } catch (e) {
          debugPrint(
            '❌ Failed to apply migration from v${migration.startVersion} to v${migration.endVersion}: $e',
          );
          rethrow;
        }
      }
    }

    // Optimize the database after migrations
    await DatabaseOptimization.optimizeDatabase(db);
  }
}
