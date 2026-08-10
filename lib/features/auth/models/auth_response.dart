import 'user_model.dart';

/// Respuesta de autenticación del API (login y registro).
class AuthResponse {
  final String token;
  final String tokenType;
  final UserModel user;

  const AuthResponse({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponse(
      token: data['token'] as String? ?? '',
      tokenType: data['tokenType'] as String? ?? 'Bearer',
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
