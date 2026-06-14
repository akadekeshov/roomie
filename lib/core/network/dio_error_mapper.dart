import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

AppException mapDioErrorToAppException(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return const AppException(
      code: AppErrorCode.network,
      message: 'network',
    );
  }

  final response = error.response;
  final data = response?.data;
  String? rawMessage;

  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String) {
      rawMessage = message;
    } else if (message is List && message.isNotEmpty) {
      rawMessage = message.first.toString();
    }
  } else if (data is String) {
    rawMessage = data;
  }

  final status = response?.statusCode;
  final normalized = (rawMessage ?? '').toLowerCase();

  if (status == 401 &&
      normalized.contains('invalid') &&
      (normalized.contains('credential') || normalized.contains('password'))) {
    return const AppException(
      code: AppErrorCode.invalidCredentials,
      message: 'invalid_credentials',
      field: 'password',
    );
  }

  if (status == 401 && normalized.contains('not verified')) {
    return const AppException(
      code: AppErrorCode.validation,
      message: 'account_not_verified',
      field: 'identity',
    );
  }

  if (status == 409 &&
      normalized.contains('email') &&
      (normalized.contains('exist') || normalized.contains('already'))) {
    return const AppException(
      code: AppErrorCode.emailAlreadyExists,
      message: 'email_exists',
      field: 'email',
    );
  }

  if (status == 409 &&
      (normalized.contains('phone') || normalized.contains('number')) &&
      (normalized.contains('exist') || normalized.contains('already'))) {
    return const AppException(
      code: AppErrorCode.phoneAlreadyExists,
      message: 'phone_exists',
      field: 'phone',
    );
  }

  if (status == 401 &&
      normalized.contains('token') &&
      (normalized.contains('invalid') ||
          normalized.contains('expired') ||
          normalized.contains('revoked'))) {
    return const AppException(
      code: AppErrorCode.invalidOrExpiredToken,
      message: 'invalid_token',
    );
  }

  if (status == 404 && normalized.contains('user not found')) {
    return const AppException(
      code: AppErrorCode.validation,
      message: 'user_not_found',
      field: 'identity',
    );
  }

  if (status == 429) {
    return const AppException(
      code: AppErrorCode.validation,
      message: 'too_many_attempts',
    );
  }

  if (status == 401 || status == 403) {
    return const AppException(
      code: AppErrorCode.validation,
      message: 'no_access',
    );
  }

  if (status == 400) {
    return const AppException(
      code: AppErrorCode.validation,
      message: 'validation',
    );
  }

  if (status != null && status >= 500) {
    return const AppException(
      code: AppErrorCode.network,
      message: 'server_error',
    );
  }

  return const AppException(
    code: AppErrorCode.unknown,
    message: 'unknown',
  );
}
