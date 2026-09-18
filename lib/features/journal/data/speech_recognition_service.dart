import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps the on-device speech recognizer (`speech_to_text`, Android/iOS
/// native APIs) so voice journals get a real, live transcript while the
/// user talks — no backend needed for this part.
///
/// The emotion analysis of that transcript stays mocked (see
/// `AiJournalService`); only the audio-to-text step is real here.
class SpeechRecognitionService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  // Android's native SpeechRecognizer auto-stops a listen session after a
  // short silence (~1-3s, a system limit the plugin itself can't override —
  // see SpeechListenOptions.pauseFor docs), which used to cut the
  // transcript short on any mid-sentence pause. We detect that stop via
  // onStatus and transparently restart listening while the user is still
  // actively recording, stitching sessions together into one transcript.
  bool _shouldKeepListening = false;
  String _committedTranscript = '';
  String _sessionWords = '';
  void Function(String text)? _onResult;

  String get _fullTranscript =>
      _committedTranscript.isEmpty ? _sessionWords : '$_committedTranscript $_sessionWords';

  /// Starts listening and streams recognized words via [onResult] as the
  /// user speaks (partial results, updated live). Returns false if speech
  /// recognition isn't available on this device/platform or the user
  /// denied the microphone/speech permission — callers should fall back to
  /// a mock transcript in that case.
  Future<bool> startListening({required void Function(String text) onResult}) async {
    _onResult = onResult;
    _committedTranscript = '';
    _sessionWords = '';
    _shouldKeepListening = true;

    if (!_initialized) {
      _initialized = await _speech.initialize(onStatus: _handleStatus);
    }
    if (!_initialized) return false;

    await _startSession();
    return true;
  }

  Future<void> _startSession() async {
    _sessionWords = '';
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        _sessionWords = result.recognizedWords;
        _onResult?.call(_fullTranscript);
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        // Long ceilings — these just cap a single native session; the real
        // continuity comes from restarting in _handleStatus below.
        listenFor: Duration(minutes: 5),
        pauseFor: Duration(seconds: 8),
      ),
    );
  }

  void _handleStatus(String status) {
    if (!_shouldKeepListening) return;
    if (status == 'notListening' || status == 'done') {
      if (_sessionWords.trim().isNotEmpty) {
        _committedTranscript = _fullTranscript;
      }
      _startSession();
    }
  }

  Future<void> stopListening() async {
    _shouldKeepListening = false;
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}
