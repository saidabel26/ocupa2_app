import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../models/offer_model.dart';
import '../providers/my_offers_provider.dart';

/// Pantalla de mis ofertas publicadas.
/// Muestra la lista, permite ver aplicantes y desactivar cada oferta.
class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyOffersProvider>().loadMyOffers();
    });
  }

  Future<void> _confirmDeactivate(OfferModel offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Desactivar oferta?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'La oferta "${offer.description.length > 50 ? '${offer.description.substring(0, 50)}…' : offer.description}" dejará de aparecer en el listado y no admitirá nuevas aplicaciones.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final ok =
        await context.read<MyOffersProvider>().deactivateOffer(offer.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '✅ Oferta desactivada correctamente.'
            : context.read<MyOffersProvider>().offersError ??
                'Error al desactivar.'),
        backgroundColor: ok ? null : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyOffersProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Publicar oferta',
            style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () => context.push(AppRoutes.createOffer),
      ),
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(child: _buildBody(provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.menu,
                      color: AppColors.textPrimary, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (b) =>
                    AppColors.primaryGradient.createShader(b),
                child: const Text(
                  'Mis Ofertas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Gestiona las ofertas que has publicado',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBody(MyOffersProvider provider) {
    if (provider.isLoadingOffers) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.offersError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              provider.offersError!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<MyOffersProvider>().loadMyOffers(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.myOffers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.business_center_outlined,
                color: AppColors.textSecondary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No has publicado ofertas aún',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca el botón "+" para publicar tu primera oferta.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => context.read<MyOffersProvider>().loadMyOffers(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: provider.myOffers.length,
        itemBuilder: (context, i) =>
            _buildOfferCard(provider.myOffers[i]),
      ),
    );
  }

  Widget _buildOfferCard(OfferModel offer) {
    final stat = offer.status?.toLowerCase();
    final isActive = stat == null ||
        stat == 'active' ||
        stat == 'open' ||
        stat == 'published';

    final statusColor = isActive ? AppColors.success : AppColors.textHint;
    final statusLabel = isActive ? 'Activa' : 'Inactiva';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de la oferta si existe
          if (offer.photo != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                offer.photo!,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 60,
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.image_not_supported,
                      color: AppColors.textHint),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges de estado
                Row(
                  children: [
                    _buildBadge(
                        label: statusLabel,
                        color: statusColor,
                        icon: isActive
                            ? Icons.check_circle_outline
                            : Icons.pause_circle_outline),
                    const SizedBox(width: 8),
                    _buildBadge(
                        label: offer.contractTypeLabel,
                        color: AppColors.accent,
                        icon: Icons.schedule),
                  ],
                ),
                const SizedBox(height: 10),

                // Descripción
                Text(
                  offer.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),

                // Dirección
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        offer.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),

                // Fecha límite
                if (offer.deadline != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            color: AppColors.textSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Fecha límite: ${_formatDate(offer.deadline!)}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),

                // Acciones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                          side: const BorderSide(
                              color: AppColors.primaryLight),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.people_outline, size: 18),
                        label: const Text('Ver aplicantes',
                            style: TextStyle(fontSize: 13)),
                        onPressed: () => context.push(
                          AppRoutes.offerApplicants
                              .replaceFirst(':id', offer.id),
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        icon:
                            const Icon(Icons.pause_circle_outline, size: 18),
                        label: const Text('Desactivar',
                            style: TextStyle(fontSize: 13)),
                        onPressed: () => _confirmDeactivate(offer),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
