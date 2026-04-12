import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/auth_token_storage.dart';
import 'api_config.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => AuthTokenStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(authTokenStorageProvider);
  Future<String?>? refreshFuture;

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  bool shouldTryRefresh(RequestOptions options) {
    final path = options.path.toLowerCase();
    if (path.contains('/auth/login')) return false;
    if (path.contains('/auth/register/')) return false;
    if (path.contains('/auth/verify/')) return false;
    if (path.contains('/auth/otp/resend')) return false;
    if (path.contains('/auth/refresh')) return false;
    return true;
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await tokenStorage.clear();
      return null;
    }

    final refreshDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data ?? <String, dynamic>{};
      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        await tokenStorage.clear();
        return null;
      }

      await tokenStorage.setAccessToken(newAccessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await tokenStorage.saveRefreshToken(
          refreshToken: newRefreshToken,
          rememberMe: true,
        );
      }

      return newAccessToken;
    } catch (_) {
      await tokenStorage.clear();
      return null;
    }
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        // ignore: avoid_print
        print(
          '[Dio] Error: ${error.requestOptions.method} ${error.requestOptions.uri}',
        );
        // ignore: avoid_print
        print('[Dio] statusCode=$statusCode data=$data');

        final request = error.requestOptions;
        final alreadyRetried = request.extra['__retried'] == true;

        if (statusCode == 401 &&
            !alreadyRetried &&
            shouldTryRefresh(request)) {
          refreshFuture ??= refreshAccessToken().whenComplete(() {
            refreshFuture = null;
          });

          final newAccessToken = await refreshFuture;
          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            try {
              final nextHeaders = Map<String, dynamic>.from(request.headers);
              nextHeaders['Authorization'] = 'Bearer $newAccessToken';

              final retried = await dio.fetch<dynamic>(
                request.copyWith(
                  headers: nextHeaders,
                  extra: <String, dynamic>{...request.extra, '__retried': true},
                ),
              );
              handler.resolve(retried);
              return;
            } catch (_) {
              await tokenStorage.clear();
            }
          } else {
            await tokenStorage.clear();
          }
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});
