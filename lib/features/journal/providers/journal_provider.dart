import 'package:flutter/foundation.dart';

import '../data/journal_repository.dart';
import '../data/mock_journal_repository.dart';
import '../data/speech_recognition_service.dart';
import '../models/journal.dart';

enum RecordingStatus { idle, recording, processing }

/// Used when on-device speech recognition isn't available (permission
/// denied, unsupported platform, or nothing was understood).
const _fallbackTranscript =
    'No pudimos escucharte con claridad, pero aquí tienes un ejemplo de '
    'cómo se vería tu journal transcrito.';

/// Holds the recording/processing state and the journal history for the UI.
///
/// Data (history, persisting new entries, action feedback) is delegated to
/// a [JournalRepository] — `ApiJournalRepository` by default (real
/// backend), or [MockJournalRepository] for offline/demo use. Speech-to-text
/// is a separate, genuinely real concern handled by [SpeechRecognitionService]
/// (on-device, no backend involved).
class JournalProvider extends ChangeNotifier {
  JournalProvider({
    JournalRepository? repository,
    SpeechRecognitionService? speechService,
  })  : _repository = repository ?? MockJournalRepository(),
        _speechService = speechService ?? SpeechRecognitionService() {
    _loadJournals();
  }

  final JournalRepository _repository;
  final SpeechRecognitionService _speechService;
  List<Journal> _journals = [];
  final Set<String> _feedbackGiven = {};

  RecordingStatus _status = RecordingStatus.idle;
  String _liveTranscript = '';

  RecordingStatus get status => _status;

  /// Text recognized so far while [status] is [RecordingStatus.recording],
  /// updated live as the user speaks.
  String get liveTranscript => _liveTranscript;

  /// Most recent journals first.
  List<Journal> get journals => List.unmodifiable(_journals);

  Journal? get latestJournal => _journals.isEmpty ? null : _journals.first;

  /// Whether the user already gave 👍/👎 feedback for this recommendation.
  bool hasFeedback(String recommendationId) => _feedbackGiven.contains(recommendationId);

  Future<void> submitActionFeedback(String recommendationId, bool wasHelpful) async {
    try {
      await _repository.submitActionFeedback(
        recommendationId: recommendationId,
        wasHelpful: wasHelpful,
      );
      _feedbackGiven.add(recommendationId);
    } catch (e) {
      debugPrint('JournalProvider: no se pudo enviar el feedback ($e)');
    }
    notifyListeners();
  }

  Future<void> _loadJournals() async {
    try {
      _journals = await _repository.fetchJournals();
    } catch (e) {
      // No tumbamos la pantalla si el backend no está corriendo al abrir la
      // app — se queda con el historial vacío.
      debugPrint('JournalProvider: no se pudo cargar el historial ($e)');
    }
    notifyListeners();
  }

  Future<void> startRecording() async {
    _status = RecordingStatus.recording;
    _liveTranscript = '';
    notifyListeners();

    final available = await _speechService.startListening(
      onResult: (text) {
        _liveTranscript = text;
        notifyListeners();
      },
    );

    // Si el dispositivo/plataforma no soporta reconocimiento de voz (o el
    // usuario negó el permiso), seguimos en estado "recording" igual: el
    // usuario puede tocar detener y se usará `_fallbackTranscript`.
    if (!available) {
      debugPrint('SpeechRecognitionService: no disponible en este dispositivo');
    }
  }

  /// Stops the (real) recording/listening, runs the resulting transcript
  /// through the mocked emotion analysis, and adds the journal to the top
  /// of the history.
  Future<void> stopRecordingAndAnalyze() async {
    _status = RecordingStatus.processing;
    notifyListeners();

    await _speechService.stopListening();

    final transcript = _liveTranscript.trim().isNotEmpty
        ? _liveTranscript.trim()
        : _fallbackTranscript;

    final journal = await _repository.submitJournal(
      text: transcript,
      entryType: JournalEntryType.voz,
    );

    _journals.insert(0, journal);
    _liveTranscript = '';
    _status = RecordingStatus.idle;
    notifyListeners();
  }

  /// Same pipeline as voice, but starting from text typed by the user.
  Future<void> submitTextJournal(String text) async {
    _status = RecordingStatus.processing;
    notifyListeners();

    final journal = await _repository.submitJournal(
      text: text,
      entryType: JournalEntryType.texto,
    );

    _journals.insert(0, journal);
    _status = RecordingStatus.idle;
    notifyListeners();
  }

  Future<void> cancelRecording() async {
    await _speechService.stopListening();
    _liveTranscript = '';
    _status = RecordingStatus.idle;
    notifyListeners();
  }
}
