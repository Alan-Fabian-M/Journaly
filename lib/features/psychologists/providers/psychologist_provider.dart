import 'package:flutter/foundation.dart';

import '../data/mock_psychologist_repository.dart';
import '../data/psychologist_repository.dart';
import '../models/psicologo.dart';

/// Loads the psychologist directory through a [PsychologistRepository].
/// Exposes a loading flag so the UI already handles the latency a real
/// network call will introduce once `MockPsychologistRepository` is swapped
/// for an `ApiPsychologistRepository`.
class PsychologistProvider extends ChangeNotifier {
  PsychologistProvider({PsychologistRepository? repository})
      : _repository = repository ?? MockPsychologistRepository() {
    _load();
  }

  final PsychologistRepository _repository;

  List<Psicologo> _psicologos = [];
  bool _isLoading = true;

  List<Psicologo> get psicologos => List.unmodifiable(_psicologos);
  bool get isLoading => _isLoading;

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _psicologos = await _repository.fetchPsicologos();
    } catch (e) {
      // No tumbamos la pantalla si el backend no está corriendo al abrir la
      // app — se queda con la lista vacía.
      debugPrint('PsychologistProvider: no se pudo cargar el listado ($e)');
    }

    _isLoading = false;
    notifyListeners();
  }
}
