import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/emotion_result.dart';
import '../providers/journal_provider.dart';
import '../utils/journal_stats.dart';
import '../widgets/activities_to_reduce_section.dart';
import '../widgets/dashboard_stat_cards.dart';
import '../widgets/emotion_badge.dart';
import '../widgets/journal_detail_sheet.dart';
import '../widgets/journal_history_item.dart';
import '../widgets/mood_trend_chart.dart';
import '../widgets/recommended_actions_section.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? AppColors.darkTile : AppColors.lightTile;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final provider = context.watch<JournalProvider>();
    final journals = provider.journals;
    final latest = provider.latestJournal;
    final history = journals.skip(1).take(4).toList();

    if (latest == null) {
      return const Center(child: Text('Aún no tienes journals registrados.'));
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text(
            'Tu resumen',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          DashboardStatCards(
            streak: currentStreak(journals),
            totalEntries: journals.length,
            dominantEmotion: dominantEmotion(journals),
          ),
          const SizedBox(height: 16),
          MoodTrendChart(journals: journals),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Último registro'),
          const SizedBox(height: 12),
          EmotionBadge(emotion: latest.emotionResult.emotion),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: latest.emotionResult.intensity,
              minHeight: 6,
              backgroundColor: tileColor,
              valueColor: AlwaysStoppedAnimation(latest.emotionResult.emotion.color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Intensidad: ${(latest.emotionResult.intensity * 100).round()}%',
            style: TextStyle(fontSize: 12, color: secondaryColor),
          ),
          if (latest.emotionResult.keywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final keyword in latest.emotionResult.keywords)
                  Chip(
                    label: Text(keyword),
                    backgroundColor: tileColor,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Text(
            latest.emotionResult.feedbackText,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 16),
          ...latest.emotionResult.suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.spa_rounded, size: 16, color: AppColors.sage),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(suggestion, style: const TextStyle(fontSize: 13, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
          if (latest.activitiesToAvoid.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...latest.activitiesToAvoid.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
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
            ),
          ],
          if (latest.recommendedActions.isNotEmpty) ...[
            const SizedBox(height: 20),
            RecommendedActionsSection(actions: latest.recommendedActions),
          ],
          if (provider.activitiesToReduce.isNotEmpty) ...[
            const SizedBox(height: 28),
            const SectionHeader(title: 'Para reducir'),
            const SizedBox(height: 12),
            ActivitiesToReduceSection(insights: provider.activitiesToReduce),
          ],
          const SizedBox(height: 28),
          const SectionHeader(title: 'Historial reciente'),
          const SizedBox(height: 12),
          for (final journal in history)
            JournalHistoryItem(
              journal: journal,
              onTap: () => showJournalDetailSheet(context, journal),
            ),
        ],
      ),
    );
  }
}
