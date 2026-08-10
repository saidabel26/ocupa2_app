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
  String? _error;

  NewsProvider(this._service);

  List<NewsModel> get newsList => _newsList;
  NewsModel? get selectedNews => _selectedNews;
  bool get isLoading => _isLoading;
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
  /// El detalle se obtiene desde el listado cargado, que es el único endpoint
  /// de noticias disponible en el contrato del API.
  Future<void> loadNewsDetail(String id) async {
    final cached = _newsList.where((n) => n.id == id).toList();
    if (cached.isNotEmpty) {
      _selectedNews = cached.first;
      _error = null;
    } else {
      _selectedNews = null;
      _error = 'Detalle de noticia no encontrado.';
    }
    notifyListeners();
  }

  void clearSelected() {
    _selectedNews = null;
  }
}
