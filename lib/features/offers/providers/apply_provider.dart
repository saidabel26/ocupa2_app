import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

/// Estado del formulario de aplicación a una oferta.
enum ApplyStatus { idle, submitting, success, error }

/// Provider para el formulario de aplicación.
/// Gestiona el envío de POST /offers/{id}/apply.
class ApplyProvider extends ChangeNotifier {
  final ApplicationService _service;

  ApplyProvider(this._service);

  ApplyStatus _status = ApplyStatus.idle;
  String? _error;
  ApplicationModel? _result;

  ApplyStatus get status => _status;
  String? get error => _error;
  ApplicationModel? get result => _result;
  bool get isSubmitting => _status == ApplyStatus.submitting;

  /// Envía la aplicación al API.
  Future<bool> apply(
    String offerId, {
    required String comment,
    List<Map<String, dynamic>>? answers,
  }) async {
    _status = ApplyStatus.submitting;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _service.applyToOffer(
        offerId,
        comment: comment,
        answers: answers,
      );
      _status = ApplyStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _status = ApplyStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Reinicia el estado (para reutilizar el provider en otra oferta).
  void reset() {
    _status = ApplyStatus.idle;
    _error = null;
    _result = null;
    notifyListeners();
  }

  String _extractMessage(Object e) {
    final str = e.toString();
    if (str.contains('409') || str.contains('Ya aplicaste')) {
      return 'Ya tienes una aplicación en revisión para esta oferta.';
    }
    if (str.contains('403') || str.contains('propia')) {
      return 'No puedes aplicar a tu propia oferta.';
    }
    if (str.contains('network') || str.contains('SocketException')) {
      return 'Sin conexión. Verifica tu red.';
    }
    final match = RegExp(r'message: (.+)').firstMatch(str);
    if (match != null) return match.group(1)!;
    return 'No se pudo enviar la aplicación. Intenta de nuevo.';
  }
}
