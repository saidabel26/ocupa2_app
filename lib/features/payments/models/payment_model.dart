/// Modelo de pago simulado.
/// Mapea la respuesta de POST /payments y GET /me/payments.
class PaymentModel {
  final String id;
  final double? amount;
  final String? currency;
  final String? status;
  final String? cardLast4;
  final String? cardholder;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    this.amount,
    this.currency,
    this.status,
    this.cardLast4,
    this.cardholder,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    // cardLast4 puede derivarse del campo cardNumber o del propio campo
    String? cardLast4 = json['cardLast4'] as String?;
    final cardNumber = json['cardNumber'] as String?;
    if (cardLast4 == null && cardNumber != null && cardNumber.length >= 4) {
      cardLast4 = cardNumber.substring(cardNumber.length - 4);
    }

    return PaymentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      cardLast4: cardLast4,
      cardholder: json['cardholder'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
