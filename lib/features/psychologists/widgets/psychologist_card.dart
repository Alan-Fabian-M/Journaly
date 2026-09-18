import 'package:flutter/material.dart';

import '../models/psicologo.dart';
import '../../../shared/theme/app_colors.dart';

/// Row-style psychologist item, aligned with the contact-list rows from
/// design.md: avatar + stacked name/subtitle, whole row tappable, trailing
/// chevron instead of a boxed card.
class PsychologistCard extends StatelessWidget {
  const PsychologistCard({super.key, required this.psicologo, this.onTap, this.compatibility});

  final Psicologo psicologo;
  final VoidCallback? onTap;

  /// Compatibility score (0-100) with the user, from `compatibilityScore`
  /// in `psychologist_matching.dart`. Null hides the badge.
  final int? compatibility;

  Color _compatibilityColor(int score) {
    if (score >= 75) return const Color(0xFF8AA68C);
    if (score >= 50) return const Color(0xFFD8A657);
    return const Color(0xFFC97B63);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
              child: Text(
                psicologo.initials,
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    psicologo.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    psicologo.specialty,
                    style: TextStyle(fontSize: 12, color: secondaryColor),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final filled = i < psicologo.rating.round();
                        return Icon(
                          filled ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 14,
                          color: const Color(0xFFD8A657),
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        psicologo.rating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 11, color: secondaryColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (compatibility != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _compatibilityColor(compatibility!).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$compatibility% match',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _compatibilityColor(compatibility!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded, color: secondaryColor),
          ],
        ),
      ),
    );
  }
}
