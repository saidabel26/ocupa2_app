import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/experience_model.dart';

/// Servicio para gestionar experiencias del usuario.
/// Consume GET /me/experiences, POST /me/experiences, DELETE /me/experiences/{id}.
class ExperienceService {
  final ApiClient _client;

  ExperienceService(this._client);

  /// GET /me/experiences – lista de mis experiencias.
  Future<List<ExperienceModel>> getExperiences() async {
    final response = await _client.get(ApiConstants.meExperiences);
    final raw = response['data'];
    final List<dynamic> list = raw is List ? raw : (raw is Map ? [] : []);
    return list
        .map((e) => ExperienceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /me/experiences – agrega una nueva experiencia.
  /// [title], [description] son requeridos.
  /// [jobTypeKey] y [certificateImage] son opcionales.
  Future<ExperienceModel> addExperience({
    required String title,
    required String description,
    String? jobTypeKey,
    String? certificateImage,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      if (jobTypeKey != null && jobTypeKey.isNotEmpty) 'jobTypeKey': jobTypeKey,
      if (certificateImage != null && certificateImage.isNotEmpty)
        'certificateImage': certificateImage,
    };

    final response = await _client.post(
      ApiConstants.meExperiences,
      body: body,
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final inner = data['experience'];
      if (inner is Map<String, dynamic>) {
        return ExperienceModel.fromJson(inner);
      }
      return ExperienceModel.fromJson(data);
    }

    throw Exception('Respuesta inesperada al agregar experiencia.');
  }

  /// DELETE /me/experiences/{id} – elimina una experiencia.
  Future<void> deleteExperience(String id) async {
    await _client.delete('${ApiConstants.meExperiences}/$id');
  }
}
