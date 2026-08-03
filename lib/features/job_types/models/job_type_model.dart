import 'custom_field_model.dart';

/// Modelo de tipo de empleo (categoría).
/// Incluye campos personalizados dinámicos que el administrador puede definir.
class JobTypeModel {
  final String id;
  final String key;  // Clave string del tipo de empleo (ej: 'tecnologia')
  final String name;
  final String? description;
  final String? icon;
  final List<CustomFieldModel> customFields;

  const JobTypeModel({
    required this.id,
    required this.key,
    required this.name,
    this.description,
    this.icon,
    this.customFields = const [],
  });

  factory JobTypeModel.fromJson(Map<String, dynamic> json) {
    final rawFields = json['customFields'] as List<dynamic>?;
    return JobTypeModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      // 'key' es el identificador string que coincide con jobTypeKey en las ofertas
      key: json['key']?.toString() ?? json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      customFields: rawFields
              ?.map((e) => CustomFieldModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
