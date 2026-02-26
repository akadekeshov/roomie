import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/api_config.dart';

class MeUser {
  const MeUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.city,
    required this.bio,
    required this.photos,
    required this.verificationStatus,
    required this.onboardingCompleted,
    required this.role,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? city;
  final String? bio;
  final List<String> photos;
  final String? verificationStatus;
  final bool onboardingCompleted;
  final String? role;

  factory MeUser.fromJson(Map<String, dynamic> json) => MeUser(
        id: (json['id'] as String?) ?? '',
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        city: json['city'] as String?,
        bio: json['bio'] as String?,
        photos:
            (json['photos'] as List<dynamic>?)?.whereType<String>().toList() ??
                const <String>[],
        verificationStatus: json['verificationStatus'] as String?,
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
        role: json['role'] as String?,
      );

  String get displayName {
    final fn = (firstName ?? '').trim();
    final ln = (lastName ?? '').trim();
    final name = ('$fn $ln').trim();
    return name.isEmpty ? 'Пользователь' : name;
  }

  String get subtitle {
    final e = (email ?? '').trim();
    if (e.isNotEmpty) return e;
    return (phone ?? '').trim();
  }

  String? get avatarUrl {
    final raw = photos.isNotEmpty ? photos.first.trim() : '';
    if (raw.isEmpty) return null;

    if (raw.startsWith('http')) return raw;
    final base = ApiConfig.publicBaseUrl;
    return '${base}${raw.startsWith('/') ? '' : '/'}$raw';
  }

  bool get isVerified => verificationStatus == 'VERIFIED';
}

class MeRepository {
  const MeRepository(this._dio);
  final Dio _dio;

  Future<MeUser> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return MeUser.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<String?> uploadAvatar(String path) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(path),
    });
    final response = await _dio.patch<Map<String, dynamic>>(
      '/users/me/avatar/upload',
      data: formData,
    );
    return response.data?['avatarUrl'] as String?;
  }
}

final meRepositoryProvider = Provider<MeRepository>((ref) {
  return MeRepository(ref.read(dioProvider));
});

final meProvider = FutureProvider<MeUser>((ref) async {
  return ref.read(meRepositoryProvider).getMe();
});
