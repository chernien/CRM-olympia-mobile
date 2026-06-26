class ApiConstants {
  ApiConstants._();

  /// Base URL of the .NET backend (dev = HTTP profile on `localhost:5000`).
  ///
  /// We use `localhost` everywhere. On Android (USB phone OR emulator) the
  /// device reaches the PC's backend through an adb reverse tunnel:
  ///   adb reverse tcp:5000 tcp:5000
  /// so `localhost:5000` on the device is forwarded to the PC over USB — no LAN
  /// IP and no firewall rule needed. Web/desktop hit localhost directly.
  ///
  /// Override for a real server with:
  ///   flutter run --dart-define=API_BASE_URL=https://api.olympia.ma/api
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'http://localhost:5000/api';
  }

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';

  // Dashboard — one rich endpoint; ?periode=month|quarter
  static const String dashboardStats = '/dashboard/stats';

  // Tâches clients
  static const String taches = '/taches';
  static const String tacheDetail = '/taches/{id}';

  // Demandes (9 types)
  static const String demandes = '/demandes';
  static const String demandeDetail = '/demandes/{id}';
  static const String demandeTypes = '/demandes/types';

  // Clients (Divalto)
  static const String clients = '/clients';
  static const String clientSearch = '/clients/search';

  // Upload
  static const String upload = '/upload';

  // Notifications
  static const String notifications = '/notifications';

  // Profile
  static const String profile = '/profile';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
