# Ocupa2

Cliente Flutter para la plataforma de empleos temporales de estudiantes del ITLA. La aplicación consume la API REST de Ocupa2 para publicar ofertas, aplicar a ellas y gestionar perfiles, experiencias y pagos.

## Requisitos

- Flutter SDK compatible con Dart 3.12 o superior.
- Un dispositivo Android o emulador con conexión a internet.

## Ejecución

```bash
flutter pub get
flutter analyze
flutter run
```

Para generar el APK de prueba:

```bash
flutter build apk --release
```

El APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

## Arquitectura

La aplicación se organiza por funcionalidades. Cada módulo separa pantallas, servicios, modelos y estado:

```text
lib/
  app/       configuración, tema y navegación
  core/      cliente HTTP, errores, constantes y uploads
  features/  módulos funcionales de la aplicación
  shared/    widgets y navegación compartidos
```

El flujo de datos principal es `pantalla → provider → servicio → ApiClient → API`. El estado se maneja con `provider`, las rutas con `go_router` y la sesión JWT se conserva con `shared_preferences`.

## Módulos

- Registro, inicio de sesión, recuperación y cambio de contraseña.
- Completar y editar perfil con guard de `profileCompleted`.
- Inicio, noticias y videos educativos.
- Exploración, detalle y mapa de ofertas.
- Publicación de ofertas con foto, pago simulado, campos dinámicos y preguntas para aplicantes.
- Gestión de ofertas propias y aplicantes.
- Aplicaciones, experiencias, certificados e historial de pagos.
- Acerca de con información y medios de contacto del equipo.

## API

La URL base se define en `lib/core/constants/api_constants.dart`:

```text
https://ocupa2.ia3x.com/apix
```

Los endpoints y contratos de referencia usados por el cliente están documentados en `openapi.yaml`.
