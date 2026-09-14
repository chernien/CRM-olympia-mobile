import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  /// Backend visé en DEBUG, c'est-à-dire depuis Android Studio.
  ///
  /// « localhost » désigne le TÉLÉPHONE, pas le PC : c'est le tunnel USB qui
  /// fait le lien, à ouvrir une fois par branchement —
  ///
  ///   adb reverse tcp:5199 tcp:5199
  ///
  /// Ce tunnel est préférable à l'adresse Wi-Fi du poste (192.168.x.y) : il ne
  /// dépend ni du réseau ni du pare-feu Windows, et il continue de fonctionner
  /// quand le PC change de Wi-Fi. Pour viser malgré tout le poste par le
  /// réseau, passer API_BASE_URL à la compilation — cette valeur l'emporte.
  static const String devBaseUrl = 'http://localhost:5199/api';

  /// Adresse du backend .NET.
  ///
  /// Trois niveaux, du plus fort au plus faible :
  ///   1. API_BASE_URL passé à la compilation — gagne toujours ;
  ///   2. en DEBUG, le backend de développement ci-dessus ;
  ///   3. sinon (donc en RELEASE), la PRODUCTION.
  ///
  /// Pourquoi distinguer debug et release plutôt qu'un défaut unique : un APK
  /// remis aux commerciaux doit viser la production sans qu'on ait pensé à
  /// passer un paramètre — et une session de test doit viser le backend en
  /// cours de mise au point sans qu'on ait pensé non plus. Les deux oublis sont
  /// réels ; celui du 11/09/2026 a fait tester la production en croyant tester
  /// les nouveautés. kDebugMode est figé à la compilation : la release ne peut
  /// pas partir vers un poste de développement.
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kDebugMode) return devBaseUrl;
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

  /// Listes SANS saisie (bouton « ouvrir la liste » — réunion client du
  /// 10/09/2026). Le périmètre clients est décidé par l'API d'après le jeton :
  /// un commercial ne reçoit que son portefeuille (CLI.REPR_0001).
  static const String clientsListe = '/clients/liste';
  static const String articlesListe = '/articles/liste';

  /// Cascade TAR des lignes d'échantillon : référence → teintes (SREF1),
  /// puis référence + teinte → bases (SREF2, valeur vide incluse).
  static const String articleTeintes = '/articles/teintes';
  static const String articleBases = '/articles/bases';

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
