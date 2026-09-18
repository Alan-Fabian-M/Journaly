import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/psicologo.dart';
import '../../../shared/theme/app_colors.dart';
import '../../journal/models/emotion_result.dart';
import '../../journal/models/journal.dart';
import '../../journal/providers/journal_provider.dart' show JournalProvider;
import '../../journal/utils/journal_stats.dart';
import '../utils/psychologist_matching.dart';

class PsychologistDetailScreen extends StatelessWidget {
  const PsychologistDetailScreen({super.key, required this.psicologo});

  final Psicologo psicologo;

  Color _compatibilityColor(int score) {
    if (score >= 75) return const Color(0xFF8AA68C);
    if (score >= 50) return const Color(0xFFD8A657);
    return const Color(0xFFC97B63);
  }

  String _compatibilityExplanation(List<Journal> journals) {
    final dominant = dominantEmotion(journals);
    if (dominant == null) {
      return 'Aún no tienes suficientes journals para personalizar esta '
          'compatibilidad — este puntaje se basa solo en su calificación.';
    }
    final matches = psicologo.focusEmotions.contains(dominant);
    if (matches) {
      return 'Alta compatibilidad: tus journals recientes reflejan '
          'principalmente ${dominant.label.toLowerCase()}, y ${psicologo.name} '
          'se especializa en eso.';
    }
    return 'Tus journals recientes reflejan principalmente '
        '${dominant.label.toLowerCase()}, algo distinto a la especialidad de '
        '${psicologo.name} (${psicologo.specialty.toLowerCase()}).';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final journals = context.watch<JournalProvider>().journals;
    final score = compatibilityScore(psicologo, journals);

    return Scaffold(
      appBar: AppBar(title: Text(psicologo.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  psicologo.initials,
                  style: TextStyle(
                    fontSize: 28,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                psicologo.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                psicologo.specialty,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _compatibilityColor(score).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.favorite_rounded, size: 18, color: _compatibilityColor(score)),
                      const SizedBox(width: 8),
                      Text(
                        '$score% de compatibilidad',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _compatibilityColor(score),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _compatibilityExplanation(journals),
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Sobre mí', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(psicologo.bio, style: const TextStyle(fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            const Text('Disponibilidad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in psicologo.availability)
                  Chip(
                    label: Text(slot),
                    backgroundColor: isDark ? AppColors.darkTile : AppColors.lightTile,
                    side: BorderSide.none,
                    shape: const StadiumBorder(),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                // TODO: integrar con API real de psicólogos/agenda para
                // reservar la consulta de verdad.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidad próximamente')),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('Agendar consulta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
