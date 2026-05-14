class AppConfig {
  static const String productBaseUrl = String.fromEnvironment(
    'PRODUCT_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static const String glowMatchBaseUrl = String.fromEnvironment(
    'GLOW_MATCH_BASE_URL',
    defaultValue: 'http://localhost:8001',
  );

  static const String imageBaseUrl = String.fromEnvironment(
    'IMAGE_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}

String getImageUrl(String path) {
  if (path.isEmpty) return '';

  if (path.startsWith('http')) return path;

  final cleanPath =
      path.startsWith('/')
          ? path.substring(1)
          : path;

  if (cleanPath.startsWith('storage/')) {
    return '${AppConfig.imageBaseUrl}/$cleanPath';
  }

  return '${AppConfig.imageBaseUrl}/storage/$cleanPath';
}