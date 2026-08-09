import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/theme.dart';
import '../../../core/services/upload_service.dart';
import '../../job_types/providers/job_type_provider.dart';
import '../models/experience_model.dart';
import '../providers/experience_provider.dart';

/// Pantalla Mi Perfil / Experiencias.
/// Permite ver, agregar y eliminar experiencias con imagen de certificado.
class ExperiencesScreen extends StatefulWidget {
  const ExperiencesScreen({super.key});

  @override
  State<ExperiencesScreen> createState() => _ExperiencesScreenState();
}

class _ExperiencesScreenState extends State<ExperiencesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExperienceProvider>().loadExperiences();
      context.read<JobTypeProvider>().loadJobTypes();
    });
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddExperienceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.menu,
                  color: AppColors.textPrimary, size: 22),
            ),
          ),
        ),
        title: const Text(
          'Experiencias',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<ExperienceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.status == ExperienceStatus.error &&
              provider.experiences.isEmpty) {
            return _ErrorView(
              message: provider.error ?? 'Error al cargar experiencias.',
              onRetry: () => provider.loadExperiences(),
            );
          }

          if (provider.experiences.isEmpty) {
            return _EmptyView(onAdd: _showAddSheet);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.loadExperiences(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.experiences.length,
              itemBuilder: (context, index) {
                final exp = provider.experiences[index];
                return _ExperienceCard(
                  experience: exp,
                  onDelete: () => _confirmDelete(exp, provider),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _confirmDelete(
    ExperienceModel exp,
    ExperienceProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Eliminar experiencia',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Confirmas que deseas eliminar "${exp.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ok = await provider.deleteExperience(exp.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Experiencia eliminada.'
              : provider.error ?? 'No se pudo eliminar.'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de una experiencia
// ─────────────────────────────────────────────────────────────────────────────
class _ExperienceCard extends StatelessWidget {
  final ExperienceModel experience;
  final VoidCallback onDelete;

  const _ExperienceCard({
    required this.experience,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final jobTypeProvider = context.watch<JobTypeProvider>();
    final jobType = experience.jobTypeKey != null
        ? jobTypeProvider.findById(experience.jobTypeKey!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de certificado (si existe)
          if (experience.certificateImage != null &&
              experience.certificateImage!.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                experience.certificateImage!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: AppColors.surfaceVariant,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: AppColors.textHint, size: 40),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera: título + botón eliminar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.work_history_rounded,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            experience.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (jobType != null) ...[
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                jobType.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.error, size: 20),
                      tooltip: 'Eliminar',
                      onPressed: onDelete,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Descripción
                Text(
                  experience.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                // Fecha
                if (experience.createdAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(experience.createdAt!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet para agregar experiencia
// ─────────────────────────────────────────────────────────────────────────────
class _AddExperienceSheet extends StatefulWidget {
  const _AddExperienceSheet();

  @override
  State<_AddExperienceSheet> createState() => _AddExperienceSheetState();
}

class _AddExperienceSheetState extends State<_AddExperienceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedJobTypeKey;
  String? _certificateImageUrl;
  bool _uploadingImage = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile == null) return;
    if (!mounted) return;

    setState(() => _uploadingImage = true);
    try {
      final uploadService = context.read<UploadService>();
      final result = await uploadService.uploadXFile(xFile);
      if (!mounted) return;
      setState(() {
        _certificateImageUrl = result.url;
        _uploadingImage = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExperienceProvider>();
    final ok = await provider.addExperience(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      jobTypeKey: _selectedJobTypeKey,
      certificateImage: _certificateImageUrl,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Experiencia agregada exitosamente.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final jobTypeProvider = context.watch<JobTypeProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Cabecera
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_circle_outline_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Agregar experiencia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Título *',
                        hintText: 'Ej. Cuidador de adultos mayores',
                        prefixIcon: Icon(Icons.title_rounded,
                            color: AppColors.primaryLight),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'El título es requerido.'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Descripción
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        hintText:
                            'Describe tu experiencia en detalle...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.description_outlined,
                              color: AppColors.primaryLight),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Escribe al menos 10 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Tipo de empleo (opcional)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedJobTypeKey,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        labelText: 'Tipo de empleo (opcional)',
                        prefixIcon: Icon(Icons.category_outlined,
                            color: AppColors.primaryLight),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Seleccionar...'),
                        ),
                        ...jobTypeProvider.jobTypes.map((jt) =>
                            DropdownMenuItem(
                              value: jt.key,
                              child: Text(jt.name),
                            )),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedJobTypeKey = val),
                    ),
                    const SizedBox(height: 16),

                    // Imagen de certificado
                    const Text(
                      'Imagen de certificado',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _uploadingImage ? null : _pickCertificate,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _certificateImageUrl != null
                                ? AppColors.success
                                : AppColors.border,
                            width: _certificateImageUrl != null ? 2 : 1,
                          ),
                        ),
                        child: _uploadingImage
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : _certificateImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _certificateImageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: AppColors.textHint,
                                        size: 36,
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Toca para adjuntar certificado',
                                        style: TextStyle(
                                          color: AppColors.textHint,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    if (_certificateImageUrl != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 14),
                          const SizedBox(width: 4),
                          const Expanded(
                            child: Text(
                              'Certificado cargado exitosamente.',
                              style: TextStyle(
                                  color: AppColors.success, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _certificateImageUrl = null),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                            ),
                            child: const Text('Quitar', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Error
                    Consumer<ExperienceProvider>(
                      builder: (context, provider, child) {
                        if (provider.error != null) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              provider.error!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 13),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Botón guardar
                    Consumer<ExperienceProvider>(
                      builder: (context, provider, child) => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isSubmitting ? null : _submit,
                          icon: provider.isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: Text(provider.isSubmitting
                              ? 'Guardando...'
                              : 'Guardar experiencia'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vistas auxiliares
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work_history_rounded,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin experiencias aún',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Agrega tus experiencias laborales y certificados para destacar tu perfil ante los empleadores.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar primera experiencia'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.textSecondary, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
