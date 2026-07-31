import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

/// Proveedor de videos educativos.
class VideoProvider extends ChangeNotifier {
  final VideoService _service;

  List<VideoModel> _videos = [];
  bool _isLoading = false;
  String? _error;
  bool _loaded = false;

  VideoProvider(this._service);

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get loaded => _loaded;

  /// Carga el listado de videos desde GET /videos.
  Future<void> loadVideos({bool force = false}) async {
    if (_loaded && !force) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _videos = await _service.getVideos();
      _loaded = true;
    } on AppError catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Error al cargar los videos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
