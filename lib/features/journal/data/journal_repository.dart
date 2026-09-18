import '../models/journal.dart';

/// Contract for everything journal-related, served by the real backend
/// (`ApiJournalRepository`) or an in-memory mock (`MockJournalRepository`)
/// so `JournalProvider` and the UI never need to change based on which one
/// is wired up.
abstract class JournalRepository {
  /// `GET /journals` — historial del usuario.
  Future<List<Journal>> fetchJournals();

  /// Sends raw journal text (from the real on-device transcript, see
  /// `SpeechRecognitionService`, or typed directly) to be analyzed and
  /// persisted, returning the resulting `Journal` with its `EmotionResult`
  /// and `recommendedActions` already filled in.
  /// `POST /journals { text, entryType }`.
  Future<Journal> submitJournal({
    required String text,
    required JournalEntryType entryType,
  });

  /// Records whether a recommended coping action (see
  /// `Journal.recommendedActions`) was helpful.
  /// `POST /recommendations/{recommendationId}/feedback`.
  Future<void> submitActionFeedback({
    required String recommendationId,
    required bool wasHelpful,
  });
}
