/// App configuration — toggle between mock and real API mode.
///
/// Set [useMockData] to `false` and update [ApiConstants.baseUrl]
/// with your real .NET API URL to switch to production mode.
///
/// All flags can also be overridden at build time via --dart-define:
///   flutter run --dart-define=USE_MOCK=true
class AppConfig {
  AppConfig._();

  /// When `true`, the app uses in-memory fake data (no network calls).
  /// Set to `false` when your real .NET API is available.
  static const bool useMockData =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);

  /// When `true`, Dio logs full request/response bodies to the console.
  /// Always `false` in production — never log JWT tokens or PII.
  static const bool enableNetworkLogs =
      bool.fromEnvironment('NETWORK_LOGS', defaultValue: true);
}
