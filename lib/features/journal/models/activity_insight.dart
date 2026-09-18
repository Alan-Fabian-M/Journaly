/// An activity from the user's journals mentioned repeatedly with negative
/// valence — see `GET /activity-insights` in backend.md — surfaced as a
/// "consider doing less of this" suggestion, the inverse of `RecommendedAction`.
class ActivityInsight {
  const ActivityInsight({
    required this.activity,
    required this.mentions,
    required this.score,
  });

  final String activity;
  final int mentions;
  final int score;

  factory ActivityInsight.fromJson(Map<String, dynamic> json) {
    return ActivityInsight(
      activity: json['activity'] as String,
      mentions: json['mentions'] as int,
      score: json['score'] as int,
    );
  }
}
