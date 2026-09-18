import '../models/journal.dart';
import 'ai_journal_service.dart';
import 'journal_repository.dart';
import 'mock_journals.dart';

/// In-memory implementation of [JournalRepository] backed by
/// [mockJournals] and the mocked [AiJournalService]. This is what the app
/// uses today; swap it for an `ApiJournalRepository` once the real backend
/// endpoints exist — nothing above this layer (provider, screens) needs to
/// change.
class MockJournalRepository implements JournalRepository {
  MockJournalRepository({AiJournalService? aiService})
      : _aiService = aiService ?? AiJournalService(),
        _journals = List.of(mockJournals);

  final AiJournalService _aiService;
  final List<Journal> _journals;

  @override
  Future<List<Journal>> fetchJournals() async {
    return List.unmodifiable(_journals);
  }

  @override
  Future<Journal> submitJournal({
    required String text,
    required JournalEntryType entryType,
  }) async {
    final emotionResult = await _aiService.analyzeJournal(text);

    final journal = Journal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      entryType: entryType,
      transcript: text,
      shortSummary: text.length > 60 ? '${text.substring(0, 60)}...' : text,
      emotionResult: emotionResult,
    );

    _journals.insert(0, journal);
    return journal;
  }

  @override
  Future<void> submitActionFeedback({
    required String recommendationId,
    required bool wasHelpful,
  }) async {
    // Mock journals never have real recommendedActions (no matching engine
    // client-side), so there's nothing to persist — no-op.
  }
}
