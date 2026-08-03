import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/offer_model.dart';

/// Servicio de ofertas.
/// Consume GET /offers y GET /offers/{id}.
class OfferService {
  final ApiClient _client;

  OfferService(this._client);

  /// GET /offers – listado de ofertas con filtros opcionales.
  Future<List<OfferModel>> getOffers({
    String? jobTypeKey,
    String? contractType,
  }) async {
    final queryParams = <String, dynamic>{};
    if (jobTypeKey != null && jobTypeKey.isNotEmpty) {
      queryParams['jobTypeKey'] = jobTypeKey;
      queryParams['jobType'] = jobTypeKey;
    }
    if (contractType != null && contractType.isNotEmpty) {
      queryParams['contractType'] = contractType;
    }

    final response = await _client.get(
      ApiConstants.offers,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    // Algunos endpoints envuelven el listado en data.items o data.results
    if (data is Map<String, dynamic>) {
      final list = data['items'] as List<dynamic>? ??
          data['results'] as List<dynamic>? ??
          [];
      return list
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// GET /offers/{id} – detalle de una oferta.
  Future<OfferModel> getOfferDetail(String id) async {
    final response = await _client.get('${ApiConstants.offers}/$id');
    final data = response['data'] as Map<String, dynamic>;
    return OfferModel.fromJson(data);
  }
}
