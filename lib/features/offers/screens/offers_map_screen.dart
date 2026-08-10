import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../models/offer_model.dart';
import '../providers/offer_provider.dart';

/// Pantalla del mapa interactivo con pines de ofertas.
/// Usa flutter_map con tiles gratuitos de OpenStreetMap.
class OffersMapScreen extends StatefulWidget {
  const OffersMapScreen({super.key});

  @override
  State<OffersMapScreen> createState() => _OffersMapScreenState();
}

class _OffersMapScreenState extends State<OffersMapScreen> {
  final MapController _mapController = MapController();
  OfferModel? _selectedOffer;
  LatLng? _myLocation;

  // Centro por defecto: República Dominicana (ITLA)
  final LatLng _defaultCenter = const LatLng(18.4522, -69.6300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cargar ofertas si la lista está vacía
      final provider = context.read<OfferProvider>();
      if (provider.offers.isEmpty) {
        provider.loadOffers();
      }
    });
  }

  Future<void> _locateMe() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Servicios de ubicación deshabilitados.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permisos de ubicación denegados.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisos denegados permanentemente.')),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    final myLatLng = LatLng(pos.latitude, pos.longitude);

    if (mounted) {
      setState(() => _myLocation = myLatLng);
      _mapController.move(myLatLng, 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OfferProvider>();
    final offers = provider.offersWithLocation;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.menu,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Mapa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 12.0,
              onTap: (tapPosition, point) {
                // Ocultar popup si se toca el mapa
                if (_selectedOffer != null) {
                  setState(() => _selectedOffer = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ocupa2.app',
                // Aplica un filtro oscuro para que encaje con el tema de la app
                tileBuilder: (context, widget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      // Matriz de inversión suave para efecto modo oscuro
                      -1, 0, 0, 0, 255, //
                      0, -1, 0, 0, 255, //
                      0, 0, -1, 0, 255, //
                      0, 0, 0, 1, 0, //
                    ]),
                    child: widget,
                  );
                },
              ),
              MarkerLayer(
                markers: offers.map((offer) {
                  final isSelected = _selectedOffer?.id == offer.id;
                  return Marker(
                    point: LatLng(offer.locationLat!, offer.locationLng!),
                    width: 50,
                    height: 50,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedOffer = isSelected ? null : offer;
                        });
                        if (!isSelected) {
                          _mapController.move(
                            LatLng(offer.locationLat!, offer.locationLng!),
                            14.0,
                          );
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: isSelected ? 48 : 40,
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.primaryLight,
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 6,
                              child: Icon(
                                Icons.work,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_myLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _myLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Cargando superpuesto
          if (provider.isLoading)
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),

          // 3. Popup inferior si hay oferta seleccionada
          if (_selectedOffer != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildOfferPopup(_selectedOffer!),
            ),

          // 4. Botón flotante para localizarme
          if (_selectedOffer == null)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                onPressed: _locateMe,
                child: const Icon(Icons.my_location),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfferPopup(OfferModel offer) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/offers/${offer.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagen pequeña
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    image: offer.photo != null && offer.photo!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(offer.photo!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: offer.photo == null || offer.photo!.isEmpty
                      ? const Icon(
                          Icons.work_outline,
                          color: AppColors.textHint,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.description,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offer.address,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              offer.jobTypeName ?? offer.jobTypeKey,
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Ver detalle',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
