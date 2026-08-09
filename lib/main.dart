import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/http/api_client.dart';
import 'core/services/upload_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/services/profile_service.dart';
import 'features/profile/providers/experience_provider.dart';
import 'features/profile/services/experience_service.dart';
import 'features/job_types/providers/job_type_provider.dart';
import 'features/job_types/services/job_type_service.dart';
import 'features/news/providers/news_provider.dart';
import 'features/news/services/news_service.dart';
import 'features/videos/providers/video_provider.dart';
import 'features/videos/services/video_service.dart';
import 'features/offers/providers/offer_provider.dart';
import 'features/offers/services/offer_service.dart';
import 'features/offers/providers/my_offers_provider.dart';
import 'features/offers/providers/apply_provider.dart';
import 'features/offers/services/application_service.dart';
import 'features/payments/providers/payment_provider.dart';
import 'features/payments/services/payment_service.dart';
import 'features/payments/providers/my_payments_provider.dart';
import 'features/payments/services/my_payments_service.dart';
import 'features/offers/providers/my_applications_provider.dart';
import 'features/offers/services/my_applications_service.dart';
import 'features/auth/providers/change_password_provider.dart';
import 'features/auth/services/password_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crear dependencias compartidas
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final authProvider = AuthProvider(
    apiClient: apiClient,
    authService: authService,
  );

  // Inicializar sesión desde SharedPreferences
  await authProvider.initSession();

  runApp(
    MultiProvider(
      providers: [
        // Cliente HTTP compartido.
        Provider<ApiClient>.value(value: apiClient),

        // Servicio de autenticación.
        Provider<AuthService>.value(value: authService),

        // Servicio de carga de imágenes.
        Provider<UploadService>(create: (_) => UploadService(apiClient)),

        // Estado de autenticación
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        // Perfil.
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(ProfileService(apiClient)),
        ),

        // Catálogo de tipos de empleo.
        ChangeNotifierProvider<JobTypeProvider>(
          create: (_) => JobTypeProvider(JobTypeService(apiClient)),
        ),

        // Noticias.
        ChangeNotifierProvider<NewsProvider>(
          create: (_) => NewsProvider(NewsService(apiClient)),
        ),

        // Videos.
        ChangeNotifierProvider<VideoProvider>(
          create: (_) => VideoProvider(VideoService(apiClient)),
        ),

        // Ofertas.
        ChangeNotifierProvider<OfferProvider>(
          create: (_) => OfferProvider(OfferService(apiClient)),
        ),

        // Pagos de publicación.
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(PaymentService(apiClient)),
        ),

        // Ofertas propias y aplicantes.
        ChangeNotifierProvider<MyOffersProvider>(
          create: (_) => MyOffersProvider(
            offerService: OfferService(apiClient),
            applicationService: ApplicationService(apiClient),
          ),
        ),

        // Experiencias del usuario.
        ChangeNotifierProvider<ExperienceProvider>(
          create: (_) => ExperienceProvider(ExperienceService(apiClient)),
        ),

        // Aplicaciones a ofertas.
        ChangeNotifierProvider<ApplyProvider>(
          create: (_) => ApplyProvider(ApplicationService(apiClient)),
        ),

        // Historial de aplicaciones.
        ChangeNotifierProvider<MyApplicationsProvider>(
          create: (_) =>
              MyApplicationsProvider(MyApplicationsService(apiClient)),
        ),

        // Historial de pagos.
        ChangeNotifierProvider<MyPaymentsProvider>(
          create: (_) => MyPaymentsProvider(MyPaymentsService(apiClient)),
        ),

        // Cambio de contraseña.
        ChangeNotifierProvider<ChangePasswordProvider>(
          create: (_) => ChangePasswordProvider(PasswordService(apiClient)),
        ),
      ],
      child: const Ocupa2App(),
    ),
  );
}
