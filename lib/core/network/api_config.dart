import 'api_config_stub.dart'
    if (dart.library.io) 'api_config_io.dart' as _impl;

class ApiConfig {
  static String get baseUrl => _impl.getApiBaseUrl();
  static String get publicBaseUrl => _impl.getPublicBaseUrl();
  const ApiConfig._();
}