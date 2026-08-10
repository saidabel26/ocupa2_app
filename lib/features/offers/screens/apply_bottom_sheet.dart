import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../models/offer_model.dart';
import '../models/offer_question_model.dart';
import '../providers/apply_provider.dart';

/// Formulario modal para aplicar a una oferta.
/// Se muestra como bottom sheet desde el detalle de oferta.
/// Recoge comentario + respuestas a las preguntas adicionales definidas por el publicante.
class ApplyBottomSheet extends StatefulWidget {
  final OfferModel offer;

  const ApplyBottomSheet({super.key, required this.offer});

  /// Abre el bottom sheet modal y devuelve true si la aplicación fue enviada.
  static Future<bool?> show(BuildContext context, OfferModel offer) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApplyBottomSheet(offer: offer),
    );
  }

  @override
  State<ApplyBottomSheet> createState() => _ApplyBottomSheetState();
}

class _ApplyBottomSheetState extends State<ApplyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _commentCtrl = TextEditingController();

  // Controladores para respuestas por tipo de pregunta
  final Map<int, dynamic> _answers = {};

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Construir la lista de answers con id y value
    final List<Map<String, dynamic>> answersList = [];
    for (int i = 0; i < widget.offer.questions.length; i++) {
      final q = widget.offer.questions[i];
      final val = _answers[i];
      if (q.id != null && val != null) {
        answersList.add({'questionId': q.id!, 'value': val});
      }
    }

    final provider = context.read<ApplyProvider>();
    final ok = await provider.apply(
      widget.offer.id,
      comment: _commentCtrl.text.trim(),
      answers: answersList.isNotEmpty ? answersList : null,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

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

          // Título
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Aplicar a esta oferta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Formulario scrolleable
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comentario (requerido)
                    _SectionLabel(
                      label: '¿Por qué te consideras apto?',
                      icon: Icons.chat_bubble_outline_rounded,
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _commentCtrl,
                      maxLines: 4,
                      maxLength: 600,
                      decoration: const InputDecoration(
                        hintText:
                            'Describe tu experiencia, habilidades y por qué eres la persona ideal para este trabajo...',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'El comentario es requerido.';
                        }
                        if (v.trim().length < 10) {
                          return 'Escribe al menos 10 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Preguntas adicionales de la oferta
                    if (widget.offer.questions.isNotEmpty) ...[
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 12),
                      const Text(
                        'Preguntas adicionales',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Definidas por quien publicó la oferta.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...widget.offer.questions.asMap().entries.map(
                        (entry) => _buildQuestionField(entry.key, entry.value),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Error del provider
                    Consumer<ApplyProvider>(
                      builder: (context, provider, child) {
                        if (provider.error != null &&
                            provider.status == ApplyStatus.error) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    provider.error!,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // Botón enviar
                    Consumer<ApplyProvider>(
                      builder: (context, provider, child) {
                        return SizedBox(
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
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              provider.isSubmitting
                                  ? 'Enviando...'
                                  : 'Enviar aplicación',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        );
                      },
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

  /// Construye el widget de respuesta según el tipo de pregunta.
  Widget _buildQuestionField(int index, OfferQuestionModel q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(
            label: q.label,
            icon: _iconForType(q.type),
            required: q.required,
          ),
          const SizedBox(height: 8),
          _questionInput(index, q),
        ],
      ),
    );
  }

  Widget _questionInput(int index, OfferQuestionModel q) {
    switch (q.type) {
      case 'select':
        return DropdownButtonFormField<String>(
          initialValue: _answers[index] as String?,
          dropdownColor: AppColors.surface,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(hintText: 'Selecciona una opción'),
          items: q.options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          validator: q.required
              ? (v) =>
                    (v == null || v.isEmpty) ? 'Este campo es requerido.' : null
              : null,
          onChanged: (val) => setState(() => _answers[index] = val),
        );

      case 'check':
        return CheckboxListTile(
          value: _answers[index] as bool? ?? false,
          onChanged: (val) => setState(() => _answers[index] = val ?? false),
          title: const Text(
            'Sí',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: AppColors.primary,
        );

      case 'date':
        final currentVal = _answers[index] as String?;
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2050),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.surface,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _answers[index] =
                    '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              });
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              key: ValueKey(currentVal),
              initialValue: currentVal ?? '',
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Selecciona una fecha',
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primaryLight,
                  size: 18,
                ),
              ),
              validator: q.required
                  ? (v) => (v == null || v.isEmpty)
                        ? 'Este campo es requerido.'
                        : null
                  : null,
            ),
          ),
        );

      default: // text
        return TextFormField(
          initialValue: _answers[index] as String?,
          decoration: const InputDecoration(hintText: 'Tu respuesta...'),
          validator: q.required
              ? (v) => (v == null || v.trim().isEmpty)
                    ? 'Este campo es requerido.'
                    : null
              : null,
          onChanged: (val) => setState(() => _answers[index] = val),
        );
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'select':
        return Icons.list_alt_rounded;
      case 'check':
        return Icons.check_box_outlined;
      case 'date':
        return Icons.calendar_today_outlined;
      default:
        return Icons.text_fields_rounded;
    }
  }
}

/// Etiqueta de sección con ícono y asterisco opcional para campos requeridos.
class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool required;

  const _SectionLabel({
    required this.label,
    required this.icon,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryLight),
        const SizedBox(width: 6),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
