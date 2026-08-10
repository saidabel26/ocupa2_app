/// Modelo de campo personalizado dinámico de un tipo de empleo.
/// El backend puede retornar campos tipo text, select, check o date
/// que deben renderizarse dinámicamente al publicar/filtrar ofertas.
class CustomFieldModel {
  final String key;
  final String label;
  final String type; // 'text' | 'select' | 'check' | 'date'
  final List<String> options; // Solo aplica para type == 'select'
  final bool required;

  const CustomFieldModel({
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
    this.required = false,
  });

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) {
    return CustomFieldModel(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      required: json['required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type,
      'options': options,
      'required': required,
    };
  }
}
