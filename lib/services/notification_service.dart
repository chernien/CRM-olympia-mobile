import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/theme/app_colors.dart';

/// Affichage local des notifications.
///
/// C'est l'APPLICATION qui dessine la bannière, jamais Android : le backend envoie
/// des messages FCM `data-only` (sans bloc `notification`), sinon le système
/// afficherait lui-même la notification et le code Dart ne s'exécuterait pas quand
/// l'application est fermée — impossible alors de router le tap vers la bonne fiche.
///
/// **Pourquoi il n'y avait ni bannière ni son.** Sur Android 8+, l'importance
/// est une propriété du *canal*, pas de la notification : c'est elle qui décide
/// d'un affichage en heads-up (bannière) plutôt que d'un dépôt silencieux dans
/// le tiroir. Aucun canal n'était créé explicitement ; Android en fabriquait un
/// à la volée en `IMPORTANCE_DEFAULT`, et le `Importance.max` passé dans les
/// `AndroidNotificationDetails` était ignoré. Le canal est désormais créé au
/// démarrage, en `Importance.max`, son et vibration activés.
class NotificationService {
  /// Ancien canal, créé implicitement en importance par défaut sur les
  /// téléphones déjà équipés. Android **refuse toute élévation d'importance
  /// d'un canal existant** : le seul moyen d'obtenir enfin une bannière est de
  /// publier sur un nouvel identifiant. L'ancien est supprimé au passage pour
  /// ne pas laisser une entrée morte dans les réglages du téléphone.
  static const String _legacyChannelId = 'olympia_channel_id';

  static const String channelId = 'olympia_alertes_v2';
  static const String channelName = 'Alertes Olympia';
  static const String channelDescription =
      'Demandes à traiter, tâches affectées et objectifs.';

  /// Silhouette monochrome dédiée : voir `res/drawable/ic_stat_olympia.xml`.
  ///
  /// Résolue par NOM à l'exécution. Aucun fichier XML ne la référence, donc la
  /// réduction de ressources des builds release la supprimait : les notifications
  /// arrivaient sur le téléphone mais échouaient à s'afficher (`invalid_icon`).
  /// Elle est conservée explicitement par `res/raw/keep.xml` — ne renommez pas
  /// l'une sans l'autre.
  static const String _androidIcon = '@drawable/ic_stat_olympia';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Émet la charge utile (`{type, id, notificationId}`) quand l'utilisateur
  /// touche une notification affichée par l'application.
  final StreamController<Map<String, String>> _tapController =
      StreamController<Map<String, String>>.broadcast();

  Stream<Map<String, String>> get onTap => _tapController.stream;

  /// Mémorise la *future* et non un booléen : le constructeur lance déjà `init()`
  /// sans l'attendre, et un simple drapeau laisserait un appelant concurrent
  /// croire l'initialisation terminée alors que le canal n'est pas encore créé.
  Future<void>? _initialization;

  NotificationService() {
    unawaited(init());
  }

  Future<void> init() => _initialization ??= _init();

  Future<void> _init() async {
    const androidSettings = AndroidInitializationSettings(_androidIcon);
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _plugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (response) => _emitTap(
          response.payload,
        ),
      );
      await _createAndroidChannel();
    } catch (e) {
      debugPrint('Notifications locales indisponibles : $e');
    }
  }

  /// Canal Android — l'élément qui manquait. Sans lui, pas de heads-up.
  Future<void> _createAndroidChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max, // bannière + son
        playSound: true,
        enableVibration: true,
        enableLights: true,
        showBadge: true,
      ),
    );
    // Nettoyage du canal muet historique.
    await android.deleteNotificationChannel(channelId: _legacyChannelId);
  }

  /// Demande l'autorisation d'affichage (Android 13+ et iOS).
  Future<void> requestPermission() async {
    await init();
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('Autorisation notifications refusée ou indisponible : $e');
    }
  }

  /// Application lancée depuis une notification alors qu'elle était **fermée** :
  /// le tap n'a alors traversé aucun listener, il faut aller le chercher.
  Future<void> emitLaunchTap() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return;
      _emitTap(details?.notificationResponse?.payload);
    } catch (e) {
      debugPrint('Lecture du tap de lancement impossible : $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    Map<String, String>? data,
    bool highPriority = true,
  }) async {
    await init();
    // Le titre reste tel quel : Android affiche déjà « OlyHub » en en-tête
    // (le `android:label` du manifeste). Le préfixer ferait doublon et volerait
    // de la place au titre réel.
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      icon: _androidIcon,
      // Pas de `largeIcon` : le rendu visé est celui des applications de
      // référence (LinkedIn, Gmail…) — un seul petit logo dans le cercle
      // d'en-tête, puis le titre et le corps sur toute la largeur.
      // Teinte du cercle : la couleur de marque plutôt que le gris système.
      color: AppColors.primary,
      colorized: false,
      // Sur Android 8+ ces deux valeurs sont plafonnées par l'importance du
      // canal ; elles restent utiles sur les versions antérieures.
      importance: Importance.max,
      priority: highPriority ? Priority.high : Priority.defaultPriority,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.message,
      ticker: title,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: data == null ? null : jsonEncode(data),
      );
    } catch (e) {
      debugPrint('Affichage de la notification impossible : $e');
    }
  }

  void _emitTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      _tapController.add(
        decoded.map((k, v) => MapEntry(k, v?.toString() ?? '')),
      );
    } catch (_) {
      // Charge utile illisible : on ignore plutôt que de casser au tap.
    }
  }

  void dispose() {
    _tapController.close();
  }
}
