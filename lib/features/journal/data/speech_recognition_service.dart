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

  /// Starts listening and streams recognized words via [onResult] as the
  /// user speaks (partial results, updated live). Returns false if speech
  /// recognition isn't available on this device/platform or the user
  /// denied the microphone/speech permission — callers should fall back to
  /// a mock transcript in that case.
  Future<bool> startListening({required void Function(String text) onResult}) async {
    if (!_initialized) {
      _initialized = await _speech.initialize();
    }
    if (!_initialized) return false;

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) => onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(partialResults: true),
    );
    return true;
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}
