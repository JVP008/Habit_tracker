import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodTrendChart extends StatelessWidget {
  final List<double> moodData;
  final bool showTitle;
  final bool showAverage;

  const MoodTrendChart({
    super.key,
    required this.moodData,
    this.showTitle = true,
    this.showAverage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // If no data, show empty state
    if (moodData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No mood data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate average mood
    final avgMood = moodData.isNotEmpty
        ? moodData.reduce((a, b) => a + b) / moodData.length
        : 0.0;

    // Generate spots for the chart
    final spots = moodData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    // Generate X axis labels (days of the week)
    final weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final xLabels = List.generate(
      moodData.length,
      (index) => weekDays[index % 7],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mood Trend',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (showAverage && moodData.isNotEmpty)
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getMoodColor(avgMood, theme),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Avg: ${avgMood.toStringAsFixed(1)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < moodData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            xLabels[value.toInt() % xLabels.length],
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.5,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value == 1) return const Text('😊');
                      if (value == 0) return const Text('😐');
                      if (value == -1) return const Text('😔');
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: moodData.isNotEmpty ? (moodData.length - 1).toDouble() : 0,
              minY: -1,
              maxY: 1,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: theme.colorScheme.primary,
                        strokeWidth: 2,
                        strokeColor: theme.scaffoldBackgroundColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                        theme.colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: theme.cardColor,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${_getMoodLabel(spot.y)}\n${xLabels[spot.x.toInt() % xLabels.length]}',
                        theme.textTheme.bodyMedium!,
                        textAlign: TextAlign.center,
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                      FlDotData(
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.scaffoldBackgroundColor,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMoodLabel(double value) {
    if (value > 0.6) return 'Excellent';
    if (value > 0.2) return 'Good';
    if (value > -0.2) return 'Neutral';
    if (value > -0.6) return 'Low';
    return 'Difficult';
  }

  Color _getMoodColor(double value, ThemeData theme) {
    if (value > 0.6) return Colors.green;
    if (value > 0.2) return Colors.lightGreen;
    if (value > -0.2) return Colors.orange;
    if (value > -0.6) return Colors.orange[300]!;
    return Colors.red;
  }
}
