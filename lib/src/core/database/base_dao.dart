import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

/// Base DAO class that provides common database operations
abstract class BaseDao<T> {
  final DatabaseService _dbService = DatabaseService();

  /// The name of the table this DAO operates on
  String get tableName;

  /// Converts a Map from the database to a model object
  T fromMap(Map<String, dynamic> map);

  /// Converts a model object to a Map for database storage
  Map<String, dynamic> toMap(T item);

  /// Gets the database instance
  Database get database => _dbService.db;

  /// Inserts an item into the database
  Future<int> insert(T item, {ConflictAlgorithm? conflictAlgorithm}) async {
    final db = database;
    try {
      return await db.insert(
        tableName,
        toMap(item),
        conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert item: $e');
    }
  }

  /// Inserts multiple items in a single transaction
  Future<void> insertAll(
    List<T> items, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = database;
    final batch = db.batch();

    for (var item in items) {
      batch.insert(
        tableName,
        toMap(item),
        conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
      );
    }

    try {
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Failed to insert items: $e');
    }
  }

  /// Updates an item in the database
  Future<int> update(T item, String id) async {
    final db = database;
    try {
      return await db.update(
        tableName,
        toMap(item),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  /// Deletes an item from the database
  Future<int> delete(String id) async {
    final db = database;
    try {
      return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  /// Gets an item by its ID
  Future<T?> getById(String id) async {
    final db = database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get item by id: $e');
    }
  }

  /// Gets all items from the table
  Future<List<T>> getAll() async {
    final db = database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      return List.generate(maps.length, (i) => fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to get all items: $e');
    }
  }

  /// Executes a raw query and returns the result as a list of items
  Future<List<T>> rawQuery(String query, [List<dynamic>? arguments]) async {
    final db = database;
    try {
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        query,
        arguments,
      );
      return List.generate(maps.length, (i) => fromMap(maps[i]));
    } catch (e) {
      throw Exception('Failed to execute raw query: $e');
    }
  }

  /// Executes a count query
  Future<int> count({String? where, List<dynamic>? whereArgs}) async {
    final db = database;
    try {
      final result = await db.query(
        tableName,
        columns: ['COUNT(*) as count'],
        where: where,
        whereArgs: whereArgs,
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Failed to count items: $e');
    }
  }

  /// Executes a custom query and returns the raw result
  Future<List<Map<String, dynamic>>> customQuery({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = database;
    try {
      return await db.query(
        tableName,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw Exception('Failed to execute custom query: $e');
    }
  }

  /// Executes a batch of operations in a single transaction
  Future<void> executeInTransaction(
    Future<void> Function(Batch) operations,
  ) async {
    final db = database;
    final batch = db.batch();

    try {
      await operations(batch);
      await batch.commit(noResult: true);
    } catch (e) {
      throw Exception('Transaction failed: $e');
    }
  }

  /// Closes the database connection
  Future<void> close() async {
    final db = database;
    await db.close();
  }
}

/// Extension on Database to add transaction support
extension DatabaseExtension on Database {
  /// Executes a function in a transaction and returns its result
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    final db = this;
    try {
      await db.execute('BEGIN IMMEDIATE');
      final result = await action();
      await db.execute('COMMIT');
      return result;
    } catch (e) {
      await db.execute('ROLLBACK');
      rethrow;
    }
  }
}
