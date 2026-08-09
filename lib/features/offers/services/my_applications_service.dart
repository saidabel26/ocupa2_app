import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/application_model.dart';

/// Servicio para obtener las postulaciones propias del usuario.
/// Consume GET /me/applications.
class MyApplicationsService {
  final ApiClient _client;

  MyApplicationsService(this._client);

  /// Retorna la lista de postulaciones del usuario autenticado.
  Future<List<ApplicationModel>> getMyApplications() async {
    final response = await _client.get(ApiConstants.meApplications);
    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final items = data['items'] ?? data['applications'] ?? data['data'];
      if (items is List) {
        return items
            .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }
}
