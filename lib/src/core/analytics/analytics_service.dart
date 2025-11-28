import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:habit_tracker/src/core/database/database_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  
  factory AnalyticsService({DatabaseService? dbService}) {
    if (dbService != null) {
      return AnalyticsService._internal(dbService: dbService);
    }
    return _instance;
  }

  AnalyticsService._internal({DatabaseService? dbService}) 
      : _dbService = dbService ?? DatabaseService();

  final Logger _logger = Logger();
  final DatabaseService _dbService;

  /// Get comprehensive user analytics
  Future<UserAnalytics> getUserAnalytics(String userId, {Database? testDb}) async {
    try {
      final db = testDb ?? _dbService.db;
      _logger.d('Service using DB path: ${db.path}');

      // Get habit completion data
      final habitData = await _getHabitAnalytics(userId, db);

      // Get challenge participation data
      final challengeData = await _getChallengeAnalytics(userId, db);

      // Get journal analytics
      final journalData = await _getJournalAnalytics(userId, db);

      // Get mood analytics
      final moodData = await _getMoodAnalytics(userId, db);

      // Get streak data
      final streakData = await _getStreakAnalytics(userId, db);

      // Calculate overall insights
      final insights = _calculateInsights(
        habitData: habitData,
        challengeData: challengeData,
        journalData: journalData,
        moodData: moodData,
        streakData: streakData,
      );

      return UserAnalytics(
        userId: userId,
        habitAnalytics: habitData,
        challengeAnalytics: challengeData,
        journalAnalytics: journalData,
        moodAnalytics: moodData,
        streakAnalytics: streakData,
        insights: insights,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Failed to get user analytics: $e');
      rethrow;
    }
  }

  /// Get habit analytics
  Future<HabitAnalytics> _getHabitAnalytics(String userId, Database db) async {
    final allHabits = await db.query('habits');
    _logger.d('Total habits in DB: ${allHabits.length}');
    final habits = await db.query(
      'habits',
      // where: 'user_id = ?',
      // whereArgs: [userId],
    );
    _logger.d('Service found ${habits.length} habits for user $userId');

    final completions = await db.query(
      'habit_completions',
      where: 'habit_id IN (SELECT id FROM habits WHERE user_id = ?)',
      whereArgs: [userId],
    );

    final habitData = <String, HabitCompletionData>{};

    for (final habit in habits) {
      final habitId = habit['id'] as String;
      final habitCompletions = completions
          .where((c) => c['habit_id'] == habitId)
          .toList();

      // Calculate completion rate for last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentCompletions = habitCompletions.where((c) {
        final completedAt = DateTime.fromMillisecondsSinceEpoch(
          c['created_at'] as int,
        );
        return completedAt.isAfter(thirtyDaysAgo);
      }).toList();

      // Calculate best completion day
      final dayCompletions = <int, int>{};
      for (final completion in habitCompletions) {
        final day = DateTime.fromMillisecondsSinceEpoch(
          completion['created_at'] as int,
        ).weekday;
        dayCompletions[day] = (dayCompletions[day] ?? 0) + 1;
      }

      final bestDay = dayCompletions.entries.isNotEmpty
          ? dayCompletions.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
          : 1;

      habitData[habitId] = HabitCompletionData(
        habitId: habitId,
        habitTitle: habit['title'] as String,
        totalCompletions: habitCompletions.length,
        recentCompletions: recentCompletions.length,
        completionRate30Days: recentCompletions.length / 30.0,
        bestCompletionDay: bestDay,
        currentStreak: _calculateCurrentStreak(recentCompletions),
        longestStreak: _calculateLongestStreak(habitCompletions),
      );
    }

    // Calculate overall metrics
    final totalHabits = habits.length;
    final activeHabits = habits.where((h) => h['is_active'] == 1).length;
    final avgCompletionRate = habitData.values.isEmpty
        ? 0.0
        : habitData.values
                  .map((d) => d.completionRate30Days)
                  .reduce((a, b) => a + b) /
              habitData.length;

    return HabitAnalytics(
      totalHabits: totalHabits,
      activeHabits: activeHabits,
      averageCompletionRate: avgCompletionRate,
      habitData: habitData,
    );
  }

  /// Get challenge analytics
  Future<ChallengeAnalytics> _getChallengeAnalytics(
    String userId,
    Database db,
  ) async {
    final participations = await db.query(
      'challenge_participants',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final progress = await db.query(
      'challenge_progress',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    final completedChallenges = participations
        .where((p) => p['status'] == 'completed')
        .length;
    final activeChallenges = participations
        .where((p) => p['status'] == 'active')
        .length;
    final totalChallenges = participations.length;

    // Calculate success rate
    final successRate = totalChallenges > 0
        ? completedChallenges / totalChallenges
        : 0.0;

    // Calculate average completion percentage
    final avgCompletion = progress.isEmpty
        ? 0.0
        : progress
                  .map((p) => p['completion_percentage'] as int)
                  .reduce((a, b) => a + b) /
              progress.length;

    return ChallengeAnalytics(
      totalChallenges: totalChallenges,
      completedChallenges: completedChallenges,
      activeChallenges: activeChallenges,
      successRate: successRate,
      averageCompletionPercentage: avgCompletion,
    );
  }

  /// Get journal analytics
  Future<JournalAnalytics> _getJournalAnalytics(
    String userId,
    Database db,
  ) async {
    final entries = await db.query(
      'journal_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    final totalEntries = entries.length;
    final wordsPerEntry = entries
        .map((e) => (e['content'] as String).split(' ').length)
        .toList();
    final avgWordsPerEntry = wordsPerEntry.isEmpty
        ? 0.0
        : wordsPerEntry.reduce((a, b) => a + b) / wordsPerEntry.length;

    // Calculate writing frequency
    final thisMonth = DateTime.now();
    final monthEntries = entries.where((e) {
      final createdAt = DateTime.fromMillisecondsSinceEpoch(
        e['created_at'] as int,
      );
      return createdAt.year == thisMonth.year &&
          createdAt.month == thisMonth.month;
    }).length;

    // Most common tags
    final allTags = entries.expand((e) {
      final tagsStr = e['tags'] as String?;
      return tagsStr?.split(',') ?? <String>[];
    }).toList();

    final tagCounts = <String, int>{};
    for (final tag in allTags) {
      final cleanTag = tag.trim();
      if (cleanTag.isNotEmpty) {
        tagCounts[cleanTag] = (tagCounts[cleanTag] ?? 0) + 1;
      }
    }

    final mostCommonTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return JournalAnalytics(
      totalEntries: totalEntries,
      averageWordsPerEntry: avgWordsPerEntry,
      entriesThisMonth: monthEntries,
      mostCommonTags: mostCommonTags.take(10).map((e) => e.key).toList(),
      writingStreak: _calculateWritingStreak(entries),
    );
  }

  /// Get mood analytics
  Future<MoodAnalytics> _getMoodAnalytics(String userId, Database db) async {
    final entries = await db.query(
      'mood_entries',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    if (entries.isEmpty) {
      return MoodAnalytics(
        totalEntries: 0,
        averageMood: '',
        moodDistribution: {},
        averageEnergy: 0.0,
        averageStress: 0.0,
        averageSleep: 0.0,
        moodTrends: [],
      );
    }

    // Calculate mood distribution
    final moodCounts = <String, int>{};
    int totalEnergy = 0;
    int totalStress = 0;
    int totalSleep = 0;

    for (final entry in entries) {
      final mood = entry['mood_label'] as String;
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
      totalEnergy += entry['energy'] as int;
      totalStress += entry['stress'] as int;
      totalSleep += entry['sleep'] as int;
    }

    // Find most common mood
    final mostCommonMood = moodCounts.entries.isNotEmpty
        ? moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : '';

    // Calculate mood trends (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentEntries = entries.where((e) {
      final recordedAt = DateTime.fromMillisecondsSinceEpoch(
        e['created_at'] as int,
      );
      return recordedAt.isAfter(thirtyDaysAgo);
    }).toList();

    final moodTrends = <MoodTrend>[];
    for (int i = 0; i < min(30, recentEntries.length); i++) {
      final entry = recentEntries[i];
      moodTrends.add(
        MoodTrend(
          date: DateTime.fromMillisecondsSinceEpoch(
            entry['created_at'] as int,
          ),
          mood: entry['mood_label'] as String,
          energy: entry['energy'] as int,
          stress: entry['stress'] as int,
          sleep: entry['sleep'] as int,
        ),
      );
    }

    return MoodAnalytics(
      totalEntries: entries.length,
      averageMood: mostCommonMood,
      moodDistribution: moodCounts,
      averageEnergy: totalEnergy / entries.length,
      averageStress: totalStress / entries.length,
      averageSleep: totalSleep / entries.length,
      moodTrends: moodTrends,
    );
  }

  /// Get streak analytics
  Future<StreakAnalytics> _getStreakAnalytics(
    String userId,
    Database db,
  ) async {
    final user = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (user.isEmpty) {
      return const StreakAnalytics(
        currentStreak: 0,
        longestStreak: 0,
        totalStreakDays: 0,
        averageStreakLength: 0.0,
      );
    }

    final userData = user.first;
    final currentStreak = userData['streak_days'] as int? ?? 0;

    // Calculate other streak metrics (this would require more complex analysis)
    return StreakAnalytics(
      currentStreak: currentStreak,
      longestStreak: currentStreak, // Simplified - would need historical data
      totalStreakDays: currentStreak, // Simplified
      averageStreakLength: currentStreak.toDouble(), // Simplified
    );
  }

  /// Calculate insights from all data
  List<UserInsight> _calculateInsights({
    required HabitAnalytics habitData,
    required ChallengeAnalytics challengeData,
    required JournalAnalytics journalData,
    required MoodAnalytics moodData,
    required StreakAnalytics streakData,
  }) {
    final insights = <UserInsight>[];

    // Habit insights
    if (habitData.totalHabits > 0) {
      if (habitData.averageCompletionRate > 0.8) {
        insights.add(
          UserInsight(
            type: InsightType.positive,
            title: 'Great Habit Consistency!',
            description:
                'You\'re completing ${((habitData.averageCompletionRate * 100).toInt())}% of your habits. Keep it up!',
            actionable: false,
          ),
        );
      } else if (habitData.averageCompletionRate < 0.5) {
        insights.add(
          UserInsight(
            type: InsightType.improvement,
            title: 'Habit Consistency Needs Attention',
            description:
                'Your habit completion rate is ${((habitData.averageCompletionRate * 100).toInt())}%. Consider reducing the number of habits or adjusting reminders.',
            actionable: true,
          ),
        );
      }
    }

    // Mood insights
    if (moodData.totalEntries > 0) {
      if (moodData.averageStress > 7) {
        insights.add(
          UserInsight(
            type: InsightType.warning,
            title: 'High Stress Levels Detected',
            description:
                'Your average stress level is ${moodData.averageStress.toStringAsFixed(1)}/10. Consider stress management techniques.',
            actionable: true,
          ),
        );
      }

      if (moodData.averageSleep < 6) {
        insights.add(
          UserInsight(
            type: InsightType.warning,
            title: 'Sleep Quality Needs Improvement',
            description:
                'Your average sleep quality is ${moodData.averageSleep.toStringAsFixed(1)}/10. Better sleep could improve your overall wellbeing.',
            actionable: true,
          ),
        );
      }
    }

    // Challenge insights
    if (challengeData.successRate > 0.8) {
      insights.add(
        UserInsight(
          type: InsightType.positive,
          title: 'Challenge Champion!',
          description:
              'You complete ${(challengeData.successRate * 100).toInt()}% of challenges. You\'re very goal-oriented!',
          actionable: false,
        ),
      );
    }

    // Journal insights
    if (journalData.writingStreak > 7) {
      insights.add(
        UserInsight(
          type: InsightType.positive,
          title: 'Consistent Journaling!',
          description:
              'You\'ve been journaling for ${journalData.writingStreak} consecutive days. Reflection is a powerful tool!',
          actionable: false,
        ),
      );
    }

    return insights;
  }

  /// Export user data
  Future<Map<String, dynamic>> exportUserData(String userId, {Database? testDb}) async {
    try {
      final analytics = await getUserAnalytics(userId, testDb: testDb);

      return {
        'export_date': DateTime.now().toIso8601String(),
        'user_id': userId,
        'analytics': {
          'habits': {
            'total_habits': analytics.habitAnalytics.totalHabits,
            'active_habits': analytics.habitAnalytics.activeHabits,
            'average_completion_rate':
                analytics.habitAnalytics.averageCompletionRate,
          },
          'challenges': {
            'total_challenges': analytics.challengeAnalytics.totalChallenges,
            'completed_challenges':
                analytics.challengeAnalytics.completedChallenges,
            'success_rate': analytics.challengeAnalytics.successRate,
          },
          'journal': {
            'total_entries': analytics.journalAnalytics.totalEntries,
            'average_words_per_entry':
                analytics.journalAnalytics.averageWordsPerEntry,
            'most_common_tags': analytics.journalAnalytics.mostCommonTags,
          },
          'mood': {
            'total_entries': analytics.moodAnalytics.totalEntries,
            'average_mood': analytics.moodAnalytics.averageMood,
            'mood_distribution': analytics.moodAnalytics.moodDistribution,
            'average_energy': analytics.moodAnalytics.averageEnergy,
            'average_stress': analytics.moodAnalytics.averageStress,
            'average_sleep': analytics.moodAnalytics.averageSleep,
          },
          'streaks': {
            'current_streak': analytics.streakAnalytics.currentStreak,
            'longest_streak': analytics.streakAnalytics.longestStreak,
          },
        },
        'insights': analytics.insights
            .map(
              (insight) => {
                'type': insight.type.toString(),
                'title': insight.title,
                'description': insight.description,
                'actionable': insight.actionable,
              },
            )
            .toList(),
      };
    } catch (e) {
      _logger.e('Failed to export user data: $e');
      rethrow;
    }
  }

  // Helper methods
  int _calculateCurrentStreak(List<Map<String, dynamic>> completions) {
    if (completions.isEmpty) return 0;

    final sortedCompletions =
        completions
            .map(
              (c) =>
                  DateTime.fromMillisecondsSinceEpoch(c['created_at'] as int),
            )
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? lastCompletion;

    for (final completion in sortedCompletions) {
      final today = DateTime.now();
      final completionDate = DateTime(
        completion.year,
        completion.month,
        completion.day,
      );
      final todayDate = DateTime(today.year, today.month, today.day);

      if (lastCompletion == null) {
        if (completionDate.isAtSameMomentAs(todayDate) ||
            completionDate.isAtSameMomentAs(
              todayDate.subtract(const Duration(days: 1)),
            )) {
          streak++;
          lastCompletion = completionDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastCompletion.subtract(const Duration(days: 1));
        if (completionDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          lastCompletion = completionDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  int _calculateLongestStreak(List<Map<String, dynamic>> completions) {
    // Simplified implementation - would need more complex logic for accurate calculation
    return _calculateCurrentStreak(completions);
  }

  int _calculateWritingStreak(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 0;

    final sortedEntries =
        entries
            .map(
              (e) =>
                  DateTime.fromMillisecondsSinceEpoch(e['created_at'] as int),
            )
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? lastEntry;

    for (final entry in sortedEntries) {
      final today = DateTime.now();
      final entryDate = DateTime(entry.year, entry.month, entry.day);
      final todayDate = DateTime(today.year, today.month, today.day);

      if (lastEntry == null) {
        if (entryDate.isAtSameMomentAs(todayDate) ||
            entryDate.isAtSameMomentAs(
              todayDate.subtract(const Duration(days: 1)),
            )) {
          streak++;
          lastEntry = entryDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastEntry.subtract(const Duration(days: 1));
        if (entryDate.isAtSameMomentAs(expectedDate)) {
          streak++;
          lastEntry = entryDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }
}

// Data models for analytics
class UserAnalytics {
  final String userId;
  final HabitAnalytics habitAnalytics;
  final ChallengeAnalytics challengeAnalytics;
  final JournalAnalytics journalAnalytics;
  final MoodAnalytics moodAnalytics;
  final StreakAnalytics streakAnalytics;
  final List<UserInsight> insights;
  final DateTime generatedAt;

  const UserAnalytics({
    required this.userId,
    required this.habitAnalytics,
    required this.challengeAnalytics,
    required this.journalAnalytics,
    required this.moodAnalytics,
    required this.streakAnalytics,
    required this.insights,
    required this.generatedAt,
  });
}

class HabitAnalytics {
  final int totalHabits;
  final int activeHabits;
  final double averageCompletionRate;
  final Map<String, HabitCompletionData> habitData;

  const HabitAnalytics({
    required this.totalHabits,
    required this.activeHabits,
    required this.averageCompletionRate,
    required this.habitData,
  });
}

class HabitCompletionData {
  final String habitId;
  final String habitTitle;
  final int totalCompletions;
  final int recentCompletions;
  final double completionRate30Days;
  final int bestCompletionDay;
  final int currentStreak;
  final int longestStreak;

  const HabitCompletionData({
    required this.habitId,
    required this.habitTitle,
    required this.totalCompletions,
    required this.recentCompletions,
    required this.completionRate30Days,
    required this.bestCompletionDay,
    required this.currentStreak,
    required this.longestStreak,
  });
}

class ChallengeAnalytics {
  final int totalChallenges;
  final int completedChallenges;
  final int activeChallenges;
  final double successRate;
  final double averageCompletionPercentage;

  const ChallengeAnalytics({
    required this.totalChallenges,
    required this.completedChallenges,
    required this.activeChallenges,
    required this.successRate,
    required this.averageCompletionPercentage,
  });
}

class JournalAnalytics {
  final int totalEntries;
  final double averageWordsPerEntry;
  final int entriesThisMonth;
  final List<String> mostCommonTags;
  final int writingStreak;

  const JournalAnalytics({
    required this.totalEntries,
    required this.averageWordsPerEntry,
    required this.entriesThisMonth,
    required this.mostCommonTags,
    required this.writingStreak,
  });
}

class MoodAnalytics {
  final int totalEntries;
  final String averageMood;
  final Map<String, int> moodDistribution;
  final double averageEnergy;
  final double averageStress;
  final double averageSleep;
  final List<MoodTrend> moodTrends;

  const MoodAnalytics({
    required this.totalEntries,
    required this.averageMood,
    required this.moodDistribution,
    required this.averageEnergy,
    required this.averageStress,
    required this.averageSleep,
    required this.moodTrends,
  });
}

class MoodTrend {
  final DateTime date;
  final String mood;
  final int energy;
  final int stress;
  final int sleep;

  const MoodTrend({
    required this.date,
    required this.mood,
    required this.energy,
    required this.stress,
    required this.sleep,
  });
}

class StreakAnalytics {
  final int currentStreak;
  final int longestStreak;
  final int totalStreakDays;
  final double averageStreakLength;

  const StreakAnalytics({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalStreakDays,
    required this.averageStreakLength,
  });
}

class UserInsight {
  final InsightType type;
  final String title;
  final String description;
  final bool actionable;

  const UserInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.actionable,
  });
}

enum InsightType { positive, warning, improvement, achievement }
