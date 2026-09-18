import 'emotion_result.dart';
import 'recommended_action.dart';

enum JournalEntryType { voz, texto }

/// A single journal entry.
///
/// Shape kept intentionally simple so a future `JournalRepository` backed by
/// a real API can produce the same class from server data.
class Journal {
  const Journal({
    required this.id,
    required this.date,
    required this.entryType,
    required this.transcript,
    required this.shortSummary,
    required this.emotionResult,
    this.durationSeconds,
    this.recommendedActions = const [],
    this.activitiesToAvoid = const [],
  });

  final String id;
  final DateTime date;
  final JournalEntryType entryType;
  final String transcript;
  final String shortSummary;
  final EmotionResult emotionResult;

  /// Mock audio length, only set for [JournalEntryType.voz] entries.
  final int? durationSeconds;

  /// Coping actions the backend's matching engine recommended for this
  /// journal. Empty for mock data / journals analyzed before the matching
  /// engine existed.
  final List<RecommendedAction> recommendedActions;

  /// Activities mentioned in THIS journal with negative valence — "what to
  /// avoid" specific to this entry, the inverse of `emotionResult.
  /// suggestions`. Not the aggregated cross-journal profile (see
  /// `JournalProvider.activitiesToReduce` / `GET /activity-insights`).
  final List<String> activitiesToAvoid;

  /// Parses a journal object as returned by the backend (see backend.md
  /// section 4, `GET/POST /journals`).
  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      entryType: JournalEntryType.values.byName(json['entryType'] as String),
      transcript: json['transcript'] as String,
      shortSummary: json['shortSummary'] as String,
      durationSeconds: json['durationSeconds'] as int?,
      emotionResult: EmotionResult.fromJson(json['emotionResult'] as Map<String, dynamic>),
      recommendedActions: (json['recommendedActions'] as List? ?? [])
          .map((e) => RecommendedAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      activitiesToAvoid: (json['activitiesToAvoid'] as List? ?? []).cast<String>(),
    );
  }
}
