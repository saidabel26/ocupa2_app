import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/payment_model.dart';

/// Servicio para consultar el historial de pagos del usuario.
/// Consume GET /me/payments.
class MyPaymentsService {
  final ApiClient _client;

  MyPaymentsService(this._client);

  /// Retorna la lista de pagos realizados por el usuario autenticado.
  Future<List<PaymentModel>> getMyPayments() async {
    final response = await _client.get(ApiConstants.mePayments);
    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final items = data['items'] ?? data['payments'] ?? data['data'];
      if (items is List) {
        return items
            .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }
}
