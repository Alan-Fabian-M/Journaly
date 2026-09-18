import '../models/psicologo.dart';
import 'mock_psicologos.dart';
import 'psychologist_repository.dart';

/// In-memory implementation backed by [mockPsicologos], with a small
/// artificial delay to mimic a real network call.
class MockPsychologistRepository implements PsychologistRepository {
  @override
  Future<List<Psicologo>> fetchPsicologos() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(mockPsicologos);
  }
}
