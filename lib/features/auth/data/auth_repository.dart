import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class CurrentUser {
  const CurrentUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
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
    final endpoint = useEmail ? '/auth/register/email' : '/auth/register/phone';
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
  }

  Future<LoginResult> verifyRegisterOtp({
    required bool useEmail,
    required String identity,
    required String code,
  }) async {
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
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Missing auth tokens in response',
      );
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return LoginResult(
      onboardingStep: user?['onboardingStep'] as String?,
      onboardingCompleted: user?['onboardingCompleted'] as bool? ?? false,
    );
  }

  Future<void> resendOtp({
    required bool useEmail,
    required String identity,
  }) async {
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
  }

  Future<LoginResult> login({
    required bool useEmail,
    required String identity,
    required String password,
  }) async {
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
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Missing auth tokens in response',
      );
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return LoginResult(
      onboardingStep: user?['onboardingStep'] as String?,
      onboardingCompleted: user?['onboardingCompleted'] as bool? ?? false,
    );
  }

  Future<CurrentUser> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data ?? <String, dynamic>{};
    return CurrentUser(
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      email: data['email'] as String?,
      phone: data['phone'] as String?,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(dioProvider),
    ref.read(authTokenStorageProvider),
  );
});
