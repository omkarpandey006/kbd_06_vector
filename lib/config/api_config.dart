import 'package:flutter/foundation.dart';

/// Central API configuration.
///
/// Automatically connects to the live Cloudflare HTTPS backend when running on Vercel/Web,
/// uses 10.0.2.2 on Android emulator to connect to host PC,
/// and 127.0.0.1 on local desktop.
class ApiConfig {
  ApiConfig._();

  /// Live Cloudflare HTTPS Tunnel URL connecting directly to the active Python AI backend.
  static String customBaseUrl =
      'https://complete-laura-royal-maintains.trycloudflare.com';

  /// Detect platform default host.
  static String get defaultHost {
    if (kIsWeb) {
      final isLocalWeb =
          Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1';
      if (!isLocalWeb) {
        return 'https://complete-laura-royal-maintains.trycloudflare.com';
      }
      return 'http://127.0.0.1:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  /// Base URL of the FastAPI backend (no trailing slash).
  static String get baseUrl =>
      customBaseUrl.isNotEmpty ? customBaseUrl : defaultHost;

  /// Full URL for the /predict endpoint.
  static String get predictEndpoint => '$baseUrl/predict';

  /// Full URL for the specialized /predict-pcb endpoint.
  static String get pcbAnalysisEndpoint => '$baseUrl/predict-pcb';

  /// Request timeout duration.
  static const Duration requestTimeout = Duration(seconds: 35);
}
