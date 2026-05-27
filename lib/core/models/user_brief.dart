import '../network/api_config.dart';

class UserBrief {
  const UserBrief({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.city,
    required this.email,
    required this.phone,
    required this.photos,
    required this.verificationStatus,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? city;
  final String? email;
  final String? phone;
  final List<String> photos;
  final String? verificationStatus;

  factory UserBrief.fromJson(Map<String, dynamic> json) {
    return UserBrief(
      id: '${json['id'] ?? ''}',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      age: (json['age'] as num?)?.toInt(),
      city: json['city'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      photos: (json['photos'] as List?)?.whereType<String>().toList() ??
          const <String>[],
      verificationStatus: json['verificationStatus'] as String?,
    );
  }

  String get displayName {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    final fullName = '$first $last'.trim();
    return fullName.isEmpty ? 'Пользователь' : fullName;
  }

  String get subtitle {
    final cityValue = (city ?? '').trim();
    if (cityValue.isNotEmpty) {
      return age == null ? cityValue : '$cityValue, $age';
    }

    final emailValue = (email ?? '').trim();
    if (emailValue.isNotEmpty) {
      return emailValue;
    }

    return (phone ?? '').trim();
  }

  String? get avatarUrl {
    final raw = photos.isNotEmpty ? photos.first.trim() : '';
    if (raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return '${ApiConfig.publicBaseUrl}${raw.startsWith('/') ? '' : '/'}$raw';
  }
}
