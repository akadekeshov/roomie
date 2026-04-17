import '../../../core/network/api_config.dart';

class RecommendedUser {
  const RecommendedUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.city,
    required this.bio,
    required this.searchDistrict,
    required this.photos,
    required this.isSaved,
    required this.matchPercent,
    required this.isVerified,
    required this.preferenceTag,
    required this.isProfileComplete,
    this.lifestyle,
    this.occupationStatus,
    this.searchBudgetMin,
    this.searchBudgetMax,
    this.ruleScore,
    this.embeddingScore,
    this.aiScore,
    this.finalScore,
    this.compatibilityBreakdown,
    this.aiReasoning,
    this.aiStrengths = const [],
    this.aiRisks = const [],
    this.compatibilityReasons = const [],
    this.explicitAvatarUrl,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? city;
  final String? bio;
  final String? searchDistrict;
  final List<String> photos;
  final bool isSaved;
  final int matchPercent;
  final bool isVerified;
  final String? preferenceTag;
  final bool isProfileComplete;
  final Map<String, dynamic>? lifestyle;
  final String? occupationStatus;
  final int? searchBudgetMin;
  final int? searchBudgetMax;
  final int? ruleScore;
  final int? embeddingScore;
  final int? aiScore;
  final int? finalScore;
  final Map<String, dynamic>? compatibilityBreakdown;
  final String? aiReasoning;
  final List<String> aiStrengths;
  final List<String> aiRisks;
  final List<String> compatibilityReasons;
  final String? explicitAvatarUrl;

