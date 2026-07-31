import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/profile/screens/complete_profile_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/news/screens/news_list_screen.dart';
import '../features/news/screens/news_detail_screen.dart';
import '../features/videos/screens/videos_screen.dart';
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
  static const String newsDetail = '/news/:id';
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
        builder: (context, state) => const CompleteProfileScreen(),
      ),

      // ── Detalle de noticia (sin shell) ──────────────────────────────
      GoRoute(
        path: AppRoutes.newsDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NewsDetailScreen(newsId: id);
        },
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

      // ── Shell con navegación inferior ───────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
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
            builder: (context, state) => const NewsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.videos,
            builder: (context, state) => const VideosScreen(),
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Página no encontrada: ${state.uri}'),
      ),
    ),
  );
}
