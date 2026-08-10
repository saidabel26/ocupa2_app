import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/app_error.dart';

/// Cliente HTTP centralizado.
/// Agrega el token JWT en cada petición autenticada y maneja errores globales.
class ApiClient {
  static const Duration _requestTimeout = Duration(seconds: 20);

  final String baseUrl;
  String? _token;

  ApiClient({this.baseUrl = ApiConstants.baseUrl});

  /// Establece el token de autenticación para las solicitudes subsecuentes.
  void setToken(String? token) {
    _token = token;
  }

  /// Limpia el token (logout).
  void clearToken() {
    _token = null;
  }

  Map<String, String> _headers({bool requiresAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
      );
    }
    return uri;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.get(
        _uri(path, queryParams),
        headers: _headers(requiresAuth: requiresAuth),
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on AppError {
      rethrow;
    } catch (e) {
      throw AppError.network();
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.post(
        _uri(path),
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on AppError {
      rethrow;
    } catch (e) {
      throw AppError.network();
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.put(
        _uri(path),
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on AppError {
      rethrow;
    } catch (e) {
      throw AppError.network();
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.patch(
        _uri(path),
        headers: _headers(requiresAuth: requiresAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on AppError {
      rethrow;
    } catch (e) {
      throw AppError.network();
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await http.delete(
        _uri(path),
        headers: _headers(requiresAuth: requiresAuth),
      ).timeout(_requestTimeout);
      return _handleResponse(response);
    } on AppError {
      rethrow;
    } catch (e) {
      throw AppError.network();
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return {'ok': true};
      try {
        return jsonDecode(body) as Map<String, dynamic>;
      } catch (_) {
        return {'ok': true};
      }
    }
    throw AppError.fromStatusCode(response.statusCode, body: body);
  }
}
