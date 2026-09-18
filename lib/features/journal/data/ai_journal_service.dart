import '../models/emotion_result.dart';

/// Stub for the emotion-analysis half of the AI pipeline.
///
/// Transcription is now real (see `SpeechRecognitionService`, on-device
/// speech-to-text). This service still mocks the part that actually needs
/// an AI/LLM: turning journal text into a detected emotion + feedback.
class AiJournalService {
  /// TODO: reemplazar con una llamada real a un servicio de IA/LLM que
  /// reciba el texto del journal y devuelva la emoción detectada más
  /// feedback y sugerencias personalizadas.
  /// Hoy devuelve un resultado mock fijo (emoción "Estrés") para mantener
  /// consistencia con el flujo de demo.
  Future<EmotionResult> analyzeJournal(String text) async {
    await Future.delayed(const Duration(seconds: 1));
    return const EmotionResult(
      emotion: EmotionType.estres,
      feedbackText:
          'Notamos que tuviste un día estresante. Aquí tienes algunas recomendaciones:',
      intensity: 0.74,
      keywords: ['día agitado', 'poco descanso', 'pendientes'],
      suggestions: [
        'Tómate 5 minutos para respirar profundo antes de seguir con tu día.',
        'Prioriza solo 3 tareas importantes para mañana.',
        'Considera hablar de esto con alguien de confianza o un psicólogo.',
      ],
    );
  }
}
