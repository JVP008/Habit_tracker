import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/user_profile.dart';

class ParticipantProgressCard extends StatelessWidget {
  final SocialUser user;
  final double progress;
  final int completedDays;
  final int totalDays;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const ParticipantProgressCard({
    super.key,
    required this.user,
    required this.progress,
    required this.completedDays,
    required this.totalDays,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isCurrentUser
          ? theme.colorScheme.primary.withAlpha((0.1 * 255).toInt())
          : theme.colorScheme.surfaceContainerHighest.withAlpha(
              (0.3 * 255).toInt(),
            ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // User Info Row
              Row(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      // User Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        backgroundImage: user.photoUrl != null
                            ? CachedNetworkImageProvider(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.displayName[0].toUpperCase(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              )
                            : null,
                      ),

                      // Online Status Indicator
                      if (isCurrentUser)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isCurrentUser ? 'You' : user.displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'You',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Streak Info
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.streakDays} day streak',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha((0.8 * 255).toInt()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.completedChallenges} challenges',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withAlpha((0.8 * 255).toInt()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Progress Percentage
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getProgressColor(progress, theme),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getProgressTextColor(progress, theme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedDays of $totalDays days',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withAlpha((0.3 * 255).toInt()),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progress, theme),
                      ),
                      minHeight: 8,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Progress Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0%', style: theme.textTheme.labelSmall),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getProgressColor(progress, theme),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('100%', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),

              // Last Active
              if (!isCurrentUser) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Last active: ${_formatLastActive(user.lastActive)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(
                        (0.6 * 255).toInt(),
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress, ThemeData theme) {
    if (progress >= 0.9) {
      return Colors.green;
    } else if (progress >= 0.5) {
      return theme.colorScheme.primary;
    } else if (progress > 0) {
      return Colors.orange;
    } else {
      return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getProgressTextColor(double progress, ThemeData theme) {
    if (progress >= 0.9) {
      return Colors.white;
    } else if (progress >= 0.5) {
      return theme.colorScheme.onPrimary;
    } else if (progress > 0) {
      return Colors.white;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
