class AppConfig {
  // API Laravel produk/admin
  static const String productBaseUrl = String.fromEnvironment(
    'PRODUCT_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  // API Python Glow Match / AI
  static const String glowMatchBaseUrl = String.fromEnvironment(
    'GLOW_MATCH_BASE_URL',
    defaultValue: 'http://localhost:8001',
  );
}