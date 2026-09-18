import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/theme/app_colors.dart';
import '../models/recommended_action.dart';
import '../providers/journal_provider.dart';

/// Shows the backend's recommended coping actions for a journal, with a
/// 👍/👎 to give feedback (POST /recommendations/{id}/feedback). Renders
/// nothing when [actions] is empty (mock data, or journals from before the
/// matching engine existed).
class RecommendedActionsSection extends StatelessWidget {
  const RecommendedActionsSection({super.key, required this.actions});

  final List<RecommendedAction> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? AppColors.darkTile : AppColors.lightTile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones recomendadas',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        for (final action in actions)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(action.title, style: const TextStyle(fontSize: 13)),
                ),
                _FeedbackButtons(recommendationId: action.recommendationId),
              ],
            ),
          ),
      ],
    );
  }
}

class _FeedbackButtons extends StatelessWidget {
  const _FeedbackButtons({required this.recommendationId});

  final String recommendationId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JournalProvider>();
    final answered = provider.hasFeedback(recommendationId);

    if (answered) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.check_rounded, size: 18, color: AppColors.sage),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.thumb_up_outlined, size: 18),
          onPressed: () => context.read<JournalProvider>().submitActionFeedback(recommendationId, true),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.thumb_down_outlined, size: 18),
          onPressed: () => context.read<JournalProvider>().submitActionFeedback(recommendationId, false),
        ),
      ],
    );
  }
}
