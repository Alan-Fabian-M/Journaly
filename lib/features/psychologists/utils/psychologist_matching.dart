import '../../journal/models/journal.dart';
import '../../journal/utils/journal_stats.dart';
import '../models/psicologo.dart';

/// Compatibility score (0-100) between [psicologo] and the user, based on
/// how much of their recent emotional history (from [journals]) falls under
/// the emotions this psychologist specializes in.
///
/// With no journals in the window, or a psychologist with no declared
/// [Psicologo.focusEmotions], falls back to a score derived only from
/// [Psicologo.rating] so the UI still has something sensible to show.
int compatibilityScore(Psicologo psicologo, List<Journal> journals, {int lastNDays = 30}) {
  final distribution = emotionDistribution(journals, lastNDays: lastNDays);
  final ratingScore = (psicologo.rating / 5.0 * 100).round();

  if (distribution.isEmpty || psicologo.focusEmotions.isEmpty) {
    return ratingScore.clamp(0, 100);
  }

  final overlap = psicologo.focusEmotions.fold<double>(
    0.0,
    (sum, emotion) => sum + (distribution[emotion] ?? 0.0),
  );

  // Overlap (how much of the user's recent journals match this
  // psychologist's focus) drives the score; rating only nudges it as a
  // tie-breaker between otherwise-similar matches.
  final score = overlap * 90 + (psicologo.rating / 5.0) * 10;
  return score.round().clamp(0, 100);
}

/// [psicologos] sorted from most to least compatible with [journals].
List<Psicologo> sortedByCompatibility(List<Psicologo> psicologos, List<Journal> journals) {
  final sorted = List<Psicologo>.from(psicologos);
  sorted.sort(
    (a, b) => compatibilityScore(b, journals).compareTo(compatibilityScore(a, journals)),
  );
  return sorted;
}
