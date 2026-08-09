import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../services/password_service.dart';

/// Estado del flujo de cambio de contraseña.
enum ChangePasswordStatus { idle, loading, success, error }

/// Provider para el módulo "Cambiar Contraseña".
/// Consume PUT /me/password.
class ChangePasswordProvider extends ChangeNotifier {
  final PasswordService _service;

  ChangePasswordProvider(this._service);

  ChangePasswordStatus _status = ChangePasswordStatus.idle;
  String? _error;

  ChangePasswordStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ChangePasswordStatus.loading;
  bool get isSuccess => _status == ChangePasswordStatus.success;

  /// Cambia la contraseña del usuario autenticado.
  /// Retorna true si el cambio fue exitoso.
  Future<bool> changePassword(String newPassword) async {
    _status = ChangePasswordStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _service.changePassword(newPassword);
      _status = ChangePasswordStatus.success;
      notifyListeners();
      return true;
    } on AppError catch (e) {
      _error = e.message;
      _status = ChangePasswordStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'No se pudo cambiar la contraseña. Inténtalo de nuevo.';
      _status = ChangePasswordStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Reinicia el estado al salir de la pantalla.
  void reset() {
    _status = ChangePasswordStatus.idle;
    _error = null;
    notifyListeners();
  }
}
