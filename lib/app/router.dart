import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/profile/screens/complete_profile_screen.dart';
import '../features/profile/screens/experiences_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/news/screens/news_list_screen.dart';
import '../features/news/screens/news_detail_screen.dart';
import '../features/videos/screens/videos_screen.dart';
import '../features/videos/screens/video_player_screen.dart';
import '../features/offers/screens/offers_list_screen.dart';
import '../features/offers/screens/offer_detail_screen.dart';
import '../features/offers/screens/offers_map_screen.dart';
import '../features/offers/screens/my_offers_screen.dart';
import '../features/offers/screens/create_offer_screen.dart';
import '../features/offers/screens/offer_applicants_screen.dart';
import '../features/offers/screens/my_applications_screen.dart';
import '../features/payments/screens/my_payments_screen.dart';
import '../features/auth/screens/change_password_screen.dart';
import '../features/about/screens/about_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../shared/screens/main_shell_screen.dart';


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
  static const String createOffer = '/create-offer';
  static const String offerApplicants = '/offer-applicants/:id';
  static const String applications = '/applications';
  static const String experiences = '/experiences';
  static const String payments = '/payments';
  static const String news = '/news';
  static const String newsDetail = '/news/:id';
  static const String videos = '/videos';
  static const String videoPlayer = '/video-player';
  static const String about = '/about';
  static const String changePassword = '/change-password';
  static const String profile = '/profile';
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

      // ── Reproductor de Video (sin shell) ────────────────────────────
      GoRoute(
        path: AppRoutes.videoPlayer,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return VideoPlayerScreen(
            videoUrl: data['url'] ?? '',
            title: data['title'] ?? 'Video',
          );
        },
      ),

      // ── Detalle de oferta (sin shell) ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.offerDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OfferDetailScreen(offerId: id);
        },
      ),

      // ── Publicar oferta (sin shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.createOffer,
        builder: (context, state) => const CreateOfferScreen(),
      ),

      // ── Aplicantes de mi oferta (sin shell) ────────────────────────────
      GoRoute(
        path: AppRoutes.offerApplicants,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OfferApplicantsScreen(offerId: id);
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
            builder: (context, state) => const OffersListScreen(),
          ),
          GoRoute(
            path: AppRoutes.map,
            builder: (context, state) => const OffersMapScreen(),
          ),
          GoRoute(
            path: AppRoutes.myOffers,
            builder: (context, state) => const MyOffersScreen(),
          ),
          GoRoute(
            path: AppRoutes.applications,
            builder: (context, state) => const MyApplicationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.experiences,
            builder: (context, state) => const ExperiencesScreen(),
          ),
          GoRoute(
            path: AppRoutes.payments,
            builder: (context, state) => const MyPaymentsScreen(),
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
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: AppRoutes.changePassword,
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
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
