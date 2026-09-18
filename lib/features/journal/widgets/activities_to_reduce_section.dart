import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/activity_insight.dart';

/// Activities the user mentioned repeatedly with negative valence — the
/// inverse of `RecommendedActionsSection`: things to consider doing less of,
/// not new actions to try. Renders nothing when [insights] is empty (not
/// enough negative-activity signal yet).
class ActivitiesToReduceSection extends StatelessWidget {
  const ActivitiesToReduceSection({super.key, required this.insights});

  final List<ActivityInsight> insights;

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? AppColors.darkTile : AppColors.lightTile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final insight in insights)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_down_rounded, size: 18, color: AppColors.terracotta),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Considerá reducir: ${insight.activity}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Mencionado ${insight.mentions} veces con malestar',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
