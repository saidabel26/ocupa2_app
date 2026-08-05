import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../models/application_model.dart';
import '../providers/my_offers_provider.dart';

/// Pantalla de aplicantes de una oferta propia.
/// El publicante puede calificar (1–5 ⭐), descartar, marcar como finalista
/// o elegir al ganador.
class OfferApplicantsScreen extends StatefulWidget {
  final String offerId;
  const OfferApplicantsScreen({super.key, required this.offerId});

  @override
  State<OfferApplicantsScreen> createState() => _OfferApplicantsScreenState();
}

class _OfferApplicantsScreenState extends State<OfferApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyOffersProvider>().loadApplications(widget.offerId);
    });
  }

  // ── Acciones ─────────────────────────────────────────────────────────────

  Future<void> _setStatus(ApplicationModel app, String status) async {
    if (status == 'winner') {
      final confirmed = await _showWinnerConfirmation(app);
      if (confirmed != true) return;
    }

    if (!mounted) return;
    final ok = await context
        .read<MyOffersProvider>()
        .patchApplication(app.id, status: status);

    if (!mounted) return;

    final labels = {
      'discarded': 'descartado',
      'finalist': 'marcado como finalista',
      'winner': '¡Ganador seleccionado! Se ha creado un contrato.',
      'applied': 'regresado a revisión',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '✅ Aplicante ${labels[status] ?? status}'
            : context.read<MyOffersProvider>().patchError ??
                'Error al actualizar.'),
        backgroundColor: ok ? null : AppColors.error,
      ),
    );
  }

  Future<void> _setRating(ApplicationModel app, int rating) async {
    final ok = await context
        .read<MyOffersProvider>()
        .patchApplication(app.id, rating: rating);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              context.read<MyOffersProvider>().patchError ??
                  'Error al calificar.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<bool?> _showWinnerConfirmation(ApplicationModel app) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.warning),
            SizedBox(width: 8),
            Text(
              '¿Elegir como ganador?',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          'Se seleccionará a ${app.applicant?.nombre ?? 'este aplicante'} como ganador. Esto creará automáticamente un contrato. Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.emoji_events, size: 18),
            label: const Text('Elegir ganador'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyOffersProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: ShaderMask(
          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
          child: const Text(
            'Aplicantes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => context
                .read<MyOffersProvider>()
                .loadApplications(widget.offerId),
          ),
        ],
      ),
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _buildBody(provider),
      ),
    );
  }

  Widget _buildBody(MyOffersProvider provider) {
    if (provider.isLoadingApplications) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.applicationsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              provider.applicationsError!,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<MyOffersProvider>()
                  .loadApplications(widget.offerId),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (provider.selectedApplications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                color: AppColors.textSecondary, size: 64),
            SizedBox(height: 16),
            Text(
              'Aún no hay aplicantes',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Los candidatos aparecerán aquí cuando apliquen.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Agrupar por estado para mejor UX
    final winners = provider.selectedApplications
        .where((a) => a.status == 'winner')
        .toList();
    final finalists = provider.selectedApplications
        .where((a) => a.status == 'finalist')
        .toList();
    final inReview = provider.selectedApplications
        .where((a) => a.status == 'applied')
        .toList();
    final discarded = provider.selectedApplications
        .where((a) => a.status == 'discarded')
        .toList();
        
    final hasWinner = winners.isNotEmpty;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () => context
          .read<MyOffersProvider>()
          .loadApplications(widget.offerId),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen
          _buildSummaryBar(provider.selectedApplications.length, winners.length),
          const SizedBox(height: 16),

          if (winners.isNotEmpty) ...[
            _buildGroupHeader('🏆 Ganador', AppColors.warning, winners.length),
            ...winners.map((a) => _buildApplicantCard(a, hasWinner: hasWinner)),
            const SizedBox(height: 8),
          ],
          if (finalists.isNotEmpty) ...[
            _buildGroupHeader(
                '⭐ Finalistas', AppColors.primary, finalists.length),
            ...finalists.map((a) => _buildApplicantCard(a, hasWinner: hasWinner)),
            const SizedBox(height: 8),
          ],
          if (inReview.isNotEmpty) ...[
            _buildGroupHeader(
                '👁️ En revisión', AppColors.accent, inReview.length),
            ...inReview.map((a) => _buildApplicantCard(a, hasWinner: hasWinner)),
            const SizedBox(height: 8),
          ],
          if (discarded.isNotEmpty) ...[
            _buildGroupHeader(
                '❌ Descartados', AppColors.textSecondary, discarded.length),
            ...discarded.map((a) => _buildApplicantCard(a, hasWinner: hasWinner)),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryBar(int total, int winners) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('Total', total.toString(), Icons.people),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStat('Ganadores', winners.toString(), Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildGroupHeader(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style:
                    TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(ApplicationModel app, {bool hasWinner = false}) {
    final isWinner = app.status == 'winner';
    final isDiscarded = app.status == 'discarded';
    final isFinalist = app.status == 'finalist';
    
    final String displayName = isWinner ? (app.applicant?.nombre ?? 'Aplicante') : 'Aplicante anónimo';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner
              ? AppColors.warning.withAlpha(100)
              : AppColors.border,
          width: isWinner ? 2 : 1,
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                    color: AppColors.warning.withAlpha(40),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del aplicante
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: isWinner
                      ? AppColors.warning.withAlpha(40)
                      : AppColors.surfaceVariant,
                  child: Text(
                    _initials(displayName),
                    style: TextStyle(
                      color: isWinner ? AppColors.warning : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: isWinner
                              ? AppColors.warning
                              : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isWinner && app.applicant?.email != null)
                        Text(
                          app.applicant!.email!,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                if (isWinner)
                  const Icon(Icons.emoji_events, color: AppColors.warning),
              ],
            ),
            const SizedBox(height: 12),

            // Calificación con estrellas
            _buildStarRating(app),
            const SizedBox(height: 10),

            // Comentario del aplicante
            if (app.comment != null && app.comment!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '"${app.comment}"',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Fecha de aplicación
            if (app.createdAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.textHint, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Aplicó el ${_formatDate(app.createdAt!)}',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),

            // Acciones (no mostrar si ya hay ganador)
            if (!isWinner) _buildActions(app, isDiscarded, isFinalist, hasWinner),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(ApplicationModel app) {
    final provider = context.watch<MyOffersProvider>();
    final isBusy = provider.isPatching;

    return Row(
      children: [
        const Text('Calificar: ',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        ...List.generate(5, (i) {
          final starVal = i + 1;
          return GestureDetector(
            onTap: isBusy
                ? null
                : () => _setRating(app, starVal),
            child: Icon(
              starVal <= (app.rating ?? 0)
                  ? Icons.star
                  : Icons.star_border_outlined,
              color: starVal <= (app.rating ?? 0)
                  ? AppColors.warning
                  : AppColors.textHint,
              size: 24,
            ),
          );
        }),
        if (isBusy) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary),
          ),
        ],
      ],
    );
  }

  Widget _buildActions(
      ApplicationModel app, bool isDiscarded, bool isFinalist, bool hasWinner) {
    final provider = context.watch<MyOffersProvider>();
    final isBusy = provider.isPatching;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (!isFinalist && !isDiscarded && !hasWinner)
          _actionButton(
            label: 'Finalista',
            icon: Icons.star_outline,
            color: AppColors.primary,
            isLoading: isBusy,
            onPressed: () => _confirmFinalistOrWinner(app),
          ),
        if (isFinalist && !hasWinner)
          _actionButton(
            label: 'Ganador 🏆',
            icon: Icons.emoji_events,
            color: AppColors.warning,
            isLoading: isBusy,
            onPressed: () => _setStatus(app, 'winner'),
          ),
        if (!isDiscarded)
          _actionButton(
            label: 'Descartar',
            icon: Icons.close,
            color: AppColors.error,
            isLoading: isBusy,
            onPressed: () => _setStatus(app, 'discarded'),
          ),
        if (isDiscarded)
          _actionButton(
            label: 'En revisión',
            icon: Icons.undo,
            color: AppColors.accent,
            isLoading: isBusy,
            onPressed: () => _setStatus(app, 'applied'),
          ),
      ],
    );
  }

  Future<void> _confirmFinalistOrWinner(ApplicationModel app) async {
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Elegir como ganador?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Puedes marcar a este aplicante como finalista para evaluarlo más tarde, o elegirlo directamente como el ganador de la oferta.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textHint)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'finalist'),
            child: const Text('Solo Finalista', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, 'winner'),
            child: const Text('Elegir Ganador 🏆'),
          ),
        ],
      ),
    );
    
    if (result == 'finalist') {
      _setStatus(app, 'finalist');
    } else if (result == 'winner') {
      _setStatus(app, 'winner');
    }
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: isLoading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: color),
            )
          : Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: isLoading ? null : onPressed,
    );
  }

  String _initials(String nombre) {
    final parts = nombre.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
