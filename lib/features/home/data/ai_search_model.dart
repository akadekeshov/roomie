import '../../../core/network/api_config.dart';
import 'recommended_user_model.dart';

class AiSearchUser {
  const AiSearchUser({
    required this.id,
    required this.firstName,
    required this.age,
    required this.city,
    required this.bio,
    required this.photos,
  });

  final String id;
  final String? firstName;
  final int? age;
  final String? city;
  final String? bio;
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
      explanation.semantic,
      explanation.lifestyle,
      explanation.preferences,
    ].where((text) => text.trim().isNotEmpty).toList(growable: false);

    return RecommendedUser(
      id: user.id,
      firstName: user.firstName,
      lastName: null,
      age: user.age,
      city: user.city,
      bio: user.bio,
      searchDistrict: user.city,
      photos: user.photos,
      isSaved: isSaved,
      matchPercent: matchPercent,
      isVerified: true,
      preferenceTag: null,
      isProfileComplete: true,
      lifestyle: null,
      occupationStatus: null,
      searchBudgetMin: null,
      searchBudgetMax: null,
      finalScore: matchPercent,
      aiReasoning: reasoningParts.join(' '),
      compatibilityReasons: explanation.matchedFields,
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
