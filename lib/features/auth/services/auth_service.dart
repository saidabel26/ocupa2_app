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

  /// PUT /me/profile — actualiza nombre, email o foto del usuario autenticado.
  /// El endpoint puede devolver { ok, data: {...} } o la data directamente.
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    String? cedula,
    String? gender,
    DateTime? birthDate,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (email != null) body['email'] = email;
    if (photoUrl != null) body['photo'] = photoUrl;
    if (cedula != null) body['cedula'] = cedula;
    if (gender != null) body['gender'] = gender;
    if (birthDate != null) body['birthDate'] = birthDate.toIso8601String().split('T').first;

    final response = await _client.put(ApiConstants.meProfile, body: body);

    // El API puede responder con wrapper { data: {...} } o directo
    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      return UserModel.fromJson(rawData);
    }
    // Si no hay wrapper 'data', intentar parsear la respuesta completa como usuario
    // o refrescar desde /me
    return await getMe();
  }

  /// POST /uploads — sube una imagen en base64 (o data URI) y retorna la URL pública.
  /// Según el API, el campo 'image' acepta base64 puro o data URI (data:image/...;base64,...).
  Future<String> uploadImage({
    required String base64Image,
    required String filename,
  }) async {
    final response = await _client.post(
      ApiConstants.uploads,
      body: {
        'image': base64Image,
        'filename': filename,
      },
    );
    // Manejo robusto: el API devuelve { ok, data: { key, url, mime, size } }
    final rawData = response['data'];
    if (rawData is Map<String, dynamic>) {
      final url = rawData['url'];
      if (url is String && url.isNotEmpty) return url;
    }
    throw Exception('La respuesta del servidor no incluyó una URL válida.');
  }
}
