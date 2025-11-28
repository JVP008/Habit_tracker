import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final double? moodScore; // -1.0 to 1.0
  final List<String>? tags;
  final String? voiceNotePath;

  JournalEntry({
    String? id,
    required this.title,
    required this.content,
    DateTime? date,
    this.moodScore,
    this.tags,
    this.voiceNotePath,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date = date ?? DateTime.now();

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'moodScore': moodScore,
      'tags': tags,
      'voiceNotePath': voiceNotePath,
    };
  }

  // Create from map
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      moodScore: map['moodScore'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      voiceNotePath: map['voiceNotePath'],
    );
  }

  // Copy with method for immutability
  JournalEntry copyWith({
    String? title,
    String? content,
    double? moodScore,
    List<String>? tags,
    String? voiceNotePath,
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date,
      moodScore: moodScore ?? this.moodScore,
      tags: tags ?? this.tags,
      voiceNotePath: voiceNotePath ?? this.voiceNotePath,
    );
  }

  // Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date); // Day name
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  // Get color based on mood score
  Color get moodColor {
    if (moodScore == null) return Colors.grey;
    if (moodScore! > 0.3) return Colors.green;
    if (moodScore! > 0) return Colors.lightGreen;
    if (moodScore! > -0.3) return Colors.orange;
    return Colors.red;
  }

  // Get mood emoji
  String get moodEmoji {
    if (moodScore == null) return '🤔';
    if (moodScore! > 0.6) return '😊';
    if (moodScore! > 0.3) return '🙂';
    if (moodScore! > 0) return '😐';
    if (moodScore! > -0.3) return '😕';
    return '😔';
  }
}
