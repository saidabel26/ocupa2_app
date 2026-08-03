import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/http/api_client.dart';
import 'core/services/upload_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/services/profile_service.dart';
import 'features/job_types/providers/job_type_provider.dart';
import 'features/job_types/services/job_type_service.dart';
import 'features/news/providers/news_provider.dart';
import 'features/news/services/news_service.dart';
import 'features/videos/providers/video_provider.dart';
import 'features/videos/services/video_service.dart';
import 'features/offers/providers/offer_provider.dart';
import 'features/offers/services/offer_service.dart';

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
        // Exponer el ApiClient a toda la app (partes futuras lo pueden usar)
        Provider<ApiClient>.value(value: apiClient),

        // Exponer el UploadService a toda la app
        Provider<UploadService>(
          create: (_) => UploadService(apiClient),
        ),

        // Estado de autenticación
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),

        // Parte 2 – Completar perfil
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(ProfileService(apiClient)),
        ),

        // Parte 2 – Catálogo de tipos de empleo (compartido con partes 3 y 4)
        ChangeNotifierProvider<JobTypeProvider>(
          create: (_) => JobTypeProvider(JobTypeService(apiClient)),
        ),

        // Parte 2 – Noticias
        ChangeNotifierProvider<NewsProvider>(
          create: (_) => NewsProvider(NewsService(apiClient)),
        ),

        // Parte 2 – Videos
        ChangeNotifierProvider<VideoProvider>(
          create: (_) => VideoProvider(VideoService(apiClient)),
        ),

        // Parte 3 – Ofertas
        ChangeNotifierProvider<OfferProvider>(
          create: (_) => OfferProvider(OfferService(apiClient)),
        ),
      ],
      child: const Ocupa2App(),
    ),
  );
}
