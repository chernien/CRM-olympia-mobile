/// App configuration — toggle between mock and real API mode.
///
/// Set [useMockData] to `false` and update [ApiConstants.baseUrl]
/// with your real .NET API URL to switch to production mode.
class AppConfig {
  AppConfig._();

  /// When `true`, the app uses in-memory fake data (no network calls).
  /// Set to `false` when your real .NET API is available.
  static const bool useMockData = true;
}
