import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/job_type_model.dart';

/// Servicio de catálogo de tipos de empleo.
/// Consume GET /job-types.
class JobTypeService {
  final ApiClient _client;

  JobTypeService(this._client);

  /// GET /job-types – devuelve la lista de tipos de empleo con sus campos dinámicos.
  Future<List<JobTypeModel>> getJobTypes() async {
    final response = await _client.get(ApiConstants.jobTypes);
    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => JobTypeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
