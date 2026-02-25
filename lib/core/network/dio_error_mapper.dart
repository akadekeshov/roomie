import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

AppException mapDioErrorToAppException(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return const AppException(
      code: AppErrorCode.network,
      message: 'Нет подключения к серверу. Проверьте интернет.',
    );
  }

  final res = error.response;
  final data = res?.data;
  String? rawMessage;

  if (data is Map<String, dynamic>) {
    final m = data['message'];
    if (m is String) {
      rawMessage = m;
    } else if (m is List && m.isNotEmpty) {
      rawMessage = m.first.toString();
    }
  } else if (data is String) {
    rawMessage = data;
  }

  final status = res?.statusCode;
  final normalized = (rawMessage ?? '').toLowerCase();

  if (status == 401 &&
      normalized.contains('invalid') &&
      (normalized.contains('credential') || normalized.contains('password'))) {
    return const AppException(
      code: AppErrorCode.invalidCredentials,
      message: 'Неверный логин или пароль.',
      field: 'password',
    );
  }

  if (status == 409 &&
      normalized.contains('email') &&
      (normalized.contains('exist') || normalized.contains('already'))) {
    return const AppException(
      code: AppErrorCode.emailAlreadyExists,
      message: 'Этот email уже был зарегистрирован.',
      field: 'email',
    );
  }

  if (status == 409 &&
      (normalized.contains('phone') || normalized.contains('number')) &&
      (normalized.contains('exist') || normalized.contains('already'))) {
    return const AppException(
      code: AppErrorCode.phoneAlreadyExists,
      message: 'Этот номер уже был зарегистрирован.',
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
      message: 'Сессия истекла. Войдите заново.',
    );
  }

  if (status == 400) {
    return const AppException(
      code: AppErrorCode.validation,
      message: 'Проверьте правильность введённых данных.',
    );
  }

  if (status != null && status >= 500) {
    return const AppException(
      code: AppErrorCode.network,
      message: 'Сервер недоступен. Попробуйте позже.',
    );
  }

  return const AppException(
    code: AppErrorCode.unknown,
    message: 'Что-то пошло не так. Попробуйте ещё раз.',
  );
}

