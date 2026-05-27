import '../../../core/models/user_brief.dart';

enum AgreementStatus {
  draft('DRAFT', 'Черновик'),
  waitingSecondParty('WAITING_SECOND_PARTY', 'Ожидает второго участника'),
  pendingConfirmation('PENDING_CONFIRMATION', 'Ожидает подтверждения'),
  active('ACTIVE', 'Активен'),
  cancelled('CANCELLED', 'Отменен'),
  completed('COMPLETED', 'Завершен'),
  rejected('REJECTED', 'Отклонен');

  const AgreementStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AgreementStatus fromApi(String? value) {
    return AgreementStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => AgreementStatus.draft,
    );
  }
}

String agreementUtilitySplitLabel(String? value) {
  switch ((value ?? '').toUpperCase()) {
    case 'EQUAL':
      return 'Поровну';
    case 'PERCENTAGE':
      return 'В процентах';
    case 'CUSTOM':
      return 'Индивидуально';
    default:
      return 'Не указано';
  }
}

class AgreementSummary {
  const AgreementSummary({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.currentUserConfirmed,
    required this.otherUserConfirmed,
    this.otherUser,
  });

  final String id;
  final AgreementStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool currentUserConfirmed;
  final bool otherUserConfirmed;
  final UserBrief? otherUser;

