import 'package:flutter/foundation.dart';

/// Central, configurable app configuration.
///
/// The backend base URL is resolved once, here. Override it at build/run time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
class AppConfig {
  const AppConfig._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Base URL of the NeuroBridge backend (no trailing slash).
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator maps the host machine to 10.0.2.2.
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Versioned API prefix.
  static const String apiPrefix = '/api/v1';
}
