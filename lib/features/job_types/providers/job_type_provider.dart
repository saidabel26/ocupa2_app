import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/job_type_model.dart';
import '../services/job_type_service.dart';

/// Proveedor del catálogo de tipos de empleo.
/// Cachea la lista para evitar peticiones redundantes.
class JobTypeProvider extends ChangeNotifier {
  final JobTypeService _service;

  List<JobTypeModel> _jobTypes = [];
  bool _isLoading = false;
  String? _error;
  bool _loaded = false;

  JobTypeProvider(this._service);

  List<JobTypeModel> get jobTypes => _jobTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get loaded => _loaded;

  /// Carga el catálogo desde el API.
  /// Si ya está cargado, no vuelve a pedir al servidor (a menos que [force] sea true).
  Future<void> loadJobTypes({bool force = false}) async {
    if (_loaded && !force) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobTypes = await _service.getJobTypes();
      _loaded = true;
    } on AppError catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Error al cargar los tipos de empleo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Retorna un tipo de empleo por su clave pública, o null si no está cargado.
  JobTypeModel? findByKey(String key) {
    try {
      return _jobTypes.firstWhere((jt) => jt.key == key);
    } catch (_) {
      return null;
    }
  }
}
