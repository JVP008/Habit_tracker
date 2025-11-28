import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'database_optimization.dart';
import 'database_migrations.dart';
import 'migration.dart';

class DatabaseConfig {
  static const String _databaseName = 'zenflow_database.db';
  static const int _databaseVersion = 4; 

  // Table Names
  static const String tableUsers = 'users';
  static const String tableChallenges = 'challenges';
  static const String tableChallengeParticipants = 'challenge_participants';
  static const String tableChallengeProgress = 'challenge_progress';
  static const String tableFriendRequests = 'friend_requests';
  static const String tableFriends = 'friends';
  static const String tableJournalEntries = 'journal_entries';
  static const String tableMoodEntries = 'mood_entries';
  static const String tableHabits = 'habits';
  static const String tableHabitCompletions = 'habit_completions';
  static const String tableTasks = 'tasks';

  // Get all migrations from DatabaseMigrations
  static List<Migration> get _migrations => DatabaseMigrations.getMigrations();

  static final DatabaseConfig _instance = DatabaseConfig._internal();
  static Database? _database;

  factory DatabaseConfig() => _instance;

  DatabaseConfig._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      return _initDatabaseWeb();
    } else {
      return _initDatabaseNative();
    }
  }

  Future<Database> _initDatabaseWeb() async {
    return openDatabase(
      inMemoryDatabasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        await DatabaseMigrations.runMigrations(db, oldVersion);
      },
    );
  }

  Future<Database> _initDatabaseNative() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      // Enable for debugging
      debugPrint('📁 Database path: $path');

      // Check if database needs to be copied from assets (for initial setup)
      await _checkAndCopyDatabase(path);

      // Open database with migrations
      final db = await openDatabaseWithMigration(
        path,
        _databaseVersion,
        _migrations,
        onCreate: _onCreate,
      );

      // Run any pending migrations
      final currentVersion = await db.getVersion();
      if (currentVersion < _databaseVersion) {
        await DatabaseMigrations.runMigrations(db, currentVersion);
        await db.setVersion(_databaseVersion);
      }

      // Optimize the database
      await DatabaseOptimization.optimizeDatabase(db);

      return db;
    } catch (e) {
      debugPrint('❌ Failed to initialize database: $e');
      rethrow;
    }
  }

  /// Checks if database exists in assets and copies it if needed
  Future<void> _checkAndCopyDatabase(String path) async {
    final dbFile = File(path);
    final dbDir = dbFile.parent;

    // Create directory if it doesn't exist
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    // Check if database exists, if not, create it
    if (!await dbFile.exists()) {
      // You can copy a pre-populated database from assets here if needed
      // await _copyFromAssets(dbFile);

      // For now, just create an empty database
      await openDatabase(path);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // The initial database schema and indexes are now handled by Migration(1,1)
    // in DatabaseMigrations. This method will only be called when the database
    // is first created, and at that point, Migration(1,1) will be run if the
    // database version is less than or equal to 1. Therefore, no explicit
    // table or index creation is needed here.
  }

  // Helper method to convert DateTime to milliseconds since epoch
  static int dateToInt(DateTime date) => date.millisecondsSinceEpoch;

  // Helper method to convert milliseconds since epoch to DateTime
  static DateTime intToDate(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds);
}
