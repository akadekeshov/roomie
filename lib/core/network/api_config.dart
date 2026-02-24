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
