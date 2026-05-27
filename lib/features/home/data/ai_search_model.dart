import '../../../core/network/api_config.dart';
import 'recommended_user_model.dart';

String localizeAiSearchText(String value) {
  var text = value;
  const replacements = <String, String>{
    'budget': '\u0411\u044e\u0434\u0436\u0435\u0442',
    'district': '\u0420\u0430\u0439\u043e\u043d',
    'noisePreference':
        '\u041e\u0442\u043d\u043e\u0448\u0435\u043d\u0438\u0435 \u043a \u0448\u0443\u043c\u0443',
    'smokingPreference':
        '\u041e\u0442\u043d\u043e\u0448\u0435\u043d\u0438\u0435 \u043a \u043a\u0443\u0440\u0435\u043d\u0438\u044e',
    'petsPreference':
        '\u041e\u0442\u043d\u043e\u0448\u0435\u043d\u0438\u0435 \u043a \u0436\u0438\u0432\u043e\u0442\u043d\u044b\u043c',
    'chronotype': '\u0420\u0435\u0436\u0438\u043c \u0434\u043d\u044f',
    'personalityType':
        '\u0422\u0438\u043f \u043b\u0438\u0447\u043d\u043e\u0441\u0442\u0438',
    'occupationStatus':
        '\u0423\u0447\u0435\u0431\u0430/\u0440\u0430\u0431\u043e\u0442\u0430',
    'roommateGenderPreference':
        '\u041f\u0440\u0435\u0434\u043f\u043e\u0447\u0442\u0435\u043d\u0438\u0435 \u043f\u043e \u043f\u043e\u043b\u0443 \u0441\u043e\u0441\u0435\u0434\u0430',
  };

  for (final entry in replacements.entries) {
    text = text.replaceAll(entry.key, entry.value);
  }
  return text;
}

String aiSearchFieldLabel(String field) {
  return switch (field.trim()) {
    'budget' => '\u0411\u044e\u0434\u0436\u0435\u0442',
    'district' => '\u0420\u0430\u0439\u043e\u043d',
    'noisePreference' =>
      '\u0423\u0440\u043e\u0432\u0435\u043d\u044c \u0448\u0443\u043c\u0430',
    'smokingPreference' => '\u041a\u0443\u0440\u0435\u043d\u0438\u0435',
    'petsPreference' => '\u0416\u0438\u0432\u043e\u0442\u043d\u044b\u0435',
    'chronotype' => '\u0420\u0435\u0436\u0438\u043c \u0434\u043d\u044f',
    'personalityType' =>
      '\u0422\u0438\u043f \u043b\u0438\u0447\u043d\u043e\u0441\u0442\u0438',
    'occupationStatus' =>
      '\u0423\u0447\u0435\u0431\u0430/\u0440\u0430\u0431\u043e\u0442\u0430',
    'roommateGenderPreference' =>
      '\u041f\u043e\u043b \u0441\u043e\u0441\u0435\u0434\u0430',
    _ => field,
  };
}

class AiSearchUser {
  const AiSearchUser({
    required this.id,
    required this.firstName,
    required this.age,
    required this.city,
    required this.bio,
    required this.searchDistrict,
    required this.occupationStatus,
    required this.searchBudgetMin,
    required this.searchBudgetMax,
    required this.photos,
  });

  final String id;
  final String? firstName;
  final int? age;
  final String? city;
  final String? bio;
  final String? searchDistrict;
  final String? occupationStatus;
  final int? searchBudgetMin;
  final int? searchBudgetMax;
  final List<String> photos;

  factory AiSearchUser.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString().trim());
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return AiSearchUser(
      id: parseString(json['id']) ?? '',
      firstName: parseString(json['firstName']),
      age: parseInt(json['age']),
      city: parseString(json['city']),
      bio: parseString(json['bio']),
      searchDistrict: parseString(json['searchDistrict']),
      occupationStatus: parseString(json['occupationStatus']),
      searchBudgetMin: parseInt(json['searchBudgetMin']),
      searchBudgetMax: parseInt(json['searchBudgetMax']),
      photos:
          (json['photos'] as List<dynamic>?)?.whereType<String>().toList() ??
              const <String>[],
    );
  }

  String get displayName {
    final name = (firstName ?? '').trim();
    if (name.isEmpty && age == null) {
      return 'Пользователь';
    }
    if (age == null || name.isEmpty) {
      return name.isEmpty ? 'Пользователь' : name;
    }
    return '$name, $age';
  }

  String? get avatarUrl {
    final raw = photos.isNotEmpty ? photos.first.trim() : '';
    if (raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    final base = ApiConfig.publicBaseUrl;
    return '$base${raw.startsWith('/') ? '' : '/'}$raw';
  }
}

