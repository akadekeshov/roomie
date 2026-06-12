import 'dart:convert';

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
      title: _normalizeText('${json['title'] ?? ''}'),
      description: _normalizeText('${json['description'] ?? ''}'),
      evidenceUrls:
          (json['evidenceUrls'] as List?)?.whereType<String>().toList() ??
              const <String>[],
      adminComment: _normalizeNullableText(json['adminComment']),
      resultText: _normalizeNullableText(json['resultText']),
      viewerResultText: _normalizeNullableText(json['viewerResultText']),
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
      directionLabel: _normalizeNullableText(json['directionLabel']),
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

String? _normalizeNullableText(dynamic value) {
  if (value == null) return null;
  final normalized = _normalizeText(value.toString());
  return normalized.isEmpty ? null : normalized;
}

String _normalizeText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';

  if (_looksLikeMojibake(trimmed)) {
    final repairedCp1251 = _tryDecodeUtf8FromCp1251(trimmed);
    if (repairedCp1251 != null && _looksLikeRussian(repairedCp1251)) {
      return repairedCp1251.trim();
    }

    final repairedLatin1 = _tryDecodeUtf8FromLatin1(trimmed);
    if (repairedLatin1 != null && _looksLikeRussian(repairedLatin1)) {
      return repairedLatin1.trim();
    }
  }

  return trimmed;
}

bool _looksLikeMojibake(String value) {
  return value.contains('Р') ||
      value.contains('С') ||
      value.contains('Ѓ') ||
      value.contains('Ђ') ||
      value.contains('џ');
}

bool _looksLikeRussian(String value) {
  return RegExp(r'[А-Яа-яЁё]').hasMatch(value);
}

String? _tryDecodeUtf8FromLatin1(String value) {
  try {
    return utf8.decode(latin1.encode(value), allowMalformed: false);
  } catch (_) {
    return null;
  }
}

String? _tryDecodeUtf8FromCp1251(String value) {
  try {
    final bytes = <int>[];
    for (final rune in value.runes) {
      final byte = _unicodeToCp1251Byte(rune);
      if (byte == null) return null;
      bytes.add(byte);
    }
    return utf8.decode(bytes, allowMalformed: false);
  } catch (_) {
    return null;
  }
}

int? _unicodeToCp1251Byte(int rune) {
  if (rune >= 0x00 && rune <= 0x7F) {
    return rune;
  }

  if (rune >= 0x0410 && rune <= 0x044F) {
    return 0xC0 + (rune - 0x0410);
  }

  return _cp1251ReverseMap[rune];
}

const Map<int, int> _cp1251ReverseMap = {
  0x0402: 0x80,
  0x0403: 0x81,
  0x201A: 0x82,
  0x0453: 0x83,
  0x201E: 0x84,
  0x2026: 0x85,
  0x2020: 0x86,
  0x2021: 0x87,
  0x20AC: 0x88,
  0x2030: 0x89,
  0x0409: 0x8A,
  0x2039: 0x8B,
  0x040A: 0x8C,
  0x040C: 0x8D,
  0x040B: 0x8E,
  0x040F: 0x8F,
  0x0452: 0x90,
  0x2018: 0x91,
  0x2019: 0x92,
  0x201C: 0x93,
  0x201D: 0x94,
  0x2022: 0x95,
  0x2013: 0x96,
  0x2014: 0x97,
  0x2122: 0x99,
  0x0459: 0x9A,
  0x203A: 0x9B,
  0x045A: 0x9C,
  0x045C: 0x9D,
  0x045B: 0x9E,
  0x045F: 0x9F,
  0x00A0: 0xA0,
  0x040E: 0xA1,
  0x045E: 0xA2,
  0x0408: 0xA3,
  0x00A4: 0xA4,
  0x0490: 0xA5,
  0x00A6: 0xA6,
  0x00A7: 0xA7,
  0x0401: 0xA8,
  0x00A9: 0xA9,
  0x0404: 0xAA,
  0x00AB: 0xAB,
  0x00AC: 0xAC,
  0x00AD: 0xAD,
  0x00AE: 0xAE,
  0x0407: 0xAF,
  0x00B0: 0xB0,
  0x00B1: 0xB1,
  0x0406: 0xB2,
  0x0456: 0xB3,
  0x0491: 0xB4,
  0x00B5: 0xB5,
  0x00B6: 0xB6,
  0x00B7: 0xB7,
  0x0451: 0xB8,
  0x2116: 0xB9,
  0x0454: 0xBA,
  0x00BB: 0xBB,
  0x0458: 0xBC,
  0x0405: 0xBD,
  0x0455: 0xBE,
  0x0457: 0xBF,
};
