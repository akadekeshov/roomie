import '../../../core/models/user_brief.dart';

enum DisputeStatus {
  open('OPEN', 'Открыта'),
  inReview('IN_REVIEW', 'На рассмотрении'),
  resolved('RESOLVED', 'Решена'),
  rejected('REJECTED', 'Отклонена'),
  closed('CLOSED', 'Закрыта');

  const DisputeStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DisputeStatus fromApi(String? value) {
    return DisputeStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => DisputeStatus.open,
    );
  }
}

enum DisputeDecision {
  none('NONE', 'Решение не принято'),
  accepted('ACCEPTED', 'Жалоба подтверждена'),
  rejected('REJECTED', 'Жалоба отклонена'),
  needMoreInfo('NEED_MORE_INFO', 'Нужна дополнительная информация');

  const DisputeDecision(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DisputeDecision fromApi(String? value) {
    return DisputeDecision.values.firstWhere(
      (decision) => decision.apiValue == value,
      orElse: () => DisputeDecision.none,
    );
  }
}

enum DisputeAction {
  none('NONE', 'Действие не применено'),
  warning('WARNING', 'Предупреждение'),
  temporaryRestriction('TEMPORARY_RESTRICTION', 'Временное ограничение'),
  accountBan('ACCOUNT_BAN', 'Блокировка аккаунта'),
  agreementCancelled('AGREEMENT_CANCELLED', 'Договор отменен'),
  paymentRequired('PAYMENT_REQUIRED', 'Требуется оплата'),
  profileFlagged('PROFILE_FLAGGED', 'Профиль помечен');

  const DisputeAction(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DisputeAction fromApi(String? value) {
    return DisputeAction.values.firstWhere(
      (action) => action.apiValue == value,
      orElse: () => DisputeAction.none,
    );
  }
}

enum DisputeReason {
  paymentNotPaid('PAYMENT_NOT_PAID', 'Не оплатил(а)'),
  agreementViolation('AGREEMENT_VIOLATION', 'Нарушение договора'),
  propertyDamage('PROPERTY_DAMAGE', 'Порча имущества'),
  fakeInformation('FAKE_INFORMATION', 'Ложная информация'),
  rudeBehavior('RUDE_BEHAVIOR', 'Грубое поведение'),
  safetyConcern('SAFETY_CONCERN', 'Угроза безопасности'),
  other('OTHER', 'Другое');

  const DisputeReason(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DisputeReason fromApi(String? value) {
    return DisputeReason.values.firstWhere(
      (reason) => reason.apiValue == value,
      orElse: () => DisputeReason.other,
    );
  }
}

enum DisputeDirection {
  outgoing('OUTGOING', 'Вы подали жалобу'),
  incoming('INCOMING', 'На вас подали жалобу');

  const DisputeDirection(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static DisputeDirection fromApi(String? value) {
    return DisputeDirection.values.firstWhere(
      (direction) => direction.apiValue == value,
      orElse: () => DisputeDirection.outgoing,
    );
  }
}

class DisputeItem {
  const DisputeItem({
    required this.id,
    required this.reason,
    required this.status,
    required this.decision,
    required this.action,
    required this.title,
    required this.description,
    required this.evidenceUrls,
    required this.createdAt,
    required this.updatedAt,
    required this.reporterId,
    this.agreementId,
    this.conversationId,
    this.accusedId,
    this.adminComment,
    this.resultText,
    this.viewerResultText,
    this.reviewedById,
    this.reviewedAt,
    this.actionAppliedAt,
    this.actionExpiresAt,
    this.direction,
    this.directionLabel,
    this.counterparty,
    this.reporter,
    this.accused,
    this.canAppeal = false,
    this.isActionApplied = false,
  });

  final String id;
  final String? agreementId;
  final String? conversationId;
  final String reporterId;
  final String? accusedId;
  final DisputeReason reason;
  final DisputeStatus status;
  final DisputeDecision decision;
  final DisputeAction action;
  final String title;
  final String description;
  final List<String> evidenceUrls;
  final String? adminComment;
  final String? resultText;
  final String? viewerResultText;
  final String? reviewedById;
  final DateTime? reviewedAt;
  final DateTime? actionAppliedAt;
  final DateTime? actionExpiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DisputeDirection? direction;
  final String? directionLabel;
  final UserBrief? counterparty;
  final UserBrief? reporter;
  final UserBrief? accused;
  final bool canAppeal;
  final bool isActionApplied;

  factory DisputeItem.fromJson(Map<String, dynamic> json) {
    return DisputeItem(
      id: '${json['id'] ?? ''}',
      agreementId: json['agreementId']?.toString(),
      conversationId: json['conversationId']?.toString(),
      reporterId: '${json['reporterId'] ?? ''}',
      accusedId: json['accusedId']?.toString(),
      reason: DisputeReason.fromApi(json['reason']?.toString()),
      status: DisputeStatus.fromApi(json['status']?.toString()),
      decision: DisputeDecision.fromApi(json['decision']?.toString()),
      action: DisputeAction.fromApi(json['action']?.toString()),
      title: '${json['title'] ?? ''}',
      description: '${json['description'] ?? ''}',
      evidenceUrls:
          (json['evidenceUrls'] as List?)?.whereType<String>().toList() ??
              const <String>[],
      adminComment: json['adminComment'] as String?,
      resultText: json['resultText'] as String?,
      viewerResultText: json['viewerResultText'] as String?,
      reviewedById: json['reviewedById']?.toString(),
      reviewedAt: DateTime.tryParse('${json['reviewedAt'] ?? ''}'),
      actionAppliedAt:
          DateTime.tryParse('${json['actionAppliedAt'] ?? ''}'),
      actionExpiresAt:
          DateTime.tryParse('${json['actionExpiresAt'] ?? ''}'),
      createdAt:
          DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse('${json['updatedAt'] ?? ''}') ?? DateTime.now(),
      direction: json['direction'] == null
          ? null
          : DisputeDirection.fromApi(json['direction']?.toString()),
      directionLabel: json['directionLabel'] as String?,
      counterparty: json['counterparty'] is Map<String, dynamic>
          ? UserBrief.fromJson(json['counterparty'] as Map<String, dynamic>)
          : null,
      reporter: json['reporter'] is Map<String, dynamic>
          ? UserBrief.fromJson(json['reporter'] as Map<String, dynamic>)
          : null,
      accused: json['accused'] is Map<String, dynamic>
          ? UserBrief.fromJson(json['accused'] as Map<String, dynamic>)
          : null,
      canAppeal: json['canAppeal'] as bool? ?? false,
      isActionApplied: json['isActionApplied'] as bool? ?? false,
    );
  }

  String get directionTitle => directionLabel ?? direction?.label ?? 'Жалоба';

  String get counterpartySubtitle {
    final userName = counterparty?.displayName ?? 'Пользователь';
    if (direction == DisputeDirection.incoming) {
      return 'От пользователя: $userName';
    }
    return 'На пользователя: $userName';
  }

  String? get summaryResult {
    final viewerText = (viewerResultText ?? '').trim();
    if (viewerText.isNotEmpty) return viewerText;

    final baseText = (resultText ?? '').trim();
    if (baseText.isNotEmpty) return baseText;

    if (decision == DisputeDecision.rejected) {
      return 'Жалоба отклонена. Нарушение не подтверждено.';
    }

    if (decision == DisputeDecision.needMoreInfo) {
      return 'Для рассмотрения жалобы требуется дополнительная информация.';
    }

    return null;
  }
}
