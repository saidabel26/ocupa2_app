import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../features/auth/providers/auth_provider.dart';

/// Shell principal de navegación con BottomNavigationBar.
/// Envuelve todas las rutas protegidas que tienen la barra inferior.
class MainShellScreen extends StatelessWidget {
  final Widget child;

  const MainShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      drawer: _buildDrawer(context),
      bottomNavigationBar: _buildBottomNav(context, location),
    );
  }

  Widget _buildBottomNav(BuildContext context, String location) {
    final items = [
      (AppRoutes.home, Icons.home_outlined, Icons.home, 'Inicio'),
      (AppRoutes.offers, Icons.work_outline, Icons.work, 'Ofertas'),
      (AppRoutes.map, Icons.map_outlined, Icons.map, 'Mapa'),
      (
        AppRoutes.myOffers,
        Icons.business_center_outlined,
        Icons.business_center,
        'Mis Ofertas',
      ),
      (AppRoutes.news, Icons.newspaper_outlined, Icons.newspaper, 'Noticias'),
    ];

    final currentIndex = items.indexWhere((e) => location == e.$1);

    return BottomNavigationBar(
      currentIndex: currentIndex < 0 ? 0 : currentIndex,
      onTap: (i) => context.go(items[i].$1),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.surface,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      items: items
          .map(
            (e) => BottomNavigationBarItem(
              icon: Icon(e.$2),
              activeIcon: Icon(e.$3),
              label: e.$4,
            ),
          )
          .toList(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                children: [
                  _drawerItem(
                    context,
                    Icons.home_outlined,
                    'Inicio',
                    AppRoutes.home,
                  ),
                  _drawerItem(
                    context,
                    Icons.work_outline,
                    'Explorar Ofertas',
                    AppRoutes.offers,
                  ),
                  _drawerItem(
                    context,
                    Icons.map_outlined,
                    'Mapa',
                    AppRoutes.map,
                  ),
                  _drawerItem(
                    context,
                    Icons.business_center_outlined,
                    'Mis Ofertas',
                    AppRoutes.myOffers,
                  ),
                  _drawerItem(
                    context,
                    Icons.assignment_outlined,
                    'Mis Aplicaciones',
                    AppRoutes.applications,
                  ),
                  _drawerItem(
                    context,
                    Icons.school_outlined,
                    'Experiencias',
                    AppRoutes.experiences,
                  ),
                  _drawerItem(
                    context,
                    Icons.receipt_long_outlined,
                    'Mis Pagos',
                    AppRoutes.payments,
                  ),
                  const Divider(color: AppColors.border),
                  _drawerItem(
                    context,
                    Icons.newspaper_outlined,
                    'Noticias',
                    AppRoutes.news,
                  ),
                  _drawerItem(
                    context,
                    Icons.play_circle_outline,
                    'Videos',
                    AppRoutes.videos,
                  ),
                  const Divider(color: AppColors.border),
                  _drawerItem(
                    context,
                    Icons.person_outline,
                    'Mi Perfil',
                    AppRoutes.profile,
                  ),
                  _drawerItem(
                    context,
                    Icons.info_outline,
                    'Acerca de',
                    AppRoutes.about,
                  ),
                ],
              ),
            ),
            // Logout
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: AppColors.error),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.error, width: 1),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await authProvider.logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    final current = GoRouterState.of(context).uri.toString();
    final isActive = current == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
    );
  }
}
