/// Cross-cutting constants shared across the app.
///
/// Network values come from `--dart-define` so they can change per build
/// without touching code.
class Constants {
  Constants._();

  /// Base URL for the tracking API. Overridable at build time:
  /// `--dart-define=API_BASE_URL=https://api.latelogic.app`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.latelogic.app',
  );

  /// Request timeout for API calls.
  static const Duration apiTimeout = Duration(seconds: 20);

  /// Simulated latency used by mock/refresh flows.
  static const Duration mockLatency = Duration(milliseconds: 900);
}
