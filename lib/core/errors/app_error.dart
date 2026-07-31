/// Tipos de error de la aplicación
enum AppErrorType {
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  conflict,
  server,
  unknown,
}

/// Error centralizado de la aplicación
class AppError implements Exception {
  final AppErrorType type;
  final String message;
  final int? statusCode;

  const AppError({
    required this.type,
    required this.message,
    this.statusCode,
  });

  /// Construye un AppError a partir del código de status HTTP
  factory AppError.fromStatusCode(int statusCode, {String? body}) {
    final msg = _parseMessage(body);
    switch (statusCode) {
      case 401:
        return AppError(
          type: AppErrorType.unauthorized,
          message: msg ?? 'Credenciales inválidas. Por favor inicia sesión de nuevo.',
          statusCode: statusCode,
        );
      case 403:
        return AppError(
          type: AppErrorType.forbidden,
          message: msg ?? 'No tienes permiso para realizar esta acción.',
          statusCode: statusCode,
        );
      case 404:
        return AppError(
          type: AppErrorType.notFound,
          message: msg ?? 'El recurso no fue encontrado.',
          statusCode: statusCode,
        );
      case 409:
        return AppError(
          type: AppErrorType.conflict,
          message: msg ?? 'Ya existe un registro con esos datos.',
          statusCode: statusCode,
        );
      case 422:
        return AppError(
          type: AppErrorType.validation,
          message: msg ?? 'Los datos enviados no son válidos.',
          statusCode: statusCode,
        );
      case 402:
        return AppError(
          type: AppErrorType.validation,
          message: msg ?? 'Pago requerido o rechazado.',
          statusCode: statusCode,
        );
      default:
        if (statusCode >= 500) {
          return AppError(
            type: AppErrorType.server,
            message: msg ?? 'Error del servidor. Intenta de nuevo más tarde.',
            statusCode: statusCode,
          );
        }
        return AppError(
          type: AppErrorType.unknown,
          message: msg ?? 'Ocurrió un error inesperado.',
          statusCode: statusCode,
        );
    }
  }

  factory AppError.network() => const AppError(
        type: AppErrorType.network,
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );

  factory AppError.unknown([String? msg]) => AppError(
        type: AppErrorType.unknown,
        message: msg ?? 'Ocurrió un error inesperado.',
      );

  static String? _parseMessage(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      // Intentar extraer el campo "message" del JSON de error
      final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(body);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => message;
}