  factory RecommendedUser.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? fallback;
      return fallback;
    }

    double parseDouble(dynamic value, {double fallback = 0}) {
      if (value == null) return fallback;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.trim()) ?? fallback;
      return fallback;
    }

    bool parseBool(dynamic value, {bool fallback = false}) {
      if (value == null) return fallback;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
          return true;
        }
        if (normalized == 'false' ||
            normalized == '0' ||
            normalized == 'no') {
          return false;
        }
      }
      return fallback;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    List<String> parseStringList(dynamic value) {
      if (value is! List) return const <String>[];
      return value
          .map((item) => parseString(item))
          .whereType<String>()
          .toList(growable: false);
    }

    final photos = parseStringList(json['photos']);
    final rawAvatarUrl = parseString(
      json['avatarUrl'] ?? json['avatar'] ?? json['photo'],
    );

    final canonicalScore = parseInt(
      json['finalScore'] ??
          json['matchPercent'] ??
          json['compatibility'] ??
          json['score'] ??
          json['match_percentage'] ??
          json['match'] ??
          json['ruleScore'],
    ).clamp(0, 100).toInt();

    final verificationStatus =
        parseString(json['verificationStatus'])?.toUpperCase();
    final isVerified = parseBool(
      json['isVerified'] ??
          json['verified'] ??
          json['profileVerified'] ??
          json['kycVerified'] ??
          json['verificationApproved'] ??
          (verificationStatus == 'APPROVED' || verificationStatus == 'VERIFIED'),
    );

    final rawTag = parseString(
      json['preferenceTag'] ??
          json['petPreference'] ??
          json['petsPreference'] ??
          json['animalsPreference'],
    );

    final petsAllowed = json.containsKey('petsAllowed')
        ? parseBool(json['petsAllowed'])
        : null;
    final preferenceTag = _mapPreferenceTag(rawTag) ??
        (petsAllowed == null
            ? null
            : petsAllowed
                ? 'Можно с животными'
                : 'Без животных');

    final isProfileComplete = parseBool(
      json['isProfileComplete'] ??
          json['profileComplete'] ??
          json['isCompleted'] ??
          json['completed'] ??
          json['onboardingCompleted'],
    );

    final lifestyle = (json['lifestyle'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{
          if (json['chronotype'] != null) 'chronotype': json['chronotype'],
          if (json['smokingPreference'] != null)
            'smoking': '${json['smokingPreference']}'.toUpperCase() == 'SMOKER',
          if (json['petsPreference'] != null)
            'petsAllowed':
                '${json['petsPreference']}'.toUpperCase() == 'WITH_PETS',
        };

    final compatibilityBreakdown =
        (json['compatibilityBreakdown'] as Map?)?.cast<String, dynamic>();
    final compatibilityReasons =
        _russianOnly(parseStringList(json['compatibilityReasons']));
    final aiReasoning = _russianOrNull(parseString(json['aiReasoning']));
    final aiStrengths = _russianOnly(parseStringList(json['aiStrengths']));
    final aiRisks = _russianOnly(parseStringList(json['aiRisks']));

    return RecommendedUser(
      id: parseString(json['id']) ?? '',
      firstName: parseString(json['firstName']),
      lastName: parseString(json['lastName']),
      age: json['age'] == null ? null : parseInt(json['age']),
      city: parseString(json['city']),
      bio: parseString(json['bio']),
      searchDistrict: parseString(json['searchDistrict']),
      photos: photos,
      isSaved: parseBool(json['isSaved']),
      matchPercent: canonicalScore,
      isVerified: isVerified,
      preferenceTag: preferenceTag,
      isProfileComplete: isProfileComplete,
      lifestyle: lifestyle,
      occupationStatus: parseString(json['occupationStatus']),
      searchBudgetMin: json['searchBudgetMin'] == null
          ? null
          : parseInt(json['searchBudgetMin']),
      searchBudgetMax: json['searchBudgetMax'] == null
          ? null
          : parseInt(json['searchBudgetMax']),
      ruleScore: json['ruleScore'] == null
          ? null
          : parseDouble(json['ruleScore']).round(),
      embeddingScore: json['embeddingScore'] == null
          ? null
          : parseDouble(json['embeddingScore']).round(),
      aiScore: json['aiScore'] == null
          ? null
          : parseDouble(json['aiScore']).round(),
      finalScore: json['finalScore'] == null
          ? canonicalScore
          : parseDouble(json['finalScore']).round().clamp(0, 100).toInt(),
      compatibilityBreakdown: compatibilityBreakdown,
      aiReasoning: aiReasoning,
      aiStrengths: aiStrengths,
      aiRisks: aiRisks,
      compatibilityReasons: compatibilityReasons,
      explicitAvatarUrl: rawAvatarUrl,
    );
  }

  String get displayName {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    final fullName = '$first $last'.trim();
    if (fullName.isEmpty) {
      return 'Пользователь';
    }
    if (age != null) {
      return '$fullName, $age';
    }
    return fullName;
  }

  String? get avatarUrl {
    final raw = (explicitAvatarUrl ?? (photos.isNotEmpty ? photos.first : ''))
        .trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;

    final base = ApiConfig.publicBaseUrl;
    return '$base${raw.startsWith('/') ? '' : '/'}$raw';
  }

  String get locationText {
    final text = (searchDistrict ?? city ?? '').trim();
    return text.isEmpty ? '-' : text;
  }

  String get statusText {
    return _mapOccupationStatus(occupationStatus);
  }

  int get compatibilityPercent {
    final canonical = finalScore ?? matchPercent;
    return canonical.clamp(0, 100).toInt();
  }

  String get budgetText {
    final min = searchBudgetMin;
    final max = searchBudgetMax;
    if (min == null && max == null) return '-';
    if (min != null && max != null) return '$min-$max /месяц';
    if (min != null) return 'от $min /месяц';
    return 'до $max /месяц';
  }

  int get budgetMatchPercent => _criterionPercent('budget');

  int get locationMatchPercent => _criterionPercent('district');

  int get lifestyleMatchPercent {
    const keys = [
      'noisePreference',
      'smokingPreference',
      'petsPreference',
      'chronotype',
      'personalityType',
      'occupationStatus',
    ];

    final scores = <double>[];
    final map = compatibilityBreakdown?['criterionScores'];
    if (map is Map) {
      for (final key in keys) {
        final value = map[key];
        if (value is num) {
          scores.add(value.toDouble());
        }
      }
    }

    if (scores.isEmpty) return compatibilityPercent;
    final average = scores.reduce((a, b) => a + b) / scores.length;
    return (average * 100).round().clamp(0, 100).toInt();
  }

  List<String> get quickBadges {
    final badges = <String>[];
    final matched = _criteriaList('matchedCriteria');
    final partial = _criteriaList('partiallyMatchedCriteria');
    final requiredMismatch = _criteriaList('requiredMismatches');

    if (matched.contains('budget')) {
      badges.add('Хорошее совпадение по бюджету');
    }
    if (matched.contains('noisePreference')) {
      badges.add('Похожие предпочтения по уровню шума');
    }
    if (partial.contains('district')) {
      badges.add('Тот же город, другой район');
    }
    if (requiredMismatch.contains('petsPreference')) {
      badges.add('Возможен конфликт из-за животных');
    }
    if (requiredMismatch.contains('chronotype')) {
      badges.add('Разный режим сна');
    }

    if (badges.isEmpty && compatibilityReasons.isNotEmpty) {
      return compatibilityReasons.take(3).toList(growable: false);
    }
    return badges.take(4).toList(growable: false);
  }

  int _criterionPercent(String criterion) {
    final map = compatibilityBreakdown?['criterionScores'];
    if (map is! Map) return compatibilityPercent;

    final score = map[criterion];
    if (score is! num) return compatibilityPercent;

    return (score.toDouble() * 100).round().clamp(0, 100).toInt();
  }

  List<String> _criteriaList(String key) {
    final value = compatibilityBreakdown?[key];
    if (value is! List) return const <String>[];
    return value.whereType<String>().toList(growable: false);
  }

  static String _mapOccupationStatus(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'STUDY':
        return 'Учится';
      case 'WORK':
        return 'Работает';
      case 'STUDY_WORK':
        return 'Учится и работает';
      default:
        final text = (raw ?? '').trim();
        return text.isEmpty ? '-' : text;
    }
  }

  static String? _mapPreferenceTag(String? raw) {
    switch ((raw ?? '').trim().toUpperCase()) {
      case 'WITH_PETS':
        return 'Можно с животными';
      case 'NO_PETS':
        return 'Без животных';
      default:
        return raw;
    }
  }

  static String? _russianOrNull(String? value) {
    if (value == null) return null;
    final text = value.trim();
    if (text.isEmpty) return null;
    return _hasRussianText(text) ? text : null;
  }

  static List<String> _russianOnly(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && _hasRussianText(value))
        .toList(growable: false);
  }

  static bool _hasRussianText(String value) {
    return RegExp(r'[\u0410-\u042F\u0430-\u044F\u0401\u0451]').hasMatch(value);
  }
}
