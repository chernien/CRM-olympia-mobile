class ApiConstants {
  ApiConstants._();

  // Base URL - TODO: Replace with actual .NET API URL
  static const String baseUrl = 'https://api.olympia.com/api';

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';

  // Dashboard / CA
  static const String caMensuel = '/ca-mensuel';
  static const String caTrimestriel = '/ca-trimestriel';
  static const String statsTaches = '/stats-taches';
  static const String statsVisites = '/stats-visites';

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
