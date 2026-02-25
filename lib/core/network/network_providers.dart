import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/auth_token_storage.dart';
import 'api_config.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => AuthTokenStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(authTokenStorageProvider);
<<<<<<< HEAD

=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
<<<<<<< HEAD
      onError: (error, handler) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        // ignore: avoid_print
        print('[Dio] Error: ${error.requestOptions.method} ${error.requestOptions.uri}');
        // ignore: avoid_print
        print('[Dio] statusCode=$statusCode data=$data');
        handler.next(error);
      },
=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
    ),
  );

  return dio;
<<<<<<< HEAD
});
=======
});
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
