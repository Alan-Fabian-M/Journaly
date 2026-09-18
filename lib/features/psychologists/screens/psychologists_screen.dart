import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/theme/app_colors.dart';
import '../../journal/providers/journal_provider.dart';
import '../providers/psychologist_provider.dart';
import '../utils/psychologist_matching.dart';
import '../widgets/psychologist_card.dart';
import 'psychologist_detail_screen.dart';

class PsychologistsScreen extends StatelessWidget {
  const PsychologistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<PsychologistProvider>();
    final journals = context.watch<JournalProvider>().journals;
    final psicologos = sortedByCompatibility(provider.psicologos, journals);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text(
            'Psicólogos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          // Buscador/filtro visual únicamente por ahora, sin lógica de
          // filtrado real.
          // TODO: conectar a búsqueda real cuando exista API de psicólogos.
          TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: 'Buscar por especialidad...',
              suffixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: isDark ? AppColors.darkTile : AppColors.lightTile,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            for (final psicologo in psicologos) ...[
              PsychologistCard(
                psicologo: psicologo,
                compatibility: compatibilityScore(psicologo, journals),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PsychologistDetailScreen(psicologo: psicologo),
                    ),
                  );
                },
              ),
              if (psicologo != psicologos.last)
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkTile : AppColors.lightTile,
                ),
            ],
        ],
      ),
    );
  }
}
