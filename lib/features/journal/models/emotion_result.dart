import 'package:flutter/material.dart';

/// Emotions the (future) AI model can detect from a journal entry.
enum EmotionType { estres, ansiedad, tristeza, calma, alegria }

extension EmotionTypeX on EmotionType {
  String get label {
    switch (this) {
      case EmotionType.estres:
        return 'Estrés';
      case EmotionType.ansiedad:
        return 'Ansiedad';
      case EmotionType.tristeza:
        return 'Tristeza';
      case EmotionType.calma:
        return 'Calma';
      case EmotionType.alegria:
        return 'Alegría';
    }
  }

  IconData get icon {
    switch (this) {
      case EmotionType.estres:
        return Icons.bolt_rounded;
      case EmotionType.ansiedad:
        return Icons.waves_rounded;
      case EmotionType.tristeza:
        return Icons.water_drop_rounded;
      case EmotionType.calma:
        return Icons.self_improvement_rounded;
      case EmotionType.alegria:
        return Icons.wb_sunny_rounded;
    }
  }

  Color get color {
    switch (this) {
      case EmotionType.estres:
        return const Color(0xFFC97B63);
      case EmotionType.ansiedad:
        return const Color(0xFFB08968);
      case EmotionType.tristeza:
        return const Color(0xFF7C93A8);
      case EmotionType.calma:
        return const Color(0xFF8AA68C);
      case EmotionType.alegria:
        return const Color(0xFFD8A657);
    }
  }
}

/// Result of analyzing a journal entry.
///
/// Today this is always produced by mock data / [AiJournalService] stubs.
/// Later this should be the parsed response of a real AI/LLM call.
class EmotionResult {
  const EmotionResult({
    required this.emotion,
    required this.feedbackText,
    required this.suggestions,
    this.intensity = 0.6,
    this.keywords = const [],
  });

  final EmotionType emotion;
  final String feedbackText;
  final List<String> suggestions;

  /// Mock "confidence"/intensity of the detected emotion, 0.0-1.0.
  /// Stands in for whatever score a real AI model would return.
  final double intensity;

  /// Mock topics/keywords the AI would have extracted from the text.
  final List<String> keywords;

  /// Parses the `emotionResult` object from the backend's journal response
  /// (see backend.md section 4, `GET/POST /journals`). Ignores the sibling
  /// `recommendedActions` field on the journal — there's no client-side
  /// model for that yet.
  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    return EmotionResult(
      emotion: EmotionType.values.byName(json['emotion'] as String),
      feedbackText: json['feedbackText'] as String,
      intensity: (json['intensity'] as num).toDouble(),
      keywords: (json['keywords'] as List).cast<String>(),
      suggestions: (json['suggestions'] as List).cast<String>(),
    );
  }
}
