import 'package:flutter/material.dart';

import '../models/emotion_result.dart';
import '../models/journal.dart';
import '../../../shared/theme/app_colors.dart';
import 'emotion_badge.dart';
import 'recommended_actions_section.dart';

/// Shared bottom sheet used to preview a single journal entry — from the
/// history list in Summary, and from tapping a date in the record screen's
/// date carousel.
///
/// Shows, alongside the transcript, the mock "analyzed" fields
/// (`intensity`, `keywords`, `durationSeconds`) that stand in for what a
/// real AI analysis would return.
Future<void> showJournalDetailSheet(BuildContext context, Journal journal) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final secondaryColor =
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
      final emotion = journal.emotionResult;

      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  EmotionBadge(emotion: emotion.emotion),
                  Text(
                    journal.entryType == JournalEntryType.voz
                        ? '🎙 ${_formatDuration(journal.durationSeconds)}'
                        : '📝 Texto',
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mock intensity/confidence bar — stand-in for a real AI score.
              Text(
                'Intensidad detectada',
                style: TextStyle(fontSize: 12, color: secondaryColor),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: emotion.intensity,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkTile : AppColors.lightTile,
                  valueColor: AlwaysStoppedAnimation(emotion.emotion.color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(emotion.intensity * 100).round()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 18),

              if (emotion.keywords.isNotEmpty) ...[
                Text(
                  'Temas detectados',
                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final keyword in emotion.keywords)
                      Chip(
                        label: Text(keyword),
                        backgroundColor: isDark ? AppColors.darkTile : AppColors.lightTile,
                        side: BorderSide.none,
                        shape: const StadiumBorder(),
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
              ],

              if (journal.recommendedActions.isNotEmpty) ...[
                RecommendedActionsSection(actions: journal.recommendedActions),
                const SizedBox(height: 18),
              ],

              if (journal.activitiesToAvoid.isNotEmpty) ...[
                Text(
                  'Para evitar',
                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
                const SizedBox(height: 8),
                for (final activity in journal.activitiesToAvoid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Icon(
                            Icons.trending_down_rounded,
                            size: 16,
                            color: AppColors.terracotta,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(activity, style: const TextStyle(fontSize: 13, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
              ],

              Text(
                'Transcripción',
                style: TextStyle(fontSize: 12, color: secondaryColor),
              ),
              const SizedBox(height: 6),
              Text(journal.transcript, style: const TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

String _formatDuration(int? seconds) {
  if (seconds == null) return '';
  final minutes = seconds ~/ 60;
  final remaining = seconds % 60;
  return '$minutes:${remaining.toString().padLeft(2, '0')} min';
}
