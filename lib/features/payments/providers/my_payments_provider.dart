import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/payment_model.dart';
import '../services/my_payments_service.dart';

/// Estado de carga para el historial de pagos.
enum MyPaymentsStatus { idle, loading, success, error }

/// Provider para el módulo "Mis Pagos".
/// Consume GET /me/payments y expone la lista al UI.
class MyPaymentsProvider extends ChangeNotifier {
  final MyPaymentsService _service;

  MyPaymentsProvider(this._service);

  List<PaymentModel> _payments = [];
  MyPaymentsStatus _status = MyPaymentsStatus.idle;
  String? _error;

  List<PaymentModel> get payments => List.unmodifiable(_payments);
  MyPaymentsStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == MyPaymentsStatus.loading;

  /// Carga (o recarga) el historial de pagos del usuario autenticado.
  Future<void> loadPayments() async {
    _status = MyPaymentsStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _payments = await _service.getMyPayments();
      _status = MyPaymentsStatus.success;
    } on AppError catch (e) {
      _error = e.message;
      _status = MyPaymentsStatus.error;
    } catch (e) {
      _error = 'No se pudo cargar el historial de pagos.';
      _status = MyPaymentsStatus.error;
    }

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
