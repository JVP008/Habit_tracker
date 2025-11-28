import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WellbeingInsightCard extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final bool showAnimation;
  final VoidCallback? onTap;

  const WellbeingInsightCard({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.showAnimation = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
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
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: color.withValues(alpha: 0.7),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyMedium),
            if (showAnimation) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: Lottie.asset(
                  _getAnimationAsset(color),
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getAnimationAsset(Color color) {
    // This is a simplified version - in a real app, you'd have actual Lottie files
    if (color == Colors.green) {
      return 'assets/loading.json/improving.json';
    } else if (color == Colors.orange || color == Colors.red) {
      return 'assets/loading.json/declining.json';
    } else {
      return 'assets/loading.json/stable.json';
    }
  }
}

// Example usage in your code:
/*
WellbeingInsightCard(
  title: 'Mood Trend Improving',
  message: 'Your mood has been improving over the last 7 days. Keep up the good work!',
  icon: Icons.trending_up,
  color: Colors.green,
  showAnimation: true,
  onTap: () {
    // Navigate to insights screen
  },
)
*/
