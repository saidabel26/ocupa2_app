import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/profile_request.dart';
import '../services/profile_service.dart';
import '../../../features/auth/models/user_model.dart';

/// Estado del proceso de completar / actualizar perfil.
class ProfileProvider extends ChangeNotifier {
  final ProfileService _service;

  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._service);

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Envía PUT /me/profile y retorna el [UserModel] actualizado.
  /// Lanza [AppError] si el servidor rechaza los datos.
  Future<UserModel> updateProfile(ProfileRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _service.updateProfile(request);
      return updatedUser;
    } on AppError catch (e) {
      _error = e.message;
      rethrow;
    } catch (_) {
      _error = 'Error inesperado al actualizar el perfil.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
