import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/payment_model.dart';

/// Servicio de pagos simulados.
/// Consume POST /payments para procesar el cobro de 1 USD requerido para publicar.
class PaymentService {
  final ApiClient _client;

  PaymentService(this._client);

  /// POST /payments – procesa un cobro simulado.
  /// Retorna el [PaymentModel] con el id de pago para usarlo al crear la oferta.
  /// Lanza [AppError] si la tarjeta es rechazada (402).
  Future<PaymentModel> processPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    String? cardholder,
  }) async {
    final body = <String, dynamic>{
      'cardNumber': cardNumber,
      'cvv': cvv,
      'expMonth': expMonth,
      'expYear': expYear,
      if (cardholder != null && cardholder.isNotEmpty) 'cardholder': cardholder,
    };

    final response = await _client.post(ApiConstants.payments, body: body);
    final data = response['data'];

    // El API puede devolver el payment en data directamente o en data.payment
    if (data is Map<String, dynamic>) {
      final inner = data['payment'];
      if (inner is Map<String, dynamic>) {
        return PaymentModel.fromJson(inner);
      }
      return PaymentModel.fromJson(data);
    }

    throw Exception('Respuesta inesperada del servidor de pagos.');
  }
}
