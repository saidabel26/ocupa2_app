import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

/// Gestiona el flujo del cobro de 1 USD requerido para publicar una oferta.
class PaymentProvider extends ChangeNotifier {
  final PaymentService _service;

  PaymentModel? _lastPayment;
  bool _isLoading = false;
  String? _error;

  PaymentProvider(this._service);

  PaymentModel? get lastPayment => _lastPayment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// El paymentId resultante del último pago aprobado, listo para usar en POST /offers.
  String? get paymentId => _lastPayment?.id;

  /// Procesa el cobro simulado.
  /// Actualiza [lastPayment] y retorna true si fue aprobado, false si hubo error.
  Future<bool> processPayment({
    required String cardNumber,
    required String cvv,
    required int expMonth,
    required int expYear,
    String? cardholder,
  }) async {
    _isLoading = true;
    _error = null;
    _lastPayment = null;
    notifyListeners();

    try {
      _lastPayment = await _service.processPayment(
        cardNumber: cardNumber,
        cvv: cvv,
        expMonth: expMonth,
        expYear: expYear,
        cardholder: cardholder,
      );
      return true;
    } on AppError catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error al procesar el pago. Verifica los datos de la tarjeta.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia el pago actual (por ejemplo al cerrar el formulario).
  void reset() {
    _lastPayment = null;
    _error = null;
    notifyListeners();
  }
}
