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

    // ✅ screenshot fields
    required this.matchPercent,
    required this.isVerified,
    required this.preferenceTag,

    // ✅ NEW (for profile page logic)
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

  // ✅ screenshot fields
  final int matchPercent; // 0..100
  final bool isVerified; // verified icon on top-right
  final String? preferenceTag; // "С животными", ...

  // ✅ NEW fields
  final bool isProfileComplete;
  final Map<String, dynamic>? lifestyle;

  final String? occupationStatus;
  final int? searchBudgetMin;
  final int? searchBudgetMax;

  factory RecommendedUser.fromJson(Map<String, dynamic> json) {
    // ---- helpers (robust parsing) ----
    int _int(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v.trim()) ?? fallback;
      return fallback;
    }

    bool _bool(dynamic v, {bool fallback = false}) {
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.trim().toLowerCase();
        if (s == 'true' || s == '1' || s == 'yes') return true;
        if (s == 'false' || s == '0' || s == 'no') return false;
      }
      return fallback;
    }

    String? _str(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    // ✅ match percent: accept different backend keys
    final match = _int(
      json['matchPercent'] ??
          json['match_percentage'] ??
          json['match'] ??
          json['compatibility'] ??
          json['score'],
      fallback: 0,
    ).clamp(0, 100);

    // ✅ verified: accept different backend keys
    final verified = _bool(
      json['isVerified'] ??
          json['verified'] ??
          json['profileVerified'] ??
          json['kycVerified'] ??
          json['verificationApproved'] ??
          (json['verificationStatus'] == 'APPROVED' ? true : null),
      fallback: false,
    );

    // ✅ tag: accept different backend keys or compute from petsAllowed
    final rawTag = _str(
      json['preferenceTag'] ??
          json['petPreference'] ??
          json['petsPreference'] ??
          json['animalsPreference'],
    );

    final petsAllowed = json.containsKey('petsAllowed')
        ? _bool(json['petsAllowed'], fallback: false)
        : null;

    String? computedTag = rawTag;
    if (computedTag == null && petsAllowed != null) {
      computedTag = petsAllowed ? 'Можно с животными' : 'Без животных';
    }

    // ✅ NEW: profile complete
    final isComplete = _bool(
      json['isProfileComplete'] ??
          json['profileComplete'] ??
          json['isCompleted'] ??
          json['completed'],
      fallback: false,
    );

    // ✅ NEW: lifestyle map
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
    final fn = (firstName ?? '').trim();
    final ln = (lastName ?? '').trim();
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
      (searchDistrict ?? city ?? '').trim().isNotEmpty
          ? (searchDistrict ?? city ?? '').trim()
          : '-';

  String get statusText =>
      (occupationStatus ?? '').trim().isNotEmpty
          ? occupationStatus!.trim()
          : '-';

  String get budgetText {
    final min = searchBudgetMin;
    final max = searchBudgetMax;
    if (min == null && max == null) return '-';
    if (min != null && max != null) return '$min-$max /месяц';
    if (min != null) return 'от $min /месяц';
    return 'до $max /месяц';
  }
}