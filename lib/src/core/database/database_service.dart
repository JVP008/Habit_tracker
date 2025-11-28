import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:logger/logger.dart';

import 'database_config.dart';
import 'database_optimization.dart';
import 'migration.dart';

/// A service class that manages the database connection and provides access to DAOs
class DatabaseService {
  final DatabaseConfig _config = DatabaseConfig();
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
  
  static final _lock = Lock();
  Database? _database;
  bool _isInitialized = false;
  bool _isInitializing = false;
  
  // Singleton instance
  static final DatabaseService _instance = DatabaseService._internal();
  
  /// Get the singleton instance
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();

  /// Initializes the database connection with retry logic
  Future<void> initialize({int maxRetries = 3}) async {
    if (_isInitialized) return;
    if (_isInitializing) return;
    
    _isInitializing = true;
    
    try {
      // Use a lock to prevent multiple initializations
      await _lock.synchronized(() async {
        if (_isInitialized) return;
        
        int attempt = 0;
        while (attempt < maxRetries) {
          try {
            _logger.i('🔌 Initializing database (attempt ${attempt + 1}/$maxRetries)');
            
            // Get database instance (this will trigger creation/migration if needed)
            _database = await _config.database;
            
            // Enable foreign key support
            await _database?.rawQuery('PRAGMA foreign_keys = ON');
            
            // Run database optimizations
            await _configureForPerformance();
            
            // Run database analysis and optimization
            await _runMaintenance();
            
            _isInitialized = true;
            _logger.i('✅ Database initialized successfully');
            return;
            
          } catch (e, stackTrace) {
            attempt++;
            _logger.e(
              '❌ Database initialization failed (attempt $attempt/$maxRetries)',
              error: e,
              stackTrace: stackTrace,
            );
            
            if (attempt >= maxRetries) {
              _isInitializing = false;
              rethrow;
            }
            
            // Exponential backoff
            await Future.delayed(Duration(seconds: 1 * attempt));
          }
        }
      });
    } finally {
      _isInitializing = false;
    }
  }

