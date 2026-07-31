import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../shared/screens/main_shell_screen.dart';
import '../shared/screens/placeholder_screen.dart';

/// Rutas de la aplicación
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Rutas protegidas
  static const String home = '/home';
  static const String completeProfile = '/complete-profile';
  static const String offers = '/offers';
  static const String offerDetail = '/offers/:id';
  static const String map = '/map';
  static const String myOffers = '/my-offers';
  static const String applications = '/applications';
  static const String experiences = '/experiences';
  static const String payments = '/payments';
  static const String news = '/news';
  static const String videos = '/videos';
  static const String about = '/about';
  static const String changePassword = '/change-password';
}

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final status = authProvider.status;
      final location = state.uri.toString();

      // Aún inicializando → no redirigir
      if (status == AuthStatus.unknown) return null;

      final isPublicRoute = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword;

      // No autenticado → forzar login
      if (status == AuthStatus.unauthenticated) {
        return isPublicRoute ? null : AppRoutes.login;
      }

      // Autenticado pero perfil incompleto → forzar completar perfil
      if (status == AuthStatus.authenticated &&
          !authProvider.profileCompleted &&
          location != AppRoutes.completeProfile) {
        return AppRoutes.completeProfile;
      }

      // Autenticado con perfil completo intentando entrar a ruta pública → home
      if (status == AuthStatus.authenticated &&
          authProvider.profileCompleted &&
          isPublicRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // ── Rutas públicas ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ── Completar perfil (parte 2) ───────────────────────────────────
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Completar Perfil',
          icon: Icons.person_outline,
          description: 'Esta pantalla será implementada en la Parte 2.',
          showLogout: true,
        ),
      ),

      // ── Shell con navegación inferior ───────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Inicio',
              icon: Icons.home_outlined,
              description: 'Slider de bienvenida. Será implementado en la Parte 2.',
            ),
          ),
          GoRoute(
            path: AppRoutes.offers,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Explorar Ofertas',
              icon: Icons.work_outline,
              description: 'Listado y filtro de ofertas. Parte 3.',
            ),
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Mapa de Ofertas',
              icon: Icons.map_outlined,
              description: 'Mapa con pines de ofertas. Parte 3.',
            ),
          ),
          GoRoute(
            path: AppRoutes.myOffers,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Mis Ofertas',
              icon: Icons.business_center_outlined,
              description: 'Mis ofertas publicadas. Parte 4.',
            ),
          ),
          GoRoute(
            path: AppRoutes.applications,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Mis Aplicaciones',
              icon: Icons.assignment_outlined,
              description: 'Estado de mis postulaciones. Parte 6.',
            ),
          ),
          GoRoute(
            path: AppRoutes.experiences,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Mi Perfil / Experiencias',
              icon: Icons.school_outlined,
              description: 'Perfil y experiencias laborales. Parte 5.',
            ),
          ),
          GoRoute(
            path: AppRoutes.payments,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Mis Pagos',
              icon: Icons.receipt_long_outlined,
              description: 'Historial de pagos. Parte 6.',
            ),
          ),
          GoRoute(
            path: AppRoutes.news,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Noticias',
              icon: Icons.newspaper_outlined,
              description: 'Noticias de empleo. Parte 2.',
            ),
          ),
          GoRoute(
            path: AppRoutes.videos,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Videos',
              icon: Icons.play_circle_outline,
              description: 'Videos educativos. Parte 2.',
            ),
          ),
          GoRoute(
            path: AppRoutes.about,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Acerca de',
              icon: Icons.info_outline,
              description: 'Equipo de desarrollo. Parte 6.',
            ),
          ),
          GoRoute(
            path: AppRoutes.changePassword,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Cambiar Contraseña',
              icon: Icons.lock_outline,
              description: 'Cambio de contraseña. Parte 6.',
            ),
          ),
        ],
      ),

      // ── Detalle de oferta (sin shell) ───────────────────────────────
      GoRoute(
        path: AppRoutes.offerDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlaceholderScreen(
            title: 'Detalle de Oferta',
            icon: Icons.work_outline,
            description: 'Detalle de oferta $id. Parte 3 y 5.',
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.uri}'),
      ),
    ),
  );
}
