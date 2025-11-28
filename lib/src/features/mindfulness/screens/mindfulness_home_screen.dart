import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../src/core/utils/animations.dart';
import '../models/meditation_model.dart';

class MindfulnessHomeScreen extends StatelessWidget {
  const MindfulnessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: AppAnimations.fadeIn(child: const Text('Mindfulness')),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.8 * 255).round()),
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha((0.8 * 255).round()),
                    ],
                  ),
                ),
                child: AppAnimations.scaleIn(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  child: const Center(
                    child: Icon(
                      Icons.self_improvement,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: AppAnimations.staggeredList(
                  children: [
                    _buildSectionHeader(context, 'Quick Sessions'),
                    const SizedBox(height: 8),
                    _buildQuickSessions(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Meditation Programs'),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final meditation = sampleMeditations[index];
              return AppAnimations.fadeSlideIn(
                offset: Offset(0, 0.05 * index),
                child: _MeditationCard(meditation: meditation),
              );
            }, childCount: sampleMeditations.length),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return AppAnimations.fadeIn(
      duration: const Duration(milliseconds: 600),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildQuickSessions(BuildContext context) {
    final quickSessions = [
      {'minutes': '5', 'label': 'Quick Calm', 'icon': Icons.self_improvement},
      {'minutes': '10', 'label': 'Focus Boost', 'icon': Icons.psychology},
      {'minutes': '3', 'label': 'Breathe', 'icon': Icons.air},
      {'minutes': '15', 'label': 'Power Nap', 'icon': Icons.snooze},
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickSessions.length,
        itemBuilder: (context, index) {
          final session = quickSessions[index];
          return AppAnimations.fadeSlideIn(
            offset: Offset(0, 0.1 * (index + 1)),
            child: AppAnimations.bounce(
              onTap: () {
                // Navigate to player with a quick session
                GoRouter.of(context).push('/mindfulness/player', extra: Meditation(
                  id: 'quick_${index + 1}',
                  title: session['label'] as String,
                  description:
                      'A quick ${session['minutes']}-minute session to refresh your mind',
                  instructor: 'ZenFlow',
                  duration: Duration(
                    minutes: int.parse(session['minutes'] as String),
                  ),
                  audioAsset: 'assets/audio/quick_${index + 1}.mp3',
                  imageAsset: 'assets/images/quick_${index + 1}.jpg',
                  type: MeditationType.breathing,
                ));
              },
              child: Container(
                width: 110,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                      Theme.of(
                        context,
                      ).colorScheme.secondary.withAlpha((0.1 * 255).round()),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha((0.2 * 255).round()),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha((0.05 * 255).round()),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha((0.2 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        session['icon'] as IconData,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${session['minutes']}m',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session['label'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color
                            ?.withAlpha((0.8 * 255).round()),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MeditationCard extends StatelessWidget {
  final Meditation meditation;

  const _MeditationCard({required this.meditation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          GoRouter.of(context).push('/mindfulness/player', extra: meditation);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/images/meditation_placeholder.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Icon(
                  meditation.typeIcon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          meditation.typeName,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (meditation.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber[300]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'PREMIUM',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.amber[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meditation.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meditation.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${meditation.duration.inMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.person, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          meditation.instructor.split(' ')[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