  /// Configures the database for optimal performance
  Future<void> _configureForPerformance() async {
    if (_database == null) return;

    try {
      _logger.i('⚙️ Configuring database for optimal performance');
      
      // Apply all performance optimizations
      await DatabaseOptimization.optimizeDatabase(_database!);
      
      // Additional performance tuning
      await _database!.rawQuery('PRAGMA temp_store = MEMORY');
      await _database!.rawQuery('PRAGMA journal_size_limit = 1048576'); // 1MB
      
      _logger.i('✅ Database performance optimized');
    } catch (e, stackTrace) {
      _logger.e(
        '⚠️ Could not apply all performance optimizations',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Runs database maintenance tasks
  Future<void> _runMaintenance() async {
    if (_database == null) return;
    
    try {
      _logger.i('🔧 Running database maintenance');
      
      // Rebuild indexes for better performance
      await DatabaseOptimization.rebuildIndexes(_database!);
      
      // Analyze the database to optimize query plans
      await DatabaseOptimization.analyzeDatabase(_database!);
      
      // Get database statistics
      final stats = await DatabaseOptimization.getDatabaseStats(_database!);
      _logger.i('📊 Database statistics: $stats');
      
      _logger.i('✅ Database maintenance completed');
    } catch (e, stackTrace) {
      _logger.e(
        '⚠️ Error during database maintenance',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the database instance with auto-initialization if needed
  Future<Database> get database async {
    if (!_isInitialized && !_isInitializing) {
      await initialize();
    }
    
    if (_database == null) {
      throw StateError('Database is not initialized. Call initialize() first.');
    }
    
    return _database!;
  }
  
  /// Gets the database instance synchronously (must be called after initialization)
  Database get db {
    if (_database == null) {
      throw StateError('Database is not initialized. Call initialize() first.');
    }
    return _database!;
  }
  
  /// Sets the database instance (used for tests)
  set db(Database database) {
    _database = database;
    _isInitialized = true;
  }

  /// Closes the database connection
  Future<void> close() async {
    await _lock.synchronized(() async {
      if (_database != null) {
        try {
          _logger.i('🔌 Closing database connection');
          await _database!.close();
          _logger.i('✅ Database connection closed');
        } catch (e, stackTrace) {
          _logger.e(
            '❌ Error closing database connection',
            error: e,
            stackTrace: stackTrace,
          );
          rethrow;
        } finally {
          _database = null;
          _isInitialized = false;
          _isInitializing = false;
        }
      }
    });
  }

  /// Deletes the database file (for testing or reset)
  Future<void> deleteDatabase() async {
    await _lock.synchronized(() async {
      try {
        _logger.w('⚠️ Deleting database file');
        
        // Close the database if it's open
        if (_database != null) {
          await _database!.close();
        }
        
        // Get the database path and delete the file
        final db = await _config.database;
        final path = db.path;
        await db.close();
        
        final dbFile = File(path);
        if (await dbFile.exists()) {
          await dbFile.delete();
          _logger.i('✅ Database file deleted: $path');
        }
        
        // Reset state
        _database = null;
        _isInitialized = false;
        _isInitializing = false;
        
        // Reinitialize the database
        await initialize();
        
      } catch (e, stackTrace) {
        _logger.e(
          '❌ Failed to delete database',
          error: e,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    });
  }

  /// Registers the database service with the service locator
  static Future<DatabaseService> register() async {
    try {
      // Initialize the database service
      await _instance.initialize();
      
      // Register with GetIt
      if (!GetIt.I.isRegistered<DatabaseService>()) {
        GetIt.I.registerSingleton<DatabaseService>(
          _instance,
          dispose: (service) => service.close(),
        );
        
        _instance._logger.i('✅ DatabaseService registered with GetIt');
      }
      
      return _instance;
      
    } catch (e, stackTrace) {
      _instance._logger.e(
        '❌ Failed to register DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

/// Extension to easily access the database service from anywhere
extension DatabaseServiceExtension on DatabaseService {
  /// Executes a function in a transaction with retry logic
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    int maxRetries = 3,
    Duration? retryDelay,
  }) async {
    int attempt = 0;
    
    while (true) {
      final txn = await database;
      
      try {
        return await txn.transaction<T>((txn) async {
          return await action(txn);
        });
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          _logger.e('❌ Transaction failed after $maxRetries attempts', error: e);
          rethrow;
        }
        
        // Exponential backoff with jitter
        final delay = (retryDelay ?? const Duration(milliseconds: 100)) * (1 << (attempt - 1));
        final jitter = Duration(milliseconds: (delay.inMilliseconds * 0.2 * (0.5 + Random().nextDouble())).toInt());
        
        _logger.w(
          '🔄 Retrying transaction (attempt ${attempt + 1}/$maxRetries) after ${(delay + jitter).inMilliseconds}ms',
          error: e,
        );
        
        await Future.delayed(delay + jitter);
      }
    }
  }
  
  /// Executes a batch of operations in a single transaction with retry logic
  Future<void> batch(
    Future<void> Function(Batch batch) operations, {
    int maxRetries = 3,
    bool noResult = true,
  }) async {
    int attempt = 0;
    
    while (true) {
      final db = await database;
      final batch = db.batch();
      
      try {
        await operations(batch);
        await batch.commit(noResult: noResult);
        return;
      } catch (e) {
        
        attempt++;
        if (attempt >= maxRetries) {
          _logger.e('❌ Batch operation failed after $maxRetries attempts', error: e);
          rethrow;
        }
        
        // Exponential backoff with jitter
        final delay = Duration(milliseconds: 100 * (1 << (attempt - 1)));
        final jitter = Duration(milliseconds: (delay.inMilliseconds * 0.2 * (0.5 + Random().nextDouble())).toInt());
        
        _logger.w(
          '🔄 Retrying batch operation (attempt ${attempt + 1}/$maxRetries) after ${(delay + jitter).inMilliseconds}ms',
          error: e,
        );
        
        await Future.delayed(delay + jitter);
      }
    }
  }
  
  /// Runs a migration script with proper error handling and logging
  Future<void> migrate(int fromVersion, int toVersion, Migration migration) async {
    final db = await database;

    try {
      _logger.i('🔄 Running migration from v$fromVersion to v$toVersion');
      await db.transaction((txn) async {
        await migration.migrate(db, fromVersion, toVersion);
      });
      _logger.i('✅ Migration from v$fromVersion to v$toVersion completed successfully');
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Migration from v$fromVersion to v$toVersion failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Gets database statistics
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    return await DatabaseOptimization.getDatabaseStats(db);
  }
  
  /// Rebuilds all indexes
  Future<void> rebuildIndexes() async {
    final db = await database;
    await DatabaseOptimization.rebuildIndexes(db);
  }
  
  /// Analyzes the database to optimize query plans
  Future<void> analyze() async {
    final db = await database;
    await DatabaseOptimization.analyzeDatabase(db);
  }
  
  /// Compacts the database file
  Future<void> compact() async {
    final db = await database;
    await DatabaseOptimization.compactDatabase(db);
  }
}

/// A simple dependency injection container
final class ServiceLocator {
  static final GetIt _locator = GetIt.instance;
  
  /// Gets an instance of the specified type
  static T get<T extends Object>() => _locator.get<T>();
  
  /// Registers a singleton instance
  static void registerSingleton<T extends Object>(
    T instance, {
    FutureOr<void> Function(T)? dispose,
  }) {
    _locator.registerSingleton<T>(
      instance,
      dispose: dispose != null ? (i) async => await dispose(i) : null,
    );
  }
  
  /// Registers a lazy singleton
  static void registerLazySingleton<T extends Object>(
    T Function() factory, {
    FutureOr<void> Function(T)? dispose,
  }) {
    _locator.registerLazySingleton<T>(
      factory,
      dispose: dispose != null ? (i) async => await dispose(i) : null,
    );
  }
  
  /// Registers a factory
  static void registerFactory<T extends Object>(T Function() factory) {
    _locator.registerFactory<T>(factory);
  }
  
  /// Unregisters a type
  static Future<void> unregister<T extends Object>([T? instance]) async {
    if (instance != null) {
      await _locator.unregister(instance: instance);
    } else {
      await _locator.unregister<T>();
    }
  }
  
  /// Resets the locator
  static Future<void> reset() async {
    await _locator.reset();
  }
}
