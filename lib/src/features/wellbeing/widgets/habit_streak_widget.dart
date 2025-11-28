import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HabitStreakWidget extends StatelessWidget {
  final String title;
  final int days;
  final int? total;
  final IconData icon;
  final Color color;
  final bool showCelebration;

  const HabitStreakWidget({
    super.key,
    required this.title,
    required this.days,
    this.total,
    required this.icon,
    required this.color,
    this.showCelebration = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Stack(
        children: [
          if (showCelebration && days > 0 && days % 7 == 0)
            Positioned(
              top: -20,
              right: -20,
              child: Lottie.asset(
                'assets/loading.json/celebration.json',
                width: 100,
                height: 100,
                repeat: false,
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  if (total != null) ...[
                    Text(
                      '$days/$total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    days.toString(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (days > 0) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: total != null ? days / total! : 1.0,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              if (days > 0 && days % 7 == 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.celebration_outlined, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${days ~/ 7} week streak!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
