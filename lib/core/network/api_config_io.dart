// import 'dart:io';
import 'dart:io' show Platform;


String getApiBaseUrl() {
  const port = String.fromEnvironment('API_PORT', defaultValue: '3000');
  if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
  return 'http://localhost:$port/api';
}

String getPublicBaseUrl() {
  const port = String.fromEnvironment('API_PORT', defaultValue: '3000');
  if (Platform.isAndroid) return 'http://10.0.2.2:$port';
  return 'http://localhost:$port';
}