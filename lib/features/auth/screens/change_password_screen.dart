import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/loading_button.dart';
import '../../../shared/widgets/ocupa2_text_field.dart';
import '../providers/change_password_provider.dart';

/// Pantalla "Cambiar Contraseña".
/// Permite al usuario autenticado actualizar su contraseña vía PUT /me/password.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    // Escuchar cambios en el campo de contraseña para actualizar indicador de fortaleza
    _newPassCtrl.addListener(() => setState(() {}));

    // Resetear el provider al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChangePasswordProvider>().reset();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ChangePasswordProvider>();
    final success = await provider.changePassword(_newPassCtrl.text.trim());

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al cambiar la contraseña.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Contraseña actualizada!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Tu contraseña ha sido cambiada exitosamente.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop(); // cerrar el diálogo
                  context.pop(); // volver a la pantalla anterior (Perfil)
                  
                  // Limpiar campos
                  _newPassCtrl.clear();
                  _confirmCtrl.clear();
                  if (mounted) {
                    context.read<ChangePasswordProvider>().reset();
                  }
                },
                child: const Text('Aceptar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Icon
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(80),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Titulo y descripcion
                  const Text(
                    'Nueva contraseña',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elige una contraseña segura con al menos 6 caracteres.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo nueva contraseña
                  Ocupa2TextField(
                    controller: _newPassCtrl,
                    label: 'Nueva contraseña',
                    hint: 'Mínimo 6 caracteres',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ingresa una contraseña.';
                      }
                      if (v.trim().length < 6) {
                        return 'Debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo confirmar contraseña
                  Ocupa2TextField(
                    controller: _confirmCtrl,
                    label: 'Confirmar contraseña',
                    hint: 'Repite la nueva contraseña',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Confirma tu contraseña.';
                      }
                      if (v.trim() != _newPassCtrl.text.trim()) {
                        return 'Las contraseñas no coinciden.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Indicadores de seguridad
                  _buildPasswordStrength(),
                  const SizedBox(height: 32),

                  // Botón de envío
                  Consumer<ChangePasswordProvider>(
                    builder: (context, provider, _) {
                      return LoadingButton(
                        isLoading: provider.isLoading,
                        onPressed: _submit,
                        label: 'Cambiar Contraseña',
                        icon: Icons.save_outlined,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final pass = _newPassCtrl.text;
    if (pass.isEmpty) return const SizedBox.shrink();

    final checks = [
      ('Al menos 6 caracteres', pass.length >= 6),
      ('Al menos una letra', pass.contains(RegExp(r'[a-zA-Z]'))),
      ('Al menos un número', pass.contains(RegExp(r'\d'))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seguridad de la contraseña',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...checks.map(
          (check) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  check.$2
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: check.$2 ? AppColors.success : AppColors.textHint,
                ),
                const SizedBox(width: 8),
                Text(
                  check.$1,
                  style: TextStyle(
                    color: check.$2
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
