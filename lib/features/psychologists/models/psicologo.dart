/// A psychologist profile.
///
/// Mock-only for this MVP. Later this should come from a real
/// psychologists/booking API with the same field shape.
class Psicologo {
  const Psicologo({
    required this.id,
    required this.name,
    required this.initials,
    required this.specialty,
    required this.rating,
    required this.bio,
    required this.availability,
  });

  final String id;
  final String name;
  final String initials;
  final String specialty;
  final double rating;
  final String bio;
  final List<String> availability;

  /// Parses a psychologist object as returned by the backend (see
  /// backend.md section 4, `GET /psychologists`).
  factory Psicologo.fromJson(Map<String, dynamic> json) {
    return Psicologo(
      id: json['id'] as String,
      name: json['name'] as String,
      initials: json['initials'] as String,
      specialty: json['specialty'] as String,
      rating: (json['rating'] as num).toDouble(),
      bio: json['bio'] as String,
      availability: (json['availability'] as List).cast<String>(),
    );
  }
}
