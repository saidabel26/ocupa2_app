import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/upload_service.dart';
import '../../job_types/models/custom_field_model.dart';
import '../../job_types/providers/job_type_provider.dart';
import '../../payments/providers/payment_provider.dart';
import '../providers/my_offers_provider.dart';

/// Pantalla de publicación de oferta.
/// Flujo en 2 pasos:
///   Paso 1 – Cobro de 1 USD (formulario de tarjeta)
///   Paso 2 – Datos de la oferta (tipo, contrato, foto, etc.)
class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  int _step = 0; // 0 = pago, 1 = datos

  // ── Formulario de pago ───────────────────────────────────────────────────
  final _payFormKey = GlobalKey<FormState>();
  final _cardNumberCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _expMonthCtrl = TextEditingController();
  final _expYearCtrl = TextEditingController();
  final _cardholderCtrl = TextEditingController();

  // ── Formulario de oferta ─────────────────────────────────────────────────
  final _offerFormKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();

  String? _selectedJobTypeKey;
  String _contractType = 'temporal';
  String _currency = 'DOP';
  String? _uploadedPhotoUrl;
  bool _isUploadingPhoto = false;

  // Campos dinámicos del tipo de empleo seleccionado
  final Map<String, TextEditingController> _customFieldControllers = {};
  final Map<String, String?> _customFieldSelectValues = {};
  final Map<String, bool> _customFieldCheckValues = {};

  // Preguntas adicionales del publicante
  final List<Map<String, dynamic>> _questions = [];
  final List<TextEditingController> _qLabelControllers = [];

  // Opciones de preguntas select
  final List<List<String>> _qOptions = [];

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cvvCtrl.dispose();
    _expMonthCtrl.dispose();
    _expYearCtrl.dispose();
    _cardholderCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _amountCtrl.dispose();
    _deadlineCtrl.dispose();
    for (var c in _customFieldControllers.values) {
      c.dispose();
    }
    for (var c in _qLabelControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── PASO 1: Pago ─────────────────────────────────────────────────────────

  Future<void> _processPay() async {
    if (!_payFormKey.currentState!.validate()) return;

    final payProvider = context.read<PaymentProvider>();
    final month = int.tryParse(_expMonthCtrl.text.trim()) ?? 0;
    final year = int.tryParse(_expYearCtrl.text.trim()) ?? 0;

    final ok = await payProvider.processPayment(
      cardNumber: _cardNumberCtrl.text.trim(),
      cvv: _cvvCtrl.text.trim(),
      expMonth: month,
      expYear: year,
      cardholder: _cardholderCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      setState(() => _step = 1);
    } else {
      _showError(payProvider.error ?? 'Pago rechazado. Verifica los datos.');
    }
  }

  // ── PASO 2: Publicar oferta ───────────────────────────────────────────────

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (xFile == null || !mounted) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final uploadService = context.read<UploadService>();
      final result = await uploadService.uploadXFile(xFile);
      setState(() => _uploadedPhotoUrl = result.url);
    } catch (e) {
      if (!mounted) return;
      _showError('Error al subir la foto. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _publishOffer() async {
    if (!_offerFormKey.currentState!.validate()) return;

    if (_uploadedPhotoUrl == null) {
      _showError('La foto de la oferta es obligatoria.');
      return;
    }
    if (_selectedJobTypeKey == null) {
      _showError('Selecciona el tipo de empleo.');
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showError('La paga de la oferta debe ser mayor a 0.');
      return;
    }

    final payProvider = context.read<PaymentProvider>();
    final myOffersProvider = context.read<MyOffersProvider>();

    // Construir customAnswers a partir de campos dinámicos
    final Map<String, dynamic> customAnswers = {};
    for (final entry in _customFieldControllers.entries) {
      final val = entry.value.text.trim();
      if (val.isNotEmpty) customAnswers[entry.key] = val;
    }
    for (final entry in _customFieldSelectValues.entries) {
      if (entry.value != null) customAnswers[entry.key] = entry.value;
    }
    for (final entry in _customFieldCheckValues.entries) {
      customAnswers[entry.key] = entry.value;
    }

    // Construir preguntas adicionales
    final List<Map<String, dynamic>> questions = [];
    for (int i = 0; i < _questions.length; i++) {
      final q = Map<String, dynamic>.from(_questions[i]);
      final labelCtrl = _qLabelControllers[i];
      q['label'] = labelCtrl.text.trim();
      if (q['label'].toString().isEmpty) continue;
      if (q['type'] == 'select' && _qOptions.length > i) {
        q['options'] = _qOptions[i];
      }
      questions.add(q);
    }

    final ok = await myOffersProvider.createOffer(
      jobTypeKey: _selectedJobTypeKey!,
      contractType: _contractType,
      description: _descCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      photo: _uploadedPhotoUrl!,
      paymentId: payProvider.paymentId!,
      locationLat: double.tryParse(_latCtrl.text.trim()),
      locationLng: double.tryParse(_lngCtrl.text.trim()),
      paymentAmount: double.tryParse(_amountCtrl.text.trim()),
      paymentCurrency: _currency,
      deadline: _deadlineCtrl.text.trim().isNotEmpty
          ? _deadlineCtrl.text.trim()
          : null,
      customAnswers: customAnswers.isNotEmpty ? customAnswers : null,
      questions: questions.isNotEmpty ? questions : null,
    );

    if (!mounted) return;
    if (ok) {
      payProvider.reset();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ¡Oferta publicada exitosamente!')),
      );
      context.pop();
    } else {
      _showError(myOffersProvider.createError ?? 'Error al publicar.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  // ── Campos dinámicos del tipo de empleo ──────────────────────────────────

  void _onJobTypeChanged(String? key) {
    setState(() {
      _selectedJobTypeKey = key;
      _customFieldControllers.clear();
      _customFieldSelectValues.clear();
      _customFieldCheckValues.clear();

      if (key == null) return;
      final jobTypeProvider = context.read<JobTypeProvider>();
      final jt = jobTypeProvider.jobTypes.firstWhere(
        (j) => j.key == key,
        orElse: () => jobTypeProvider.jobTypes.first,
      );
      for (final field in jt.customFields) {
        switch (field.type) {
          case 'text':
          case 'date':
          case 'number':
            _customFieldControllers[field.name] = TextEditingController();
          case 'select':
            _customFieldSelectValues[field.name] = null;
          case 'check':
            _customFieldCheckValues[field.name] = false;
        }
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: ShaderMask(
          shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
          child: Text(
            _step == 0 ? 'Pago (1 USD)' : 'Publicar Oferta',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _step == 0 ? _buildPaymentStep() : _buildOfferStep(),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // PASO 1 – Formulario de Pago
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildPaymentStep() {
    final payProvider = context.watch<PaymentProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _payFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta decorativa
            Container(
              height: 180,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(76),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'OCUPA2 PAY',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.credit_card, color: Colors.white70),
                    ],
                  ),
                  Text(
                    _cardNumberCtrl.text.isEmpty
                        ? '•••• •••• •••• ••••'
                        : _formatCardDisplay(_cardNumberCtrl.text),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TITULAR',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            _cardholderCtrl.text.isEmpty
                                ? 'NOMBRE DEL TITULAR'
                                : _cardholderCtrl.text.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'EXP',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${_expMonthCtrl.text.isEmpty ? 'MM' : _expMonthCtrl.text}/${_expYearCtrl.text.isEmpty ? 'YYYY' : _expYearCtrl.text}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info de tarjetas de prueba
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tarjetas de prueba',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '✅ Aprobada: 4242 4242 4242 4242',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    '❌ Rechazada: 4000 0000 0000 0002',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionLabel('Número de tarjeta'),
            _buildField(
              controller: _cardNumberCtrl,
              hint: '4242 4242 4242 4242',
              keyboardType: TextInputType.number,
              maxLength: 16,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final clean = (v ?? '').replaceAll(' ', '');
                if (clean.length < 13) return 'Número inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildSectionLabel('Titular de la tarjeta'),
            _buildField(
              controller: _cardholderCtrl,
              hint: 'Juan Pérez',
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Mes (exp.)'),
                      _buildField(
                        controller: _expMonthCtrl,
                        hint: '12',
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1 || n > 12) {
                            return 'Mes inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Año (exp.)'),
                      _buildField(
                        controller: _expYearCtrl,
                        hint: '2030',
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 2025) return 'Año inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('CVV'),
                      _buildField(
                        controller: _cvvCtrl,
                        hint: '123',
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        validator: (v) {
                          if ((v ?? '').length < 3) return 'CVV inválido';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            if (payProvider.error != null)
              _buildErrorBanner(payProvider.error!),

            _buildGradientButton(
              label: payProvider.isLoading ? 'Procesando…' : 'Pagar 1 USD',
              icon: Icons.lock_outline,
              isLoading: payProvider.isLoading,
              onPressed: payProvider.isLoading ? null : _processPay,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  // PASO 2 – Formulario de Oferta
  // ═════════════════════════════════════════════════════════════════════════

  Widget _buildOfferStep() {
    final jobTypeProvider = context.watch<JobTypeProvider>();
    final myOffersProvider = context.watch<MyOffersProvider>();
    final payProvider = context.watch<PaymentProvider>();

    // Cargar tipos de empleo si no están disponibles
    if (!jobTypeProvider.loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<JobTypeProvider>().loadJobTypes();
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _offerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de pago aprobado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ Pago de 1 USD aprobado. ID: ${payProvider.paymentId ?? ""}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tipo de empleo
            _buildSectionLabel('Tipo de empleo *'),
            jobTypeProvider.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _buildDropdown(
                    value: _selectedJobTypeKey,
                    hint: 'Seleccionar tipo…',
                    items: jobTypeProvider.jobTypes
                        .map(
                          (jt) => DropdownMenuItem(
                            value: jt.key,
                            child: Text(jt.name),
                          ),
                        )
                        .toList(),
                    onChanged: _onJobTypeChanged,
                  ),
            const SizedBox(height: 16),

            // Campos dinámicos del tipo de empleo
            if (_selectedJobTypeKey != null) _buildDynamicFields(),

            // Tipo de contrato
            _buildSectionLabel('Tipo de contrato *'),
            _buildDropdown(
              value: _contractType,
              hint: 'Seleccionar…',
              items: const [
                DropdownMenuItem(value: 'temporal', child: Text('Temporal')),
                DropdownMenuItem(value: 'fijo', child: Text('Fijo')),
                DropdownMenuItem(value: 'horas', child: Text('Por horas')),
              ],
              onChanged: (v) => setState(() => _contractType = v ?? 'temporal'),
            ),
            const SizedBox(height: 16),

            // Descripción
            _buildSectionLabel('Descripción *'),
            _buildField(
              controller: _descCtrl,
              hint: 'Describe el trabajo, requisitos, horario…',
              maxLines: 4,
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            // Dirección
            _buildSectionLabel('Dirección *'),
            _buildField(
              controller: _addressCtrl,
              hint: 'Ej: Av. 27 de Febrero, Santo Domingo',
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            // Coordenadas opcionales
            _buildSectionLabel('Coordenadas (opcionales)'),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _latCtrl,
                    hint: 'Latitud',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _lngCtrl,
                    hint: 'Longitud',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pago
            _buildSectionLabel('Pago ofrecido (opcional)'),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildField(
                    controller: _amountCtrl,
                    hint: '25000',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    value: _currency,
                    hint: 'Moneda',
                    items: const [
                      DropdownMenuItem(value: 'DOP', child: Text('DOP')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                    ],
                    onChanged: (v) => setState(() => _currency = v ?? 'DOP'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fecha límite
            _buildSectionLabel('Fecha límite para aplicar (opcional)'),
            _buildField(
              controller: _deadlineCtrl,
              hint: 'YYYY-MM-DD  (ej: 2026-09-30)',
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),

            // Foto obligatoria
            _buildSectionLabel('Foto de la oferta *'),
            _buildPhotoSelector(),
            const SizedBox(height: 20),

            // Preguntas adicionales
            _buildSectionLabel('Preguntas adicionales (opcional)'),
            _buildQuestionsSection(),
            const SizedBox(height: 28),

            if (myOffersProvider.createError != null)
              _buildErrorBanner(myOffersProvider.createError!),

            _buildGradientButton(
              label: myOffersProvider.isCreating
                  ? 'Publicando…'
                  : 'Publicar Oferta',
              icon: Icons.publish_outlined,
              isLoading: myOffersProvider.isCreating,
              onPressed: myOffersProvider.isCreating ? null : _publishOffer,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Campos dinámicos del tipo de empleo ──────────────────────────────────

  Widget _buildDynamicFields() {
    final jobTypeProvider = context.watch<JobTypeProvider>();
    final jt = jobTypeProvider.jobTypes
        .where((j) => j.key == _selectedJobTypeKey)
        .toList();
    if (jt.isEmpty || jt.first.customFields.isEmpty)
      return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campos específicos: ${jt.first.name}',
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ...jt.first.customFields.map((field) => _buildCustomField(field)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomField(CustomFieldModel field) {
    switch (field.type) {
      case 'text':
      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildField(
            controller: _customFieldControllers[field.name]!,
            hint: field.label,
            keyboardType: field.type == 'number'
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            validator: field.required
                ? (v) => (v?.trim().isEmpty ?? true)
                      ? '${field.label} requerido'
                      : null
                : null,
          ),
        );

      case 'date':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildField(
            controller: _customFieldControllers[field.name]!,
            hint: '${field.label} (YYYY-MM-DD)',
            keyboardType: TextInputType.datetime,
          ),
        );

      case 'select':
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                field.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              _buildDropdown(
                value: _customFieldSelectValues[field.name],
                hint: 'Seleccionar ${field.label}…',
                items: field.options
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _customFieldSelectValues[field.name] = v),
              ),
            ],
          ),
        );

      case 'check':
        return CheckboxListTile(
          value: _customFieldCheckValues[field.name] ?? false,
          onChanged: (v) =>
              setState(() => _customFieldCheckValues[field.name] = v ?? false),
          title: Text(
            field.label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          ),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ── Foto ─────────────────────────────────────────────────────────────────

  Widget _buildPhotoSelector() {
    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _uploadedPhotoUrl != null
                ? AppColors.success
                : AppColors.border,
            width: _uploadedPhotoUrl != null ? 2 : 1,
          ),
        ),
        child: _isUploadingPhoto
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'Subiendo imagen…',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : _uploadedPhotoUrl != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _uploadedPhotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image,
                        color: AppColors.textSecondary,
                        size: 48,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tocar para seleccionar foto',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const Text(
                    '(obligatoria)',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Preguntas adicionales ─────────────────────────────────────────────────

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _questions.length; i++) _buildQuestionItem(i),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Agregar pregunta'),
          onPressed: _addQuestion,
        ),
      ],
    );
  }

  Widget _buildQuestionItem(int i) {
    final q = _questions[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pregunta ${i + 1}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                onPressed: () => _removeQuestion(i),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _qLabelControllers[i],
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Escribe la pregunta…',
              hintStyle: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Tipo: ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: q['type'] as String,
                dropdownColor: AppColors.surface,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('Texto')),
                  DropdownMenuItem(value: 'date', child: Text('Fecha')),
                  DropdownMenuItem(value: 'select', child: Text('Selección')),
                  DropdownMenuItem(value: 'check', child: Text('Sí/No')),
                ],
                onChanged: (v) {
                  setState(() {
                    _questions[i]['type'] = v ?? 'text';
                    if (v == 'select' && _qOptions.length <= i) {
                      _qOptions.add([]);
                    }
                  });
                },
              ),
            ],
          ),
          if (q['type'] == 'select' && _qOptions.length > i)
            _buildSelectOptions(i),
        ],
      ),
    );
  }

  Widget _buildSelectOptions(int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Opciones:',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        ..._qOptions[i].asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _qOptions[i].removeAt(entry.key)),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Agregar opción', style: TextStyle(fontSize: 12)),
          onPressed: () => _addSelectOption(i),
        ),
      ],
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add({'type': 'text', 'required': false});
      _qLabelControllers.add(TextEditingController());
      _qOptions.add([]);
    });
  }

  void _removeQuestion(int i) {
    setState(() {
      _questions.removeAt(i);
      _qLabelControllers[i].dispose();
      _qLabelControllers.removeAt(i);
      if (_qOptions.length > i) _qOptions.removeAt(i);
    });
  }

  void _addSelectOption(int i) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Nueva opción',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Escribe la opción…'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result != null && result.isNotEmpty) {
      setState(() => _qOptions[i].add(result));
    }
  }

  // ── Helpers de UI ─────────────────────────────────────────────────────────

  String _formatCardDisplay(String input) {
    final clean = input.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < clean.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(clean[i]);
    }
    if (clean.length < 16) {
      for (int i = clean.length; i < 16; i++) {
        if (i > 0 && i % 4 == 0) buf.write(' ');
        buf.write('•');
      }
    }
    return buf.toString();
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<T>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(color: AppColors.textHint, fontSize: 13),
        ),
        isExpanded: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? AppColors.primaryGradient
            : const LinearGradient(
                colors: [AppColors.surfaceVariant, AppColors.surfaceVariant],
              ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(76),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
