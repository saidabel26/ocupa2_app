import 'offer_question_model.dart';

/// Modelo de oferta de empleo del API de Ocupa2.
/// Mapea la respuesta de GET /offers y GET /offers/{id}.
class OfferModel {
  final String id;
  final String jobTypeKey;
  final String? jobTypeName;
  final String contractType;
  final String description;
  final String address;
  final String? photo;
  final double? locationLat;
  final double? locationLng;
  final double? paymentAmount;
  final String? paymentCurrency;
  final DateTime? deadline;
  final String? status;
  final DateTime? createdAt;
  final int likesCount;
  final bool liked;
  final Map<String, dynamic> customAnswers;
  final List<OfferQuestionModel> questions;

  const OfferModel({
    required this.id,
    required this.jobTypeKey,
    this.jobTypeName,
    required this.contractType,
    required this.description,
    required this.address,
    this.photo,
    this.locationLat,
    this.locationLng,
    this.paymentAmount,
    this.paymentCurrency,
    this.deadline,
    this.status,
    this.createdAt,
    this.likesCount = 0,
    this.liked = false,
    this.customAnswers = const {},
    this.questions = const [],
  });

  /// Indica si la oferta tiene coordenadas válidas para mostrar en mapa.
  bool get hasLocation =>\n      locationLat != null &&\n      locationLng != null &&\n      locationLat != 0.0 &&\n      locationLng != 0.0;

  /// Texto legible del tipo de contrato.
  String get contractTypeLabel {
    switch (contractType) {
      case 'temporal':
        return 'Temporal';
      case 'fijo':
        return 'Fijo';
      case 'horas':
        return 'Por horas';
      default:
        return contractType;
    }
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    // Extraer ubicación (puede venir como objeto {lat, lng} o campos planos)
    double? lat;
    double? lng;
    final loc = json['location'];
    if (loc is Map<String, dynamic>) {
      lat = (loc['lat'] as num?)?.toDouble();
      lng = (loc['lng'] as num?)?.toDouble();
    } else {
      lat = (json['lat'] as num?)?.toDouble() ??
          (json['locationLat'] as num?)?.toDouble();
      lng = (json['lng'] as num?)?.toDouble() ??
          (json['locationLng'] as num?)?.toDouble();
    }

    // Extraer pago (puede venir como objeto {amount, currency} o campos planos)
    double? payAmount;
    String? payCurrency;
    final pay = json['payment'];
    if (pay is Map<String, dynamic>) {
      payAmount = (pay['amount'] as num?)?.toDouble();
      payCurrency = pay['currency'] as String?;
    } else {
      payAmount = (json['paymentAmount'] as num?)?.toDouble() ??
          (json['salary'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble();
      payCurrency = json['paymentCurrency'] as String? ??
          json['currency'] as String?;
    }

    // Extraer preguntas adicionales
    final rawQuestions = json['questions'] as List<dynamic>?;

    // Extraer custom answers
    final rawCustom = json['customAnswers'];
    final Map<String, dynamic> customMap =
        rawCustom is Map<String, dynamic> ? rawCustom : {};

    return OfferModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      jobTypeKey: json['jobTypeKey'] as String? ?? '',
      jobTypeName: json['jobTypeName'] as String?,
      contractType: json['contractType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photo: json['photo'] as String?,
      locationLat: lat,
      locationLng: lng,
      paymentAmount: payAmount,
      paymentCurrency: payCurrency,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      status: json['status'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      likesCount: json['likesCount'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      customAnswers: customMap,
      questions: rawQuestions
              ?.map(
                  (e) => OfferQuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Crea una copia del modelo con los campos especificados reemplazados.
  OfferModel copyWith({
    String? id,
    String? jobTypeKey,
    String? jobTypeName,
    String? contractType,
    String? description,
    String? address,
    String? photo,
    double? locationLat,
    double? locationLng,
    double? paymentAmount,
    String? paymentCurrency,
    DateTime? deadline,
    String? status,
    DateTime? createdAt,
    int? likesCount,
    bool? liked,
    Map<String, dynamic>? customAnswers,
    List<OfferQuestionModel>? questions,
  }) {
    return OfferModel(
      id: id ?? this.id,
      jobTypeKey: jobTypeKey ?? this.jobTypeKey,
      jobTypeName: jobTypeName ?? this.jobTypeName,
      contractType: contractType ?? this.contractType,
      description: description ?? this.description,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      liked: liked ?? this.liked,
      customAnswers: customAnswers ?? this.customAnswers,
      questions: questions ?? this.questions,
    );
  }
}
