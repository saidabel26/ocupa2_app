import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/errors/app_error.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/ocupa2_text_field.dart';
import '../models/profile_request.dart';
import '../providers/profile_provider.dart';

/// Pantalla de completar perfil (primer acceso).
/// Se muestra obligatoriamente cuando profileCompleted == false.
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();

  String _gender = 'masculino';
  DateTime? _birthDate;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const List<Map<String, String>> _genderOptions = [
    {'value': 'masculino', 'label': 'Masculino'},
    {'value': 'femenino', 'label': 'Femenino'},
    {'value': 'otro', 'label': 'Otro'},
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();

    // Pre-rellenar con datos existentes si los hay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _firstNameCtrl.text = user.firstName;
        _lastNameCtrl.text = user.lastName;
        if (user.cedula != null) _cedulaCtrl.text = user.cedula!;
        if (user.gender != null) setState(() => _gender = user.gender!);
        if (user.birthDate != null) setState(() => _birthDate = user.birthDate);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _cedulaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 15),
      helpText: 'Selecciona tu fecha de nacimiento',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      _showError('Selecciona tu fecha de nacimiento.');
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    final request = ProfileRequest(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      cedula: _cedulaCtrl.text.trim(),
      gender: _gender,
      birthDate:
          '${_birthDate!.year.toString().padLeft(4, '0')}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
    );

    try {
      final updatedUser = await profileProvider.updateProfile(request);
      if (!mounted) return;
      // Actualiza el AuthProvider → el guard del router redirige a /home
      authProvider.updateUser(updatedUser);
      context.go(AppRoutes.home);
    } on AppError catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('Error inesperado. Intenta de nuevo.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: AppColors.surface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 28),
                      _buildFormCard(isLoading),
                      const SizedBox(height: 20),
                      _buildLogoutLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'Completa tu Perfil',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Necesitamos algunos datos antes de empezar',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nombre
          Ocupa2TextField(
            label: 'Nombre',
            hint: 'Juan',
            controller: _firstNameCtrl,
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre';
              if (v.trim().length < 2) return 'Muy corto';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Apellido
          Ocupa2TextField(
            label: 'Apellido',
            hint: 'Pérez',
            controller: _lastNameCtrl,
            prefixIcon: Icons.badge_outlined,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu apellido';
              if (v.trim().length < 2) return 'Muy corto';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Cédula
          Ocupa2TextField(
            label: 'Cédula',
            hint: '40212345678',
            controller: _cedulaCtrl,
            prefixIcon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa tu cédula';
              final digits = v.trim().replaceAll(RegExp(r'\D'), '');
              if (digits.length != 11) return 'La cédula debe tener 11 dígitos';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Género
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: InputDecoration(
              labelText: 'Género',
              prefixIcon: const Icon(
                Icons.wc_outlined,
                color: AppColors.textSecondary,
              ),
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
                borderSide: const BorderSide(
                  color: AppColors.borderFocus,
                  width: 2,
                ),
              ),
            ),
            dropdownColor: AppColors.surface,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            items: _genderOptions
                .map(
                  (g) => DropdownMenuItem(
                    value: g['value'],
                    child: Text(g['label']!),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _gender = v);
            },
          ),
          const SizedBox(height: 16),

          // Fecha de nacimiento
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Fecha de nacimiento',
                prefixIcon: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                ),
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
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ),
              child: Text(
                _birthDate != null
                    ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                    : 'Seleccionar fecha',
                style: TextStyle(
                  color: _birthDate != null
                      ? AppColors.textPrimary
                      : AppColors.textHint,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Botón guardar
          GradientButton(
            label: 'Guardar y continuar',
            onPressed: isLoading ? null : _submit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
        },
        icon: const Icon(
          Icons.logout,
          size: 16,
          color: AppColors.textSecondary,
        ),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
