import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:habit_tracker/src/core/data/models/base_model.dart';
import 'package:habit_tracker/src/core/error/exceptions.dart';
import 'package:habit_tracker/src/core/error/failures.dart';
import 'package:dartz/dartz.dart';

/// A base DAO (Data Access Object) that provides common CRUD operations
abstract class BaseDao<T extends BaseModel<T>, ID> {
  /// The name of the database table
  String get tableName;

  /// The name of the primary key column
  String get primaryKey;

  /// Converts a database row to a model
  T fromMap(Map<String, dynamic> map);

  /// Converts a model to a database row
  Map<String, dynamic> toMap(T model);

  /// The database connection
  final Database db;

  BaseDao(this.db);

  /// Creates a new record in the database
  Future<T> create(T model) async {
    try {
      final id = await db.insert(
        tableName,
        toMap(model),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Return the created model with the generated ID
      return model.copyWithJson({primaryKey: id});
    } catch (e) {
      throw DatabaseException(message: 'Failed to insert $T: $e');
    }
  }

  /// Finds a record by its ID
  Future<T?> findById(ID id) async {
    try {
      final maps = await db.query(
        tableName,
        where: '$primaryKey = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException(message: 'Failed to find $T with ID $id: $e');
    }
  }

  /// Finds all records matching the given criteria
  Future<List<T>> findAll({
    Map<String, dynamic>? filters,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      final where = filters?.keys.map((key) => '$key = ?').join(' AND ');
      final whereArgs = filters?.values.toList();

      final result = await db.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        limit: limit,
        offset: offset,
        orderBy: orderBy != null
            ? '$orderBy ${descending ? 'DESC' : 'ASC'}'
            : null,
      );

      return result.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(message: 'Failed to find all $T: $e');
    }
  }

  /// Updates an existing record
  Future<T> update(T model) async {
    try {
      final id = model.id;
      if (id == null) {
        throw DatabaseException(message: 'Cannot update $T with null ID');
      }

      final count = await db.update(
        tableName,
        toMap(model),
        where: '$primaryKey = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw DatabaseException(
          message: 'Failed to update $T with ID $id: Record not found',
        );
      }

      return model;
    } catch (e) {
      throw DatabaseException(message: 'Failed to update $T: $e');
    }
  }

  /// Deletes a record by its ID
  Future<int> delete(ID id) async {
    try {
      return await db.delete(
        tableName,
        where: '$primaryKey = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException(message: 'Failed to delete $T with ID $id: $e');
    }
  }

  /// Counts the number of records matching the given criteria
  Future<int> count({Map<String, dynamic>? filters}) async {
    try {
      final where = filters?.keys.map((key) => '$key = ?').join(' AND ');
      final whereArgs = filters?.values.toList();

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName${where != null ? ' WHERE $where' : ''}',
        whereArgs,
      );

      return result.first['count'] as int;
    } catch (e) {
      throw DatabaseException(message: 'Failed to count $T: $e');
    }
  }

  /// Executes a raw query and returns the results
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      throw DatabaseException(message: 'Failed to execute raw query: $e');
    }
  }

  /// Executes a raw update/insert/delete query
  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    try {
      return await db.rawUpdate(sql, arguments);
    } catch (e) {
      throw DatabaseException(message: 'Failed to execute raw update: $e');
    }
  }

  /// Begins a database transaction
  Future<R> transaction<R>(Future<R> Function(Transaction txn) action) async {
    return await db.transaction<R>((txn) async {
      return await action(txn);
    });
  }

  /// Creates the database table
  Future<void> createTable() async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableName (
          ${buildTableDefinition()}
        )
      ''');

      // Create indexes
      await createIndexes();
    } catch (e) {
      throw DatabaseException(message: 'Failed to create table $tableName: $e');
    }
  }

  /// Builds the table definition (to be implemented by subclasses)
  String buildTableDefinition();

  /// Creates indexes on the table (can be overridden by subclasses)
  Future<void> createIndexes() async {
    // Default implementation does nothing
  }

  /// Drops the database table
  Future<void> dropTable() async {
    try {
      await db.execute('DROP TABLE IF EXISTS $tableName');
    } catch (e) {
      throw DatabaseException(message: 'Failed to drop table $tableName: $e');
    }
  }

  /// Handles database errors and converts them to appropriate failures
  Future<Either<Failure, R>> handleDatabaseErrors<R>(
    Future<R> Function() fn,
  ) async {
    try {
      final result = await fn();
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'An unexpected error occurred: $e'));
    }
  }
}
