String getApiBaseUrl() {
  return const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
}

String getPublicBaseUrl() {
  return const String.fromEnvironment(
    'PUBLIC_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}