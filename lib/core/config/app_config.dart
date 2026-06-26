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
  /// Now `false` by default — the backend endpoints (dashboard, taches,
  /// demandes, clients, upload) are wired. Override with
  /// `--dart-define=USE_MOCK=true` to demo without a backend.
  static const bool useMockData =
      bool.fromEnvironment('USE_MOCK', defaultValue: false);

  /// Auth is decoupled from [useMockData]: the real `/auth/login` endpoint is
  /// wired, so authentication always hits the backend while other features can
  /// still run on mock data. Override with `--dart-define=USE_MOCK_AUTH=true`
  /// to fall back to the in-memory mock login.
  static const bool useMockAuth =
      bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: false);

  /// When `true`, Dio logs full request/response bodies to the console.
  /// Always `false` in production — never log JWT tokens or PII.
  static const bool enableNetworkLogs =
      bool.fromEnvironment('NETWORK_LOGS', defaultValue: true);
}
