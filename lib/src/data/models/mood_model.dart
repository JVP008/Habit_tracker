import 'package:uuid/uuid.dart';

enum MoodLevel {
  verySad,
  sad,
  neutral,
  happy,
  veryHappy,
}

class MoodEntry {
  final String id;
  final MoodLevel moodLevel;
  final String? note;
  final DateTime date;
  final Map<String, dynamic>? additionalData;

  MoodEntry({
    String? id,
    required this.moodLevel,
    this.note,
    DateTime? date,
    this.additionalData,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  MoodEntry copyWith({
    String? id,
    MoodLevel? moodLevel,
    String? note,
    DateTime? date,
    Map<String, dynamic>? additionalData,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      moodLevel: moodLevel ?? this.moodLevel,
      note: note ?? this.note,
      date: date ?? this.date,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moodLevel': moodLevel.index,
      'note': note,
      'date': date.toIso8601String(),
      'additionalData': additionalData,
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      moodLevel: MoodLevel.values[map['moodLevel']],
      note: map['note'],
      date: DateTime.parse(map['date']),
      additionalData: map['additionalData'],
    );
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, moodLevel: $moodLevel, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Extension to get emoji representation of mood
extension MoodLevelExtension on MoodLevel {
  String get emoji {
    switch (this) {
      case MoodLevel.verySad:
        return '😢';
      case MoodLevel.sad:
        return '😞';
      case MoodLevel.neutral:
        return '😐';
      case MoodLevel.happy:
        return '😊';
      case MoodLevel.veryHappy:
        return '😄';
    }
  }

  String get label {
    switch (this) {
      case MoodLevel.verySad:
        return 'Very Sad';
      case MoodLevel.sad:
        return 'Sad';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.happy:
        return 'Happy';
      case MoodLevel.veryHappy:
        return 'Very Happy';
    }
  }
}
