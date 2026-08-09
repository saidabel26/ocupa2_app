import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/application_model.dart';
import '../services/my_applications_service.dart';

/// Estado de carga para las aplicaciones propias.
enum MyApplicationsStatus { idle, loading, success, error }

/// Provider para el módulo "Mis Aplicaciones".
/// Consume GET /me/applications y expone la lista al UI.
class MyApplicationsProvider extends ChangeNotifier {
  final MyApplicationsService _service;

  MyApplicationsProvider(this._service);

  List<ApplicationModel> _applications = [];
  MyApplicationsStatus _status = MyApplicationsStatus.idle;
  String? _error;

  List<ApplicationModel> get applications =>
      List.unmodifiable(_applications);
  MyApplicationsStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == MyApplicationsStatus.loading;

  /// Carga (o recarga) las postulaciones del usuario autenticado.
  Future<void> loadApplications() async {
    _status = MyApplicationsStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _applications = await _service.getMyApplications();
      _status = MyApplicationsStatus.success;
    } on AppError catch (e) {
      _error = e.message;
      _status = MyApplicationsStatus.error;
    } catch (e) {
      _error = 'No se pudieron cargar tus aplicaciones.';
      _status = MyApplicationsStatus.error;
    }

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
