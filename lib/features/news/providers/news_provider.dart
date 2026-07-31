import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

/// Proveedor de noticias (listado + detalle seleccionado).
class NewsProvider extends ChangeNotifier {
  final NewsService _service;

  List<NewsModel> _newsList = [];
  NewsModel? _selectedNews;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  NewsProvider(this._service);

  List<NewsModel> get newsList => _newsList;
  NewsModel? get selectedNews => _selectedNews;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;

  /// Carga el listado de noticias desde GET /news.
  Future<void> loadNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _newsList = await _service.getNews();
    } on AppError catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Error al cargar las noticias.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga el detalle de una noticia por id.
  /// Intenta primero buscarlo en la lista ya cargada; si no lo encuentra
  /// hace GET /news/{id}.
  Future<void> loadNewsDetail(String id) async {
    // Intentar desde caché primero
    final cached = _newsList.where((n) => n.id == id).toList();
    if (cached.isNotEmpty) {
      _selectedNews = cached.first;
      notifyListeners();
      return;
    }

    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _selectedNews = await _service.getNewsDetail(id);
    } on AppError catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Error al cargar el detalle de la noticia.';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void clearSelected() {
    _selectedNews = null;
  }
}
