import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/http/api_client.dart';
import 'core/services/upload_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';

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
      ],
      child: const Ocupa2App(),
    ),
  );
}
