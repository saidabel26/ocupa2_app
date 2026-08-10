import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Botón reutilizable para abrir el drawer lateral.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          ScaffoldState? scaffold = Scaffold.maybeOf(context);
          if (scaffold != null && !scaffold.hasDrawer) {
            scaffold = context.findRootAncestorStateOfType<ScaffoldState>();
          }
          scaffold?.openDrawer();
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(Icons.menu, color: AppColors.textPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}
