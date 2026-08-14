class ApiConstants {
  ApiConstants._();

  /// Adresse du backend .NET. Par défaut : le SERVEUR DE PRODUCTION.
  ///
  /// Le défaut vise la production parce que c'est le cas d'usage courant — un APK
  /// remis aux commerciaux doit fonctionner sans qu'on ait pensé à passer un
  /// paramètre de compilation. Un oubli donnerait sinon une application qui cherche
  /// un serveur sur le téléphone lui-même, avec un message d'erreur incompréhensible
  /// pour l'utilisateur.
  ///
  /// Pour travailler en LOCAL, surcharger explicitement :
  ///   flutter run --dart-define=API_BASE_URL=http://localhost:5063/api
  /// Sur un téléphone branché en USB, « localhost » désigne le TÉLÉPHONE : il faut
  /// ouvrir le tunnel adb au préalable, sinon rien ne répond —
  ///   adb reverse tcp:5063 tcp:5063
  ///
  /// En clair (http) et non https tant que le certificat n'est pas installé sur
  /// olyhub.net ; l'exception est déclarée dans network_security_config.xml et
  /// limitée à ce domaine. À repasser en https dès que le certificat existe.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'http://olyhub.net/api';
  }

  // Auth
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String changePassword = '/auth/change-password';

  // Dashboard — one rich endpoint; ?periode=month|quarter
  static const String dashboardStats = '/dashboard/stats';

  // CA split by article category (Intérieur | Extérieur | Olybat)
  static const String dashboardCaCategories = '/dashboard/ca-categories';

  // Tâches clients
  static const String taches = '/taches';
  static const String tacheDetail = '/taches/{id}';

  // Demandes (9 types)
  static const String demandes = '/demandes';
  static const String demandeDetail = '/demandes/{id}';

  // Recherches Divalto (autocomplétion des formulaires de demandes)
  static const String clientSearch = '/clients/search';
  static const String articleSearch = '/articles/search';

  /// Techniciens enregistrés dans l'application (liste fermée, non paginée) —
  /// alimente les champs `source: 'technicien'` du schéma de formulaire.
  static const String techniciens = '/techniciens';

  // Objectifs (attainment for the current commercial)
  static const String objectifsProgress = '/objectifs/progress';
  static const String objectifCelebrate = '/objectifs/{id}/celebrate';

  // Upload
  static const String upload = '/upload';

  // Notifications (REST = le contrat ; FCM n'est qu'un réveil)
  static const String notifications = '/notifications';
  static const String notificationLu = '/notifications/{id}/lu';
  static const String notificationsToutLu = '/notifications/tout-lu';

  /// Enregistrement / suppression du jeton FCM de cet appareil.
  static const String notificationAppareils = '/notifications/appareils';

  // Profile

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
