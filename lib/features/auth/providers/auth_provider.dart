// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/http/api_client.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Gestiona el estado de autenticación de la sesión.
/// Persiste el token en SharedPreferences para sesión persistente.
class AuthProvider extends ChangeNotifier {
  static const String _tokenKey = 'ocupa2_auth_token';

  final ApiClient _apiClient;
  final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required ApiClient apiClient, required AuthService authService})
    : _apiClient = apiClient,
      _authService = authService;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get profileCompleted => _user?.profileCompleted ?? false;

  /// Inicializa la sesión leyendo el token guardado en SharedPreferences.
  /// Debe llamarse en main() antes de arrancar la app.
  Future<void> initSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _apiClient.setToken(token);

    try {
      // Revalidar el token con GET /me y actualizar profileCompleted
      final userModel = await _authService.getMe();
      _user = userModel;
      _status = AuthStatus.authenticated;
    } catch (_) {
      // Token inválido o expirado → sesión limpia
      await _clearSession(prefs);
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  /// Registra un nuevo usuario y lo autentica directamente.
  Future<void> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String referralMatricula,
  }) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        referralMatricula: referralMatricula,
      );
      await _persistSession(authResponse);
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia sesión con email y contraseña.
  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.login(
        email: email,
        password: password,
      );
      await _persistSession(authResponse);
    } finally {
      _setLoading(false);
    }
  }

  /// Cierra la sesión actual.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
  }

  /// Actualiza el usuario en memoria (llamado por partes futuras tras completar perfil).
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> _persistSession(AuthResponse authResponse) async {
    _apiClient.setToken(authResponse.token);
    _user = authResponse.user;
    _status = AuthStatus.authenticated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.token);

    notifyListeners();
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.remove(_tokenKey);
    _apiClient.clearToken();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }
}
