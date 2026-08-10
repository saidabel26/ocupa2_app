import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/application_model.dart';

/// Servicio de aplicaciones (postulaciones).
/// - Perspectiva del publicante: PATCH /applications/{id}.
/// - Perspectiva del aplicante: POST /offers/{id}/apply.
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

  /// POST /offers/{id}/apply – aplicar a una oferta como candidato.
  /// [comment]: Por qué te consideras apto (requerido).
  /// [answers]: Respuestas a las preguntas adicionales de la oferta (opcional).
  Future<ApplicationModel> applyToOffer(
    String offerId, {
    required String comment,
    List<Map<String, dynamic>>? answers,
  }) async {
    final body = <String, dynamic>{
      'comment': comment,
      if (answers != null && answers.isNotEmpty) 'answers': answers,
    };

    final response = await _client.post(
      '${ApiConstants.offers}/$offerId/apply',
      body: body,
    );

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final inner = data['application'];
      if (inner is Map<String, dynamic>) {
        return ApplicationModel.fromJson(inner);
      }
      return ApplicationModel.fromJson(data);
    }

    throw Exception('Respuesta inesperada al aplicar a la oferta.');
  }
}
