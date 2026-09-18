import 'package:dio/dio.dart';

import '../../../shared/data/api_client.dart';
import '../models/psicologo.dart';
import 'psychologist_repository.dart';

/// Real implementation of [PsychologistRepository] against
/// `journaly-backend` (see backend.md, `GET /psychologists`).
class ApiPsychologistRepository implements PsychologistRepository {
  ApiPsychologistRepository({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  @override
  Future<List<Psicologo>> fetchPsicologos() async {
    final response = await _dio.get('/psychologists');
    final data = response.data as List;
    return data.map((json) => Psicologo.fromJson(json as Map<String, dynamic>)).toList();
  }
}
