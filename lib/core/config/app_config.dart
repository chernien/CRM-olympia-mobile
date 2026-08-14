import 'package:flutter/foundation.dart';

/// App configuration.
///
/// The app runs exclusively against the real .NET backend — there is no mock
/// data layer. Configure the API endpoint via [ApiConstants.baseUrl] (or the
/// `--dart-define=API_BASE_URL=...` override).
class AppConfig {
  AppConfig._();

  /// Quand `true`, Dio écrit les corps COMPLETS des requêtes et des réponses
  /// dans le journal Android : jeton JWT de l'en-tête Authorization, mot de passe
  /// envoyé à la connexion, noms de clients, contenu des demandes.
  ///
  /// Le défaut valait `true`, donc un APK construit sans passer explicitement
  /// `--dart-define=NETWORK_LOGS=false` déversait tout cela dans logcat, lisible
  /// par toute application ou tout PC branché en USB. Le commentaire d'origine
  /// affirmait « always false in production » — le code disait le contraire.
  ///
  /// Le défaut suit désormais le MODE DE COMPILATION : actif en débogage, où il
  /// rend service, éteint en release. La surcharge reste possible pour diagnostiquer
  /// un incident sur un build de production, mais elle devient un geste conscient.
  static const bool enableNetworkLogs =
      bool.fromEnvironment('NETWORK_LOGS', defaultValue: kDebugMode);
}
