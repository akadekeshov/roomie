import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';

enum VerificationStatus { none, pending, approved, rejected }

class VerificationMe {
  const VerificationMe({
    required this.status,
    required this.documentUrl,
    required this.selfieUrl,
  });

  final VerificationStatus status;
  final String? documentUrl;
  final String? selfieUrl;

  factory VerificationMe.fromJson(Map<String, dynamic> json) {
    final raw = (json['status'] as String?)?.toUpperCase() ?? 'NONE';
    VerificationStatus st;

    switch (raw) {
      case 'PENDING':
        st = VerificationStatus.pending;
        break;
      case 'APPROVED':
      case 'VERIFIED':
        st = VerificationStatus.approved;
        break;
      case 'REJECTED':
        st = VerificationStatus.rejected;
        break;
      default:
        st = VerificationStatus.none;
    }

    return VerificationMe(
      status: st,
      documentUrl: json['documentUrl'] as String?,
      selfieUrl: json['selfieUrl'] as String?,
    );
  }
}

class VerificationRepository {
  const VerificationRepository(this._dio);
  final Dio _dio;

  Future<VerificationMe> getMe() async {
    final res = await _dio.get<Map<String, dynamic>>('/verification/me');
    return VerificationMe.fromJson(res.data ?? {});
  }

  Future<String?> uploadDocument(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    final res = await _dio.patch<Map<String, dynamic>>(
      '/verification/document/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    return (res.data?['documentUrl'] as String?) ??
        (res.data?['url'] as String?);
  }

  Future<String?> uploadSelfie(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
    });

    final res = await _dio.patch<Map<String, dynamic>>(
      '/verification/selfie/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );

    return (res.data?['selfieUrl'] as String?) ?? (res.data?['url'] as String?);
  }

  Future<void> submit() async {
    await _dio.post('/verification/submit');
  }
}

final verificationRepositoryProvider = Provider<VerificationRepository>((ref) {
  return VerificationRepository(ref.read(dioProvider));
});

final verificationMeProvider = FutureProvider<VerificationMe>((ref) async {
  return ref.read(verificationRepositoryProvider).getMe();
});
