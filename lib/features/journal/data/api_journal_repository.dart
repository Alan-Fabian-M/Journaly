import 'package:dio/dio.dart';

import '../../../shared/data/api_client.dart';
import '../models/journal.dart';
import 'journal_repository.dart';

/// Real implementation of [JournalRepository] against `journaly-backend`
/// (see backend.md, `GET/POST /journals`). Emotion analysis now runs
/// server-side (heuristic or a real LLM via OpenRouter, depending on the
/// backend's config) — the client no longer does any of that itself.
class ApiJournalRepository implements JournalRepository {
  ApiJournalRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  @override
  Future<List<Journal>> fetchJournals() async {
    final response = await _dio.get('/journals');
    final data = response.data as List;
    return data.map((json) => Journal.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Journal> submitJournal({
    required String text,
    required JournalEntryType entryType,
  }) async {
    final response = await _dio.post(
      '/journals',
      data: {'text': text, 'entryType': entryType.name},
    );
    return Journal.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> submitActionFeedback({
    required String recommendationId,
    required bool wasHelpful,
  }) async {
    await _dio.post(
      '/recommendations/$recommendationId/feedback',
      data: {'wasHelpful': wasHelpful},
    );
  }
}
