/// Modelo de aplicación/postulación a una oferta.
/// Mapea la respuesta de GET /offers/{id}/applications.
class ApplicationModel {
  final String id;
  final String offerId;
  final String? offerTitle;
  final String status; // applied, discarded, finalist, winner
  final int? rating;
  final String? comment;
  final DateTime? createdAt;
  final ApplicantInfo? applicant;
  final List<ApplicationAnswer> answers;

  const ApplicationModel({
    required this.id,
    required this.offerId,
    this.offerTitle,
    required this.status,
    this.rating,
    this.comment,
    this.createdAt,
    this.applicant,
    this.answers = const [],
  });

  /// Texto legible del estado de la postulación.
  String get statusLabel {
    switch (status) {
      case 'applied':
        return 'En revisión';
      case 'discarded':
        return 'Descartado';
      case 'finalist':
        return 'Finalista';
      case 'winner':
        return 'Ganador';
      default:
        return status;
    }
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // El aplicante puede venir en varios campos
    ApplicantInfo? applicant;
    final rawApplicant = json['applicant'] ?? json['user'] ?? json['userId'];
    if (rawApplicant is Map<String, dynamic>) {
      applicant = ApplicantInfo.fromJson(rawApplicant);
    }

    final rawAnswers = json['answers'] as List<dynamic>?;

    // Intentar extraer el título de la oferta desde distintos campos anidados
    String? offerTitle;
    final rawOffer = json['offer'];
    if (rawOffer is Map<String, dynamic>) {
      offerTitle = rawOffer['title'] as String? ??
          rawOffer['description'] as String?;
    }
    offerTitle ??= json['offerTitle'] as String?;

    return ApplicationModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      offerId: json['offerId']?.toString() ?? '',
      offerTitle: offerTitle,
      status: json['status'] as String? ?? 'applied',
      rating: json['rating'] as int?,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      applicant: applicant,
      answers: rawAnswers
              ?.map((e) =>
                  ApplicationAnswer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Información básica del aplicante (visible para el dueño de la oferta).
class ApplicantInfo {
  final String id;
  final String nombre;
  final String? email;

  const ApplicantInfo({
    required this.id,
    required this.nombre,
    this.email,
  });

  factory ApplicantInfo.fromJson(Map<String, dynamic> json) {
    return ApplicantInfo(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: json['nombre'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      email: json['email'] as String?,
    );
  }
}

/// Respuesta de un aplicante a una pregunta adicional de la oferta.
class ApplicationAnswer {
  final String? questionId;
  final dynamic value;

  const ApplicationAnswer({this.questionId, this.value});

  factory ApplicationAnswer.fromJson(Map<String, dynamic> json) {
    return ApplicationAnswer(
      questionId: json['questionId'] as String?,
      value: json['value'],
    );
  }
}
