import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/auth_token_storage.dart';

class LoginResult {
  const LoginResult({
    required this.onboardingStep,
    required this.onboardingCompleted,
  });

  final String? onboardingStep;
  final bool onboardingCompleted;
}

class AuthFlowResult {
  const AuthFlowResult({required this.next});

  final String? next;
}

class AuthRepository {
  const AuthRepository(this._dio, this._tokenStorage);

  final Dio _dio;
  final AuthTokenStorage _tokenStorage;

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) {
      return digits;
    }
    return '+$digits';
  }

  String _normalizeEmail(String raw) {
    return raw.trim().toLowerCase();
  }

  Future<AuthFlowResult> register({
    required bool useEmail,
    required String identity,
    required String password,
  }) async {
    try {
      final endpoint =
          useEmail ? '/auth/register/email' : '/auth/register/phone';
      final body = <String, dynamic>{'password': password};
      if (useEmail) {
        body['email'] = _normalizeEmail(identity);
      } else {
        body['phone'] = _normalizePhone(identity.trim());
      }

      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: body,
      );
      return AuthFlowResult(next: response.data?['next'] as String?);
    } on DioException catch (e) {
      throw mapDioErrorToAppException(e);
    } catch (_) {
      throw const AppException(
        code: AppErrorCode.unknown,
        message: 'Не удалось зарегистрироваться. Попробуйте позже.',
      );
    }
  }

  Future<LoginResult> verifyRegisterOtp({
    required bool useEmail,
    required String identity,
    required String code,
    bool rememberMe = true,
  }) async {
    try {
      final endpoint = useEmail ? '/auth/verify/email' : '/auth/verify/phone';
      final body = <String, dynamic>{'code': code.trim()};
      if (useEmail) {
        body['email'] = _normalizeEmail(identity);
      } else {
        body['phone'] = _normalizePhone(identity.trim());
      }

      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: body,
      );
      final data = response.data ?? <String, dynamic>{};
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = (data['user'] as Map?)?.cast<String, dynamic>();

      if (accessToken == null || refreshToken == null) {
        throw const AppException(
          code: AppErrorCode.unknown,
          message: 'Ответ сервера не содержит токены.',
        );
      }

      await _tokenStorage.setAccessToken(accessToken);
      await _tokenStorage.saveRefreshToken(
        refreshToken: refreshToken,
        rememberMe: rememberMe,
      );

      return LoginResult(
        onboardingStep: user?['onboardingStep'] as String?,
        onboardingCompleted: user?['onboardingCompleted'] as bool? ?? false,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw mapDioErrorToAppException(e);
    } catch (_) {
      throw const AppException(
        code: AppErrorCode.unknown,
        message: 'Не удалось подтвердить код. Попробуйте ещё раз.',
      );
    }
  }

  Future<void> resendOtp({
    required bool useEmail,
    required String identity,
  }) async {
    try {
      await _dio.post(
        '/auth/otp/resend',
        data: {
          'channel': useEmail ? 'EMAIL' : 'PHONE',
          'purpose': 'REGISTER',
          'target': useEmail
              ? _normalizeEmail(identity)
              : _normalizePhone(identity.trim()),
        },
      );
    } on DioException catch (e) {
      throw mapDioErrorToAppException(e);
    } catch (_) {
      throw const AppException(
        code: AppErrorCode.unknown,
        message: 'Не удалось отправить код. Попробуйте позже.',
      );
    }
  }

  Future<LoginResult> login({
    required bool useEmail,
    required String identity,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final body = <String, dynamic>{'password': password};
      if (useEmail) {
        body['email'] = _normalizeEmail(identity);
      } else {
        body['phone'] = _normalizePhone(identity.trim());
      }

      final response = await _dio.post('/auth/login', data: body);
      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      final user = (data['user'] as Map?)?.cast<String, dynamic>();

      if (accessToken == null || refreshToken == null) {
        throw const AppException(
          code: AppErrorCode.unknown,
          message: 'Ответ сервера не содержит токены.',
        );
      }

      await _tokenStorage.setAccessToken(accessToken);
      await _tokenStorage.saveRefreshToken(
        refreshToken: refreshToken,
        rememberMe: rememberMe,
      );

      return LoginResult(
        onboardingStep: user?['onboardingStep'] as String?,
        onboardingCompleted: user?['onboardingCompleted'] as bool? ?? false,
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw mapDioErrorToAppException(e);
    } catch (_) {
      throw const AppException(
        code: AppErrorCode.unknown,
        message: 'Не удалось войти. Попробуйте позже.',
      );
    }
  }

  Future<LoginResult?> tryLoginWithRefreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data ?? <String, dynamic>{};
      final accessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      final user = (data['user'] as Map?)?.cast<String, dynamic>();

      if (accessToken == null || newRefreshToken == null) {
        return null;
      }

      await _tokenStorage.setAccessToken(accessToken);
      await _tokenStorage.saveRefreshToken(
        refreshToken: newRefreshToken,
        rememberMe: true,
      );

      return LoginResult(
        onboardingStep: user?['onboardingStep'] as String?,
        onboardingCompleted: user?['onboardingCompleted'] as bool? ?? false,
      );
    } on DioException catch (e) {
      final appEx = mapDioErrorToAppException(e);
      if (appEx.code == AppErrorCode.invalidOrExpiredToken) {
        await _tokenStorage.clear();
        return null;
      }
      return null;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(dioProvider),
    ref.read(authTokenStorageProvider),
  );
});

