import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';

/// Servicio de cambio de contraseña.
/// Consume PUT /me/password.
/// Según el Swagger confirmado, el request body es: { "password": "string" }
class PasswordService {
  final ApiClient _client;

  PasswordService(this._client);

  /// Actualiza la contraseña del usuario autenticado.
  /// [newPassword] debe tener al menos 6 caracteres.
  Future<void> changePassword(String newPassword) async {
    await _client.put(ApiConstants.mePassword, body: {'password': newPassword});
  }
}
