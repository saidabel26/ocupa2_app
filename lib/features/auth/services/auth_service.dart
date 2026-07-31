import '../../../core/constants/api_constants.dart';
import '../../../core/http/api_client.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

/// Servicio de autenticación.
/// Consume los endpoints de auth y perfil del API de Ocupa2.
class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  /// POST /auth/register
  Future<AuthResponse> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    final response = await _client.post(
      ApiConstants.register,
      body: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
        'referralMatricula': referralMatricula,
      },
      requiresAuth: false,
    );
    return AuthResponse.fromJson(response);
  }

  /// POST /auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );
    return AuthResponse.fromJson(response);
  }

  /// POST /auth/forgot-password
  /// Devuelve true si la solicitud fue exitosa (200).
  Future<bool> forgotPassword({
    required String email,
    required String referralMatricula,
  }) async {
    await _client.post(
      ApiConstants.forgotPassword,
      body: {
        'email': email,
        'referralMatricula': referralMatricula,
      },
      requiresAuth: false,
    );
    return true;
  }

  /// GET /me
  Future<UserModel> getMe() async {
    final response = await _client.get(ApiConstants.me);
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