class AiSearchScoreBreakdown {
  const AiSearchScoreBreakdown({
    required this.semanticSimilarity,
    required this.lifestyleMatch,
    required this.preferenceMatch,
    required this.behavioralMatch,
    required this.profileQuality,
    required this.finalScore,
  });

  final double semanticSimilarity;
  final double lifestyleMatch;
  final double preferenceMatch;
  final double behavioralMatch;
  final double profileQuality;
  final double finalScore;

  factory AiSearchScoreBreakdown.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.trim()) ?? 0;
      return 0;
    }

    return AiSearchScoreBreakdown(
      semanticSimilarity: parseDouble(json['semanticSimilarity']),
      lifestyleMatch: parseDouble(json['lifestyleMatch']),
      preferenceMatch: parseDouble(json['preferenceMatch']),
      behavioralMatch: parseDouble(json['behavioralMatch']),
      profileQuality: parseDouble(json['profileQuality']),
      finalScore: parseDouble(json['finalScore']),
    );
  }
}

class AiSearchExplanation {
  const AiSearchExplanation({
    required this.semantic,
    required this.lifestyle,
    required this.preferences,
    required this.matchedFields,
  });

  final String semantic;
  final String lifestyle;
  final String preferences;
  final List<String> matchedFields;

  factory AiSearchExplanation.fromJson(Map<String, dynamic> json) {
    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString().trim();
    }

    return AiSearchExplanation(
      semantic: parseString(json['semantic']),
      lifestyle: parseString(json['lifestyle']),
      preferences: parseString(json['preferences']),
      matchedFields: (json['matchedFields'] as List<dynamic>?)
              ?.whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const <String>[],
    );
  }
}

class AiSearchResult {
  const AiSearchResult({
    required this.user,
    required this.score,
    required this.breakdown,
    required this.explanation,
  });

  final AiSearchUser user;
  final double score;
  final AiSearchScoreBreakdown breakdown;
  final AiSearchExplanation explanation;

  factory AiSearchResult.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value.trim()) ?? 0;
      return 0;
    }

    return AiSearchResult(
      user: AiSearchUser.fromJson(
        (json['user'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      score: parseDouble(json['score']),
      breakdown: AiSearchScoreBreakdown.fromJson(
        (json['breakdown'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      explanation: AiSearchExplanation.fromJson(
        (json['explanation'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }

  int get matchPercent {
    final value = (breakdown.finalScore * 100).round();
    return value.clamp(0, 100);
  }

  RecommendedUser toRecommendedUser({required bool isSaved}) {
    final reasoningParts = <String>[
      localizeAiSearchText(explanation.semantic),
      localizeAiSearchText(explanation.lifestyle),
      localizeAiSearchText(explanation.preferences),
    ].where((text) => text.trim().isNotEmpty).toList(growable: false);

    return RecommendedUser(
      id: user.id,
      firstName: user.firstName,
      lastName: null,
      age: user.age,
      city: user.city,
      bio: user.bio,
      searchDistrict: user.searchDistrict ?? user.city,
      photos: user.photos,
      isSaved: isSaved,
      matchPercent: matchPercent,
      isVerified: true,
      preferenceTag: null,
      isProfileComplete: true,
      lifestyle: null,
      occupationStatus: user.occupationStatus,
      searchBudgetMin: user.searchBudgetMin,
      searchBudgetMax: user.searchBudgetMax,
      finalScore: matchPercent,
      aiReasoning: reasoningParts.join(' '),
      compatibilityReasons:
          explanation.matchedFields.map(aiSearchFieldLabel).toList(),
    );
  }
}

class AiSearchResponseMeta {
  const AiSearchResponseMeta({
    required this.status,
    required this.limit,
    required this.sessionId,
  });

  final String status;
  final int? limit;
  final String? sessionId;

  factory AiSearchResponseMeta.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString().trim());
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      return text.isEmpty ? null : text;
    }

    return AiSearchResponseMeta(
      status: parseString(json['status']) ?? 'unknown',
      limit: parseInt(json['limit']),
      sessionId: parseString(json['sessionId']),
    );
  }
}

class AiSearchResponse {
  const AiSearchResponse({
    required this.results,
    required this.meta,
  });

  final List<AiSearchResult> results;
  final AiSearchResponseMeta meta;

  factory AiSearchResponse.fromJson(Map<String, dynamic> json) {
    final resultsRaw = json['results'];
    final results = resultsRaw is List
        ? resultsRaw
            .whereType<Map>()
            .map((e) => AiSearchResult.fromJson(e.cast<String, dynamic>()))
            .toList()
        : const <AiSearchResult>[];

    return AiSearchResponse(
      results: results,
      meta: AiSearchResponseMeta.fromJson(
        (json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
    );
  }
}
