<<<<<<< HEAD
import 'api_config_stub.dart'
    if (dart.library.io) 'api_config_io.dart' as _impl;

class ApiConfig {
  static String get baseUrl => _impl.getApiBaseUrl();
  static String get publicBaseUrl => _impl.getPublicBaseUrl();
  const ApiConfig._();
}
=======
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _localBaseUrl = 'http://localhost:3000/api';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:3000/api';

  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) {
      return _localBaseUrl;
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? _androidEmulatorBaseUrl
        : _localBaseUrl;
  }

  const ApiConfig._();
}
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