  factory AgreementSummary.fromJson(Map<String, dynamic> json) {
    return AgreementSummary(
      id: '${json['id'] ?? ''}',
      status: AgreementStatus.fromApi(json['status']?.toString()),
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse('${json['updatedAt'] ?? ''}') ?? DateTime.now(),
      currentUserConfirmed: json['currentUserConfirmed'] as bool? ?? false,
      otherUserConfirmed: json['otherUserConfirmed'] as bool? ?? false,
      otherUser: json['otherUser'] is Map<String, dynamic>
          ? UserBrief.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AgreementConversationStatus {
  const AgreementConversationStatus({
    required this.canCreateAgreement,
    required this.reason,
    required this.existingAgreement,
    required this.messageCount,
    required this.bothUsersHaveMessages,
  });

  final bool canCreateAgreement;
  final String? reason;
  final AgreementSummary? existingAgreement;
  final int messageCount;
  final bool bothUsersHaveMessages;

  factory AgreementConversationStatus.fromJson(Map<String, dynamic> json) {
    return AgreementConversationStatus(
      canCreateAgreement: json['canCreateAgreement'] as bool? ?? false,
      reason: json['reason'] as String?,
      existingAgreement: json['existingAgreement'] is Map<String, dynamic>
          ? AgreementSummary.fromJson(
              json['existingAgreement'] as Map<String, dynamic>,
            )
          : null,
      messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
      bothUsersHaveMessages: json['bothUsersHaveMessages'] as bool? ?? false,
    );
  }
}

class RoommateAgreement {
  const RoommateAgreement({
    required this.id,
    required this.status,
    required this.creatorId,
    required this.firstUserId,
    required this.secondUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.firstUser,
    required this.secondUser,
    required this.creator,
    required this.currentUserConfirmed,
    required this.otherUserConfirmed,
    required this.housingFound,
    required this.noticePeriodDays,
    required this.payments,
    required this.disputes,
    this.otherUser,
    this.conversationId,
    this.city,
    this.address,
    this.moveInDate,
    this.moveOutDate,
    this.monthlyRent,
    this.depositAmount,
    this.utilitySplitType,
    this.firstUserUtilityPercent,
    this.secondUserUtilityPercent,
    this.houseRules,
    this.guestPolicy,
    this.quietHours,
    this.cleaningSchedule,
    this.smokingPolicy,
    this.petPolicy,
    this.damageResponsibility,
    this.terminationTerms,
    this.disputeTerms,
    this.sentForConfirmationAt,
    this.firstUserConfirmedAt,
    this.secondUserConfirmedAt,
    this.cancelledAt,
    this.cancelledById,
    this.rejectedAt,
    this.rejectedById,
    this.completedAt,
    this.pdfUrl,
    this.digitalSignatureStatus,
    this.notaryStatus,
  });

  final String id;
  final String? conversationId;
  final String creatorId;
  final String firstUserId;
  final String secondUserId;
  final AgreementStatus status;
  final String? city;
  final String? address;
  final DateTime? moveInDate;
  final DateTime? moveOutDate;
  final int? monthlyRent;
  final int? depositAmount;
  final bool housingFound;
  final String? utilitySplitType;
  final int? firstUserUtilityPercent;
  final int? secondUserUtilityPercent;
  final String? houseRules;
  final String? guestPolicy;
  final String? quietHours;
  final String? cleaningSchedule;
  final String? smokingPolicy;
  final String? petPolicy;
  final int? noticePeriodDays;
  final String? damageResponsibility;
  final String? terminationTerms;
  final String? disputeTerms;
  final DateTime? sentForConfirmationAt;
  final DateTime? firstUserConfirmedAt;
  final DateTime? secondUserConfirmedAt;
  final DateTime? cancelledAt;
  final String? cancelledById;
  final DateTime? rejectedAt;
  final String? rejectedById;
  final DateTime? completedAt;
  final String? pdfUrl;
  final String? digitalSignatureStatus;
  final String? notaryStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserBrief firstUser;
  final UserBrief secondUser;
  final UserBrief creator;
  final UserBrief? otherUser;
  final bool currentUserConfirmed;
  final bool otherUserConfirmed;
  final List<dynamic> payments;
  final List<dynamic> disputes;

  factory RoommateAgreement.fromJson(Map<String, dynamic> json) {
    return RoommateAgreement(
      id: '${json['id'] ?? ''}',
      conversationId: json['conversationId']?.toString(),
      creatorId: '${json['creatorId'] ?? ''}',
      firstUserId: '${json['firstUserId'] ?? ''}',
      secondUserId: '${json['secondUserId'] ?? ''}',
      status: AgreementStatus.fromApi(json['status']?.toString()),
      city: json['city'] as String?,
      address: json['address'] as String?,
      moveInDate: DateTime.tryParse('${json['moveInDate'] ?? ''}'),
      moveOutDate: DateTime.tryParse('${json['moveOutDate'] ?? ''}'),
      monthlyRent: (json['monthlyRent'] as num?)?.toInt(),
      depositAmount: (json['depositAmount'] as num?)?.toInt(),
      housingFound: json['housingFound'] as bool? ?? false,
      utilitySplitType: json['utilitySplitType'] as String?,
      firstUserUtilityPercent:
          (json['firstUserUtilityPercent'] as num?)?.toInt(),
      secondUserUtilityPercent:
          (json['secondUserUtilityPercent'] as num?)?.toInt(),
      houseRules: json['houseRules'] as String?,
      guestPolicy: json['guestPolicy'] as String?,
      quietHours: json['quietHours'] as String?,
      cleaningSchedule: json['cleaningSchedule'] as String?,
      smokingPolicy: json['smokingPolicy'] as String?,
      petPolicy: json['petPolicy'] as String?,
      noticePeriodDays: (json['noticePeriodDays'] as num?)?.toInt(),
      damageResponsibility: json['damageResponsibility'] as String?,
      terminationTerms: json['terminationTerms'] as String?,
      disputeTerms: json['disputeTerms'] as String?,
      sentForConfirmationAt:
          DateTime.tryParse('${json['sentForConfirmationAt'] ?? ''}'),
      firstUserConfirmedAt:
          DateTime.tryParse('${json['firstUserConfirmedAt'] ?? ''}'),
      secondUserConfirmedAt:
          DateTime.tryParse('${json['secondUserConfirmedAt'] ?? ''}'),
      cancelledAt: DateTime.tryParse('${json['cancelledAt'] ?? ''}'),
      cancelledById: json['cancelledById']?.toString(),
      rejectedAt: DateTime.tryParse('${json['rejectedAt'] ?? ''}'),
      rejectedById: json['rejectedById']?.toString(),
      completedAt: DateTime.tryParse('${json['completedAt'] ?? ''}'),
      pdfUrl: json['pdfUrl'] as String?,
      digitalSignatureStatus: json['digitalSignatureStatus'] as String?,
      notaryStatus: json['notaryStatus'] as String?,
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse('${json['updatedAt'] ?? ''}') ?? DateTime.now(),
      firstUser: UserBrief.fromJson(
        (json['firstUser'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      secondUser: UserBrief.fromJson(
        (json['secondUser'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      creator: UserBrief.fromJson(
        (json['creator'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      ),
      otherUser: json['otherUser'] is Map<String, dynamic>
          ? UserBrief.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
      currentUserConfirmed: json['currentUserConfirmed'] as bool? ?? false,
      otherUserConfirmed: json['otherUserConfirmed'] as bool? ?? false,
      payments: (json['payments'] as List?)?.toList() ?? const [],
      disputes: (json['disputes'] as List?)?.toList() ?? const [],
    );
  }

  bool get isConfirmedByBoth =>
      firstUserConfirmedAt != null && secondUserConfirmedAt != null;
}
