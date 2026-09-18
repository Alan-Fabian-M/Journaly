import 'package:flutter/material.dart';
import 'package:flutter_twemoji/flutter_twemoji.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/emotion_result.dart';

/// Row of small stat tiles summarizing the user's journal history — streak,
/// total entries, and the dominant emotion of the last week.
class DashboardStatCards extends StatelessWidget {
  const DashboardStatCards({
    super.key,
    required this.streak,
    required this.totalEntries,
    required this.dominantEmotion,
  });

  final int streak;
  final int totalEntries;
  final EmotionType? dominantEmotion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Racha',
            value: '$streak',
            suffix: streak == 1 ? 'día' : 'días',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Entradas',
            value: '$totalEntries',
            suffix: totalEntries == 1 ? 'journal' : 'journals',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'Esta semana',
            value: dominantEmotion?.label ?? '—',
            emoji: dominantEmotion?.emoji,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.suffix, this.emoji});

  final String label;
  final String value;
  final String? suffix;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? AppColors.darkTile : AppColors.lightTile;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: tileColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: secondaryColor)),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Twemoji(emoji: emoji!, height: 16, width: 16),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (suffix != null)
            Text(suffix!, style: TextStyle(fontSize: 11, color: secondaryColor)),
        ],
      ),
    );
  }
}
