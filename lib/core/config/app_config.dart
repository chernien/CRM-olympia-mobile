/// App configuration.
///
/// The app runs exclusively against the real .NET backend — there is no mock
/// data layer. Configure the API endpoint via [ApiConstants.baseUrl] (or the
/// `--dart-define=API_BASE_URL=...` override).
class AppConfig {
  AppConfig._();

  /// When `true`, Dio logs full request/response bodies to the console.
  /// Always `false` in production — never log JWT tokens or PII.
  static const bool enableNetworkLogs =
      bool.fromEnvironment('NETWORK_LOGS', defaultValue: true);
}
