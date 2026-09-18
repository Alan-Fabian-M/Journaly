/// A coping action recommended by the backend's matching engine for a
/// specific journal (see backend.md sección 3, motor de matching).
class RecommendedAction {
  const RecommendedAction({
    required this.id,
    required this.recommendationId,
    required this.title,
    required this.score,
  });

  /// `coping_action` id — the catalog entry this recommendation points to.
  final String id;

  /// `journal_action_recommendations` id — this is what
  /// `POST /recommendations/{id}/feedback` expects, NOT [id] above.
  final String recommendationId;

  final String title;
  final double score;

  factory RecommendedAction.fromJson(Map<String, dynamic> json) {
    return RecommendedAction(
      id: json['id'] as String,
      recommendationId: json['recommendationId'] as String,
      title: json['title'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }
}
