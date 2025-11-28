import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../models/user_profile.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;
  final bool showParticipants;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
    this.showParticipants = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;
    final progress = challenge.completionPercentage;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Challenge Image or Placeholder
            if (challenge.imageUrl != null)
              CachedNetworkImage(
                imageUrl: challenge.imageUrl!,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.error_outline_rounded),
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withAlpha((0.7 * 255).toInt()),
                      theme.colorScheme.secondary.withAlpha(
                        (0.7 * 255).toInt(),
                      ),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getChallengeIcon(challenge.goal['type']),
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),

            // Challenge Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          challenge.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            challenge,
                            theme,
                          ).withAlpha((0.2 * 255).toInt()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(challenge, daysLeft),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(challenge, theme),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    challenge.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}% Complete',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${challenge.participants.length} ${challenge.participants.length == 1 ? 'Participant' : 'Participants'}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(challenge, theme),
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Timeline and CTA
                  Row(
                    children: [
                      // Timeline
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat('MMM d').format(challenge.startDate)} - ${DateFormat('MMM d, y').format(challenge.endDate)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${challenge.endDate.difference(challenge.startDate).inDays + 1} days • ${daysLeft >= 0 ? '$daysLeft days left' : 'Ended'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha((0.7 * 255).toInt()),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // CTA Button
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getStatusColor(challenge, theme),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('View'),
                      ),
                    ],
                  ),

                  // Participants Avatars
                  if (showParticipants &&
                      challenge.participants.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildParticipantsAvatars(challenge, theme),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsAvatars(Challenge challenge, ThemeData theme) {
    final maxAvatars = 5;
    final extraCount = challenge.participants.length > maxAvatars
        ? challenge.participants.length - maxAvatars + 1
        : 0;

    return Row(
      children: [
        Text(
          'Participants: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withAlpha(
              (0.7 * 255).toInt(),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Stack(
          children: [
            // Display up to maxAvatars - 1 participants
            for (
              int i = 0;
              i < challenge.participants.length &&
                  i < (extraCount > 0 ? maxAvatars - 1 : maxAvatars);
              i++
            )
              Container(
                margin: EdgeInsets.only(left: i * 16.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    challenge.participants[i][0].toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),

            // Show +X more if there are extra participants
            if (extraCount > 0)
              Container(
                margin: EdgeInsets.only(left: (maxAvatars - 1) * 16.0),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    '+$extraCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  IconData _getChallengeIcon(String type) {
    switch (type) {
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      case 'learning':
        return Icons.school_rounded;
      case 'habits':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Color _getStatusColor(Challenge challenge, ThemeData theme) {
    if (challenge.isCompleted) {
      return Colors.green;
    } else if (challenge.isActive) {
      return theme.colorScheme.primary;
    } else {
      return theme.colorScheme.secondary;
    }
  }

  String _getStatusText(Challenge challenge, int daysLeft) {
    if (challenge.isCompleted) {
      return 'Completed';
    } else if (challenge.isActive) {
      return '${daysLeft}d left';
    } else {
      return 'Starts ${challenge.startDate.difference(DateTime.now()).inDays.abs()}d';
    }
  }
}
