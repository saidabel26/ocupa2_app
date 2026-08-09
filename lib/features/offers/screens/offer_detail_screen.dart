import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../job_types/providers/job_type_provider.dart';
import '../models/offer_model.dart';
import '../providers/offer_provider.dart';
import '../providers/apply_provider.dart';
import '../providers/my_offers_provider.dart';
import 'apply_bottom_sheet.dart';

/// Pantalla de detalle de una oferta.
/// Muestra toda la información de la oferta sin el formulario de aplicación
/// Incluye el formulario de aplicación cuando corresponde.
class OfferDetailScreen extends StatefulWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OfferProvider>().loadOfferDetail(widget.offerId);
      // Reiniciar estado de aplicación cada vez que se abre el detalle
      context.read<ApplyProvider>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OfferProvider>();
    final offer = provider.selectedOffer;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildContent(provider, offer),
    );
  }

  Widget _buildContent(OfferProvider provider, OfferModel? offer) {
    if (provider.isLoadingDetail && offer == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.error != null && offer == null) {
      return SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.textSecondary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => provider.loadOfferDetail(widget.offerId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (offer == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(offer),
        SliverToBoxAdapter(child: _buildOfferDetails(offer)),
      ],
    );
  }

  Widget _buildSliverAppBar(OfferModel offer) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: offer.photo != null && offer.photo!.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    offer.photo!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textHint,
                        size: 56,
                      ),
                    ),
                  ),
                  // Gradiente oscuro en la parte inferior
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.work_rounded,
                  size: 64,
                  color: Colors.white38,
                ),
              ),
      ),
    );
  }

  Widget _buildOfferDetails(OfferModel offer) {
    final jobTypeProvider = context.read<JobTypeProvider>();
    final jobType = jobTypeProvider.findByKey(offer.jobTypeKey);
    final jobTypeName = offer.jobTypeName ?? jobType?.name ?? offer.jobTypeKey;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges: tipo de empleo + tipo de contrato
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(
                jobTypeName,
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primaryLight,
              ),
              _badge(
                offer.contractTypeLabel,
                AppColors.accent.withValues(alpha: 0.15),
                AppColors.accent,
              ),
              if (offer.status != null)
                _badge(
                  offer.status == 'active' ? 'Activa' : offer.status!,
                  offer.status == 'active'
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.warning.withValues(alpha: 0.15),
                  offer.status == 'active'
                      ? AppColors.success
                      : AppColors.warning,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Descripción
          const Text(
            'Descripción',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            offer.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // Información principal
          _buildInfoSection(offer),
          const SizedBox(height: 24),

          // Campos personalizados
          if (offer.customAnswers.isNotEmpty) ...[
            _buildCustomAnswers(offer),
            const SizedBox(height: 24),
          ],

          // Preguntas adicionales
          if (offer.questions.isNotEmpty) ...[
            _buildQuestions(offer),
            const SizedBox(height: 24),
          ],

          // Botón para aplicar a la oferta.
          Consumer<ApplyProvider>(
            builder: (consumerContext, applyProvider, child) {
              final alreadyApplied =
                  applyProvider.status == ApplyStatus.success;

              final now = DateTime.now();
              final isExpired =
                  offer.deadline != null && offer.deadline!.isBefore(now);

              // Verificar si es la propia oferta usando MyOffersProvider
              final myOffers = context.read<MyOffersProvider>().myOffers;
              final isOwnOffer = myOffers.any((o) => o.id == offer.id);

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (alreadyApplied || isExpired || isOwnOffer)
                      ? null
                      : () async {
                          final sent = await ApplyBottomSheet.show(
                            consumerContext,
                            offer,
                          );
                          if (!consumerContext.mounted) return;
                          if (sent == true) {
                            ScaffoldMessenger.of(consumerContext).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  '¡Aplicación enviada! Te notificaremos el resultado.',
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                  icon: Icon(
                    alreadyApplied
                        ? Icons.check_circle_rounded
                        : isExpired
                        ? Icons.timer_off_outlined
                        : Icons.send_rounded,
                  ),
                  label: Text(
                    isOwnOffer
                        ? 'No puedes aplicar a tu propia oferta'
                        : alreadyApplied
                        ? 'Aplicación enviada'
                        : isExpired
                        ? 'Fecha límite alcanzada'
                        : 'Aplicar a esta oferta',
                  ),
                  style: alreadyApplied
                      ? ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        )
                      : ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoSection(OfferModel offer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.location_on_outlined,
            'Dirección',
            offer.address.isNotEmpty ? offer.address : 'No especificada',
          ),
          if (offer.paymentAmount != null) ...[
            const Divider(color: AppColors.border, height: 20),
            _infoRow(
              Icons.payments_outlined,
              'Pago',
              '${_formatAmount(offer.paymentAmount!)} ${offer.paymentCurrency ?? 'DOP'}',
            ),
          ],
          if (offer.deadline != null) ...[
            const Divider(color: AppColors.border, height: 20),
            _infoRow(
              Icons.calendar_today_outlined,
              'Fecha límite',
              _formatDate(offer.deadline!),
            ),
          ],
          if (offer.createdAt != null) ...[
            const Divider(color: AppColors.border, height: 20),
            _infoRow(
              Icons.access_time_outlined,
              'Publicada',
              _formatDate(offer.createdAt!),
            ),
          ],
          if (offer.hasLocation) ...[
            const Divider(color: AppColors.border, height: 20),
            _infoRow(
              Icons.map_outlined,
              'Ubicación',
              '${offer.locationLat!.toStringAsFixed(4)}, ${offer.locationLng!.toStringAsFixed(4)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomAnswers(OfferModel offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Datos adicionales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: offer.customAnswers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.label_outline,
                      size: 16,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_humanizeKey(entry.key)}: ',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestions(OfferModel offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preguntas para aplicantes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        ...offer.questions.asMap().entries.map((entry) {
          final i = entry.key;
          final q = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tipo: ${q.type}${q.required ? ' · Requerida' : ''}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      if (q.options.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: q.options
                              .map(
                                (opt) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    opt,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // Helpers de presentación.

  Widget _badge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryLight),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatAmount(double amount) {
    if (amount == amount.toInt()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  String _humanizeKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'[_-]'), (m) => ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .split(' ')
        .map(
          (w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
              : '',
        )
        .join(' ');
  }
}
