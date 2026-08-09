import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/news_model.dart';

/// Servicio de noticias.
/// Consume GET /news y GET /news/{id}.
class NewsService {
  final ApiClient _client;

  NewsService(this._client);

  /// GET /news – listado de noticias paginado.
  Future<List<NewsModel>> getNews() async {
    final response = await _client.get(ApiConstants.news);
    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Algunos endpoints envuelven el listado en data.items o data.results
    if (data is Map<String, dynamic>) {
      final list =
          data['items'] as List<dynamic>? ??
          data['results'] as List<dynamic>? ??
          [];
      return list
          .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /news/{id} – detalle de una noticia.
  Future<NewsModel> getNewsDetail(String id) async {
    final response = await _client.get('${ApiConstants.news}/$id');
    final data = response['data'] as Map<String, dynamic>;
    return NewsModel.fromJson(data);
  }
}
