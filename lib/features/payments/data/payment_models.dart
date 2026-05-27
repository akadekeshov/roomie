import '../../../core/models/user_brief.dart';

enum PaymentStatus {
  pending('PENDING', 'Ожидает оплаты'),
  paid('PAID', 'Оплачено'),
  failed('FAILED', 'Ошибка'),
  cancelled('CANCELLED', 'Отменено'),
  refunded('REFUNDED', 'Возвращено');

  const PaymentStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PaymentStatus fromApi(String? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentType {
  deposit('DEPOSIT', 'Депозит'),
  monthlyRent('MONTHLY_RENT', 'Ежемесячная оплата'),
  utilities('UTILITIES', 'Коммунальные платежи'),
  other('OTHER', 'Прочее');

  const PaymentType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PaymentType fromApi(String? value) {
    return PaymentType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => PaymentType.other,
    );
  }
}

class UserPaymentCard {
  const UserPaymentCard({
    required this.id,
    required this.maskedPan,
    required this.status,
    this.provider,
    this.cardBrand,
  });

  final String id;
  final String? provider;
  final String maskedPan;
  final String? cardBrand;
  final String status;

  factory UserPaymentCard.fromJson(Map<String, dynamic> json) {
    return UserPaymentCard(
      id: '${json['id'] ?? ''}',
      provider: json['provider'] as String?,
      maskedPan: '${json['maskedPan'] ?? ''}',
      cardBrand: json['cardBrand'] as String?,
      status: '${json['status'] ?? ''}',
    );
  }
}

class AgreementPayment {
  const AgreementPayment({
    required this.id,
    required this.agreementId,
    required this.payerId,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.paidAt,
    this.description,
    this.mockReceiptNo,
    this.payer,
  });

  final String id;
  final String agreementId;
  final String payerId;
  final PaymentType type;
  final PaymentStatus status;
  final int amount;
  final String currency;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? description;
  final String? mockReceiptNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserBrief? payer;

  factory AgreementPayment.fromJson(Map<String, dynamic> json) {
    return AgreementPayment(
      id: '${json['id'] ?? ''}',
      agreementId: '${json['agreementId'] ?? ''}',
      payerId: '${json['payerId'] ?? ''}',
      type: PaymentType.fromApi(json['type']?.toString()),
      status: PaymentStatus.fromApi(json['status']?.toString()),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: '${json['currency'] ?? 'KZT'}',
      dueDate: DateTime.tryParse('${json['dueDate'] ?? ''}'),
      paidAt: DateTime.tryParse('${json['paidAt'] ?? ''}'),
      description: json['description'] as String?,
      mockReceiptNo: json['mockReceiptNo'] as String?,
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse('${json['updatedAt'] ?? ''}') ?? DateTime.now(),
      payer: json['payer'] is Map<String, dynamic>
          ? UserBrief.fromJson(json['payer'] as Map<String, dynamic>)
          : null,
    );
  }
}
