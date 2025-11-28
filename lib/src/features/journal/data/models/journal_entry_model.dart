import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:habit_tracker/src/core/data/models/base_model.dart';

part 'journal_entry_model.g.dart';

@JsonSerializable()
class JournalEntryModel extends BaseModel<JournalEntryModel> with EquatableMixin {
  @override
  final String? id;
  final String userId;
  final String title;
  final String content;
  final List<String> tags;
  final String mood;
  final int rating; // 1-5 scale
  final List<String> attachments;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntryModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.tags = const [],
    required this.mood,
    this.rating = 3,
    this.attachments = const [],
    this.isPrivate = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$JournalEntryModelToJson(this);

  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    List<String>? tags,
    String? mood,
    int? rating,
    List<String>? attachments,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      rating: rating ?? this.rating,
      attachments: attachments ?? this.attachments,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  JournalEntryModel copyWithJson(Map<String, dynamic> json) {
    return copyWith(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      tags: (json['tags'] as List?)?.cast<String>(),
      mood: json['mood'] as String?,
      rating: json['rating'] as int?,
      attachments: (json['attachments'] as List?)?.cast<String>(),
      isPrivate: json['is_private'] as bool?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        tags,
        mood,
        rating,
        attachments,
        isPrivate,
        createdAt,
        updatedAt,
      ];

  bool get isEmpty => id?.isEmpty ?? true;
  bool get isNotEmpty => !isEmpty;
  
  int get wordCount => content.split(' ').length;
  int get characterCount => content.length;
  
  JournalEntryModel updateContent(String newContent) {
    return copyWith(
      content: newContent,
      updatedAt: DateTime.now(),
    );
  }
  
  JournalEntryModel addTag(String tag) {
    final newTags = List<String>.from(tags);
    if (!newTags.contains(tag)) {
      newTags.add(tag);
    }
    return copyWith(
      tags: newTags,
      updatedAt: DateTime.now(),
    );
  }
  
  JournalEntryModel removeTag(String tag) {
    final newTags = List<String>.from(tags);
    newTags.remove(tag);
    return copyWith(
      tags: newTags,
      updatedAt: DateTime.now(),
    );
  }
}
