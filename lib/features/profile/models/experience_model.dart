/// Modelo de experiencia laboral del usuario.
/// Mapea la respuesta de GET /me/experiences y POST /me/experiences.
class ExperienceModel {
  final String id;
  final String title;
  final String description;
  final String? jobTypeKey;
  final String? certificateImage;
  final DateTime? createdAt;

  const ExperienceModel({
    required this.id,
    required this.title,
    required this.description,
    this.jobTypeKey,
    this.certificateImage,
    this.createdAt,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      jobTypeKey: json['jobTypeKey'] as String?,
      certificateImage: json['certificateImage'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        if (jobTypeKey != null) 'jobTypeKey': jobTypeKey,
        if (certificateImage != null) 'certificateImage': certificateImage,
      };
}
