import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/application_model.dart';

/// Servicio de aplicaciones (postulaciones) desde la perspectiva del publicante.
/// Consume PATCH /applications/{id}.
class ApplicationService {
  final ApiClient _client;

  ApplicationService(this._client);

  /// PATCH /applications/{id} – calificar, descartar, marcar finalista o ganador.
  /// [status]: 'applied' | 'discarded' | 'finalist' | 'winner'
  /// [rating]: 1–5 (opcional)
  Future<ApplicationModel> patchApplication(
    String applicationId, {
    String? status,
    int? rating,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (rating != null) body['rating'] = rating;

    final response = await _client.patch(
      '${ApiConstants.applications}/$applicationId',
      body: body,
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      // El API puede devolver la aplicación en data o en data.application
      final inner = data['application'];
      if (inner is Map<String, dynamic>) {
        return ApplicationModel.fromJson(inner);
      }
      return ApplicationModel.fromJson(data);
    }

    throw Exception('Respuesta inesperada al actualizar la aplicación.');
  }
}
