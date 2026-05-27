import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/network/network_providers.dart';
import 'agreement_models.dart';

class AgreementService {
  const AgreementService(this._dio);

  final Dio _dio;

  Future<AgreementConversationStatus> getConversationStatus(
    String conversationId,
  ) async {
    try {
      final response = await _dio.get(
        '/agreements/conversation/$conversationId/status',
      );
      return AgreementConversationStatus.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<RoommateAgreement> createFromConversation(String conversationId) async {
    try {
      final response = await _dio.post(
        '/agreements/from-conversation',
        data: {'conversationId': conversationId},
      );
      return RoommateAgreement.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<List<RoommateAgreement>> getMyAgreements() async {
    try {
      final response = await _dio.get('/agreements/my');
      final raw = response.data as List? ?? const [];
      return raw
          .whereType<Map>()
          .map(
            (json) => RoommateAgreement.fromJson(
              json.cast<String, dynamic>(),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<RoommateAgreement> getAgreement(String id) async {
    try {
      final response = await _dio.get('/agreements/$id');
      return RoommateAgreement.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<RoommateAgreement> updateAgreement(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.patch('/agreements/$id', data: payload);
      return RoommateAgreement.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<RoommateAgreement> sendForConfirmation(String id) async {
    try {
      final response = await _dio.post(
        '/agreements/$id/send-for-confirmation',
        data: const <String, dynamic>{},
      );
      return RoommateAgreement.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<RoommateAgreement> confirmAgreement(String id) async {
    try {
      final response = await _dio.post(
        '/agreements/$id/confirm',
        data: {'confirm': true},
      );
      return RoommateAgreement.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<RoommateAgreement> rejectAgreement(String id) async {
    try {
      final response = await _dio.post(
        '/agreements/$id/reject',
        data: const <String, dynamic>{},
      );
      return RoommateAgreement.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<RoommateAgreement> cancelAgreement(String id) async {
    try {
      final response = await _dio.post('/agreements/$id/cancel');
      return RoommateAgreement.fromJson(
        (response.data as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
      );
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }
}

final agreementServiceProvider = Provider<AgreementService>((ref) {
  return AgreementService(ref.read(dioProvider));
});

class AgreementStatusNotifier
    extends StateNotifier<AsyncValue<AgreementConversationStatus?>> {
  AgreementStatusNotifier(this._service) : super(const AsyncValue.data(null));

  final AgreementService _service;

  Future<void> load(String conversationId) async {
    state = const AsyncValue.loading();
    try {
      final value = await _service.getConversationStatus(conversationId);
      state = AsyncValue.data(value);
    } on AppException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final agreementConversationStatusProvider = StateNotifierProvider.autoDispose
    .family<AgreementStatusNotifier, AsyncValue<AgreementConversationStatus?>, String>(
  (ref, conversationId) {
    final notifier = AgreementStatusNotifier(ref.read(agreementServiceProvider));
    notifier.load(conversationId);
    return notifier;
  },
);

final myAgreementsProvider = FutureProvider.autoDispose<List<RoommateAgreement>>(
  (ref) async {
    return ref.read(agreementServiceProvider).getMyAgreements();
  },
);

final agreementDetailProvider =
    FutureProvider.autoDispose.family<RoommateAgreement, String>((ref, id) async {
  return ref.read(agreementServiceProvider).getAgreement(id);
});
