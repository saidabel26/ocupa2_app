import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/video_model.dart';

/// Servicio de videos educativos.
/// Consume GET /videos.
class VideoService {
  final ApiClient _client;

  VideoService(this._client);

  /// GET /videos – listado de videos educativos.
  Future<List<VideoModel>> getVideos() async {
    final response = await _client.get(ApiConstants.videos);
    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['items'] as List<dynamic>? ??
          data['results'] as List<dynamic>? ??
          [];
      return list
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
