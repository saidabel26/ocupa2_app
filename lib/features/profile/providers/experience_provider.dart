import 'package:flutter/material.dart';
import '../models/experience_model.dart';
import '../services/experience_service.dart';

/// Estado de carga para operaciones de experiencias.
enum ExperienceStatus { idle, loading, success, error }

/// Provider para gestionar las experiencias del usuario (Mi Perfil / Experiencias).
/// Sigue el mismo patrón ChangeNotifier del proyecto.
class ExperienceProvider extends ChangeNotifier {
  final ExperienceService _service;

  ExperienceProvider(this._service);

  List<ExperienceModel> _experiences = [];
  ExperienceStatus _status = ExperienceStatus.idle;
  String? _error;
  bool _isSubmitting = false;

  List<ExperienceModel> get experiences => List.unmodifiable(_experiences);
  ExperienceStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ExperienceStatus.loading;
  bool get isSubmitting => _isSubmitting;

  /// Carga la lista de experiencias del usuario.
  Future<void> loadExperiences() async {
    _status = ExperienceStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _experiences = await _service.getExperiences();
      _status = ExperienceStatus.success;
    } catch (e) {
      _error = _extractMessage(e);
      _status = ExperienceStatus.error;
    }

    notifyListeners();
  }

  /// Agrega una experiencia al servidor y la inserta en la lista local.
  Future<bool> addExperience({
    required String title,
    required String description,
    String? jobTypeKey,
    String? certificateImage,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final created = await _service.addExperience(
        title: title,
        description: description,
        jobTypeKey: jobTypeKey,
        certificateImage: certificateImage,
      );
      _experiences = [created, ..._experiences];
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Elimina una experiencia del servidor y la quita de la lista local.
  Future<bool> deleteExperience(String id) async {
    _error = null;
    try {
      await _service.deleteExperience(id);
      _experiences = _experiences.where((e) => e.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _extractMessage(Object e) {
    final str = e.toString();
    // Intenta extraer el mensaje del AppError
    final match = RegExp(r'message: (.+)').firstMatch(str);
    if (match != null) return match.group(1)!;
    if (str.contains('network') || str.contains('SocketException')) {
      return 'Sin conexión. Verifica tu red.';
    }
    return 'Ocurrió un error inesperado.';
  }
}
