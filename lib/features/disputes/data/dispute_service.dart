import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../../../core/network/network_providers.dart';
import 'dispute_models.dart';

class DisputeService {
  const DisputeService(this._dio);

  final Dio _dio;

  Future<String> createDispute({
    String? agreementId,
    String? conversationId,
    required String accusedId,
    required DisputeReason reason,
    required String title,
    required String description,
    required List<String> evidenceUrls,
  }) async {
    try {
      final response = await _dio.post(
        '/disputes',
        data: {
          if (agreementId != null && agreementId.isNotEmpty)
            'agreementId': agreementId,
          if (conversationId != null && conversationId.isNotEmpty)
            'conversationId': conversationId,
          'accusedId': accusedId,
          'reason': reason.apiValue,
          'title': title,
          'description': description,
          'evidenceUrls': evidenceUrls,
        },
      );
      final data = (response.data as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};
      return (data['message'] as String?) ?? 'Жалоба успешно отправлена.';
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<List<DisputeItem>> getMyDisputes() async {
    try {
      final response = await _dio.get('/disputes/my');
      final raw = response.data as List? ?? const [];
      return raw
          .whereType<Map>()
          .map((json) => DisputeItem.fromJson(json.cast<String, dynamic>()))
          .toList();
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<List<DisputeItem>> getAllDisputes({
    DisputeStatus? status,
    DisputeReason? reason,
  }) async {
    try {
      final response = await _dio.get(
        '/disputes/admin/all',
        queryParameters: {
          if (status != null) 'status': status.apiValue,
          if (reason != null) 'reason': reason.apiValue,
        },
      );
      final raw = response.data as List? ?? const [];
      return raw
          .whereType<Map>()
          .map((json) => DisputeItem.fromJson(json.cast<String, dynamic>()))
          .toList();
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<DisputeItem> getDispute(String id) async {
    try {
      final response = await _dio.get('/disputes/$id');
      return DisputeItem.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<DisputeItem> resolveDispute({
    required String disputeId,
    required DisputeDecision decision,
    required DisputeAction action,
    String? adminComment,
    int? restrictionDays,
  }) async {
    try {
      final response = await _dio.patch(
        '/disputes/admin/$disputeId/resolve',
        data: {
          'decision': decision.apiValue,
          'action': action.apiValue,
          if (adminComment != null && adminComment.trim().isNotEmpty)
            'adminComment': adminComment.trim(),
          if (restrictionDays != null) 'restrictionDays': restrictionDays,
        },
      );
      return DisputeItem.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }
}

final disputeServiceProvider = Provider<DisputeService>((ref) {
  return DisputeService(ref.read(dioProvider));
});

final myDisputesProvider =
    FutureProvider.autoDispose<List<DisputeItem>>((ref) async {
  return ref.read(disputeServiceProvider).getMyDisputes();
});

final adminDisputesProvider = FutureProvider.autoDispose
    .family<List<DisputeItem>, Map<String, String?>>((ref, filters) async {
  final statusValue = filters['status'];
  final reasonValue = filters['reason'];

  final status = statusValue == null
      ? null
      : DisputeStatus.values.firstWhere(
          (item) => item.apiValue == statusValue,
          orElse: () => DisputeStatus.open,
        );
  final reason = reasonValue == null
      ? null
      : DisputeReason.values.firstWhere(
          (item) => item.apiValue == reasonValue,
          orElse: () => DisputeReason.other,
        );

  return ref.read(disputeServiceProvider).getAllDisputes(
        status: status,
        reason: reason,
      );
});

