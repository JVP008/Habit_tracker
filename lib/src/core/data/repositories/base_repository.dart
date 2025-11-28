import 'package:dartz/dartz.dart';
import 'package:habit_tracker/src/core/error/failures.dart';
import 'package:habit_tracker/src/core/data/models/base_model.dart';

/// A base repository interface that defines common CRUD operations
abstract class BaseRepository<T extends BaseModel<T>, ID> {
  /// Creates a new entity
  Future<Either<Failure, T>> create(T entity);
  
  /// Retrieves an entity by its ID
  Future<Either<Failure, T?>> findById(ID id);
  
  /// Retrieves all entities, optionally filtered
  Future<Either<Failure, List<T>>> findAll({
    Map<String, dynamic>? filters,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = false,
  });
  
  /// Updates an existing entity
  Future<Either<Failure, T>> update(T entity);
  
  /// Deletes an entity by its ID
  Future<Either<Failure, void>> delete(ID id);
  
  /// Checks if an entity with the given ID exists
  Future<Either<Failure, bool>> exists(ID id);
  
  /// Counts the number of entities, optionally filtered
  Future<Either<Failure, int>> count({Map<String, dynamic>? filters});
}

/// A repository that supports pagination
abstract class PaginatedRepository<T extends BaseModel<T>, ID> 
    implements BaseRepository<T, ID> {
  
  /// Retrieves a paginated list of entities
  Future<Either<Failure, PaginatedResponse<T>>> findPaginated({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
  });
}

/// A repository that supports search
abstract class SearchableRepository<T extends BaseModel<T>, ID, Query> {
  /// Searches for entities matching the given query
  Future<Either<Failure, List<T>>> search(Query query, {
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = false,
  });
  
  /// Searches for entities with pagination
  Future<Either<Failure, PaginatedResponse<T>>> searchPaginated(
    Query query, {
    int page = 1,
    int limit = 20,
    String? orderBy,
    bool descending = false,
  });
}

/// A repository that supports caching
abstract class CachedRepository<T extends BaseModel<T>, ID> {
  /// Gets an entity from the cache
  Future<Either<Failure, T?>> getFromCache(ID id);
  
  /// Caches an entity
  Future<Either<Failure, void>> cache(T entity);
  
  /// Removes an entity from the cache
  Future<Either<Failure, void>> removeFromCache(ID id);
  
  /// Clears the entire cache
  Future<Either<Failure, void>> clearCache();
}

/// A repository that supports offline-first functionality
typedef OnlineDataSource<T> = Future<T> Function();
typedef OfflineDataSource<T> = Future<T> Function();

abstract class OfflineFirstRepository<T extends BaseModel<T>, ID> 
    implements BaseRepository<T, ID> {
  
  /// Fetches data from the online source and updates the local cache
  Future<Either<Failure, T>> fetchAndCache(ID id);
  
  /// Fetches all data from the online source and updates the local cache
  Future<Either<Failure, List<T>>> fetchAllAndCache({
    Map<String, dynamic>? filters,
    int? limit,
    int? offset,
    String? orderBy,
    bool descending = false,
  });
  
  /// Synchronizes local data with the remote server
  Future<Either<Failure, void>> synchronize();
}
