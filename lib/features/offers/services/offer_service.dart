import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/offer_model.dart';
import '../models/application_model.dart';

/// Servicio de ofertas.
/// Consume GET /offers, GET /offers/{id}, POST /offers,
/// GET /me/offers, GET /offers/{id}/applications, POST /offers/{id}/deactivate.
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

  /// POST /offers – publicar una oferta.
  /// Requiere [paymentId] de un pago aprobado y [photo] (URL de /uploads).
  Future<OfferModel> createOffer({
    required String jobTypeKey,
    required String contractType,
    required String description,
    required String address,
    required String photo,
    required String paymentId,
    double? locationLat,
    double? locationLng,
    double? paymentAmount,
    String? paymentCurrency,
    String? deadline,
    Map<String, dynamic>? customAnswers,
    List<Map<String, dynamic>>? questions,
  }) async {
    final body = <String, dynamic>{
      'jobTypeKey': jobTypeKey,
      'contractType': contractType,
      'description': description,
      'address': address,
      'photo': photo,
      'paymentId': paymentId,
    };

    if (locationLat != null && locationLng != null) {
      body['location'] = {'lat': locationLat, 'lng': locationLng};
    }

    if (paymentAmount != null) {
      body['payment'] = {
        'amount': paymentAmount,
        'currency': paymentCurrency ?? 'DOP',
      };
    }

    if (deadline != null && deadline.isNotEmpty) {
      body['deadline'] = deadline;
    }

    if (customAnswers != null && customAnswers.isNotEmpty) {
      body['customAnswers'] = customAnswers;
    }

    if (questions != null && questions.isNotEmpty) {
      body['questions'] = questions;
    }

    final response = await _client.post(ApiConstants.offers, body: body);
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final inner = data['offer'];
      if (inner is Map<String, dynamic>) {
        return OfferModel.fromJson(inner);
      }
      return OfferModel.fromJson(data);
    }
    throw Exception('Respuesta inesperada al crear la oferta.');
  }

  /// GET /me/offers – mis ofertas publicadas.
  Future<List<OfferModel>> getMyOffers() async {
    final response = await _client.get(ApiConstants.meOffers);
    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
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

  /// GET /offers/{id}/applications – aplicantes de mi oferta (solo dueño).
  Future<List<ApplicationModel>> getApplications(String offerId) async {
    final response =
        await _client.get('${ApiConstants.offers}/$offerId/applications');
    final data = response['data'];
    if (data is List) {
      return data
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final list = data['items'] as List<dynamic>? ??
          data['results'] as List<dynamic>? ??
          [];
      return list
          .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// POST /offers/{id}/deactivate – desactivar mi oferta.
  Future<void> deactivateOffer(String offerId) async {
    await _client.post('${ApiConstants.offers}/$offerId/deactivate');
  }
}

