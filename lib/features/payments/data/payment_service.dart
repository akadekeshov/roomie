import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_error_mapper.dart';
import '../../../core/network/network_providers.dart';
import 'payment_models.dart';

class PaymentService {
  const PaymentService(this._dio);

  final Dio _dio;

  Future<List<UserPaymentCard>> getMyCards() async {
    try {
      final response = await _dio.get('/payments/cards/my');
      final raw = response.data as List? ?? const [];
      return raw
          .whereType<Map>()
          .map(
            (json) => UserPaymentCard.fromJson(
              json.cast<String, dynamic>(),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<String> bindMockCard({
    required String cardLast4,
    required String cardBrand,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/cards/bind',
        data: {
          'cardLast4': cardLast4,
          'cardBrand': cardBrand,
        },
      );
      final data =
          (response.data as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
      return (data['message'] as String?) ??
          'Это тестовая привязка карты. Реальные деньги не списываются.';
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<void> removeCard(String cardId) async {
    try {
      await _dio.delete('/payments/cards/$cardId');
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<List<AgreementPayment>> getAgreementPayments(String agreementId) async {
    try {
      final response = await _dio.get('/payments/agreement/$agreementId');
      final raw = response.data as List? ?? const [];
      return raw
          .whereType<Map>()
          .map(
            (json) => AgreementPayment.fromJson(
              json.cast<String, dynamic>(),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<String> mockPay(String paymentId) async {
    try {
      final response = await _dio.post('/payments/$paymentId/mock-pay');
      final data =
          (response.data as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
      return (data['message'] as String?) ??
          'Тестовый платеж успешно выполнен. Реальные деньги не списывались.';
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }

  Future<List<AgreementPayment>> getMyReminders() async {
    try {
      final response = await _dio.get('/payments/my-reminders');
      final raw = response.data as List? ?? const [];
      return raw
          .whereType<Map>()
          .map(
            (json) => AgreementPayment.fromJson(
              json.cast<String, dynamic>(),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw mapDioErrorToAppException(error);
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.read(dioProvider));
});

final myCardsProvider = FutureProvider.autoDispose<List<UserPaymentCard>>(
  (ref) async => ref.read(paymentServiceProvider).getMyCards(),
);

final paymentRemindersProvider = FutureProvider.autoDispose<List<AgreementPayment>>(
  (ref) async => ref.read(paymentServiceProvider).getMyReminders(),
);

final agreementPaymentsProvider =
    FutureProvider.autoDispose.family<List<AgreementPayment>, String>(
  (ref, agreementId) async {
    return ref.read(paymentServiceProvider).getAgreementPayments(agreementId);
  },
);
