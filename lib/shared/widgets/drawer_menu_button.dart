import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Botón reutilizable para abrir el Drawer lateral.
/// Debe usarse dentro de un [Builder] o contexto que tenga acceso al [Scaffold]
/// padre que posee el [Drawer].
///
/// Uso en AppBar.leading:
///   leading: const DrawerMenuButton(),
///
/// Uso dentro de un Row (buildHeader):
///   const DrawerMenuButton(),
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldState? scaffold = Scaffold.maybeOf(context);
        // Si el Scaffold más cercano no tiene Drawer (ej. Scaffold interno de la vista),
        // buscamos el Scaffold raíz (el del ShellRoute).
        if (scaffold != null && !scaffold.hasDrawer) {
          scaffold = context.findRootAncestorStateOfType<ScaffoldState>();
        }
        scaffold?.openDrawer();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}
