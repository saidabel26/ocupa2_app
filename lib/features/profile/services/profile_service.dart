import '../../../core/http/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../features/auth/models/user_model.dart';
import '../models/profile_request.dart';

/// Servicio para actualizar el perfil del usuario.
/// Consume PUT /me/profile y devuelve el UserModel actualizado.
class ProfileService {
  final ApiClient _client;

  ProfileService(this._client);

  /// PUT /me/profile – actualiza los datos de perfil del usuario.
  /// Retorna el [UserModel] actualizado desde el campo data de la respuesta.
  Future<UserModel> updateProfile(ProfileRequest request) async {
    final response = await _client.put(
      ApiConstants.meProfile,
      body: request.toJson(),
    );
    // El API devuelve { ok: true, data: { ...user } }
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
