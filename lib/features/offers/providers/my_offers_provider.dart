// ignore_for_file: prefer_initializing_formals
import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../models/offer_model.dart';
import '../models/application_model.dart';
import '../services/offer_service.dart';
import '../services/application_service.dart';

/// Gestiona el ciclo completo de "quien publica":
/// - Mis ofertas publicadas (GET /me/offers)
/// - Crear oferta (POST /offers)
/// - Aplicantes de una oferta (GET /offers/{id}/applications)
/// - Calificar/descartar/finalista/ganador (PATCH /applications/{id})
/// - Desactivar oferta (POST /offers/{id}/deactivate)
class MyOffersProvider extends ChangeNotifier {
  final OfferService _offerService;
  final ApplicationService _applicationService;

  List<OfferModel> _myOffers = [];
  List<ApplicationModel> _selectedApplications = [];
  String? _selectedOfferId;

  bool _isLoadingOffers = false;
  bool _isCreating = false;
  bool _isLoadingApplications = false;
  bool _isPatching = false;

  String? _offersError;
  String? _createError;
  String? _applicationsError;
  String? _patchError;
  MyOffersProvider({
    required OfferService offerService,
    required ApplicationService applicationService,
  })  : _offerService = offerService,
        _applicationService = applicationService;

  // ── Getters ──────────────────────────────────────────────────────────────

  List<OfferModel> get myOffers => _myOffers;
  List<ApplicationModel> get selectedApplications => _selectedApplications;
  String? get selectedOfferId => _selectedOfferId;

  bool get isLoadingOffers => _isLoadingOffers;
  bool get isCreating => _isCreating;
  bool get isLoadingApplications => _isLoadingApplications;
  bool get isPatching => _isPatching;

  String? get offersError => _offersError;
  String? get createError => _createError;
  String? get applicationsError => _applicationsError;
  String? get patchError => _patchError;

  // ── Acciones ─────────────────────────────────────────────────────────────

  /// Carga las ofertas propias desde el API.
  Future<void> loadMyOffers() async {
    _isLoadingOffers = true;
    _offersError = null;
    notifyListeners();

    try {
      _myOffers = await _offerService.getMyOffers();
    } on AppError catch (e) {
      _offersError = e.message;
    } catch (_) {
      _offersError = 'Error al cargar tus ofertas publicadas.';
    } finally {
      _isLoadingOffers = false;
      notifyListeners();
    }
  }

  /// Publica una oferta completa. Retorna true si fue exitoso.
  Future<bool> createOffer({
    required String jobTypeKey,
    required String contractType,
    required String description,
    required String address,
    required String photo,
    required String paymentId,
    double? locationLat,
    double? locationLng,
    double? paymentAmount,
    String? paymentCurrency,
    String? deadline,
    Map<String, dynamic>? customAnswers,
    List<Map<String, dynamic>>? questions,
  }) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final offer = await _offerService.createOffer(
        jobTypeKey: jobTypeKey,
        contractType: contractType,
        description: description,
        address: address,
        photo: photo,
        paymentId: paymentId,
        locationLat: locationLat,
        locationLng: locationLng,
        paymentAmount: paymentAmount,
        paymentCurrency: paymentCurrency,
        deadline: deadline,
        customAnswers: customAnswers,
        questions: questions,
      );
      // Agregar la nueva oferta al inicio de la lista local
      _myOffers = [offer, ..._myOffers];
      return true;
    } on AppError catch (e) {
      _createError = e.message;
      return false;
    } catch (e) {
      _createError = 'Error al publicar la oferta. Intenta nuevamente.';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  /// Carga los aplicantes de una oferta específica.
  Future<void> loadApplications(String offerId) async {
    _selectedOfferId = offerId;
    _isLoadingApplications = true;
    _applicationsError = null;
    notifyListeners();

    try {
      _selectedApplications = await _offerService.getApplications(offerId);
    } on AppError catch (e) {
      _applicationsError = e.message;
    } catch (_) {
      _applicationsError = 'Error al cargar los aplicantes.';
    } finally {
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  /// Actualiza el estado/rating de un aplicante. Retorna true si fue exitoso.
  Future<bool> patchApplication(
    String applicationId, {
    String? status,
    int? rating,
  }) async {
    _isPatching = true;
    _patchError = null;
    notifyListeners();

    try {
      final updated = await _applicationService.patchApplication(
        applicationId,
        status: status,
        rating: rating,
      );
      // Actualizar en la lista local
      final idx = _selectedApplications.indexWhere((a) => a.id == applicationId);
      if (idx != -1) {
        _selectedApplications = List.from(_selectedApplications)
          ..[idx] = updated;
      }
      return true;
    } on AppError catch (e) {
      _patchError = e.message;
      return false;
    } catch (_) {
      _patchError = 'Error al actualizar la aplicación.';
      return false;
    } finally {
      _isPatching = false;
      notifyListeners();
    }
  }

  /// Desactiva una oferta propia. Retorna true si fue exitoso.
  Future<bool> deactivateOffer(String offerId) async {
    try {
      await _offerService.deactivateOffer(offerId);
      // Actualizar el estado localmente en memoria para evitar
      // hacer un re-fetch completo (que causaba un crash de pantalla negra
      // al llamar notifyListeners dentro del flujo del diálogo).
      final idx = _myOffers.indexWhere((o) => o.id == offerId);
      if (idx != -1) {
        final updated = _myOffers[idx].copyWith(status: 'inactive');
        _myOffers = List<OfferModel>.from(_myOffers)..[idx] = updated;
      }
      _offersError = null;
      notifyListeners();
      return true;
    } on AppError catch (e) {
      _offersError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _offersError = 'Error al desactivar la oferta.';
      notifyListeners();
      return false;
    }
  }

  void clearApplications() {
    _selectedApplications = [];
    _selectedOfferId = null;
    _applicationsError = null;
    notifyListeners();
  }

  void clearCreateError() {
    _createError = null;
    notifyListeners();
  }
}
