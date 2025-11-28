/// Base model class that all data models will extend
abstract class BaseModel<T> {
  const BaseModel();

  /// The unique identifier for the model
  String? get id;

  /// Converts the model to a JSON map
  Map<String, dynamic> toJson();

  /// Creates a copy of the model with the given fields replaced
  T copyWithJson(Map<String, dynamic> json);

  /// Creates a new instance of the model from a JSON map
  factory BaseModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }
}

/// A mixin that provides JSON serialization for models
mixin JsonSerializableMixin {
  /// Converts the model to a JSON map
  Map<String, dynamic> toJson();

  /// Creates a copy of the model with the given fields replaced
  T copyWithJson<T>(Map<String, dynamic> json);
}

/// A base class for paginated API responses
class PaginatedResponse<T> {
  /// The list of items in the current page
  final List<T> items;

  /// The total number of items across all pages
  final int totalCount;

  /// The current page number
  final int currentPage;

  /// The number of items per page
  final int pageSize;

  /// Whether there are more pages
  bool get hasNextPage => (currentPage * pageSize) < totalCount;

  /// The total number of pages
  int get totalPages => (totalCount / pageSize).ceil();

  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  /// Creates a paginated response from JSON
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items: (json['items'] as List).map((item) => fromJsonT(item)).toList(),
      totalCount: json['totalCount'] as int,
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  /// Converts the paginated response to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map((item) => toJsonT(item)).toList(),
      'totalCount': totalCount,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }

  /// Creates a copy of the paginated response with the given fields replaced
  PaginatedResponse<T> copyWith({
    List<T>? items,
    int? totalCount,
    int? currentPage,
    int? pageSize,
  }) {
    return PaginatedResponse<T>(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
