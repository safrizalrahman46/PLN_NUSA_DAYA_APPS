class AppConfig {
  AppConfig._();

  /// Central DIGIKIT API server for production login, format-logsheets, and submissions (using secure HTTPS to avoid 301 Cloudflare redirects)
  static const String baseUrl = 'https://wacb.nusadaya.net/api';

  /// Central DIGIKIT API server
  static const String digikitBaseUrl = 'https://wacb.nusadaya.net/api';

  /// Kode region Kalimantan 3
  static const String kdRegion = '05';

  static const double defaultRadiusMeter = 250;
  static const int reportIntervalHour = 1;
  static const Duration splashDelay = Duration(milliseconds: 2200);
}
