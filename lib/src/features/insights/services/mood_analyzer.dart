import 'dart:math';

class MoodAnalyzer {
  // This is a simplified version - in a real app, you'd use a proper ML model
  static const List<String> _positiveWords = [
    'happy', 'joy', 'peace', 'calm', 'grateful', 'thankful', 'excited', 'love',
    'bliss', 'serene', 'content', 'hopeful', 'inspired', 'motivated', 'proud'
  ];
  
  static const List<String> _negativeWords = [
    'sad', 'angry', 'anxious', 'stressed', 'tired', 'frustrated', 'overwhelmed',
    'lonely', 'worried', 'scared', 'exhausted', 'depressed', 'hopeless'
  ];
  
  // Analyze journal entry and return mood score (-1 to 1)
  static double analyzeMood(String text) {
    if (text.isEmpty) return 0.0;
    
    final words = text.toLowerCase().split(RegExp(r'\s+'))..removeWhere((w) => w.length < 3);
    if (words.isEmpty) return 0.0;
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final word in words) {
      if (_positiveWords.any((w) => word.contains(w))) {
        positiveCount++;
      } else if (_negativeWords.any((w) => word.contains(w))) {
        negativeCount++;
      }
    }
    
    // Simple sentiment score
    final score = (positiveCount - negativeCount) / max(1, words.length);
    return score.clamp(-1.0, 1.0);
  }
  
  // Get mood emoji based on score
  static String getMoodEmoji(double score) {
    if (score > 0.3) return '😊';
    if (score > 0) return '🙂';
    if (score > -0.3) return '😐';
    if (score > -0.7) return '😕';
    return '😔';
  }
  
  // Get mood label
  static String getMoodLabel(double score) {
    if (score > 0.6) return 'Ecstatic';
    if (score > 0.3) return 'Happy';
    if (score > 0) return 'Good';
    if (score > -0.3) return 'Neutral';
    if (score > -0.6) return 'Down';
    return 'Struggling';
  }
  
  // Generate insights based on mood history
  static Map<String, dynamic> generateInsights(List<double> moodHistory) {
    if (moodHistory.isEmpty) return {};
    
    final avgMood = moodHistory.reduce((a, b) => a + b) / moodHistory.length;
    final variance = _calculateVariance(moodHistory, avgMood);
    
    String trend;
    if (moodHistory.length > 1) {
      final last = moodHistory.last;
      final secondLast = moodHistory[moodHistory.length - 2];
      trend = last > secondLast ? 'improving' : last < secondLast ? 'declining' : 'stable';
    } else {
      trend = 'stable';
    }
    
    return {
      'averageMood': avgMood,
      'moodStability': 1.0 - variance, // Closer to 1 is more stable
      'trend': trend,
      'recommendations': _generateRecommendations(avgMood, variance, trend),
    };
  }
  
  static double _calculateVariance(List<double> values, double mean) {
    if (values.length < 2) return 0.0;
    
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / (values.length - 1);
  }
  
  static List<String> _generateRecommendations(double avgMood, double stability, String trend) {
    final recommendations = <String>[];
    
    if (avgMood < 0) {
      recommendations.add('Try our "Boost Your Mood" meditation series');
    }
    
    if (stability < 0.3) {
      recommendations.add('Your mood has been fluctuating. Consider establishing a more consistent routine.');
    }
    
    if (trend == 'declining') {
      recommendations.add('We notice your mood has been declining. Would you like to try a guided reflection?');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Your mood looks good! Keep up with your mindfulness practice.');
    }
    
    return recommendations;
  }
}
