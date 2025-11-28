import 'package:flutter/material.dart';

enum MeditationType {
  breathing,
  bodyScan,
  lovingKindness,
  sleep,
  focus,
  anxietyRelief,
}

class Meditation {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final Duration duration;
  final String audioAsset;
  final String imageAsset;
  final MeditationType type;
  final List<String> benefits;
  final bool isPremium;

  const Meditation({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    required this.audioAsset,
    required this.imageAsset,
    required this.type,
    this.benefits = const [],
    this.isPremium = false,
  });

  // Helper method to get the display name for the meditation type
  String get typeName {
    switch (type) {
      case MeditationType.breathing:
        return 'Breathing';
      case MeditationType.bodyScan:
        return 'Body Scan';
      case MeditationType.lovingKindness:
        return 'Loving Kindness';
      case MeditationType.sleep:
        return 'Sleep';
      case MeditationType.focus:
        return 'Focus';
      case MeditationType.anxietyRelief:
        return 'Anxiety Relief';
    }
  }

  // Helper method to get an icon for the meditation type
  IconData get typeIcon {
    switch (type) {
      case MeditationType.breathing:
        return Icons.air;
      case MeditationType.bodyScan:
        return Icons.self_improvement;
      case MeditationType.lovingKindness:
        return Icons.favorite;
      case MeditationType.sleep:
        return Icons.nightlight_round;
      case MeditationType.focus:
        return Icons.center_focus_strong;
      case MeditationType.anxietyRelief:
        return Icons.self_improvement_outlined;
    }
  }
}

// Sample data
final List<Meditation> sampleMeditations = [
  Meditation(
    id: '1',
    title: 'Morning Calm',
    description: 'Start your day with clarity and purpose with this gentle morning meditation.',
    instructor: 'Sarah Johnson',
    duration: const Duration(minutes: 10),
    audioAsset: 'assets/audio/morning_calm.mp3',
    imageAsset: 'assets/images/morning_meditation.jpg',
    type: MeditationType.breathing,
    benefits: ['Reduces morning anxiety', 'Increases focus', 'Sets positive tone for the day'],
  ),
  Meditation(
    id: '2',
    title: 'Deep Sleep',
    description: 'Fall asleep faster and enjoy deeper, more restful sleep.',
    instructor: 'Michael Chen',
    duration: const Duration(minutes: 15),
    audioAsset: 'assets/audio/deep_sleep.mp3',
    imageAsset: 'assets/images/sleep_meditation.jpg',
    type: MeditationType.sleep,
    benefits: ['Improves sleep quality', 'Reduces insomnia', 'Calms the mind'],
    isPremium: true,
  ),
  Meditation(
    id: '3',
    title: 'Anxiety Relief',
    description: 'Quick relief from anxiety and stress with this guided practice.',
    instructor: 'Emma Wilson',
    duration: const Duration(minutes: 5),
    audioAsset: 'assets/audio/anxiety_relief.mp3',
    imageAsset: 'assets/images/anxiety_relief.jpg',
    type: MeditationType.anxietyRelief,
    benefits: ['Reduces anxiety', 'Calms the nervous system', 'Brings present moment awareness'],
  ),
  Meditation(
    id: '4',
    title: 'Body Scan',
    description: 'Release tension and connect with your body through this mindful body scan.',
    instructor: 'David Kim',
    duration: const Duration(minutes: 20),
    audioAsset: 'assets/audio/body_scan.mp3',
    imageAsset: 'assets/images/body_scan.jpg',
    type: MeditationType.bodyScan,
    benefits: ['Reduces physical tension', 'Increases body awareness', 'Promotes relaxation'],
    isPremium: true,
  ),
  Meditation(
    id: '5',
    title: 'Loving Kindness',
    description: 'Cultivate compassion for yourself and others with this loving-kindness meditation.',
    instructor: 'Priya Patel',
    duration: const Duration(minutes: 12),
    audioAsset: 'assets/audio/loving_kindness.mp3',
    imageAsset: 'assets/images/loving_kindness.jpg',
    type: MeditationType.lovingKindness,
    benefits: ['Increases compassion', 'Reduces negative emotions', 'Enhances social connection'],
  ),
];
