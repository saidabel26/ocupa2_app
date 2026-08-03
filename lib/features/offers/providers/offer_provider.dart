import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/offer_model.dart';
import '../services/offer_service.dart';

/// Proveedor de ofertas (listado con filtro + detalle).
class OfferProvider extends ChangeNotifier {
  final OfferService _service;

  List<OfferModel> _offers = [];
  OfferModel? _selectedOffer;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;
  String? _selectedJobTypeKey;

  OfferProvider(this._service);

  List<OfferModel> get offers => _offers;
  OfferModel? get selectedOffer => _selectedOffer;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  String? get selectedJobTypeKey => _selectedJobTypeKey;

  /// Ofertas que tienen coordenadas válidas (para el mapa).
  List<OfferModel> get offersWithLocation =>
      _offers.where((o) => o.hasLocation).toList();

  /// Carga el listado de ofertas con filtro opcional por tipo de empleo.
  Future<void> loadOffers({String? jobTypeKey}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _offers = await _service.getOffers(jobTypeKey: jobTypeKey);
    } on AppError catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Error al cargar las ofertas.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia el filtro de tipo de empleo y recarga la lista.
  Future<void> setFilter(String? jobTypeKey) async {
    _selectedJobTypeKey = jobTypeKey;
    await loadOffers(jobTypeKey: jobTypeKey);
  }

  /// Carga el detalle de una oferta.
  /// Busca primero en la lista ya cargada; si no está, consulta el API.
  Future<void> loadOfferDetail(String id) async {
    // Buscar en caché local
    final cached = _offers.where((o) => o.id == id).toList();
    if (cached.isNotEmpty) {
      _selectedOffer = cached.first;
      _error = null;
      notifyListeners();
    }

    // Siempre traer la versión completa del API
    _isLoadingDetail = true;
    notifyListeners();

    try {
      _selectedOffer = await _service.getOfferDetail(id);
      _error = null;
    } on AppError catch (e) {
      // Si teníamos caché, mantenerla; si no, mostrar error
      if (_selectedOffer == null) {
        _error = e.message;
      }
    } catch (_) {
      if (_selectedOffer == null) {
        _error = 'Error al cargar el detalle de la oferta.';
      }
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  void clearSelected() {
    _selectedOffer = null;
  }
}
