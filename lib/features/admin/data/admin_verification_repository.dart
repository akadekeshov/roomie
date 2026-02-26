import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';

class AdminVerificationItem {
  AdminVerificationItem({
    required this.id,
    required this.name,
    required this.status,
    required this.documentUrl,
    required this.selfieUrl,
    this.email,
    this.phone,
  });

  final String id;
  final String name;
  final String status;
  final String? documentUrl;
  final String? selfieUrl;
  final String? email;
  final String? phone;

  factory AdminVerificationItem.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();

    return AdminVerificationItem(
      id: json['id'].toString(),
      name: ('$firstName $lastName').trim(),
      status: (json['verificationStatus'] ?? '').toString(),
      documentUrl: json['verificationDocumentUrl'] as String?,
      selfieUrl: json['verificationSelfieUrl'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class AdminVerificationRepository {
  const AdminVerificationRepository(this._dio);
  final Dio _dio;

  Future<List<AdminVerificationItem>> pending() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/admin/verifications/pending',
    );

    final items = (res.data?['items'] as List? ?? const []);
    return items
        .whereType<Map<String, dynamic>>()
        .map(AdminVerificationItem.fromJson)
        .toList();
  }

  Future<void> approve(String userId) async {
    await _dio.patch('/admin/verifications/$userId/approve');
  }

  Future<void> reject(String userId, {String? reason}) async {
    await _dio.patch('/admin/verifications/$userId/reject', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }
}

final adminVerificationRepositoryProvider =
    Provider<AdminVerificationRepository>((ref) {
  return AdminVerificationRepository(ref.read(dioProvider));
});
