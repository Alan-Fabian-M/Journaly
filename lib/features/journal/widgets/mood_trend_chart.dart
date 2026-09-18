import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/journal.dart';
import '../utils/journal_stats.dart';

/// Line chart of average emotion intensity per day over the last 14 days —
/// 0 for days with no journal entry.
class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({super.key, required this.journals});

  final List<Journal> journals;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? AppColors.darkTile : AppColors.lightTile;
    final lineColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final trend = intensityTrend(journals);
    final spots = [
      for (var i = 0; i < trend.length; i++) FlSpot(i.toDouble(), trend[i].value),
    ];

    return Container(
      height: 140,
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
      decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(20)),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2.5,
              color: lineColor,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: lineColor.withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
    );
  }
}
