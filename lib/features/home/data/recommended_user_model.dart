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

  bool _isCorruptedText(String value) {
    final t = value.trim();
    if (t.isEmpty) return true;
    final qCount = '?'.allMatches(t).length;
    return qCount >= (t.length / 2);
  }

  String _safeText(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty || _isCorruptedText(t)) return '';
    return t;
  }

  factory RecommendedUser.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value.trim()) ?? fallback;
      return fallback;
    }

    bool parseBool(dynamic value, {bool fallback = false}) {
      if (value == null) return fallback;
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final s = value.trim().toLowerCase();
        if (s == 'true' || s == '1' || s == 'yes') return true;
        if (s == 'false' || s == '0' || s == 'no') return false;
      }
      return fallback;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final s = value.toString().trim();
      return s.isEmpty ? null : s;
    }

    final match = parseInt(
      json['matchPercent'] ??
          json['match_percentage'] ??
          json['match'] ??
          json['compatibility'] ??
          json['score'],
      fallback: 0,
    ).clamp(0, 100);

    final verified = parseBool(
      json['isVerified'] ??
          json['verified'] ??
          json['profileVerified'] ??
          json['kycVerified'] ??
          json['verificationApproved'] ??
          (json['verificationStatus'] == 'APPROVED' ? true : null),
      fallback: false,
    );

    final rawTag = parseString(
      json['preferenceTag'] ??
          json['petPreference'] ??
          json['petsPreference'] ??
          json['animalsPreference'],
    );

    final petsAllowed = json.containsKey('petsAllowed')
        ? parseBool(json['petsAllowed'], fallback: false)
        : null;

    String? computedTag = rawTag;
    if (computedTag == null && petsAllowed != null) {
      computedTag = petsAllowed ? 'Можно с животными' : 'Без животных';
    }

    final isComplete = parseBool(
      json['isProfileComplete'] ??
          json['profileComplete'] ??
          json['isCompleted'] ??
          json['completed'],
      fallback: false,
    );

    final lifestyleMap = (json['lifestyle'] as Map?)?.cast<String, dynamic>();

    return RecommendedUser(
      id: (json['id'] as String?) ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      city: json['city'] as String?,
      bio: json['bio'] as String?,
      searchDistrict: json['searchDistrict'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.whereType<String>().toList() ??
          const <String>[],
      isSaved: json['isSaved'] as bool? ?? false,
      matchPercent: match,
      isVerified: verified,
      preferenceTag: computedTag,
      isProfileComplete: isComplete,
      lifestyle: lifestyleMap,
      occupationStatus: json['occupationStatus'] as String?,
      searchBudgetMin: (json['searchBudgetMin'] as num?)?.toInt(),
      searchBudgetMax: (json['searchBudgetMax'] as num?)?.toInt(),
    );
  }

  String get displayName {
    final fn = _safeText(firstName);
    final ln = _safeText(lastName);
    final name = ('$fn $ln').trim();
    if (name.isEmpty) return 'Пользователь';
    if (age != null) return '$name, $age';
    return name;
  }

  String? get avatarUrl {
    final raw = photos.isNotEmpty ? photos.first.trim() : '';
    if (raw.isEmpty) return null;

    if (raw.startsWith('http')) return raw;

    final base = ApiConfig.publicBaseUrl;
    return '$base${raw.startsWith('/') ? '' : '/'}$raw';
  }

  String get locationText =>
      _safeText(searchDistrict).isNotEmpty
          ? _safeText(searchDistrict)
          : _safeText(city).isNotEmpty
          ? _safeText(city)
          : '-';

  String get statusText {
    final raw = (occupationStatus ?? '').trim();
    if (raw.isEmpty) return '-';
    switch (raw) {
      case 'STUDY':
        return 'Учусь';
      case 'WORK':
        return 'Работаю';
      case 'STUDY_WORK':
        return 'Учусь и работаю';
      default:
        return raw;
    }
  }

  String get budgetText {
    final min = searchBudgetMin;
    final max = searchBudgetMax;
    if (min == null && max == null) return '-';
    if (min != null && max != null) return '$min-$max /месяц';
    if (min != null) return 'от $min /месяц';
    return 'до $max /месяц';
  }
}
