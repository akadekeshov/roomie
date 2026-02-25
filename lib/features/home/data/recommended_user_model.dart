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

 
  final String? occupationStatus;
  final int? searchBudgetMin;
  final int? searchBudgetMax;

  factory RecommendedUser.fromJson(Map<String, dynamic> json) {
    return RecommendedUser(
      id: (json['id'] as String?) ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      city: json['city'] as String?,
      bio: json['bio'] as String?,
      searchDistrict: json['searchDistrict'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          const <String>[],
      isSaved: json['isSaved'] as bool? ?? false,


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