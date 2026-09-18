import '../models/emotion_result.dart';
import '../models/journal.dart';

DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Consecutive days (counting back from today) with at least one journal.
/// A gap of a day (no entry yesterday, given none today) breaks the streak.
int currentStreak(List<Journal> journals) {
  if (journals.isEmpty) return 0;

  final days = journals.map((j) => _dayOnly(j.date)).toSet();
  final today = _dayOnly(DateTime.now());

  var cursor = today;
  if (!days.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!days.contains(cursor)) return 0;
  }

  var streak = 0;
  while (days.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Most frequent emotion among journals from the last [lastNDays] days.
/// Null if there are none in that window.
EmotionType? dominantEmotion(List<Journal> journals, {int lastNDays = 7}) {
  final counts = emotionDistribution(journals, lastNDays: lastNDays);
  if (counts.isEmpty) return null;
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

/// Share (0.0-1.0) of journals from the last [lastNDays] days that fall
/// under each [EmotionType]. Only emotions with at least one journal are
/// present. Empty if there are no journals in that window.
Map<EmotionType, double> emotionDistribution(List<Journal> journals, {int lastNDays = 30}) {
  final cutoff = _dayOnly(DateTime.now()).subtract(Duration(days: lastNDays - 1));
  final counts = <EmotionType, int>{};
  var total = 0;

  for (final journal in journals) {
    if (_dayOnly(journal.date).isBefore(cutoff)) continue;
    final emotion = journal.emotionResult.emotion;
    counts[emotion] = (counts[emotion] ?? 0) + 1;
    total++;
  }

  if (total == 0) return {};
  return counts.map((emotion, count) => MapEntry(emotion, count / total));
}

/// Average emotion intensity per day for the last [lastNDays] days, oldest
/// first, one entry per day (0.0 for days with no journal) — ready to plot.
List<MapEntry<DateTime, double>> intensityTrend(List<Journal> journals, {int lastNDays = 14}) {
  final today = _dayOnly(DateTime.now());
  final sums = <DateTime, double>{};
  final counts = <DateTime, int>{};

  for (final journal in journals) {
    final day = _dayOnly(journal.date);
    if (today.difference(day).inDays >= lastNDays) continue;
    sums[day] = (sums[day] ?? 0) + journal.emotionResult.intensity;
    counts[day] = (counts[day] ?? 0) + 1;
  }

  return [
    for (var i = lastNDays - 1; i >= 0; i--)
      MapEntry(
        today.subtract(Duration(days: i)),
        () {
          final day = today.subtract(Duration(days: i));
          final count = counts[day];
          return count == null ? 0.0 : sums[day]! / count;
        }(),
      ),
  ];
}
