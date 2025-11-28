import 'package:habit_tracker/src/core/di/injection.dart';
import 'package:habit_tracker/src/core/database/database_service.dart';
import 'package:logger/logger.dart';

/// Initializes the application
class AppInitializer {
  static final _logger = Logger();
  
  /// Initializes all app dependencies and services
  static Future<void> initialize() async {
    try {
      _logger.i('🚀 Initializing ZenFlow app...');
      
      // Initialize database
      _logger.i('📊 Initializing database...');
      await DatabaseService.register();
      _logger.i('✅ Database initialized successfully');
      
      // Configure dependency injection
      _logger.i('🔧 Configuring dependency injection...');
      await configureDependencies();
      _logger.i('✅ Dependency injection configured');
      
      // Initialize other services here
      // await AnalyticsService.initialize();
      // await NotificationService.initialize();
      // etc.
      
      _logger.i('🎉 App initialization completed successfully!');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Failed to initialize app', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Cleans up resources when the app is shutting down
  static Future<void> cleanup() async {
    try {
      _logger.i('🧹 Cleaning up app resources...');
      
      // Close database connection
      final dbService = getIt<DatabaseService>();
      await dbService.close();
      _logger.i('✅ Database connection closed');
      
      // Clean up other services here
      
      _logger.i('✅ App cleanup completed');
      
    } catch (e, stackTrace) {
      _logger.e('❌ Error during cleanup', error: e, stackTrace: stackTrace);
    }
  }
}
