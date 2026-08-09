/// Envuelve las respuestas del API en un contenedor tipado.
class ApiResponse<T> {
  final bool ok;
  final T? data;
  final String? errorMessage;

  const ApiResponse({required this.ok, this.data, this.errorMessage});

  bool get isSuccess => ok && data != null;
  bool get isError => !ok || errorMessage != null;
}
