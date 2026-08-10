import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import 'router.dart';
import 'theme.dart';

class Ocupa2App extends StatefulWidget {
  const Ocupa2App({super.key});

  @override
  State<Ocupa2App> createState() => _Ocupa2AppState();
}

class _Ocupa2AppState extends State<Ocupa2App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Instanciar el router una sola vez para que no se reinicie el estado
    // de la pantalla al cambiar el Provider
    final authProvider = context.read<AuthProvider>();
    _router = buildRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ocupa2',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
