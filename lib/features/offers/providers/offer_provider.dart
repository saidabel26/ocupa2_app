import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/offer_model.dart';
import '../services/offer_service.dart';

/// Proveedor de ofertas (listado con filtro + detalle).
class OfferProvider extends ChangeNotifier {
  final OfferService _service;

  List<OfferModel> _allOffers = [];
  OfferModel? _selectedOffer;
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;
  String? _selectedJobTypeKey;

  OfferProvider(this._service);

  /// Lista de ofertas filtrada por el tipo de empleo seleccionado.
  List<OfferModel> get offers {
    if (_selectedJobTypeKey == null || _selectedJobTypeKey!.isEmpty) {
      return _allOffers;
    }
    return _allOffers
        .where((o) => o.jobTypeKey == _selectedJobTypeKey || o.jobTypeName == _selectedJobTypeKey)
        .toList();
  }

  OfferModel? get selectedOffer => _selectedOffer;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  String? get selectedJobTypeKey => _selectedJobTypeKey;

  /// Ofertas que tienen coordenadas válidas (para el mapa), respetando el filtro actual.
  List<OfferModel> get offersWithLocation =>
      offers.where((o) => o.hasLocation).toList();

  /// Carga todas las ofertas desde el API.
  Future<void> loadOffers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allOffers = await _service.getOffers();
    } on AppError catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Error al cargar las ofertas.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia el filtro de tipo de empleo y notifica a la UI.
  void setFilter(String? jobTypeKey) {
    _selectedJobTypeKey = jobTypeKey;
    notifyListeners();
  }

  /// Carga el detalle de una oferta.
  Future<void> loadOfferDetail(String id) async {
    final cached = _allOffers.where((o) => o.id == id).toList();
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
