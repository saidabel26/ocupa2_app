/// Modelo de pregunta adicional definida por quien publica una oferta.
/// Estas preguntas aparecen en el formulario de aplicación (Parte 5) y
/// en la vista de detalle como informativas.
class OfferQuestionModel {
  final String? id;
  final String label;
  final String type; // text, date, select, check
  final bool required;
  final List<String> options;

  const OfferQuestionModel({
    this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.options = const [],
  });

  factory OfferQuestionModel.fromJson(Map<String, dynamic> json) {
    return OfferQuestionModel(
      id: json['id'] as String? ?? json['_id'] as String?,
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      required: json['required'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
