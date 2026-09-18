import '../models/psicologo.dart';

/// Contract for the psychologists directory/booking data.
/// `MockPsychologistRepository` is the only implementation today; a future
/// `ApiPsychologistRepository` should implement this same interface against
/// real HTTP endpoints (see `shared/data/api_client.dart` for the Dio
/// client this would use).
abstract class PsychologistRepository {
  /// TODO: reemplazar por `GET /psychologists` (con filtros de búsqueda).
  Future<List<Psicologo>> fetchPsicologos();
}
