import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_api_service.dart';
import 'notification_service.dart';

/// Point d'entrée FCM du mobile — **le seul transport push de l'application**.
///
/// Pourquoi pas SignalR ici : un WebSocket meurt avec le processus. Le commercial
/// est sur le terrain, l'application est fermée la plupart du temps ; seul FCM
/// peut le joindre dans cet état.
///
/// Trois règles structurantes, imposées par le backend et respectées ici :
///  • messages **data-only** → c'est cette classe qui affiche la bannière, via
///    [NotificationService] (flutter_local_notifications) ;
///  • le message ne transporte que `{type, id, notificationId}` → le contenu réel
///    est rechargé depuis l'API REST ;
///  • **aucune configuration Firebase n'est requise pour démarrer** : tant que le
///    client n'a pas fourni `google-services.json`, [isAvailable] reste faux et
///    l'application fonctionne normalement, sans push.
class PushService {
  final NotificationApiService _api;
  final NotificationService _local;

  PushService(this._api, this._local);

  bool _available = false;
  bool _initialised = false;
  String? _token;
  String? _reason;

  final StreamController<Map<String, String>> _openController =
      StreamController<Map<String, String>>.broadcast();

  /// Émet à chaque notification **reçue** (pas seulement ouverte) : c'est ce
  /// qui permet à la pastille du tableau de bord de s'incrémenter en direct.
  final StreamController<Map<String, String>> _receivedController =
      StreamController<Map<String, String>>.broadcast();

  /// Vrai uniquement si Firebase a pu s'initialiser sur cet appareil.
  bool get isAvailable => _available;

  /// Raison du repli, journalisée et affichable en support.
  String? get unavailableReason => _reason;

  String? get token => _token;

  /// Émet `{type, id, notificationId}` quand l'utilisateur ouvre une notification.
  Stream<Map<String, String>> get onOpen => _openController.stream;

  /// Émet `{type, id, notificationId}` dès qu'une notification est reçue.
  Stream<Map<String, String>> get onReceived => _receivedController.stream;

  /// Initialisation au démarrage de l'application. Ne lève jamais.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    await _local.init();

    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      // Cas nominal aujourd'hui : le projet Firebase du client n'existe pas encore.
      _available = false;
      _reason = e.toString();
      debugPrint('Firebase non configuré — push désactivé, l\'app continue. ($e)');
    }

    // Le tap sur une bannière affichée par l'application remonte ici.
    _local.onTap.listen(_openController.add);

    // L'autorisation d'affichage (Android 13+) n'a rien à voir avec Firebase :
    // elle est demandée même si le projet FCM n'est pas encore configuré, sinon
    // aucune bannière ne peut être affichée, pas même celles de l'application.
    await _local.requestPermission();

    // Application lancée par un tap alors qu'elle était fermée.
    unawaited(_local.emitLaunchTap());

    if (!_available) return;

    try {
      await FirebaseMessaging.instance.requestPermission();

      // Android affiche lui-même les messages qui portent un bloc `notification`.
      // Le backend n'en envoie pas ; cette ligne empêche en plus tout doublon iOS.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        _token = token;
        unawaited(_api.registerDevice(token: token, plateforme: _platform));
      });
    } catch (e) {
      debugPrint('Initialisation FCM incomplète : $e');
    }
  }

  /// Appelé après une connexion réussie : lie cet appareil au compte.
  Future<void> registerDevice() async {
    if (!_available) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      _token = token;
      await _api.registerDevice(token: token, plateforme: _platform);
    } catch (e) {
      debugPrint('Enregistrement du jeton FCM impossible : $e');
    }
  }

  /// Appelé à la déconnexion : sans cela, l'utilisateur suivant sur le même
  /// téléphone recevrait les notifications du précédent.
  Future<void> unregisterDevice() async {
    final token = _token;
    _token = null;
    if (token == null) return;
    try {
      await _api.unregisterDevice(token);
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Suppression du jeton FCM impossible : $e');
    }
  }

  /// Message reçu application au premier plan : on affiche nous-mêmes.
  Future<void> _handleMessage(RemoteMessage message) async {
    final data = message.data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
    await showLocally(data);
  }

  /// Affiche une notification à partir d'une charge utile FCM `data-only`.
  ///
  /// Exposé (et non privé) parce que c'est exactement ce chemin que le test
  /// d'intégration `notification_banner_test.dart` déclenche pour prouver la
  /// bannière sans dépendre de la livraison FCM réelle.
  Future<void> showLocally(Map<String, String> data) async {
    final type = data['type'] ?? '';
    await _local.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: titleFor(type),
      body: bodyFor(type),
      data: data,
      highPriority: type == 'demande_a_traiter',
    );
    if (!_receivedController.isClosed) _receivedController.add(data);
  }

  static String get _platform {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }

  /// Libellés génériques : la charge utile FCM ne contient volontairement aucun
  /// texte métier (limite de 4 Ko, et tout y transiterait par Google).
  static String titleFor(String type) => switch (type) {
        'demande_a_traiter' => 'Demande à traiter',
        'demande_cloturee' => 'Demande clôturée',
        'tache_creee' => 'Nouvelle tâche',
        'objectif_cree' => 'Nouvel objectif',
        _ => 'OlyHub',
      };

  static String bodyFor(String type) => switch (type) {
        'demande_a_traiter' => 'Une demande attend votre traitement.',
        'demande_cloturee' => 'Une de vos demandes vient d\'être clôturée.',
        'tache_creee' => 'Une tâche vous a été affectée.',
        'objectif_cree' => 'Un nouvel objectif vous a été assigné.',
        _ => 'Vous avez une nouvelle notification.',
      };

  void dispose() {
    _openController.close();
    _receivedController.close();
  }
}

/// Handler d'arrière-plan : **doit** être une fonction de premier niveau annotée
/// `vm:entry-point` — Android la réveille dans un isolate dédié, application fermée.
/// C'est précisément ce que les messages data-only rendent possible.
@pragma('vm:entry-point')
Future<void> olympiaFirebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    return; // Pas de configuration Firebase : rien à faire, surtout pas planter.
  }
  final data = message.data.map((k, v) => MapEntry(k, v?.toString() ?? ''));
  final type = data['type'] ?? '';
  final local = NotificationService();
  await local.init();
  await local.showNotification(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: PushService.titleFor(type),
    body: PushService.bodyFor(type),
    data: data,
    highPriority: type == 'demande_a_traiter',
  );
}
