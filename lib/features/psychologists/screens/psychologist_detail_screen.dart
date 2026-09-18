import 'package:flutter/material.dart';

import '../models/psicologo.dart';
import '../../../shared/theme/app_colors.dart';

class PsychologistDetailScreen extends StatelessWidget {
  const PsychologistDetailScreen({super.key, required this.psicologo});

  final Psicologo psicologo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

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
